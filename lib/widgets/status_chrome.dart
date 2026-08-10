import 'package:flutter/material.dart';

import '../theme/text_styles.dart';

/// Stylized in-app clock + decorative signal/battery glyphs — a pixel-art
/// flourish echoing a retro phone status bar, drawn *inside* the app's
/// content area (below the real OS status bar), matching the design.
class StatusChrome extends StatelessWidget {
  final String clock;
  final Color color;

  const StatusChrome({super.key, required this.clock, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(clock, style: PixelText.pixelify(fontSize: 13, color: color)),
              Row(
                children: [
                  CustomPaint(size: const Size(14, 9), painter: _SignalPainter(color)),
                  const SizedBox(width: 4),
                  CustomPaint(size: const Size(18, 9), painter: _BatteryPainter(color)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignalPainter extends CustomPainter {
  final Color color;
  _SignalPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..isAntiAlias = false;
    final barW = size.width / 4;
    for (var i = 0; i < 4; i++) {
      final h = size.height * (i + 1) / 4;
      canvas.drawRect(Rect.fromLTWH(i * barW, size.height - h, barW - 1, h), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignalPainter oldDelegate) => oldDelegate.color != color;
}

class _BatteryPainter extends CustomPainter {
  final Color color;
  _BatteryPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..isAntiAlias = false;
    canvas.drawRect(Rect.fromLTWH(1, 1, size.width - 2, size.height - 2), border);
    final fill = Paint()..color = color;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * .7, size.height), fill);
  }

  @override
  bool shouldRepaint(covariant _BatteryPainter oldDelegate) => oldDelegate.color != color;
}
