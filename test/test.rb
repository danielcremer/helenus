# CREATE keyspace test with strategy_class = 'NetworkTopologyStrategy';
 $: << '.'

dirname = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.join(dirname, '..', 'lib'))

require 'rubygems'
require 'minitest/autorun'
require 'minitest/pride'
require dirname + '/../lib/helenus'

Helenus::setup('127.0.0.1:9160', {:keyspace => 'test2'})

class Dog
  include Helenus
  property :size, String, :default => 'large'
  property :name, String
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