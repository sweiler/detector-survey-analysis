class GroupDistribution

  def initialize(data)
    @data = data
  end

  def counts
    array_of_hashes = GroupDistribution.fields_with_max_value.keys.map do |field|
      max_value_for_field = GroupDistribution.fields_with_max_value[field]

      values_for_field = @data.map {|row| row[field]}

      counts_for_each_possible_value = (0..max_value_for_field).map do |value|
        values_for_field.count(value)
      end

      {field => counts_for_each_possible_value}
    end
    array_of_hashes.reduce({}, :merge)
  end

  private
  def self.fields_with_max_value
    {
        :randMultiple => 2,
        :randGraphJava => 2,
        :randConf => 2
    }
  end
end