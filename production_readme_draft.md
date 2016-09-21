# Activated Railroad

## Activated

### SQLObject

### Associations
I created BelongsToOptions and HasManyOptions classes to provide default values for the :foreign_key, :class_name, :primary_key association keys and also allows these default to be overridden. Each of these classes extend from the AssocOptions class, which contains `AssocOptions#model_class` that returns the class of the associated object.

``` ruby
def belongs_to(name, options_hash = {})
  options = BelongsToOptions.new(name, options_hash)

  define_method(name) do
    # gets value of foreign key from instance of SQLObject
    key_val = self.send(options.foreign_key)
    options
      .model_class
      .where(options.primary_key => key_val)
      .first
  end
end
```

The `has_one_through` association allows one class to be associated with another class (`source_name`) through a third class's associations (`through_name`). To allow for the `has_one_through` association, I first created an `assoc_options` hash to store the two different associations needed for the join query.

``` ruby
def has_one_through(name, through_name, source_name)
  define_method(name) do
    through_options = self.class.assoc_options[through_name]
    source_options = through_options.model_class.assoc_options[source_name]

    source_table = source_options.table_name
    through_table = through_options.table_name
    through_key_val = self.send(through_options.foreign_key)

    query = DBConnection.execute(<<-SQL, through_key_val)
      SELECT
        #{source_table}.*
      FROM
        #{through_table}
      JOIN
        #{source_table}
      ON
        #{through_table}.#{source_options.foreign_key} = #{source_table}.#{through_options.primary_key}
      WHERE
        #{through_table}.#{through_options.primary_key} = ?
    SQL

    source_options.model_class.new(query[0])
  end
end
```
