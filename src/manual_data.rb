require 'json'

class ManualData
  def initialize(json_string = '[]')
    @manual_data = JSON.parse(json_string, symbolize_names: true)
    @manual_data = @manual_data.reduce({}) do |hsh, row|
      hsh.merge({row[:id] => row})
    end
  end

  def augment(rows)
    rows.map do |row|
      new_row = row.clone
      augment_row = @manual_data[row[:id]] || {}
      new_row.merge(augment_row)
    end
  end

  def add_data(id, data)
    unless @manual_data.key? id
      @manual_data[id] = {:id => id}
    end

    @manual_data[id].merge!(data)
  end

  def to_json
    JSON.generate(@manual_data.values)
  end
end