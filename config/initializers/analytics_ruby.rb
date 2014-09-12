AnalyticsRuby = Segment::Analytics.new(
  write_key: Rails.application.secrets["SEGMENT_IO_WRITE_KEY"] || "",
  on_error: Proc.new { |status, message| puts message }
)
