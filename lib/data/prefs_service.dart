import 'package:shared_preferences/shared_preferences.dart';

import 'weather_data.dart';

const _keyCityName = 'city_name';
const _keyCitySub = 'city_sub';
const _keyCityLat = 'city_lat';
const _keyCityLon = 'city_lon';
const _keyUnit = 'unit';
const _keyTheme = 'theme';
const _keyChar = 'char';
const _keyNotif = 'notif';

/// Everything the app remembers across launches. `city` is `null` only on
/// the very first launch (no previous choice saved yet) — the app uses that
/// to decide whether to send the user straight to the location picker.
class SavedPrefs {
  final CityInfo? city;
  final String? unit;
  final String? theme;
  final String? char;
  final bool? notif;
  const SavedPrefs({this.city, this.unit, this.theme, this.char, this.notif});
}

Future<SavedPrefs> loadPrefs() async {
  final p = await SharedPreferences.getInstance();
  final name = p.getString(_keyCityName);
  final lat = p.getDouble(_keyCityLat);
  final lon = p.getDouble(_keyCityLon);
  final city = (name == null || lat == null || lon == null)
      ? null
      : CityInfo(name: name, sub: p.getString(_keyCitySub) ?? '', lat: lat, lon: lon);
  return SavedPrefs(
    city: city,
    unit: p.getString(_keyUnit),
    theme: p.getString(_keyTheme),
    char: p.getString(_keyChar),
    notif: p.getBool(_keyNotif),
  );
}

Future<void> saveCity(CityInfo city) async {
  final p = await SharedPreferences.getInstance();
  await p.setString(_keyCityName, city.name);
  await p.setString(_keyCitySub, city.sub);
  await p.setDouble(_keyCityLat, city.lat);
  await p.setDouble(_keyCityLon, city.lon);
}

Future<void> saveUnit(String unit) async => (await SharedPreferences.getInstance()).setString(_keyUnit, unit);
Future<void> saveTheme(String theme) async => (await SharedPreferences.getInstance()).setString(_keyTheme, theme);
Future<void> saveChar(String char) async => (await SharedPreferences.getInstance()).setString(_keyChar, char);
Future<void> saveNotif(bool notif) async => (await SharedPreferences.getInstance()).setBool(_keyNotif, notif);
