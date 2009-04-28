
require "rubygems"
require "active_record"

dir = File.dirname(__FILE__)

require File.dirname(__FILE__) + "/../lib/field_attribute_builder"
require File.dirname(__FILE__) + "/../init"

require 'sqlite3'

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database  => ':memory:'
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
end


