# CREATE keyspace test with strategy_class = 'NetworkTopologyStrategy';
 $: << '.'

dirname = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.join(dirname, '..', 'lib'))

require 'rubygems'
require 'minitest/autorun'
require 'minitest/pride'
require dirname + '/../lib/helenus'

# Helenus::client("CREATE KEYSPACE test WITH strategy_class='org.apache.cassandra.locator.SimpleStrategy' AND strategy_options:replication_factor=1")
Helenus::setup('127.0.0.1:9160', {:keyspace => 'test'})

class Dog
  include Helenus
  property :size, String, :default => 'large'
  property :name, String, :index => true
end

class TestGenerator
  include Helenus
  id_generator Proc.new { '123456' }
end

describe "A Model" do
  before do
    @dog = Dog.new
    @dog.id = "12345"
  end

  after do
    Helenus::client("DROP KEYSPACE test")
  end
  
  it "creates an accessor on the property" do
    @dog.size = "small"
    assert_equal 'small', @dog.size
  end
  
  it "returns default property if none is set" do
    assert_equal 'large', @dog.size
  end
  
  it "returns a hash of all properties" do
    assert_equal 3, @dog.properties.size
    assert_equal 'large', @dog.properties[:size]
  end
  
  it "should set an id automatically" do
    dog = Dog.create
    assert(dog.id.size == 36)
  end

  it "can have a custom id generator" do
    test_gen = TestGenerator.create
    assert(test_gen, '123456')
  end

end


describe "A Model with indexes" do
=begin
class Person
  include Helenus
  property :name, String, :index => true
  property :age, String
  index :name_and_age, [:name, :age]
end

Person.find_by_name('john', :page => 2, :page_size => 10)
Perons.find_by_name_and_age('test')
=end

end