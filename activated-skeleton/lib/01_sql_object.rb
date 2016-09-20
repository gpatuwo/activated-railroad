require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    return @columns if @columns
    col_names = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    col_names[0].map!(&:to_sym)
    @columns = col_names.first
  end

  def self.finalize!
    # self = class
    self.columns.each do |column|
      define_method(column) do
        self.attributes[column]
      end

      define_method("#{column}=") do |value|
        # self here is instance. need to call self.attributes bc @attributes may or maybe not be empty right now
        self.attributes[column] = value
      end
    end
  end

  # allows you to override default inferred table name
  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.tableize
  end

  def self.all
    everything = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    parse_all(everything)
  end

  def self.parse_all(results)
    results.map {|result| self.new(result) }
  end

  def self.find(id)
    result_arr = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = ?
      LIMIT
        1
    SQL

    result_arr.empty? ? nil : self.new(result_arr[0])
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      # self now refers to the instance
      unless self.class.columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      end

      self.send("#{attr_name}=", value) # sent to setter method
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map {|column| self.send(column)}
  end

# TODO make private
  def insert
    # drop id column for now
    columns = self.class.columns.drop(1)
    col_names = columns.join(", ")
    q_marks = (["?"] * columns.length).join(", ")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{q_marks})
    SQL

    # assign id to object instance after finalize
    self.id = DBConnection.last_insert_row_id
  end

# TODO make private
  def update
    col_new_vals = self.class.columns
      .map {|col| "#{col} = ?"}.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{col_new_vals}
      WHERE
        id = ?
    SQL
  end

  def save
    id.nil? ? insert : update
  end
end
