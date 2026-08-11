// Shared derived-state helpers, ported from the design's Component methods
// (`effIcon`, `mascotState`, `conv`) so every screen stays consistent.

/// The default (theme = 'Tự động') time-of-day bucket for a given hour.
String autoTimeOfDay(int hour) {
  if (hour < 5) return 'night';
  if (hour < 7) return 'dawn';
  if (hour < 17) return 'day';
  if (hour < 19) return 'dusk';
  return 'night';
}

/// Resolves the Settings screen's theme label to a time-of-day key. Shared
/// between the running app and the background widget-refresh task so both
/// pick the same sky for a locked (non-'Tự động') theme.
String todForTheme(String theme, int hour) {
  switch (theme) {
    case 'Bình minh':
      return 'dawn';
    case 'Ban ngày':
      return 'day';
    case 'Hoàng hôn':
      return 'dusk';
    case 'Ban đêm':
      return 'night';
    default:
      return autoTimeOfDay(hour);
  }
}

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
