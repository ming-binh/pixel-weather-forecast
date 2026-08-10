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
