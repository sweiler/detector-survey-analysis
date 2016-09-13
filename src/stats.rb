class Stats

  def initialize(data)
    @data = data
  end

  def avg(column)
    array_avg(values_for_column(column))
  end

  def avg_with_group(column, grouping_column, group_id)
    values = values_per_group(column, grouping_column, group_id)
    array_avg(values)
  end

  def min(column)
    values_for_column(column).min || 0
  end

  def max(column)
    values_for_column(column).max || 0
  end

  def yes_no_ratio(column)
    ones_zeros = convert_yn_to_10(values_for_column(column))
    array_avg(ones_zeros)
  end

  def yes_no_ratio_with_group(column, grouping_column, group_id)
    ones_zeros = convert_yn_to_10(values_per_group(column, grouping_column, group_id))
    array_avg(ones_zeros)
  end

  private
  def values_for_column(column)
    column_values = @data.map { |row| row[column] }
    column_values.reject(&:nil?)
  end

  def array_avg(num_array)
    if num_array.empty?
      0
    else
      num_array.reduce(0, :+) / num_array.length
    end
  end

  def values_per_group(column, grouping_column, group_id)
    @data.select {|row| row[grouping_column] == group_id }.map {|row| row[column]}
  end

  def convert_yn_to_10(values)
    values.map { |v| v == 'Y' || v == true ? 1.0 : 0.0 }
  end
end