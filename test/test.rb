 $: << '.'
dirname = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.join(dirname, '..', 'lib'))

require 'benchmark'

require 'rubygems'
require 'minitest/autorun'
require 'minitest/pride'
require dirname + '/../lib/helenus'
require dirname + '/models'
require dirname + '/helpers'

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

  it "should have a nil version and updated_at when new" do
    assert_nil @dog.version
    assert_nil @dog.updated_at
  end

  # Updated_at uses the version UUID to calculate the time
  it "should automatically have a version and updated_at when saved" do
    @dog.save
    assert_instance_of String, @dog.version
    assert_instance_of Time, @dog.updated_at
  end


end


describe "A Model with indexes" do
  before do
    clear_cassandra
  end

  it "when created adds 1 index column per indexed property" do
    Dog.create(:id => '12345', :name => 'Fido')
    assert_equal 1, raw_indexes_data('dog_name').size
    Dog.create(:id => '5555', :name => 'Fido')
    assert_equal 2, raw_indexes_data('dog_name').size
  end

  it "can be queried by index" do
    dog = Dog.create(:id => '001', :name => 'Fido')
    dog = Dog.create(:id => '002', :name => 'Fido')
    dog = Dog.create(:id => '003', :name => 'Rex')
    result = Dog.find_all_by_name('Fido')
    assert_equal 2, result.size
    assert_equal '003', Dog.find_by(:name, 'rex').id
  end

  it "deletes it's index when deleted" do
    dog = Dog.create(:id => '001', :name => 'Snoopy')
    assert_equal 1, raw_indexes_data('dog_name').size
    dog.delete
    assert_equal 0, raw_indexes_data('dog_name').size
  end

  it "removes old indexes when saved with new values" do
    dog = Dog.create(:id => '001', :name => 'Snoopy')
    assert_equal 1, raw_indexes_data('dog_name').size
    dog.name = "Rufus"
    dog.save
    assert_equal 1, raw_indexes_data('dog_name').size
  end

end


describe "A Model belonging to another" do
  before do
    @page = Page.new
  end

  it "will have a property for the parent model id" do
    assert_respond_to @page, :book_id
  end

  it "can set a parent object" do
    book = Book.create
    @page.book = book
    @page.save
    assert_equal book.id, Page.find(@page.id).book_id
  end

  it "creates an index for the parent id" do
    book = Book.create
    @page.book = book
    @page.save
    results = Page.find_all_by(:book_id, book.id)
    assert_equal 1, results.size
    assert_equal @page.id, results[0].id
  end

end

describe "A Model that has_many others" do
  before do
    @book = Book.new
  end

  it "will have an empty collection" do
    assert_equal 0, @book.pages.size
  end

  it "can store an object to the collection" do
    page = Page.create
    @book.pages << page
    assert_equal page.id, @book.pages[0].id
  end

  it "can populate the collection" do
    @book.save
    page = Page.create(:book_id => @book.id)
    assert_equal page.id, @book.pages.first.id
  end

  # not working as it's trying to save the associated classes before 
  # the parent is saved
  it "will save associated objects" do
    page = Page.new(:data => "test 1")
    @book.pages << page
    @book.save
    assert_equal 1, Book.find(@book.id).pages.size
  end

end

