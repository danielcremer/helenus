require 'cassandra-cql'

$db = CassandraCQL::Database.new('127.0.0.1:9160', {:keyspace => 'Keyspace1'})

module Helenus
  module Persistence
    
    module ClassMethods
      def column_family_name
        self.to_s.downcase
      end
    end
    
    module InstanceMethods
      def save
        begin
          $db.execute("INSERT INTO ? (id, ?) VALUES (?, ?)", column_family_name, properties.keys, self.id, properties.values)
        rescue CassandraCQL::Error::InvalidRequestException => e
          if e.message.match("unconfigured columnfamily")
            self.setup_column_family
            self.save
          end
        end
      end
      
      def delete
        $db.execute("DELETE FROM ? WHERE id=?", column_family_name, self.id)
      end
      
      def column_family_name
        self.class.column_family_name
      end
      
      def setup_column_family
        $db.execute("CREATE COLUMNFAMILY ? (id varchar PRIMARY KEY)", column_family_name)
      end
      
      def execute(query, *args)
        $db.execute(query, args)
      end
      
    end
    
  end
  
end