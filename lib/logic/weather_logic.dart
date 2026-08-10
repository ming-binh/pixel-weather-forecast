// Shared derived-state helpers, ported from the design's Component methods
// (`effIcon`, `mascotState`, `conv`) so every screen stays consistent.

/// Picks which weather icon sprite to draw for the current condition + time
/// of day.
String effIcon(String cond, String tod) {
  final night = tod == 'night';
  if (cond == 'clear') return night ? 'night' : 'clear';
  if (cond == 'cloudy') return night ? 'cloudy' : 'partly';
  return cond;
}

/// Picks which mascot pose to show for the current condition + time of day.
String mascotStateFor(String cond, String tod) {
  if (tod == 'night') return 'night';
  if (cond == 'rain' || cond == 'fog') return 'rain';
  if (cond == 'snow') return 'snow';
  if (cond == 'storm') return 'storm';
  return 'clear';
}

/// Converts a Celsius value for display, matching the unit toggle.
int convertTemp(int celsius, String unit) {
  return unit == 'F' ? (celsius * 9 / 5 + 32).round() : celsius;
}

/// Short flavor note for the humidity stat tile, tiered by relative humidity %.
String humidityNote(int pct) {
  if (pct >= 80) return 'Rất ẩm, dễ oi bức';
  if (pct >= 60) return 'Hơi ẩm, tóc dễ xù';
  if (pct >= 40) return 'Khá dễ chịu';
  return 'Không khí khô';
}

/// Short flavor note for the UV stat tile, tiered by UV index.
String uvNote(double uv) {
  if (uv >= 8) return 'Rất cao — hạn chế ra nắng';
  if (uv >= 6) return 'Cao — nên che chắn';
  if (uv >= 3) return 'Trung bình';
  return 'Thấp — khá an toàn';
}
