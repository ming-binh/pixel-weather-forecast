import 'package:flutter/material.dart';

import '../pixel/pixel_grid.dart';

/// Renders a [PixelGrid] as crisp, non-antialiased squares — the Flutter
/// equivalent of the design's `image-rendering:pixelated` CSS trick.
class PixelSprite extends StatelessWidget {
  final PixelGrid grid;
  final double? size;
  final double? width;
  final double? height;

  const PixelSprite(this.grid, {super.key, this.size}) : width = null, height = null;

  const PixelSprite.box(this.grid, {super.key, required double this.width, required double this.height})
      : size = null;

  @override
  Widget build(BuildContext context) {
    final w = width ?? size!;
    final h = height ?? size!;
    return SizedBox(
      width: w,
      height: h,
      child: CustomPaint(painter: _PixelPainter(grid)),
    );
  }
}

/// Renders a [SpriteSheet], stepping frames on a fixed loop — the Flutter
/// equivalent of the design's `animation: shN <dur>s step-end infinite`.
class AnimatedPixelSprite extends StatefulWidget {
  final SpriteSheet sheet;
  final double? size;
  final double? width;
  final double? height;

  const AnimatedPixelSprite(this.sheet, {super.key, this.size}) : width = null, height = null;

  const AnimatedPixelSprite.box(this.sheet, {super.key, required double this.width, required double this.height})
      : size = null;

  @override
  State<AnimatedPixelSprite> createState() => _AnimatedPixelSpriteState();
}

class _AnimatedPixelSpriteState extends State<AnimatedPixelSprite> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.sheet.duration)..repeat();
  }

  @override
  void didUpdateWidget(covariant AnimatedPixelSprite oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sheet.duration != oldWidget.sheet.duration) {
      _c.duration = widget.sheet.duration;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width ?? widget.size!;
    final h = widget.height ?? widget.size!;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final frames = widget.sheet.frames;
        final step = (_c.value * frames.length).floor().clamp(0, frames.length - 1);
        return SizedBox(width: w, height: h, child: CustomPaint(painter: _PixelPainter(frames[step])));
      },
    );
  }
}

class _PixelPainter extends CustomPainter {
  final PixelGrid grid;
  _PixelPainter(this.grid);

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / grid.w;
    final cellH = size.height / grid.h;
    final paint = Paint()..isAntiAlias = false;
    for (var y = 0; y < grid.h; y++) {
      for (var x = 0; x < grid.w; x++) {
        final c = grid.at(x, y);
        if (c == null) continue;
        paint.color = c;
        canvas.drawRect(
          Rect.fromLTWH(x * cellW, y * cellH, cellW + 0.5, cellH + 0.5),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PixelPainter oldDelegate) => oldDelegate.grid != grid;
}
