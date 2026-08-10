import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/weather_data.dart';
import '../pixel/pixel_grid.dart';
import '../pixel/sprites.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/pixel_sprite.dart';

const _mascotSheet = [
  ['clear', 'Nắng · đeo kính râm'],
  ['rain', 'Mưa · cầm ô, ướt nhẹp'],
  ['snow', 'Lạnh · khăn quàng, run'],
  ['storm', 'Giông · lo lắng, núp mây'],
  ['night', 'Đêm · mũ ngủ, ngáp'],
  ['sad', 'Không có dữ liệu'],
];

const _iconSheet = [
  ['clear', 'Nắng'],
  ['partly', 'Nắng có mây'],
  ['cloudy', 'Nhiều mây'],
  ['rain', 'Mưa'],
  ['storm', 'Giông'],
  ['snow', 'Tuyết'],
  ['fog', 'Sương mù'],
  ['night', 'Đêm quang'],
];

/// Design reference sheet — mirrors the `isGuide` panel: color palette,
/// mascot poses, weather icon set, component states, and typography.
class StyleGuideScreen extends StatelessWidget {
  const StyleGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PixelColors.creamPanelBg,
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 100),
      child: ListView(
        children: [
          Text('STYLE GUIDE', style: PixelText.pixelify(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          Text('BẢNG MÀU: GIỜ × THỜI TIẾT',
              style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 10.5, letterSpacing: .6, color: PixelColors.mutedGray)),
          const SizedBox(height: 8),
          for (final todKey in timePaletteOrder) ...[
            _PaletteCard(todKey: todKey),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          Text('SPRITE SHEET MASCOT (24×24, SCALE ×3)',
              style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 10.5, letterSpacing: .6, color: PixelColors.mutedGray)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(color: PixelColors.cream, border: Border.all(color: PixelColors.ink, width: 3)),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: .82,
              children: [
                for (final m in _mascotSheet)
                  Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        color: PixelColors.skeletonBg,
                        child: PixelSprite(mascot(m[0]), size: 72),
                      ),
                      const SizedBox(height: 5),
                      Text(m[1], textAlign: TextAlign.center, style: PixelText.beVietnam(fontSize: 10, height: 1.3)),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('ICON SET THỜI TIẾT (16×16)',
              style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 10.5, letterSpacing: .6, color: PixelColors.mutedGray)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(color: PixelColors.cream, border: Border.all(color: PixelColors.ink, width: 3)),
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: .95,
              children: [
                for (final i in _iconSheet)
                  Column(
                    children: [
                      PixelSprite(weatherIcon(i[0]), size: 48),
                      const SizedBox(height: 4),
                      Text(i[1], textAlign: TextAlign.center, style: PixelText.beVietnam(fontSize: 9.5, color: PixelColors.mutedGray)),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('COMPONENT STATES',
              style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 10.5, letterSpacing: .6, color: PixelColors.mutedGray)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(color: PixelColors.cream, border: Border.all(color: PixelColors.ink, width: 3)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _StateChip('NORMAL', PixelColors.accentOrange, PixelColors.ink, hasShadow: true),
                    _StateChip('PRESSED', const Color(0xFFD98B2B), PixelColors.ink),
                    _StateChip('DISABLED', const Color(0xFFDCD3BE), const Color(0xFF8E8B7C), borderColor: const Color(0xFFA9A292)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(color: PixelColors.accentOrange, border: Border.all(color: PixelColors.ink, width: 3)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _SpinningPixel(),
                          const SizedBox(width: 7),
                          Text('LOADING', style: PixelText.pixelify(fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color: PixelColors.skeletonBg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Card · skeleton', style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 10.5, color: PixelColors.mutedGray)),
                            const SizedBox(height: 7),
                            Container(height: 10, color: PixelColors.skeletonBar),
                            const SizedBox(height: 5),
                            FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: .6,
                              child: Container(height: 10, color: PixelColors.skeletonBar),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: PixelColors.errorPink, border: Border.all(color: PixelColors.errorRed, width: 2)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Card · lỗi dữ liệu', style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 10.5, color: PixelColors.errorRed)),
                            const SizedBox(height: 5),
                            Text('Mất mạng rồi. Chạm để thử lại.',
                                style: PixelText.beVietnam(fontSize: 10.5, height: 1.35)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(color: PixelColors.cream, border: Border.all(color: PixelColors.ink, width: 3)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TYPOGRAPHY', style: PixelText.pixelify(fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('28° 14:00 UV 7', style: PixelText.pixelify(fontSize: 30)),
                Text('Pixelify Sans — số liệu, tiêu đề, nhãn không dấu',
                    style: PixelText.beVietnam(fontSize: 10.5, color: PixelColors.mutedGray)),
                const SizedBox(height: 4),
                Text('Trời hôm nay nắng đẹp, nhớ mang mũ nhé!', style: PixelText.beVietnam(fontSize: 13)),
                Text('Be Vietnam Pro — mọi câu tiếng Việt có dấu, đoạn gợi ý AI',
                    style: PixelText.beVietnam(fontSize: 10.5, color: PixelColors.mutedGray)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletteCard extends StatelessWidget {
  final String todKey;
  const _PaletteCard({required this.todKey});

  @override
  Widget build(BuildContext context) {
    final palette = timePalettes[todKey]!;
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(color: PixelColors.cream, border: Border.all(color: PixelColors.ink, width: 3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(palette.label, style: PixelText.pixelify(fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          for (final condKey in weatherModOrder) ...[
            _PaletteRow(stops: palette.stops, condKey: condKey),
            const SizedBox(height: 5),
          ],
        ],
      ),
    );
  }
}

class _PaletteRow extends StatelessWidget {
  final List<String> stops;
  final String condKey;
  const _PaletteRow({required this.stops, required this.condKey});

  @override
  Widget build(BuildContext context) {
    final applied = stops.map((h) => applyMod(h, condKey)).toList();
    return Row(
      children: [
        Container(
          width: 56,
          height: 22,
          decoration: BoxDecoration(
            border: Border.all(color: PixelColors.ink, width: 2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [hexColor(applied[0]), hexColor(applied[2])],
            ),
          ),
        ),
        const SizedBox(width: 7),
        SizedBox(width: 64, child: Text(weatherMods[condKey]!.label, style: PixelText.beVietnam(fontSize: 10.5))),
        Expanded(
          child: Text('${applied[0]} → ${applied[3]}',
              style: TextStyle(fontFamily: 'monospace', fontSize: 9.5, color: PixelColors.mutedGray)),
        ),
      ],
    );
  }
}

class _StateChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final Color borderColor;
  final bool hasShadow;

  const _StateChip(this.label, this.bg, this.fg, {this.borderColor = PixelColors.ink, this.hasShadow = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: borderColor, width: 3),
        boxShadow: hasShadow ? const [BoxShadow(color: Color(0x592B2B44), offset: Offset(0, 5))] : null,
      ),
      child: Text(label, style: PixelText.pixelify(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

class _SpinningPixel extends StatefulWidget {
  const _SpinningPixel();

  @override
  State<_SpinningPixel> createState() => _SpinningPixelState();
}

class _SpinningPixelState extends State<_SpinningPixel> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final step = (_c.value * 4).floor() % 4;
        return Transform.rotate(angle: step * math.pi / 2, child: child);
      },
      child: Container(width: 10, height: 10, color: PixelColors.ink),
    );
  }
}
