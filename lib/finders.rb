
module Helenus
  module Finders
    
    module ClassMethods
      def find(id)
        hash = Helenus::client.execute("SELECT * FROM ? where id = ?", column_family_name, id).fetch_hash
        raise "ModelNotFound" if hash.size == 1
        instance = self.new()
        hash.each { |key, val| instance.send((key + '=').to_sym, val)}
        instance
      end

      def find_by(index_name, val)
        self.find_all_by(index_name, val, 1).first
      end

      def find_all_by(index_name, val, limit=100)
        instances = []
        ids = self.indexes[index_name].find_ids(val, limit) #.map { |id| self.find(id) }
        Helenus::client.execute("SELECT * FROM ? where id in (?)", column_family_name, ids).fetch do |row| 
          instances << self.new(row.to_hash)
        end
        return instances
      end

    end
    
  end
end