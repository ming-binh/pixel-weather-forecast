import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/weather_data.dart';
import '../pixel/pixel_grid.dart';
import '../pixel/sprites.dart';
import 'pixel_sprite.dart';

/// The animated sky: gradient by time-of-day × weather, rolling hills,
/// twinkling stars at night, falling rain/snow, and a storm lightning flash.
/// Ported from the design's skyCss / starsLayer / hillLayer / particleLayer /
/// flash / vignette layers.
class SkyBackground extends StatefulWidget {
  final String timeOfDay;
  final String condition;
  final Widget child;

  const SkyBackground({
    super.key,
    required this.timeOfDay,
    required this.condition,
    required this.child,
  });

  @override
  State<SkyBackground> createState() => _SkyBackgroundState();
}

class _SkyBackgroundState extends State<SkyBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _clock;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(vsync: this, duration: const Duration(seconds: 120))..repeat();
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = timePalettes[widget.timeOfDay]!;
    final stops = palette.stops.map((h) => hexColor(applyMod(h, widget.condition))).toList();
    final hillColor = hexColor(applyMod(palette.hill, widget.condition));
    final night = widget.timeOfDay == 'night';
    final particleKind = widget.condition == 'rain' || widget.condition == 'storm'
        ? 'rain'
        : widget.condition == 'snow'
            ? 'snow'
            : null;
    final flashing = widget.condition == 'storm';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, .34, .68, 1],
          colors: stops,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (night)
            AnimatedBuilder(
              animation: _clock,
              builder: (context, _) => CustomPaint(
                painter: _StarsPainter(_clock.value * 120),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: LayoutBuilder(
              builder: (context, constraints) => PixelSprite.box(
                hillGrid(hillColor),
                width: constraints.maxWidth,
                height: 190,
              ),
            ),
          ),
          if (particleKind != null)
            AnimatedBuilder(
              animation: _clock,
              builder: (context, _) => CustomPaint(
                painter: _ParticlePainter(kind: particleKind, seconds: _clock.value * 120),
              ),
            ),
          if (flashing)
            AnimatedBuilder(
              animation: _clock,
              builder: (context, _) => IgnorePointer(
                child: Container(color: const Color(0xFFFFF9D6).withValues(alpha: _flashOpacity(_clock.value * 120))),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: night ? const Alignment(0, -0.6) : const Alignment(0, -0.7),
                radius: night ? 1.1 : 1.2,
                colors: [
                  const Color(0x00000000),
                  night ? const Color(0x8C06081D) : const Color(0x402B2B44),
                ],
                stops: const [0.55, 1],
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

/// Mirrors the `flash` keyframes: mostly invisible, brief bright flicker.
double _flashOpacity(double t) {
  final p = (t % 6) / 6;
  if (p < .92) return 0;
  if (p < .93) return .75;
  if (p < .94) return .1;
  if (p < .95) return .6;
  if (p < .97) return 0;
  return 0;
}

class _StarsPainter extends CustomPainter {
  final double seconds;
  _StarsPainter(this.seconds);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFFFF6C8);
    for (var i = 0; i < 34; i++) {
      final left = ((i * 47) % 97) / 100 * size.width;
      final top = ((i * 29) % 46) / 100 * size.height;
      final dim = i % 5 == 0 ? 4.0 : 2.0;
      final duration = 1.6 + (i % 5) * .5;
      final delay = (i % 7) * .3;
      final phase = ((seconds - delay) % duration) / duration;
      final opacity = phase < 0 ? .25 : (phase < .6 ? .25 : 1.0);
      paint.color = const Color(0xFFFFF6C8).withValues(alpha: opacity);
      canvas.drawRect(Rect.fromLTWH(left, top, dim, dim), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) => true;
}

class _ParticlePainter extends CustomPainter {
  final String kind;
  final double seconds;
  _ParticlePainter({required this.kind, required this.seconds});

  @override
  void paint(Canvas canvas, Size size) {
    final isSnow = kind == 'snow';
    final count = isSnow ? 30 : 46;
    final paint = Paint();
    for (var i = 0; i < count; i++) {
      final left = ((i * 37) % 100) / 100 * size.width;
      final duration = isSnow ? 4.2 + (i % 5) * .22 : .85 + (i % 5) * .22;
      final delay = (i % 13) * .19;
      final phase = ((seconds - delay) % duration) / duration;
      if (phase < 0) continue;
      final travel = size.height + 80;
      final y = -40 + phase * travel;
      if (isSnow) {
        final x = left + math.sin(phase * math.pi * 2) * 6;
        paint.color = const Color(0xFFFFFFFF);
        canvas.drawRect(Rect.fromLTWH(x, y, 5, 5), paint);
      } else {
        paint.color = const Color(0xCCB7DAF3);
        canvas.drawRect(Rect.fromLTWH(left, y, 3, 12), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
