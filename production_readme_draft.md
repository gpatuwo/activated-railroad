# Activated Railroad
## Background

Activated Railroad is an ORM and web server MVC inspired by ActiveRecord and Rails respectively.

## Functionality
This project is divided into two parts:
#### 1. Activated
Activated is the ORM inspired by ActiveRecord. It will be able to
- translate rows from a SQL query into Ruby objects on fetch
- translate Ruby objects into rows in the db on save

via Activated::Base (that all model classes extend from)

Activated will allow Ruby classes methods to perform SQL operations without writing out SQL code directly through Activated methods.

#### 2. Railroad
Railroad is a MVC framework inspired by the basic functionalities of Rails.
- Rack
- ControllerBase
- Template rendering (ERB)
- Session
- Routing
- Flash
- Rack Exceptions
- Rack Static Assets
- CSRF Protection

** FIY: I was very liberal with comments in this repo in order to better illustrate the purpose/reasoning behind the code.
## Activated
Activated is the ORM inspired by ActiveRecord. It will be able to
- translate rows from a SQL query into Ruby objects on fetch
- translate Ruby objects into rows in the db on save

via Activated::Base (that all model classes extend from)

Activated will allow Ruby classes methods to perform SQL operations without writing out SQL code directly through Activated methods.
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
---
## Railroad
Railroad is a MVC framework inspired by the basic functionalities of Rails.

### Rack Middleware
The Rack middleware sits between a web server and the web app framework to make it easier to write frameworks and servers that work with existing software (how does it make it easier??? read [this][rack]).
#### Rack Exceptions
#### Rack Static Assets
### ControllerBase
Each controller class in Railroad inherits from `ControllerBase` (which is akin to ActionController::Base in Rails). ControllerBase's job basically is to take in HTTP Request and Response objects as inputs and create methods that figure out what to do with them. These methods include:
- creating the response render (`ControllerBase#render_content`)
- handling redirects (`ControllerBase#redirect_to`)
- and handle template rendering

### Template Rendering
The `ControllerBase#render` method is able to
- create the path to a template file by using the template name and the controller
- read the template file from `File.read`
- create a new ERB template from the contents of the file
- use Kernel's `binding` to capture the controller's ivars to evaluate the ERB template
- pass result to `#render_content`

### Session
Servers uses cookies to store information that persist on the client side. The server will only have access to a cookie that matches the current request path. For determining session, the cookie needs to be available to any path, so I set the session cookie path to `/`.

To dry up the code, I created a `Session` helper class to deal with session/cookie interaction.
### Routing
### Flash
### CSRF Protection

[rack]:https://github.com/appacademy/curriculum/blob/master/rails/readings/rack.md
