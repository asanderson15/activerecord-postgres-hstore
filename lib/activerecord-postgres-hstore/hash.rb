class Hash

  # Generates an hstore string format. This is the format used
  # to insert or update stuff in the database.
  def to_hstore
    if Hash === self
      self.map { |k,v|
        "#{escape_hstore(k)}=>#{escape_hstore(v)}"
      }.join ','
    else
      self
    end
  end

  # If the method from_hstore is called in a Hash, it just returns self.
  def from_hstore
    self
  end

end
