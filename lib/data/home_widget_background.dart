import 'package:workmanager/workmanager.dart';

import '../logic/weather_logic.dart';
import 'home_widget_service.dart';
import 'open_meteo_service.dart';
import 'prefs_service.dart';

/// Unique WorkManager task name for the periodic widget refresh.
const weatherWidgetRefreshTask = 'pixel_weather_widget_refresh';

/// Entry point WorkManager launches in a separate background isolate. Reads
/// whatever city/settings were last saved (the running app, if any, isn't
/// reachable from here) and re-renders the home-screen widget from a fresh
/// Open-Meteo fetch.
@pragma('vm:entry-point')
void widgetRefreshCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != weatherWidgetRefreshTask) return true;
    try {
      final prefs = await loadPrefs();
      final city = prefs.city;
      if (city == null) return true;
      final snap = await fetchWeather(city.lat, city.lon);
      final tod = todForTheme(prefs.theme ?? 'Tự động', DateTime.now().hour);
      await updateWeatherWidget(
        weather: snap,
        city: city.name,
        cond: snap.cond,
        tod: tod,
        unit: prefs.unit ?? 'C',
        char: prefs.char ?? 'cat',
      );
    } catch (_) {
      // A transient network/API failure in the background shouldn't wipe
      // whatever the widget was last showing — just leave it as is and let
      // the next scheduled run try again.
    }
    return true;
  });
}
