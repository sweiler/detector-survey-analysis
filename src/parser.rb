require 'csv'

class Parser
  def self.parse(input_str)
    table = CSV.parse(input_str, csv_options)
    return table_to_array(table)
  end

  def self.parse_file(filename)
    table = CSV.read(filename, csv_options)
    return table_to_array(table)
  end

  private
  def self.table_to_array(table)
    res = []

    table.each do |row|
      row_hash = row.to_hash
      res.push(row_hash)
    end
    return res
  end

  def self.csv_options
    {
      :headers => true,
      :converters => :numeric,
      :header_converters => lambda {|s| s.to_sym}
    }
  end

end
