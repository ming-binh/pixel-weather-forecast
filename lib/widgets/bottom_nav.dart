import 'package:flutter/material.dart';

import '../pixel/sprites.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'pixel_sprite.dart';

class NavEntry {
  final String key;
  final String label;
  final String iconKind;
  const NavEntry(this.key, this.label, this.iconKind);
}

const navEntries = [
  NavEntry('home', 'Trang chủ', 'home'),
  NavEntry('loc', 'Địa điểm', 'pin'),
  NavEntry('set', 'Cài đặt', 'gear'),
  NavEntry('guide', 'Style', 'palette'),
];

/// 4-item bottom navigation bar with the design's chunky pixel styling.
class PixelBottomNav extends StatelessWidget {
  final String current;
  final ValueChanged<String> onSelect;

  const PixelBottomNav({super.key, required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: PixelColors.cream,
        border: Border.all(color: PixelColors.ink, width: 3),
        boxShadow: const [BoxShadow(color: Color(0x59141222), offset: Offset(0, 6))],
      ),
      child: Row(
        children: [
          for (final entry in navEntries)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(entry.key),
                child: Container(
                  color: current == entry.key ? PixelColors.creamPanelActive : Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedPixelSprite(miniIconSheet(entry.iconKind), size: 22),
                      const SizedBox(height: 3),
                      Text(
                        entry.label,
                        style: PixelText.beVietnam(
                          fontWeight: FontWeight.w600,
                          fontSize: 9.5,
                          color: current == entry.key ? PixelColors.ink : PixelColors.mutedGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
