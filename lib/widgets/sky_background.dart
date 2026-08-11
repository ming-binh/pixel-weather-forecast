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
                scenery(hillColor, widget.timeOfDay, widget.condition),
                width: constraints.maxWidth,
                height: constraints.maxWidth * 48 / 92,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) => AnimatedBuilder(
              animation: _clock,
              builder: (context, _) => _SkyDecor(
                condition: widget.condition,
                timeOfDay: widget.timeOfDay,
                seconds: _clock.value * 120,
                screenSize: constraints.biggest,
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

final SpriteSheet _birdSheet = birdSheet();
final SpriteSheet _planeSheet = planeSheet();
final SpriteSheet _balloonSheet = balloonSheet();
final SpriteSheet _ufoSheet = ufoSheet();

/// One flying decoration: a bird, plane, or balloon crossing the sky on a
/// loop. Mirrors the design's `flyR`/`flyL` lanes — linear horizontal drift,
/// looping with a per-lane duration and start delay.
class _SkyLane extends StatelessWidget {
  final SpriteSheet sheet;
  final double size;
  final double topFraction;
  final double durationSeconds;
  final double delaySeconds;
  final bool reverse;
  final double seconds;
  final Size screenSize;
  final double bobAmplitude;

  const _SkyLane({
    required this.sheet,
    required this.size,
    required this.topFraction,
    required this.durationSeconds,
    required this.delaySeconds,
    required this.seconds,
    required this.screenSize,
    this.reverse = false,
    this.bobAmplitude = 0,
  });

  @override
  Widget build(BuildContext context) {
    final span = screenSize.width + size * 2;
    var phase = ((seconds - delaySeconds) % durationSeconds) / durationSeconds;
    if (phase < 0) phase += 1;
    final x = reverse ? (screenSize.width + size) - phase * span : -size + phase * span;
    final bob = bobAmplitude == 0 ? 0.0 : (((seconds / 2.4) % 1) < 0.5 ? 0.0 : -bobAmplitude);
    return Positioned(
      top: screenSize.height * topFraction + bob,
      left: x,
      child: AnimatedPixelSprite(sheet, size: size),
    );
  }
}

/// One flying decoration rendered from a static image asset instead of a
/// procedural sprite sheet — the design's `imgFx(k,w)` layers (background
/// clouds, the flapping-bird decoration). Same `flyR`/`flyL` drift as
/// [_SkyLane], plus an optional CSS-`bob`-style vertical hop for the ones
/// that have their own inner bobbing wrapper in the design.
class _ImageSkyLane extends StatelessWidget {
  final String asset;
  final double width;
  final double aspectRatio;
  final double topFraction;
  final double durationSeconds;
  final double delaySeconds;
  final bool reverse;
  final double opacity;
  final double bobAmplitude;
  final double seconds;
  final Size screenSize;

  const _ImageSkyLane({
    required this.asset,
    required this.width,
    required this.aspectRatio,
    required this.topFraction,
    required this.durationSeconds,
    required this.delaySeconds,
    required this.seconds,
    required this.screenSize,
    this.reverse = false,
    this.opacity = 1,
    this.bobAmplitude = 0,
  });

  /// Matches the design's `bob 0.5s steps(1,end)` wrapper on the flapping
  /// decoration — the only lane that currently sets [bobAmplitude].
  static const _bobPeriodSeconds = 0.5;

  @override
  Widget build(BuildContext context) {
    final span = screenSize.width + width * 2;
    var phase = ((seconds - delaySeconds) % durationSeconds) / durationSeconds;
    if (phase < 0) phase += 1;
    final x = reverse ? (screenSize.width + width) - phase * span : -width + phase * span;
    final bob = bobAmplitude == 0 ? 0.0 : (((seconds / _bobPeriodSeconds) % 1) < 0.5 ? 0.0 : -bobAmplitude);
    return Positioned(
      top: screenSize.height * topFraction + bob,
      left: x,
      child: Opacity(
        opacity: opacity,
        child: Image.asset(
          asset,
          width: width,
          height: width * aspectRatio,
          filterQuality: FilterQuality.none,
          // Decoration is optional flourish — a missing asset (not placed
          // locally yet) should just skip silently, not show a broken-image
          // icon over the weather UI.
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

/// A brief diagonal streak of light, matching the design's `shoot` keyframes
/// — mostly invisible, flashes across a fixed 7s loop.
class _ShootingStar extends StatelessWidget {
  final double seconds;
  const _ShootingStar({required this.seconds});

  static const _period = 7.0;

  static double _opacityAt(double p) {
    if (p < .78) return 0;
    if (p < .80) return (p - .78) / .02;
    if (p < .84) return 1;
    if (p < .87) return 1 - (p - .84) / .03;
    return 0;
  }

  static Offset _offsetAt(double p) {
    if (p < .78) return Offset.zero;
    if (p < .84) {
      final t = (p - .78) / .06;
      return Offset(-64 * t, 36 * t);
    }
    if (p < .87) {
      final t = (p - .84) / .03;
      return Offset(-64 + (-84 - -64) * t, 36 + (48 - 36) * t);
    }
    return const Offset(-84, 48);
  }

  @override
  Widget build(BuildContext context) {
    var p = (seconds % _period) / _period;
    if (p < 0) p += 1;
    final opacity = _opacityAt(p);
    if (opacity <= 0) return const SizedBox.shrink();
    return Positioned(
      top: 92,
      right: 32,
      child: Transform.translate(
        offset: _offsetAt(p),
        child: Opacity(
          opacity: opacity,
          child: Transform.rotate(
            angle: 35 * math.pi / 180,
            child: Container(
              width: 22,
              height: 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.transparent, Color(0xFFFFF6C8)]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Background clouds (always on), birds/plane/balloon, an occasional storm
/// UFO, a cloudy/foggy-daytime flying decoration, and a clear-night shooting
/// star. Visibility rules match the design's `skyLayer`.
class _SkyDecor extends StatelessWidget {
  final String condition;
  final String timeOfDay;
  final double seconds;
  final Size screenSize;

  const _SkyDecor({
    required this.condition,
    required this.timeOfDay,
    required this.seconds,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final night = timeOfDay == 'night';
    final calm = condition == 'clear' || condition == 'cloudy' || condition == 'fog';
    final lanes = <Widget>[
      // Big background clouds drift regardless of weather/time.
      _ImageSkyLane(
        asset: 'assets/sky/cloud-lg.png',
        width: 168,
        aspectRatio: 153 / 612,
        topFraction: -14 / 824,
        durationSeconds: 72,
        delaySeconds: 0,
        opacity: .58,
        seconds: seconds,
        screenSize: screenSize,
      ),
      _ImageSkyLane(
        asset: 'assets/sky/cloud-md.png',
        width: 128,
        aspectRatio: 115 / 239,
        topFraction: 2 / 824,
        durationSeconds: 64,
        delaySeconds: 34,
        reverse: true,
        opacity: .44,
        seconds: seconds,
        screenSize: screenSize,
      ),
      _ImageSkyLane(
        asset: 'assets/sky/cloud-sm.png',
        width: 86,
        aspectRatio: 146 / 271,
        topFraction: 18 / 824,
        durationSeconds: 58,
        delaySeconds: 18,
        opacity: .4,
        seconds: seconds,
        screenSize: screenSize,
      ),
      if (calm && !night) ...[
        _SkyLane(sheet: _birdSheet, size: 32, topFraction: 392 / 824, durationSeconds: 17, delaySeconds: 0, seconds: seconds, screenSize: screenSize),
        _SkyLane(sheet: _birdSheet, size: 24, topFraction: 420 / 824, durationSeconds: 21, delaySeconds: 2.2, seconds: seconds, screenSize: screenSize),
        _SkyLane(sheet: _birdSheet, size: 24, topFraction: 366 / 824, durationSeconds: 25, delaySeconds: 9, seconds: seconds, screenSize: screenSize),
      ],
      if (condition != 'storm')
        _SkyLane(sheet: _planeSheet, size: 72, topFraction: 444 / 824, durationSeconds: 34, delaySeconds: 5, seconds: seconds, screenSize: screenSize),
      if (condition == 'storm')
        _SkyLane(
          sheet: _ufoSheet,
          size: 56,
          topFraction: 104 / 824,
          durationSeconds: 34,
          delaySeconds: 5,
          reverse: true,
          seconds: seconds,
          screenSize: screenSize,
        ),
      if ((condition == 'cloudy' || condition == 'fog') && !night)
        _ImageSkyLane(
          asset: 'assets/sky/flappy-bird.png',
          width: 30,
          aspectRatio: 1036 / 1466,
          topFraction: 112 / 824,
          durationSeconds: 22,
          delaySeconds: 4,
          bobAmplitude: 4,
          seconds: seconds,
          screenSize: screenSize,
        ),
      if ((timeOfDay == 'dawn' || timeOfDay == 'dusk') && calm)
        _SkyLane(
          sheet: _balloonSheet,
          size: 48,
          topFraction: 470 / 824,
          durationSeconds: 52,
          delaySeconds: 2,
          reverse: true,
          bobAmplitude: 3,
          seconds: seconds,
          screenSize: screenSize,
        ),
      if (condition == 'clear' && night) _ShootingStar(seconds: seconds),
    ];
    return IgnorePointer(child: Stack(children: lanes));
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
