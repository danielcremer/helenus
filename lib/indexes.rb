module Helenus
	module Indexes
	end
	
	class Index
		def initialize(model, name, properties=nil)
			@model = model
			@property = name
			@properties = properties || [name]
		end

		def save_index(instance)
			Helenus::client.execute("INSERT INTO helenus_indexes (id, ?) VALUES (?, NULL)", column_name(instance), row_name)
		rescue CassandraCQL::Error::InvalidRequestException => e
			if e.message.match("unconfigured columnfamily")
				setup_column_family
				save_index(instance)
			end
		end

		def clear_index(instance)
			# todo
		end

		def column_name(instance)
			prop_values = @properties.map { |prop| instance.send(prop).downcase }
			prop_values.join('_') + "." + instance.id
		end

		def row_name
			@model.to_s.downcase + "_" + @property.to_s
		end

		def setup_column_family
			Helenus::client.execute("CREATE COLUMNFAMILY ? (id varchar PRIMARY KEY)", "helenus_indexes")
		end

		def find_ids(term, limit=100)
			cols_start = "#{term.downcase}.0"
			cols_end = "#{term.downcase}.z"
			ids = []
			Helenus::client.execute("SELECT FIRST ? ?..? FROM ? WHERE id=?", 
															limit, cols_start, cols_end, "helenus_indexes", row_name).fetch_hash.each do |key, val|
				ids << key.split('.').last if key.include?('.')
			end
			return ids
		end

	end

end