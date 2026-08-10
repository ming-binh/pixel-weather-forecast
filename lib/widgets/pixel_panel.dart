import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// A flat, sharp-cornered card with a thick ink border and a solid offset
/// drop-shadow — the chunky "pixel UI" panel style used throughout the
/// design (stat tiles, forecast rows, the mascot speech bubble, buttons).
class PixelPanel extends StatelessWidget {
  final Widget child;
  final Color background;
  final Color borderColor;
  final double borderWidth;
  final double shadowDrop;
  final Color shadowColor;
  final EdgeInsetsGeometry padding;

  const PixelPanel({
    super.key,
    required this.child,
    this.background = PixelColors.cream,
    this.borderColor = PixelColors.ink,
    this.borderWidth = 3,
    this.shadowDrop = 6,
    this.shadowColor = const Color(0x592B2B44),
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: shadowDrop > 0
            ? [BoxShadow(color: shadowColor, offset: Offset(0, shadowDrop))]
            : null,
      ),
      child: child,
    );
  }
}

/// A tappable [PixelPanel].
class PixelButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color background;
  final Color borderColor;
  final double borderWidth;
  final double shadowDrop;
  final EdgeInsetsGeometry padding;

  const PixelButton({
    super.key,
    required this.child,
    required this.onTap,
    this.background = PixelColors.accentOrange,
    this.borderColor = PixelColors.ink,
    this.borderWidth = 3,
    this.shadowDrop = 5,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PixelPanel(
        background: background,
        borderColor: borderColor,
        borderWidth: borderWidth,
        shadowDrop: shadowDrop,
        padding: padding,
        child: child,
      ),
    );
  }
}
