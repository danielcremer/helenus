require 'cassandra-cql'
require 'simple_uuid'

module Helenus
  module Persistence
    
    module ClassMethods
      def column_family_name
        self.to_s.downcase
      end
    end
    
    module InstanceMethods
      def save
        self.id = self.generate_id if self.id.nil?
        begin
          Helenus::client.execute("INSERT INTO ? (id, ?) VALUES (?, ?)", column_family_name, properties.keys, self.id, properties.values)
        rescue CassandraCQL::Error::InvalidRequestException => e
          if e.message.match("unconfigured columnfamily")
            self.setup_column_family
            self.save
          end
        end
        self.save_indexes
      end

      def save_indexes
        self.class.indexes.each do |key, index|
          index.save_index(self)
        end
      end
      
      def delete
        Helenus::client.execute("DELETE FROM ? WHERE id=?", column_family_name, self.id)
      end
      
      def column_family_name
        self.class.column_family_name
      end
      
      def setup_column_family
        Helenus::client.execute("CREATE COLUMNFAMILY ? (id varchar PRIMARY KEY)", column_family_name)
      end
      
      def execute(query, *args)
        Helenus::client.execute(query, args)
      end
      
    end
    
  end
  
end