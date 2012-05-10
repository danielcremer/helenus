
module Helenus
  module Finders
    
    module ClassMethods
      def find(id)
        hash = Helenus::client.execute("SELECT * FROM ? where id = ?", column_family_name, id).fetch_hash
        raise "ModelNotFound" if hash.size == 1
        instance = self.new(hash)
        instance
      end

      def find_by(index_name, val)
        self.find_all_by(index_name, val, 1).first
      end

      def find_all_by(index_name, val, limit=1000)
        instances = []
        if (ids = self.indexes[index_name].find_ids(val, limit)).size > 0
          Helenus::client.execute("SELECT * FROM ? where id in (?)", column_family_name, ids).fetch do |row| 
            instances << self.new(row.to_hash)
          end
        end
        return instances
      end

      def method_missing(method_id, *args)
        if match = /find_(all_by|by)_([_a-zA-Z]\w*)/.match(method_id.to_s)
          index_name = match[2].to_sym
          val = args.first
          if match[1] == 'by'
            self.find_by(index_name, val)
          elsif match[1] == 'all_by'
            self.find_all_by(index_name, val)
          end
        else
          raise NoMethodError.new("undefined method '#{method_id}' for #{self}")
        end
      end

    end
    
  end
end