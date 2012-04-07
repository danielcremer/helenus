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
			Helenus::client.execute("INSERT INTO helenus_indexes (id, ?) VALUES (?, NULL)", column_name(instance), row_name) if indexable?(instance)
		rescue CassandraCQL::Error::InvalidRequestException => e
			if e.message.match("unconfigured columnfamily")
				setup_column_family
				save_index(instance)
			end
		end

		def clear_index(instance)
			# todo
		end

		def indexable?(instance)
			not	@properties.map { |prop| instance.send(prop) }.include?(nil)
		end

		def column_name(instance)
			props = @properties.map { |prop| instance.send(prop).downcase }
			props.join('_') + "." + instance.id
		end

		def row_name
			@model.to_s.downcase + "_" + @property.to_s
		end

		def setup_column_family
			Helenus::client.execute("CREATE COLUMNFAMILY ? (id varchar PRIMARY KEY)", "helenus_indexes")
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

	end

end