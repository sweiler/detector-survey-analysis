class Boxplot

  def initialize(data, group_key, group_idx, value_key)
    @values = data.reject {|row| row[group_key] != group_idx}.map {|row| row[value_key]}.reject {|v| v.nil?}.sort
  end

  def median
    p_quantile(0.5)
  end

  def p_quantile(p)
    return nil if @values.nil? || @values.empty?

    length = @values.length

    return @values[(length * p).floor] if length.odd?

    upper_val = @values[(length * p).floor]
    lower_val = @values[(length * p).floor - 1]

    (upper_val + lower_val) / 2.0
  end

  def lower_quartile
    p_quantile(0.25)
  end

  def upper_quartile
    p_quantile(0.75)
  end

  def iqr
    upper_quartile - lower_quartile
  end

  def upper_antenna
    antenna(1.5)
  end

  def lower_antenna
    antenna(-1.5)
  end

  def outliers
    @values.reject do |value|
      value >= lower_antenna && value <= upper_antenna
    end
  end

  def min_value
    @values.min
  end

  def max_value
    @values.max
  end

  private
  def antenna(diff)
    threshold = iqr * diff + median
    if diff < 0
      @values.reject {|v| v < threshold}.first
    else
      @values.reject {|v| v > threshold}.last
    end
  end
end