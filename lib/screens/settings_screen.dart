import 'package:flutter/material.dart';

import '../pixel/sprites.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/pixel_sprite.dart';

const themeOptions = ['Tự động', 'Bình minh', 'Ban ngày', 'Hoàng hôn', 'Ban đêm'];

/// Mirrors the design's `isSet` panel.
class SettingsScreen extends StatelessWidget {
  final String unit;
  final bool notif;
  final String theme;
  final ValueChanged<String> onSetUnit;
  final VoidCallback onToggleNotif;
  final ValueChanged<String> onPickTheme;
  final VoidCallback onOpenGuide;

  const SettingsScreen({
    super.key,
    required this.unit,
    required this.notif,
    required this.theme,
    required this.onSetUnit,
    required this.onToggleNotif,
    required this.onPickTheme,
    required this.onOpenGuide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PixelColors.creamPanelBg,
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 100),
      child: ListView(
        children: [
          Text('CÀI ĐẶT', style: PixelText.pixelify(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: PixelColors.cream,
              border: Border.all(color: PixelColors.ink, width: 3),
              boxShadow: const [BoxShadow(color: Color(0x402B2B44), offset: Offset(0, 6))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Đơn vị nhiệt độ', style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 12.5)),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: PixelColors.ink, width: 3)),
                      child: Row(
                        children: [
                          _UnitButton(label: '°C', active: unit == 'C', onTap: () => onSetUnit('C')),
                          _UnitButton(label: '°F', active: unit == 'F', onTap: () => onSetUnit('F')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(height: 3, color: const Color(0xFFE4D5B7)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Thông báo mỗi sáng', style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 12.5)),
                          Text('Mèo nhắc bạn mang gì lúc 7:00',
                              style: PixelText.beVietnam(fontSize: 10.5, color: PixelColors.mutedGray)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onToggleNotif,
                      child: Container(
                        width: 52,
                        height: 26,
                        decoration: BoxDecoration(
                          color: notif ? const Color(0xFF5BC0BE) : const Color(0xFFDCD3BE),
                          border: Border.all(color: PixelColors.ink, width: 3),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 150),
                          alignment: notif ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(color: PixelColors.cream, border: Border.all(color: PixelColors.ink, width: 3)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(height: 3, color: const Color(0xFFE4D5B7)),
                const SizedBox(height: 12),
                Text('Theme nền', style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 12.5)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in themeOptions)
                      GestureDetector(
                        onTap: () => onPickTheme(t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme == t ? PixelColors.accentOrange : PixelColors.cream,
                            border: Border.all(color: PixelColors.ink, width: 3),
                          ),
                          child: Text(t, style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 11)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: PixelColors.cream,
              border: Border.all(color: PixelColors.ink, width: 3),
              boxShadow: const [BoxShadow(color: Color(0x402B2B44), offset: Offset(0, 6))],
            ),
            child: Row(
              children: [
                PixelSprite(mascot('clear'), size: 56),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mèo Mây', style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 12.5)),
                      Text('Gợi ý AI mỗi ngày dựa trên thời tiết thật. Tắt nếu bạn thích yên tĩnh.',
                          style: PixelText.beVietnam(fontSize: 10.5, height: 1.4, color: PixelColors.mutedGray)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onOpenGuide,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: PixelColors.accentOrange,
                border: Border.all(color: PixelColors.ink, width: 3),
                boxShadow: const [BoxShadow(color: Color(0x592B2B44), offset: Offset(0, 6))],
              ),
              child: Text('XEM STYLE GUIDE & SPRITE SHEET',
                  style: PixelText.pixelify(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text('Pixel Weather v0.1 · bản mô phỏng thiết kế',
                style: PixelText.beVietnam(fontSize: 10.5, color: PixelColors.mutedGray)),
          ),
        ],
      ),
    );
  }
}

class _UnitButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _UnitButton({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        color: active ? PixelColors.accentOrange : PixelColors.cream,
        child: Text(label, style: PixelText.pixelify(fontSize: 12, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
