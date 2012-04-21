
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
          @properties[name] ||= Property.new(name, type, options)
          @properties[name].get()
        end
        
        define_method( (name.to_s + '=').to_sym ) do |*args|
          @properties ||= {}
          @properties[name] ||= Property.new(name, type, options)
          @properties[name].set(args.first)
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

      # Returns hash of all propery objects
      # TODO: Can this be merged with the properties method?
      def property_objects
        hash = {}
        self.class.properties.each { |prop| hash[prop] = @properties[prop] }
        hash
      end

      def dirty_properties
        props = {}
        @properties.each do |name, property|
          props[name] = property.persisted_value if property.dirty?
        end
        return props
      end
      
      def initialize(props={})
        # hackish way to initialize the properties
        self.class.properties.each { |prop_name| self.send(prop_name) }
        @version = props.delete('version')
        @old_version = @version
        props.each { |name, val| @properties[name.to_sym].load(val) }
      end

      def generate_id
        self.class.generate_id(self)
      end

      def version
        return @version
      end

      def old_version
        return @old_version
      end

      def updated_at
        @version ? SimpleUUID::UUID.new( @version ).to_time : nil
      end
      
    end
    
  end
    
  class Property
    attr_reader :dirty, :persisted_value

    def initialize(name, type, options)
      @name = name
      @type = type
      @options = options
      @dirty = false
      @value = default
      @persisted_value = @value
    end
    
    def default
      @options[:default] || nil
    end
    
    def get
      return @value
    end

    def load(val)
      @persisted_value = val
      @value = val
    end
    
    def set(val)
      @dirty = true
      @value = val
    end

    def dirty?
      dirty
    end
    
  end
    
end