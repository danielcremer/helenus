module Helenus
  module Relations

    module ClassMethods
      def belongs_to(name)
        name = name.to_sym
        relation = Helenus::Relations::BelongsTo.new(name)
        self.property(relation.property_name, String, :index => true)

        define_method(name) do
          helenus_relations[name] # || find the object from the property id
        end

        define_method( (name.to_s + "=").to_sym ) do |*args|
          object = args.first
          helenus_relations[name] = object
          # TODO: Handle new records without an id 
          self.send(relation.property_name.to_s + '=', object.id)
        end
      end

      def has_many(name)
        name = name.to_sym
        
        define_method(name) do
          helenus_relations[name] ||= Helenus::Relations::HasManyProxy.new(self, name) 
        end
      end

    end

    module InstanceMethods

      private 
      def helenus_relations
        @helenus_relations ||= {}
      end

      def helenus_set_relations
        # ... Go through relations and set properties (i.e. page.book_id)
        # This should be invoked before saving
        helenus_relations.each do |name, object|
          if object.is_a?(Helenus::Relations::HasManyProxy)
            object.save
          elsif object.id.nil?
            # save relation if new_record
            object.save
            self.send((name.to_s + '_id=').to_sym, object.id)
          end
        end
      end

    end


    class BelongsTo
      def initialize(name, opts={})
        @name = name.to_s
      end

      def property_name
        (@name + '_id').to_sym
      end

      def class
        @class = opts[:class] || Kernel.const_get("::" + @name.capitalize)
      end
    end

    class HasMany
      def initialize(parent, name, opts={})
        @name = name.to_s
      end
    end

    class HasManyProxy

      def initialize(parent, name)
        @parent = parent
        @name = name.to_s
      end

      def size
        collection.size
      end

      def <<(value)
        value.send( (foreign_key.to_s + '=').to_sym, @parent.id)
        collection << value
      end

      def [](index)
        collection[index]
      end

      def first
        collection.first
      end

      def save
        @collection.each do |obj|
          obj.send( (foreign_key.to_s + '=').to_sym, @parent.id)
          obj.save
        end
      end

      private #--------- Private

      def foreign_key
        @parent.class.to_s.foreign_key.to_sym
      end

      def find_associated
        if @parent.id
          associatedClass = @name.classify.constantize
          associatedClass.find_all_by(foreign_key, @parent.id)
        else
          []
        end
      end

      def collection
        @collection ||= find_associated
      end

    end

  end

end