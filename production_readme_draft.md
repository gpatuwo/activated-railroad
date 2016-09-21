# Activated Railroad

## Activated

### SQLObject

### Associations
I created BelongsToOptions and HasManyOptions classes to provide default values for the :foreign_key, :class_name, :primary_key association keys and also allows these default to be overridden. Each of these classes extend from the AssocOptions class, which contains #model_class that returns the class of the associated object.

<!-- put code for Associatable#belongs_to -->
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
