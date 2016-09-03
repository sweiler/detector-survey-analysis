module Helper
  def format_duration(duration_secs)
    mins = (duration_secs / 60).floor
    secs = (duration_secs - (60 * mins)).round
    "#{mins}:#{secs} min"
  end
end