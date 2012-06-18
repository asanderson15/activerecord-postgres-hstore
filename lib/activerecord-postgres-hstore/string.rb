class String

  # If the value os a column is already a String and it calls to_hstore, it
  # just returns self. Validation occurs afterwards.
  def to_hstore
    self
  end

  # Validates the hstore format. Valid formats are:
  # * An empty string
  # * A string like %("foo"=>"bar"). I'll call it a "double quoted hstore format".
  # * A string like %(foo=>bar). Postgres doesn't emit this but it does accept it as input, we should accept any input Postgres does

  def valid_hstore?
    pair = hstore_pair
    !!match(/^\s*(#{pair}\s*(,\s*#{pair})*)?\s*$/)
  end

  # Creates a hash from a valid double quoted hstore format, 'cause this is the format
  # that postgresql spits out.
  def from_hstore
    if string.nil?
      nil
    elsif String === string
      Hash[string.scan(HstorePair).map { |k,v|
        v = v.upcase == 'NULL' ? nil : v.gsub(/^"(.*)"$/,'\1').gsub(/\\(.)/, '\1')
        k = k.gsub(/^"(.*)"$/,'\1').gsub(/\\(.)/, '\1')
        [k,v]
      }]
    else
      string
    end
  end

  private

  HstorePair = begin
    quoted_string = /"[^"\\]*(?:\\.[^"\\]*)*"/
    unquoted_string = /(?:\\.|[^\s,])[^\s=,\\]*(?:\\.[^\s=,\\]*|=[^,>])*/
    /(#{quoted_string}|#{unquoted_string})\s*=>\s*(#{quoted_string}|#{unquoted_string})/
  end

  def escape_hstore(value)
      value.nil?         ? 'NULL'
    : value == ""        ? '""'
    :                      '"%s"' % value.to_s.gsub(/(["\\])/, '\\\\\1')
  end
end
