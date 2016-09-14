class Statsig

  def initialize(data)
    @data = data
  end

  def self.significance_a_greater_b(data, grouping_key, group_a, group_b, value_key)
    Statsig.new(data).run_a_greater_b(grouping_key, group_a, group_b, value_key)


  end

  def run_a_greater_b(grouping_key, group_a, group_b, value_key)
    count_a = count_for(grouping_key, group_a, value_key)
    count_b = count_for(grouping_key, group_b, value_key)
    total_a = count_total(grouping_key, group_a)
    total_b = count_total(grouping_key, group_b)

    total_ratio = (count_a + count_b).to_f / (total_a + total_b).to_f

    p_a_geq_than_observed = (count_a..total_a).map {|k| binomial(total_a, total_ratio, k)}.reduce(0.0, :+)
    p_b_leq_than_observed = (0..count_b).map {|k| binomial(total_b, total_ratio, k)}.reduce(0.0, :+)

    p_a_geq_than_observed * p_b_leq_than_observed
  end

  private
  def count_total(grouping_key, group_value)
    @data.reject {|row| row[grouping_key] != group_value}.length
  end

  def count_for(grouping_key, group_value, value_key)
    @data.reject { |row| row[grouping_key] != group_value }.map { |row| row[value_key] === 'Y' || row[value_key] === true ? 1 : 0 }.reduce(0, :+)
  end

  def binomial_coefficient(n, k)
    return 1 if k == 0
    return binomial_coefficient(n, n-k) if 2 * k > n

    result = n - k + 1
    (2..k).each do |i|
      result = result * (n - k + i)
      result = result / i
    end
    result
  end

  def binomial(n, p, k)
    binomial_coefficient(n, k) * (p ** k) * ((1-p) ** (n-k))
  end

end