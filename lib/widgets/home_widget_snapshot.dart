import 'package:flutter/material.dart';

import '../data/weather_data.dart';
import '../pixel/pixel_grid.dart';
import '../pixel/sprites.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'mascot_widget.dart';
import 'pixel_sprite.dart';

/// The 4x1 Android home-screen widget's visual, in the app's own pixel-art
/// style. Not shown inside the app itself — this is only ever built
/// standalone and rasterized to a PNG via `HomeWidget.renderFlutterWidget`
/// (see `lib/data/home_widget_service.dart`), because a native App Widget
/// can't run Flutter's custom canvas painting directly.
class WeatherWidgetSnapshot extends StatelessWidget {
  final String city;
  final String temp;
  final String condLabel;
  final String iconKind;
  final String mascotChar;
  final String mascotState;
  final String tod;

  /// Matches the 4x1 cell size Android widgets conventionally use
  /// (`70*cells - 30` dp for width, single-row height).
  static const size = Size(260, 68);

  const WeatherWidgetSnapshot({
    super.key,
    required this.city,
    required this.temp,
    required this.condLabel,
    required this.iconKind,
    required this.mascotChar,
    required this.mascotState,
    required this.tod,
  });

  @override
  Widget build(BuildContext context) {
    final dark = tod == 'dusk' || tod == 'night';
    final stops = timePalettes[tod]!.stops.map(hexColor).toList();
    final fg = dark ? PixelColors.cream : PixelColors.ink;
    final sub = dark ? PixelColors.cream.withValues(alpha: 0.8) : const Color(0xFF3E4A6B);
    final cloud = decorCloudSheet().frames.first;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: PixelColors.ink, width: 2),
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: stops),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 86,
                height: size.height,
                child: Padding(
                  padding: const EdgeInsets.only(left: 13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(city.toUpperCase(), style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 9.5, color: fg)),
                      Text(temp, style: PixelText.pixelify(fontSize: 26, fontWeight: FontWeight.w700, color: fg)),
                      Text(condLabel, style: PixelText.beVietnam(fontSize: 8.5, color: sub)),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 54,
                height: size.height,
                child: Stack(
                  children: [
                    Positioned(top: 13, left: 2, child: PixelSprite(cloud, size: 32)),
                    Positioned(top: 33, left: 28, child: PixelSprite(cloud, size: 16)),
                  ],
                ),
              ),
              Expanded(
                child: Center(child: PixelSprite(weatherIconSheet(iconKind).frames.first, size: 32)),
              ),
              SizedBox(
                width: 39,
                height: size.height,
                child: Stack(
                  children: [
                    Positioned(right: -8, top: 15, child: MascotWidget(char: mascotChar, state: mascotState, size: 80)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
