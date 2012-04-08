# Helenus

Helenus is a Ruby to Cassandra persistence library

## Usage

First setup the client:

    Helenus::setup('127.0.0.1:9160', {:keyspace => 'keyspaceName'})

Setup and use a model:

    class Person
      include Helenus

      property :name, String
      property :email, String, :index => true
    end

    john = Peron.create(:name => "John", :email => "john@hotmail.com")
    john.email = "john@gmail.com"
    john.save

    # Query the 2i
    Person.find_by(:email, "john@gmail.com") # => returns john


This object will manage it's own secondary index for any properties with the index property set to true.

## Pluggable id generation

By default Helenus uses the simple_uuid gem to generate ids automatically. You can plug in your own id generation logic:

    class Person
      include Helenus
      id_generator Proc.new { Time.now.to_f }
    end