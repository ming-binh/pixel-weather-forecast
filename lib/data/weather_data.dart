import '../pixel/pixel_grid.dart';

/// Time-of-day sky palette: 4 gradient stops (top to horizon), sun color and
/// hill tint. Ported from the design's `PAL` table.
class TimePalette {
  final String key;
  final String label;
  final List<String> stops;
  final String hill;

  const TimePalette({
    required this.key,
    required this.label,
    required this.stops,
    required this.hill,
  });
}

const timePalettes = <String, TimePalette>{
  'dawn': TimePalette(
    key: 'dawn',
    label: 'BINH MINH 5-7H',
    stops: ['#8E7AB5', '#C98BB0', '#F3A38C', '#F9C7A8'],
    hill: '#6E5A86',
  ),
  'day': TimePalette(
    key: 'day',
    label: 'BAN NGAY 7-17H',
    stops: ['#2F97DB', '#5FBDF0', '#9BDCF7', '#CFF0FB'],
    hill: '#3E7A63',
  ),
  'dusk': TimePalette(
    key: 'dusk',
    label: 'HOANG HON 17-19H',
    stops: ['#4B2F6B', '#8E4A7E', '#D9633F', '#F2A03D'],
    hill: '#39244D',
  ),
  'night': TimePalette(
    key: 'night',
    label: 'BAN DEM 19-5H',
    stops: ['#0B0F2B', '#171C46', '#2A3168', '#3B4487'],
    hill: '#0A0D22',
  ),
};

const timePaletteOrder = ['dawn', 'day', 'dusk', 'night'];

/// Weather-condition modifier applied on top of a time-of-day color.
/// Ported from the design's `MOD` table / `applyMod`.
class WeatherMod {
  final String key;
  final String label;
  final String? mixColor;
  final double t;
  final double sat;

  const WeatherMod({
    required this.key,
    required this.label,
    this.mixColor,
    required this.t,
    required this.sat,
  });
}

const weatherMods = <String, WeatherMod>{
  'clear': WeatherMod(key: 'clear', label: 'Trời quang', t: 0, sat: 0),
  'cloudy': WeatherMod(key: 'cloudy', label: 'Nhiều mây', mixColor: '#9AA7B4', t: .24, sat: .18),
  'rain': WeatherMod(key: 'rain', label: 'Mưa', mixColor: '#6B7C8C', t: .34, sat: .34),
  'storm': WeatherMod(key: 'storm', label: 'Giông bão', mixColor: '#232A38', t: .5, sat: .42),
  'snow': WeatherMod(key: 'snow', label: 'Tuyết', mixColor: '#DCE8F2', t: .32, sat: .3),
  'fog': WeatherMod(key: 'fog', label: 'Sương mù', mixColor: '#E6E9EC', t: .4, sat: .5),
};

const weatherModOrder = ['clear', 'cloudy', 'rain', 'storm', 'snow', 'fog'];

/// Applies a weather condition's desaturate+mix modifier to a base hex color.
String applyMod(String hex, String cond) {
  final m = weatherMods[cond]!;
  var c = desatColor(hexColor(hex), m.sat);
  if (m.mixColor != null) c = mixColor(c, hexColor(m.mixColor!), m.t);
  final r = (c.r * 255).round(), g = (c.g * 255).round(), b = (c.b * 255).round();
  return '#${r.toRadixString(16).padLeft(2, '0')}'
      '${g.toRadixString(16).padLeft(2, '0')}'
      '${b.toRadixString(16).padLeft(2, '0')}';
}

/// A saved place — just identity + coordinates. Live numbers (temp, hi/lo,
/// condition, forecast) come from Open-Meteo at runtime, see
/// `open_meteo_service.dart`.
class CityInfo {
  final String name;
  final String sub;
  final double lat;
  final double lon;

  const CityInfo({required this.name, required this.sub, required this.lat, required this.lon});
}

const appCities = <CityInfo>[
  CityInfo(name: 'Đà Lạt', sub: 'Lâm Đồng', lat: 11.9404, lon: 108.4583),
  CityInfo(name: 'Hà Nội', sub: 'Thủ đô', lat: 21.0278, lon: 105.8342),
  CityInfo(name: 'Huế', sub: 'Thừa Thiên Huế', lat: 16.4637, lon: 107.5909),
  CityInfo(name: 'Sa Pa', sub: 'Lào Cai', lat: 22.3364, lon: 103.8438),
  CityInfo(name: 'TP. Hồ Chí Minh', sub: 'Miền Nam', lat: 10.7769, lon: 106.7009),
  CityInfo(name: 'Nha Trang', sub: 'Khánh Hòa', lat: 12.2388, lon: 109.1967),
];

const weekdayNames = [
  'Chủ nhật', 'Thứ hai', 'Thứ ba', 'Thứ tư', 'Thứ năm', 'Thứ sáu', 'Thứ bảy',
];

const mascotAdvice = <String, String>{
  'clear': 'Nắng đẹp mà gắt đó! Đội mũ, bôi kem chống nắng, rồi hẵng phi ra đường nha.',
  'cloudy': 'Trời âm u mát rượi. Ngày vàng để đi dạo mà không sợ cháy da đâu.',
  'rain': 'Lại mưa nữa rồi… Cầm ô đi cậu ơi, kẻo ướt nhẹp như tớ bây giờ.',
  'storm': 'Giông tới! Tớ trốn dưới mây đây. Cậu ở trong nhà, rút phích cắm luôn nhé.',
  'snow': 'Lạnh cóng cả râu! Khăn quàng, áo khoác, và một cốc gì đó nóng nóng.',
  'fog': 'Sương mù đặc như sữa. Đi xe chậm thôi, bật đèn vàng vào cậu nhé.',
  'night': 'Khuya rồi đó. Mai trời quang, đi làm nhớ mang theo tinh thần tốt. Ngủ ngon!',
};
