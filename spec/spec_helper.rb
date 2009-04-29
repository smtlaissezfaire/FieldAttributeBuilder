
require "rubygems"
require "active_record"

dir = File.dirname(__FILE__)

require File.dirname(__FILE__) + "/../lib/field_attribute_builder"
require File.dirname(__FILE__) + "/../init"

require 'sqlite3'

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database  => ':memory:'
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :posts do |t|
    t.text :body
    t.timestamps
  end

  create_table :comments do |t|
    t.text :body
    t.integer :post_id
    t.timestamps
  end
end

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
end


