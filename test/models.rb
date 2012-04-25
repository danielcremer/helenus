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

class Page
  include Helenus
  belongs_to :book
end

class Book
  include Helenus
  has_many :pages
end




def clear_cassandra
  begin
    Helenus::client.execute("DROP COLUMNFAMILY dog")
  rescue CassandraCQL::Error::InvalidRequestException => e
  end
  begin
    Helenus::client.execute("DROP COLUMNFAMILY testgenerator")
  rescue CassandraCQL::Error::InvalidRequestException => e
  end

  begin
    Helenus::client.execute("DROP COLUMNFAMILY helenus_indexes")
  rescue CassandraCQL::Error::InvalidRequestException => e
  end
end