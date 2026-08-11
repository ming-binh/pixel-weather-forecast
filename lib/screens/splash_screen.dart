import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/bobbing.dart';
import '../widgets/mascot_widget.dart';

/// First screen shown on launch — mirrors the design's `isSplash` panel.
/// Navigation away from this screen (after ~2.1s) is handled by the parent.
class SplashScreen extends StatefulWidget {
  final String char;
  const SplashScreen({super.key, required this.char});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _load;

  @override
  void initState() {
    super.initState();
    _load = AnimationController(vsync: this, duration: const Duration(milliseconds: 1900))..forward();
  }

  @override
  void dispose() {
    _load.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Bobbing.bob2(
          duration: const Duration(milliseconds: 900),
          child: MascotWidget(char: widget.char, state: 'clear', size: 96),
        ),
        const SizedBox(height: 22),
        Text(
          'PIXEL WEATHER',
          style: PixelText.pixelify(
            fontSize: 30,
            letterSpacing: 2,
            color: PixelColors.cream,
            shadows: const [Shadow(color: PixelColors.ink, offset: Offset(0, 3))],
          ),
        ),
        const SizedBox(height: 22),
        Container(
          width: 180,
          height: 14,
          decoration: BoxDecoration(
            color: PixelColors.ink,
            border: Border.all(color: PixelColors.ink, width: 3),
          ),
          child: AnimatedBuilder(
            animation: _load,
            builder: (context, _) {
              final steps = (_load.value * 12).floor() / 12;
              final width = 0.06 + steps * 0.94;
              return Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: width.clamp(0.06, 1.0),
                  child: Container(height: 14, color: PixelColors.accentOrange),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'đang gọi mèo dậy xem trời…',
          style: PixelText.beVietnam(fontSize: 11.5, color: PixelColors.cream.withValues(alpha: .75)),
        ),
      ],
    );
  }
}
