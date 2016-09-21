require_relative '02_searchable'
require 'active_support/inflector'

# class to store info needed to define associations
class AssocOptions
  attr_accessor :foreign_key, :class_name, :primary_key

  # converts name to class object
  def model_class
    class_name.singularize.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      :foreign_key => "#{name}_id".to_sym,
      :class_name => name.to_s.camelcase,
      :primary_key => :id
    }

    # allows override of defaults
    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end

  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      :foreign_key => "#{self_class_name.downcase}_id".to_sym,
      :class_name => name.to_s.singularize.camelcase,
      :primary_key => :id
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

module Associatable
  def belongs_to(name, options_hash = {})
    assoc_options[name] = BelongsToOptions.new(name, options_hash)

    define_method(name) do
      options = self.class.assoc_options[name]
      # gets value of foreign key from instance of SQLObject
      key_val = self.send(options.foreign_key)
      options
        .model_class
        .where(options.primary_key => key_val)
        .first
    end
  end

  def has_many(name, options_hash = {})
    options = HasManyOptions.new(name, self.name, options_hash)

    define_method(name) do
      key_val = self.send(options.primary_key)
      options
        .model_class
        .where(options.foreign_key => key_val)
    end
  end

  # has_one_through needs to know the options for two associations. this hash allows you to store the belongs_to association so it can reference it later for the join query
  def assoc_options
    @assoc_options ||= {}
  end

  def has_one_through(name, through_name, source_name)
    through_options = assoc_options[through_name]
    define_method(name) do

    end
  end
end


class SQLObject
  extend Associatable
end
