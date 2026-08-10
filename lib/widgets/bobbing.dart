import 'package:flutter/material.dart';

/// Stepped vertical bounce, matching the design's `bob`/`bob2` CSS keyframes
/// (`steps(1,end)` — an abrupt hop between fixed offsets, not an eased
/// float).
class Bobbing extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final List<double> offsets;

  const Bobbing({
    super.key,
    required this.child,
    required this.duration,
    this.offsets = const [0, -4],
  });

  /// Matches `@keyframes bob`.
  const Bobbing.bob({super.key, required this.child, required this.duration}) : offsets = const [0, -4];

  /// Matches `@keyframes bob2`.
  const Bobbing.bob2({super.key, required this.child, required this.duration}) : offsets = const [0, -3, -6];

  @override
  State<Bobbing> createState() => _BobbingState();
}

class _BobbingState extends State<Bobbing> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration)..repeat();
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
        final step = (_c.value * widget.offsets.length).floor().clamp(0, widget.offsets.length - 1);
        return Transform.translate(offset: Offset(0, widget.offsets[step]), child: child);
      },
      child: widget.child,
    );
  }
}
