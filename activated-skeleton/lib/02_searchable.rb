require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    search_names = params.map{|attr_name, value| "#{attr_name.to_s} = ?"}.join(" AND ")
    search_vals = params.map{|attr_name, value| value}

    results = DBConnection.execute(<<-SQL,search_vals)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{search_names}
    SQL

    self.parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
