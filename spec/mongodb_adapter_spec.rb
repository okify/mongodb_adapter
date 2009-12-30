# require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.dirname(__FILE__) + '/spec_helper'
require 'mongo'

require 'dm-core/spec/adapter_shared_spec'
 
describe DataMapper::Adapters::MongoDBAdapter do
  before :all do
    @adapter = DataMapper.setup(:default,
      :adapter => 'mongodb',
      :hostname => 'localhost',
      :port => 27017,
      :database => 'dm-mongodb-test'
    )
    
    Mongo::Connection.new.db('dm-mongodb-test')['heffalumps'].remove
    
  end
 
  it_should_behave_like 'An Adapter'
  
end
