import 'dart:convert';

import 'package:http/http.dart' as http;

import 'weather_data.dart';

/// Searches Open-Meteo's free worldwide place database by name (no API key
/// needed) — this is what backs the search box on the Locations screen, so
/// it isn't limited to the handful of cities in [appCities].
Future<List<CityInfo>> searchPlaces(String query) async {
  final q = query.trim();
  if (q.isEmpty) return const [];

  final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
    'name': q,
    'count': '8',
    'language': 'vi',
    'format': 'json',
  });

  final res = await http.get(uri).timeout(const Duration(seconds: 8));
  if (res.statusCode != 200) {
    throw Exception('Geocoding trả về lỗi ${res.statusCode}');
  }
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  final results = json['results'] as List?;
  if (results == null) return const [];

  return [
    for (final r in results.cast<Map<String, dynamic>>())
      CityInfo(
        name: r['name'] as String,
        sub: [
          if (r['admin1'] != null) r['admin1'] as String,
          if (r['country'] != null) r['country'] as String,
        ].join(', '),
        lat: (r['latitude'] as num).toDouble(),
        lon: (r['longitude'] as num).toDouble(),
      ),
  ];
}
