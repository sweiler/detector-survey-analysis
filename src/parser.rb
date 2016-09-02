require 'csv'
class Parser
  def self::parse(input_str)
    res = []
    table = CSV.parse(input_str,
                      :headers => true,
                      :converters => :numeric,
                      :header_converters => [CSV::HeaderConverters[:symbol]])
    table.each do |row|
      row_hash = row.to_hash
      res.push(row_hash)
    end
    return res
  end
end
