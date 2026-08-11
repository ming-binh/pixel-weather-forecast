import 'package:flutter/material.dart';

import '../data/weather_data.dart';
import '../pixel/pixel_grid.dart';
import '../pixel/sprites.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/bobbing.dart';
import '../widgets/mascot_widget.dart';
import '../widgets/pixel_sprite.dart';

const _todBlurbs = {
  'dawn': 'Tím hồng dịu dàng, cả thành phố còn ngủ',
  'day': 'Xanh trong, nắng rực rỡ cả ngày',
  'dusk': 'Cam tím giao hòa, tan tầm nên thơ',
  'night': 'Sao lấp lánh, sao băng bất ngờ ghé qua',
};

const _weatherLegend = [
  ['clear', 'Nắng', 'Chim bay ngang, mây trôi nhẹ'],
  ['partly', 'Nắng có mây', 'Vài đám mây ghé chơi'],
  ['cloudy', 'Nhiều mây', 'Chim vàng tinh nghịch bay lượn'],
  ['rain', 'Mưa', 'Giọt nước rơi đều, nhớ mang ô'],
  ['storm', 'Giông', 'UFO bí ẩn ghé qua trên mây'],
  ['snow', 'Tuyết', 'Bông tuyết rơi lất phất'],
  ['fog', 'Sương mù', 'Mờ ảo, chim len lỏi qua sương'],
  ['night', 'Đêm quang', 'Sao băng vút ngang bầu trời'],
];

const _easterEggs = [
  'Chim nhỏ bay ngang lúc trời quang hoặc nhiều mây',
  'Ba tầng mây trôi ngang, mỗi tầng một tốc độ',
  'UFO lạ ghé thăm mỗi khi có giông bão',
  'Chim vàng flappy lượn lờ lúc nhiều mây hay sương mù',
  'Khinh khí cầu bay lúc bình minh & hoàng hôn',
];

