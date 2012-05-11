dirname = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'active_support/all'
require 'active_model'

#require 'validations'
require 'indexes'
require 'properties'
require 'relations'
require 'persistence'
require 'finders'



module Helenus
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Validations
    extend Helenus::Properties::ClassMethods
    extend Helenus::Relations::ClassMethods
    extend Helenus::Persistence::ClassMethods
    extend Helenus::Finders::ClassMethods
    property :id, String
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


