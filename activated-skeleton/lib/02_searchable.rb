require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_query = params.keys.map {|key| "#{key} = ?"}.join(" AND ")
    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_query}
    SQL

    # create new class object for each search result
    results.map{|result| self.new(result)}
  end
end

# mix in module
class SQLObject
  extend Searchable
end
