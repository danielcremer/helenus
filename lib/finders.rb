
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
    end
    
  end
end