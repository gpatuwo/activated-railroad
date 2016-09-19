require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    return @columns if @columns
    col_names = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        "#{self.table_name}"
    SQL

    col_names[0].map!(&:to_sym)
    @columns = col_names.first
  end

  def self.finalize!
    self.columns.each do |column| #self = class
      define_method("#{column}") do
        self.attributes[column]
      end

      define_method("#{column}=") do |value|
        self.attributes[column] = value
         #self here is instance. need to call self.attributes bc @attributes may or maybe not be empty right now
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.name.tableize
  end

  def self.all
    everything = DBConnection.execute2(<<-SQL)
      SELECT
        "#{self.table_name}".*
      FROM
        "#{self.table_name}"
    SQL
    self.parse_all(everything.drop(1))
  end

  def self.parse_all(results)
    parsed = []
    results.each {|result| parsed << self.new(result)}
    parsed
  end

  def self.find(id)
     result = DBConnection.execute2(<<-SQL, id)
      SELECT
        *
      FROM
        "#{self.table_name}"
      WHERE
        id = ?
      LIMIT
        1
    SQL

    result[1].is_a?(Hash) ? self.new(result.drop(1).first) : nil

  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      if self.class.columns.include?(attr_name)
        self.send("#{attr_name}=", value)
      else
        raise "unknown attribute '#{attr_name}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values #returns arr of values each attribute
    self.class.columns.map do |column|
      send("#{column}")
    end
  end

  def insert #**
    columns = self.class.columns.drop(1)
    col_names = columns.map(&:to_s).join(", ")
    question_marks = (["?"] * columns.count).join(", ")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update #**
    columns = self.class.columns.map{|attr| "#{attr} = ?"}.join(", ")

    DBConnection.execute(<<-SQL,*attribute_values, id)
      UPDATE
      #{self.class.table_name}
      SET
        #{columns}
      WHERE
        #{self.class.table_name}.id = ?
    SQL
  end

  def save
    id.nil? ? insert : update
  end
end
