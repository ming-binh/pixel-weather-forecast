import 'package:flutter/material.dart';

import '../pixel/sprites.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'mascot_widget.dart';
import 'pixel_sprite.dart';

/// The 4x2 Android home-screen widget's visual, in the app's own pixel-art
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

  /// Matches the 4x2 cell size Android widgets conventionally use
  /// (`70*cells - 30` dp).
  static const size = Size(250, 110);

  const WeatherWidgetSnapshot({
    super.key,
    required this.city,
    required this.temp,
    required this.condLabel,
    required this.iconKind,
    required this.mascotChar,
    required this.mascotState,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(color: PixelColors.creamPanelBg, border: Border.all(color: PixelColors.ink, width: 3)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MascotWidget(char: mascotChar, state: mascotState, size: 68),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(city, style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 12.5, color: PixelColors.ink)),
                  const SizedBox(height: 2),
                  Text(temp, style: PixelText.pixelify(fontSize: 38, fontWeight: FontWeight.w700, color: PixelColors.ink)),
                  Text(condLabel, style: PixelText.beVietnam(fontSize: 10.5, color: PixelColors.mutedGray)),
                ],
              ),
            ),
            const SizedBox(width: 6),
            AnimatedPixelSprite(weatherIconSheet(iconKind), size: 46),
          ],
        ),
      ),
    );
  }
}
