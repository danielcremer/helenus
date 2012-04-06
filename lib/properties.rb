#require 'active_support/concern'
#require 'active_support/core_ext/hash/indifferent_access'

module Helenus
  module Properties
    
    module ClassMethods
      # returns list of all property names
      def properties
        @properties ||= []
        @properties
      end
    
      def property(name, type, options={})
        @properties ||= []
        @properties << name
        
        define_method name.to_sym do
          @properties ||= {}
          @properties[name] ||= Property.new(name, type, options).get()
        end
        
        define_method (name.to_s + '=').to_sym do |*args|
          @properties ||= {}
          @properties[name] ||= Property.new(name, type, options).get()
          @properties[name] = args.first
        end  
      end
      
      def key(name, type, options={})
        @key = name
        property(name, type, options)
      end
      
      def key_name
        @key
      end
      
      def create(properties)
        instance = self.new(properties)
        instance.save
        return instance
      end
      
    end
    
    module InstanceMethods
      # Returns hash of all properties and their values
      def properties
        hash = {}
        self.class.properties.each { |prop| hash[prop] = self.send(prop) }
        hash
      end
      
      def initialize(props={})
        props.each { |key,val| self.send((key.to_s + '=').to_sym, val)}
      end
      
    end
    
  end
    
  class Property
    
    def initialize(name, type, options)
      @name = name
      @type = type
      @options = options
      @value = default
    end
    
    def default
      @options[:default] || nil
    end
    
    def get
      return @value
    end
    
    def set(val)
      @value = val
    end
    
  end
    
end