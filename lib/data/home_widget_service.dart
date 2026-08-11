import 'package:home_widget/home_widget.dart';

import '../logic/weather_logic.dart';
import '../widgets/home_widget_snapshot.dart';
import 'open_meteo_service.dart';
import 'weather_data.dart';

const _widgetImageKey = 'weather_widget_image';

/// Must match the Kotlin class name in
/// `android/app/src/main/kotlin/.../WeatherWidgetProvider.kt`.
const _androidProviderName = 'WeatherWidgetProvider';

/// Renders the current weather as a pixel-art snapshot PNG and pushes it to
/// the Android home-screen widget. Called both from the running app after a
/// successful fetch or a settings change (`app.dart._pushWidgetUpdate`), and
/// from the WorkManager background task in `home_widget_background.dart`
/// while the app is closed.
Future<void> updateWeatherWidget({
  required WeatherSnapshot weather,
  required String city,
  required String cond,
  required String tod,
  required String unit,
  required String char,
}) async {
  final snapshot = WeatherWidgetSnapshot(
    city: city,
    temp: '${convertTemp(weather.temp.round(), unit)}°$unit',
    condLabel: weatherMods[cond]!.label + (tod == 'night' ? ' · Đêm' : ''),
    iconKind: effIcon(cond, tod),
    mascotChar: char,
    mascotState: mascotStateFor(cond, tod),
    tod: tod,
  );
  await HomeWidget.renderFlutterWidget(
    snapshot,
    key: _widgetImageKey,
    logicalSize: WeatherWidgetSnapshot.size,
    pixelRatio: 3,
  );
  await HomeWidget.updateWidget(androidName: _androidProviderName);
}
