require_relative 'survey_structure'
class GroupDivider
  def divide(data)
    @data = data
    run
  end

  def initialize(survey_structure)
    @survey_structure = survey_structure
  end

  def run
    @data.map do |row|

     fields_per_group = group_field_associations.map do |rand_field, grouped_fields|
        rand_group = row[rand_field]
        if rand_group.nil?
          {}
        else
          group_zero_fields = grouped_fields[0]

          real_group_fields = grouped_fields[rand_group]
          new_field_assocs = real_group_fields.each_with_index.map do |field_id, idx|
            field_name_in_group_zero = group_zero_fields[idx]
            field_value_in_row = row[field_id]

            if field_value_in_row.nil?
              {}
            else
              {field_name_in_group_zero => field_value_in_row}
            end
          end

          fields_for_this_group = new_field_assocs.reduce({}, :merge)
          fields_for_this_group[rand_field] = rand_group

          fields_for_this_group
        end
      end

      new_row = remove_additional_fields(row)
      new_fields = fields_per_group.reduce({}, :merge)
      new_row.merge(new_fields)
    end
  end

  def remove_additional_fields(row)
    keys_to_remove = group_field_associations.keys
    keys_to_remove += group_field_associations.values.map {|ary| ary[1] + ary[2]}.flatten
    Hash[row.reject { |key| keys_to_remove.include? key }]
  end

  def group_field_associations
    @survey_structure.random_groups_questions
  end

end