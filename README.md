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

---
#### Bonus: 3. Demo app

#### Bonus: 4. Gem

## Implementation Timeline
#### Monday - Day 1
  - review ActiveRecord/Ruby
- [ORM reading][orm]
  - redo [ActiveRecordLite Part I][ar1]
  - review RailsLite

#### Tuesday - Day 2
- finish [ActiveRecordLite Part II][ar2]
- remove all traces of a/a

#### Wednesday - Day 3
- finish [RailsLite Part I][rl1]

#### Thursday - Day 4
- finish [RailsLite Part II][rl2]
- combining Activated + Railroad

#### Friday - Day 5
- make simple app that's a simple walkthrough of the functionality of the framework with interactive examples.

#### Saturday/Sunday - Day 6
- continue app
- production README
- (release framework as a gem)

---

## Extra bonus functionality
- "PATCH" or "DELETE" requests
- Implement link_to and button_to
- Strong params (e.g require, permit)
- URL route helpers (e.g. users_url instead of "/users')

[orm]: https://github.com/appacademy/curriculum/blob/master/sql/readings/orm.md
[ar1]:https://github.com/appacademy/curriculum/blob/master/sql/projects/active_record_lite/instructions/active-record-lite-i.md
[ar2]: https://github.com/appacademy/curriculum/blob/master/sql/projects/active_record_lite/instructions/active-record-lite-ii.md
[rl1]: https://github.com/appacademy/curriculum/blob/master/rails/projects/rails_lite/rails-lite-i.md
[rl2]:https://github.com/appacademy/curriculum/blob/master/rails/projects/rails_lite/rails-lite-ii.md
