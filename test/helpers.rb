def raw_indexes_data(index_name)
  indexes = Helenus::client.execute('SELECT * FROM ? where id=?', 'helenus_indexes', index_name).fetch_hash
  indexes.delete('id')
  return indexes
end