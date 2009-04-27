require 'rubygems'
require 'active_support'
require 'active_record'
require 'spec'

TEST_DATABASE_FILE = File.join(File.dirname(__FILE__), '..', 'test.sqlite3')

File.unlink(TEST_DATABASE_FILE) if File.exist?(TEST_DATABASE_FILE)
ActiveRecord::Base.establish_connection(
  "adapter" => "sqlite3", "database" => TEST_DATABASE_FILE
)

RAILS_DEFAULT_LOGGER = Logger.new(File.join(File.dirname(__FILE__), "debug.log"))

load(File.dirname(__FILE__) + '/schema.rb')

$: << File.join(File.dirname(__FILE__), '..', 'lib')
require File.join(File.dirname(__FILE__), '..', 'init')

class Foo < ActiveRecord::Base
end

class Bar < ActiveRecord::Base
end

class User < ActiveRecord::Base
  acts_as_visitor :of => [:foos, :bars, :users]
  acts_as_visitable :by => :users
end

class Foo < ActiveRecord::Base
  acts_as_visitable :by => :users
end

class Bar < ActiveRecord::Base
  acts_as_visitable :by => :users
end

class Visit < ActiveRecord::Base
  belongs_to :visitable, :polymorphic => true
  belongs_to :visitor, :class_name => "User", :foreign_key => "visitor_id"
  
  include ActsAsVisitable::VisitMethods
end

class SomethingElse < ActiveRecord::Base
end

def valid_user_attributes
  {:login => 'Mario'}
end

def valid_foo_attributes
  {:message => 'entertaining message !'}
end

def valid_bar_attributes
  {:size => 4}
end