 $: << '.'
dirname = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.join(dirname, '..', 'lib'))

require 'rubygems'
require 'minitest/autorun'
require 'minitest/pride'
require dirname + '/../lib/helenus'
require dirname + '/models'

describe "A Model" do
  before do
    clear_cassandra
    @dog = Dog.new(:id => '12345')
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

  it "tracks updated properties" do
    assert_equal 0, @dog.dirty_properties.size
    @dog.size = 'small'
    assert_equal 1, @dog.dirty_properties.size
    @dog.name = 'Hound'
    assert_equal 2, @dog.dirty_properties.size
    assert @dog.dirty_properties.include?(:size)
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