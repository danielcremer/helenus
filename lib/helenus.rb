#require 'active_support/concern'
#require 'active_model'
require 'properties'
require 'persistence'
require 'finders'

module Helenus
  def self.included(base)
    base.extend(Helenus::Properties::ClassMethods)
    base.extend(Helenus::Persistence::ClassMethods)
    base.extend(Helenus::Finders::ClassMethods)
  end
  
  include Helenus::Properties::InstanceMethods
  include Helenus::Persistence::InstanceMethods
    
end


