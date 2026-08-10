import 'package:flutter/material.dart';

import 'app.dart';
import 'theme/colors.dart';

void main() {
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
