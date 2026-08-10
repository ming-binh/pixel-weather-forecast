import 'dart:convert';

import 'package:http/http.dart' as http;

/// One hour of forecast, already sliced to start right after the API's
/// current local time.
class HourlyForecast {
  final DateTime time;
  final double temp;
  final int pop;
  final String cond;
  const HourlyForecast({required this.time, required this.temp, required this.pop, required this.cond});
}

/// One day of the 7-day forecast (index 0 is always today).
class DailyForecast {
  final DateTime date;
  final double hi;
  final double lo;
  final String cond;
  final double uv;
  final int pop;
  final double windSpeed;
  final int windDir;
  final int humidity;
  const DailyForecast({
    required this.date,
    required this.hi,
    required this.lo,
    required this.cond,
    required this.uv,
    required this.pop,
    required this.windSpeed,
    required this.windDir,
    required this.humidity,
  });
}

/// A full forecast snapshot for one location, as returned by a single
/// Open-Meteo `/v1/forecast` call.
class WeatherSnapshot {
  final double temp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int windDir;
  final double uvIndex;
  final String cond;
  final DateTime localTime;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  const WeatherSnapshot({
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDir,
    required this.uvIndex,
    required this.cond,
    required this.localTime,
    required this.hourly,
    required this.daily,
  });
}

/// Maps an Open-Meteo/WMO weather code to one of the app's 6 conditions.
/// https://open-meteo.com/en/docs — WMO Weather interpretation codes.
String conditionFromWmo(int code) {
  const snow = {71, 73, 75, 77, 85, 86};
  const rain = {51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82};
  const storm = {95, 96, 99};
  const fog = {45, 48};
  if (snow.contains(code)) return 'snow';
  if (storm.contains(code)) return 'storm';
  if (rain.contains(code)) return 'rain';
  if (fog.contains(code)) return 'fog';
  if (code == 0 || code == 1) return 'clear';
  return 'cloudy';
}

/// Converts a wind bearing in degrees to a Vietnamese compass label.
String windCompass(num degrees) {
  const dirs = ['Bắc', 'Đông Bắc', 'Đông', 'Đông Nam', 'Nam', 'Tây Nam', 'Tây', 'Tây Bắc'];
  final i = ((degrees % 360) / 45).round() % 8;
  return dirs[i];
}

/// Fetches current + 12h hourly + 7-day forecast for one location.
Future<WeatherSnapshot> fetchWeather(double lat, double lon) async {
  final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
    'latitude': '$lat',
    'longitude': '$lon',
    'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,wind_direction_10m,uv_index',
    'hourly': 'temperature_2m,precipitation_probability,weather_code',
    'daily':
        'weather_code,temperature_2m_max,temperature_2m_min,uv_index_max,precipitation_probability_max,wind_speed_10m_max,wind_direction_10m_dominant,relative_humidity_2m_mean',
    'timezone': 'auto',
    'forecast_days': '7',
  });

  final res = await http.get(uri).timeout(const Duration(seconds: 12));
  if (res.statusCode != 200) {
    throw Exception('Open-Meteo trả về lỗi ${res.statusCode}');
  }
  final json = jsonDecode(res.body) as Map<String, dynamic>;

  final current = json['current'] as Map<String, dynamic>;
  final localTime = DateTime.parse(current['time'] as String);

  final hourlyJson = json['hourly'] as Map<String, dynamic>;
  final hTimes = (hourlyJson['time'] as List).cast<String>();
  final hTemps = (hourlyJson['temperature_2m'] as List).cast<num>();
  final hPop = (hourlyJson['precipitation_probability'] as List).cast<num>();
  final hCode = (hourlyJson['weather_code'] as List).cast<num>();
  var startIdx = hTimes.indexWhere((t) => DateTime.parse(t).isAfter(localTime));
  if (startIdx < 0) startIdx = 0;
  final hourly = <HourlyForecast>[
    for (var i = startIdx; i < startIdx + 12 && i < hTimes.length; i++)
      HourlyForecast(
        time: DateTime.parse(hTimes[i]),
        temp: hTemps[i].toDouble(),
        pop: hPop[i].round(),
        cond: conditionFromWmo(hCode[i].round()),
      ),
  ];

  final dailyJson = json['daily'] as Map<String, dynamic>;
  final dTimes = (dailyJson['time'] as List).cast<String>();
  final dHi = (dailyJson['temperature_2m_max'] as List).cast<num>();
  final dLo = (dailyJson['temperature_2m_min'] as List).cast<num>();
  final dCode = (dailyJson['weather_code'] as List).cast<num>();
  final dUv = (dailyJson['uv_index_max'] as List).cast<num>();
  final dPop = (dailyJson['precipitation_probability_max'] as List).cast<num>();
  final dWind = (dailyJson['wind_speed_10m_max'] as List).cast<num>();
  final dWindDir = (dailyJson['wind_direction_10m_dominant'] as List).cast<num>();
  final dHumidity = (dailyJson['relative_humidity_2m_mean'] as List).cast<num>();
  final daily = <DailyForecast>[
    for (var i = 0; i < dTimes.length; i++)
      DailyForecast(
        date: DateTime.parse(dTimes[i]),
        hi: dHi[i].toDouble(),
        lo: dLo[i].toDouble(),
        cond: conditionFromWmo(dCode[i].round()),
        uv: dUv[i].toDouble(),
        pop: dPop[i].round(),
        windSpeed: dWind[i].toDouble(),
        windDir: dWindDir[i].round(),
        humidity: dHumidity[i].round(),
      ),
  ];

  return WeatherSnapshot(
    temp: (current['temperature_2m'] as num).toDouble(),
    feelsLike: (current['apparent_temperature'] as num).toDouble(),
    humidity: (current['relative_humidity_2m'] as num).round(),
    windSpeed: (current['wind_speed_10m'] as num).toDouble(),
    windDir: (current['wind_direction_10m'] as num).round(),
    uvIndex: (current['uv_index'] as num).toDouble(),
    cond: conditionFromWmo((current['weather_code'] as num).round()),
    localTime: localTime,
    hourly: hourly,
    daily: daily,
  );
}