/// Welcome / about screen — introduces the 4 sky palettes, the weather icon
/// set, the mascot companions, and a few background "easter egg" details.
/// Replaces the old dev-only design reference sheet, mirrors the design's
/// `isGuide` panel.
class StyleGuideScreen extends StatelessWidget {
  final String char;
  final VoidCallback onGoHome;
  const StyleGuideScreen({super.key, required this.char, required this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PixelColors.creamPanelBg,
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 100),
      child: ListView(
        children: [
          Column(
            children: [
              Bobbing.bob2(
                duration: const Duration(milliseconds: 1100),
                child: MascotWidget(char: char, state: 'clear', size: 84, useDefault: true),
              ),
              const SizedBox(height: 9),
              Text('CHÀO MỪNG ĐẾN\nPIXEL WEATHER',
                  textAlign: TextAlign.center,
                  style: PixelText.pixelify(fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: 1.1).copyWith(height: 1.3)),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 270),
                child: Text(
                  'Ngắm mây trôi, nghe Fu & Nii mách chuyện trời, và khám phá 4 bầu trời đổi màu theo giờ thực.',
                  textAlign: TextAlign.center,
                  style: PixelText.beVietnam(fontSize: 11.5, height: 1.5, color: PixelColors.mutedGray),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('4 BẦU TRỜI, MỘT NGÀY',
              style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 10.5, letterSpacing: .6, color: PixelColors.mutedGray)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.35,
            children: [
              for (final todKey in timePaletteOrder) _TimeCard(todKey: todKey),
            ],
          ),
          const SizedBox(height: 16),
          Text('MỌI KIỂU TRỜI, MỘT CÁI NHÌN',
              style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 10.5, letterSpacing: .6, color: PixelColors.mutedGray)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: PixelColors.cream, border: Border.all(color: PixelColors.ink, width: 3)),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 8,
              childAspectRatio: 2.6,
              children: [
                for (final w in _weatherLegend)
                  Row(
                    children: [
                      AnimatedPixelSprite(weatherIconSheet(w[0]), size: 36),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(w[1], style: PixelText.pixelify(fontSize: 10, fontWeight: FontWeight.w700)),
                            Text(w[2], style: PixelText.beVietnam(fontSize: 8.8, height: 1.3, color: PixelColors.mutedGray)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('BẠN ĐỒNG HÀNH CỦA BẠN',
              style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 10.5, letterSpacing: .6, color: PixelColors.mutedGray)),
          const SizedBox(height: 8),
          Column(
            children: [
              for (final entry in mascotChars.entries) ...[
                if (entry.key != mascotChars.keys.first) const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: PixelColors.cream, border: Border.all(color: PixelColors.ink, width: 3)),
                  child: Row(
                    children: [
                      Bobbing.bob2(
                        duration: const Duration(milliseconds: 1300),
                        child: MascotWidget(char: entry.key, state: 'clear', size: 68, useDefault: true),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.value.name, style: PixelText.pixelify(fontSize: 12, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 3),
                            Text('${entry.value.sub} · ${entry.value.tag}',
                                style: PixelText.beVietnam(fontSize: 10.5, height: 1.4, color: PixelColors.mutedGray)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text('CHI TIẾT NHỎ, ĐỂ BẠN TỰ KHÁM PHÁ',
              style: PixelText.beVietnam(fontWeight: FontWeight.w600, fontSize: 10.5, letterSpacing: .6, color: PixelColors.mutedGray)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: PixelColors.cream, border: Border.all(color: PixelColors.ink, width: 3)),
            child: Column(
              children: [
                _EggRow(icon: AnimatedPixelSprite(birdSheet(), size: 26), label: _easterEggs[0]),
                const SizedBox(height: 9),
                _EggRow(icon: _eggImage('assets/sky/cloud-sm.png', 26), label: _easterEggs[1]),
                const SizedBox(height: 9),
                _EggRow(icon: AnimatedPixelSprite(ufoSheet(), size: 34), label: _easterEggs[2]),
                const SizedBox(height: 9),
                _EggRow(icon: _eggImage('assets/sky/flappy-bird.png', 22), label: _easterEggs[3]),
                const SizedBox(height: 9),
                _EggRow(icon: AnimatedPixelSprite(balloonSheet(), size: 22), label: _easterEggs[4]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onGoHome,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PixelColors.accentOrange,
                border: Border.all(color: PixelColors.ink, width: 3),
                boxShadow: const [BoxShadow(color: Color(0x592B2B44), offset: Offset(0, 6))],
              ),
              child: Text('BẮT ĐẦU NGẮM TRỜI →',
                  style: PixelText.pixelify(fontSize: 12.5, fontWeight: FontWeight.w700, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _eggImage(String asset, double size) {
  return SizedBox(
    width: size,
    height: size,
    child: Image.asset(
      asset,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    ),
  );
}

class _TimeCard extends StatelessWidget {
  final String todKey;
  const _TimeCard({required this.todKey});

  @override
  Widget build(BuildContext context) {
    final palette = timePalettes[todKey]!;
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        border: Border.all(color: PixelColors.ink, width: 3),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [hexColor(palette.stops[0]), hexColor(palette.stops[2])],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedPixelSprite(weatherIconSheet(todKey == 'night' ? 'night' : 'clear'), size: 26),
          const SizedBox(height: 7),
          Text(palette.label, style: PixelText.pixelify(fontSize: 10.5, fontWeight: FontWeight.w700, color: PixelColors.cream)),
          const SizedBox(height: 2),
          Text(_todBlurbs[todKey]!, style: PixelText.beVietnam(fontSize: 9.5, height: 1.35, color: PixelColors.cream)),
        ],
      ),
    );
  }
}

class _EggRow extends StatelessWidget {
  final Widget icon;
  final String label;
  const _EggRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 34, child: Center(child: icon)),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: PixelText.beVietnam(fontSize: 10.5, height: 1.4))),
      ],
    );
  }
}
