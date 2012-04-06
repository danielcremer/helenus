dirname = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'minitest/autorun'
require 'minitest/pride'
require dirname + '/../lib/helenus'


class Dog
  include Helenus
  key :id, String
  property :size, String, :default => 'large'
  property :name, String
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
  
  it "should set a key property" do
    assert_equal '12345', @dog.id
    assert_equal :id, Dog.key_name
  end
  
end