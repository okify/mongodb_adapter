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

    ::Mongo::Connection.new.db('dm-mongodb-test')['heffalumps'].drop
    
    class ::Foo
      include DataMapper::Resource
      property :_id, Serial, :key => false
      property :id, String, :key => true
      property :text, String
      property :things, Array, :default => []
    end
    
  end

  before :each do
    ::Mongo::Connection.new.db('dm-mongodb-test')['foos'].drop
  end
 
  it_should_behave_like 'An Adapter'

  it "should insert Arrays on create" do
    Foo.create(:id => "foo", :text => "Foo", :things => ["Zero", "One"])
    things = Foo.get("foo").things
    things[0].should == "Zero"
    things[1].should == "One"
  end

  it "should insert Arrays on new and save" do
    @foo = Foo.new(:id => "foo", :text => "Foo", :things => ["Zero", "One"])
    @foo.save
    things = Foo.get("foo").things
    things[0].should == "Zero"
    things[1].should == "One"
  end

  it "should update things using the foo.update(hash) method" do
    Foo.create(:id => "foo", :text => "Foo")
    @foo = Foo.get("foo")
    hash = { :text => "Bar" }
    @foo.update(hash)
    Foo.get("foo").text.should == "Bar"
  end

  it "should update Arrays" do
    @foo = Foo.create(:id => "foo", :text => "Foo", :things => ["Zero", "One"])
    things = Array.new(@foo.things)
    things << "Two"
    hash = {:things => things}
    @foo.update(hash)
    things = Foo.get("foo").things
    things[2].should == "Two"
  end
  
end
