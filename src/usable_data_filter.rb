class UsableDataFilter
  def filter data
    data = data.reject {|row| row.empty?}
    data = data.reject {|row| (not row[:submitdate].nil?) and row[:submitdate].empty?}
    data = data.reject {|row| (not row[:interviewtime].nil?) and row[:interviewtime] < min_interview_time}
  end

  private
  def min_interview_time
    60 * 5
  end
end