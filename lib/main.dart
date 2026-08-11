import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'app.dart';
import 'data/home_widget_background.dart';
import 'theme/colors.dart';

void main() {
  Workmanager().initialize(widgetRefreshCallbackDispatcher);
  Workmanager().registerPeriodicTask(
    'weather-widget-refresh',
    weatherWidgetRefreshTask,
    frequency: const Duration(minutes: 30),
    constraints: Constraints(networkType: NetworkType.connected),
  );
  runApp(const PixelWeatherRoot());
}

class PixelWeatherRoot extends StatelessWidget {
  const PixelWeatherRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixel Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: PixelColors.appBg,
        colorSchemeSeed: PixelColors.accentOrange,
      ),
      home: const PixelWeatherApp(),
    );
  }
}
