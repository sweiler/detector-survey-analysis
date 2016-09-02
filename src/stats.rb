class Stats

  def initialize(data)
    @data = data
  end

  def avg(column)
    values_for_column(column).reduce(0, :+) / @data.length
  end

  def min(column)
    values_for_column(column).min
  end

  def max(column)
    values_for_column(column).max
  end

  private
  def values_for_column(column)
    column_values = @data.map { |row| row[column] }
    column_values.reject(&:nil?)
  end
end