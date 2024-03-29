dirname = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'active_support/all'

require 'indexes'
require 'properties'
require 'relations'
require 'persistence'
require 'finders'



module Helenus
  def self.included(base)
    base.extend(Helenus::Properties::ClassMethods)
    base.extend(Helenus::Relations::ClassMethods)
    base.extend(Helenus::Persistence::ClassMethods)
    base.extend(Helenus::Finders::ClassMethods)
    base.property :id, String
  end
  
  include Helenus::Properties::InstanceMethods
  include Helenus::Relations::InstanceMethods
  include Helenus::Persistence::InstanceMethods


  def self.setup(hosts, opts={})
    @@client = CassandraCQL::Database.new(hosts, opts)
  end

  def self.client(hosts=nil, opts={})
    @@client ||= CassandraCQL::Database.new(hosts, opts)
  end

end


