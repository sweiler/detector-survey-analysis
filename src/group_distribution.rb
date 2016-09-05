require_relative 'survey_structure'
class GroupDistribution

  def initialize(data)
    @data = data
  end

  def counts
    array_of_hashes = SurveyStructure.random_groups_max_value.keys.map do |field|
      max_value_for_field = SurveyStructure.random_groups_max_value[field]

      values_for_field = @data.map {|row| row[field]}

      counts_for_each_possible_value = (0..max_value_for_field).map do |value|
        values_for_field.count(value)
      end

      {field => counts_for_each_possible_value}
    end
    array_of_hashes.reduce({}, :merge)
  end
end