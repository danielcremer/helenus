
module Helenus
  module Properties
    
    module ClassMethods
      # returns list of all property names
      def properties
        @properties ||= []
      end

      def indexes
        @indexes ||= {}
      end

      def generate_id(instance)
        (@id_generator || Proc.new { SimpleUUID::UUID.new.to_guid }).call(instance)
      end
    
      def property(name, type, options={})
        @properties ||= []
        @properties << name

        if options[:index]
          indexes[name] = Helenus::Index.new(self, name)
        end
        
        define_method name.to_sym do
          @properties ||= {}
          @properties[name] ||= Property.new(name, type, options).get()
        end
        
        define_method( (name.to_s + '=').to_sym ) do |*args|
          @properties ||= {}
          @properties[name] ||= Property.new(name, type, options).get()
          @properties[name] = args.first
        end  
      end

      def id_generator(proc)
        @id_generator = proc
      end
      
      def create(properties={})
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

      def generate_id
        self.class.generate_id(self)
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