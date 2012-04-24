module Helenus
	module Indexes

		def self.setup_column_family
			Helenus::client.execute("CREATE COLUMNFAMILY ? (id varchar PRIMARY KEY)", "helenus_indexes")
		end
	end
	
	class Index
		def initialize(model, name, properties=nil)
			@model = model
			@property = name
			@properties = properties || [name]
		end


		def save_index(instance)
			cql_run {
				Helenus::client.execute("INSERT INTO helenus_indexes (id, ?) VALUES (?, NULL)", column_name(instance), row_name) if indexable?(instance)
			}
		end

		def clear_index(instance)
			cql_run {
				Helenus::client.execute("DELETE ? FROM ? WHERE id=?", column_name_for_deletion(instance), "helenus_indexes", row_name)
			}
		end

		def indexable?(instance)
			not	@properties.map { |prop| instance.send(prop) }.include?(nil)
		end

		def column_name(instance)
			props = @properties.map { |prop| instance.send(prop).downcase }
			props.join('_') + "." + instance.id
		end

		def column_name_for_deletion(instance)
			props = @properties.map { |prop| (instance.property_objects[prop].persisted_value || 'null').downcase }
			props.join('_') + "." + instance.id
		end

		def row_name
			@model.to_s.downcase + "_" + @property.to_s
		end

		# TODO: Figure out Cassandra truly sorts the columns
		def find_ids(term, limit=100)
			if term.match "\\*$"
				cols_start = "#{term.downcase}0"
				cols_start = "#{term.downcase}z"
			else
				cols_start = "#{term.downcase}.0"
				cols_end = "#{term.downcase}.z"
			end
			ids = []
			Helenus::client.execute("SELECT FIRST ? ?..? FROM ? WHERE id=?", 
															limit, cols_start, cols_end, "helenus_indexes", row_name).fetch_hash.each do |key, val|
				ids << key.split('.').last if key.include?('.')
			end
			return ids
		end

		# Execute the CQL calls in the block creating the columnfamily if it doesn't exist
		def cql_run(&block)
				block.call
			rescue CassandraCQL::Error::InvalidRequestException => e
				if e.message.match("unconfigured columnfamily")
					Helenus::Indexes::setup_column_family
					block.call
				end
		end

	end

end