import 'package:flutter/material.dart';

import '../data/weather_data.dart';
import '../logic/weather_logic.dart';
import '../pixel/sprites.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/pixel_sprite.dart';
import 'home_screen.dart';

/// Opens the day-detail bottom sheet, matching the design's `sheetOpen`
/// overlay (tap outside to close).
Future<void> showDaySheet(BuildContext context, DayDetail day, String unit) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => _DaySheetContent(day: day, unit: unit),
  );
}

class _DaySheetContent extends StatelessWidget {
  final DayDetail day;
  final String unit;
  const _DaySheetContent({required this.day, required this.unit});

  @override
  Widget build(BuildContext context) {
    final condLabel = weatherMods[day.kind]?.label ?? 'Có mây rải rác';
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
            decoration: const BoxDecoration(
              color: PixelColors.creamPanelBg,
              border: Border(top: BorderSide(color: PixelColors.ink, width: 4)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    AnimatedPixelSprite(weatherIconSheet(day.kind), size: 52),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(day.day, style: PixelText.pixelify(fontSize: 13, fontWeight: FontWeight.w700)),
                          Text(condLabel, style: PixelText.beVietnam(fontSize: 11, color: PixelColors.mutedGray)),
                        ],
                      ),
                    ),
                    Text('${convertTemp(day.hi, unit)}°/${convertTemp(day.lo, unit)}°',
                        style: PixelText.pixelify(fontSize: 28)),
                  ],
                ),
                const SizedBox(height: 11),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.6,
                  children: [
                    for (final s in day.stats)
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(color: PixelColors.cream, border: Border.all(color: PixelColors.ink, width: 2)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(s[0], style: PixelText.beVietnam(fontSize: 10, color: PixelColors.mutedGray)),
                            Text(s[1], style: PixelText.pixelify(fontSize: 20)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('chạm ra ngoài để đóng',
                    textAlign: TextAlign.center,
                    style: PixelText.beVietnam(fontSize: 10.5, color: PixelColors.mutedGray)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
