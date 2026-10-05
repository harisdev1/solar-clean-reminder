import 'dart:math' as math;

import 'package:flutter/material.dart';

class CountdownRing extends StatelessWidget {
  const CountdownRing({
    super.key,
    required this.progress,
    required this.color,
    required this.child,
  });

  final double progress;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final track = Theme.of(context).colorScheme.surface;
    return SizedBox(
      width: 250,
      height: 250,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        builder: (_, p, __) => TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: color),
          duration: const Duration(milliseconds: 500),
          builder: (_, col, __) => CustomPaint(
            painter: _RingPainter(p, col ?? color, track),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.p, this.color, this.track);
  final double p;
  final Color color, track;

  @override
  void paint(Canvas canvas, Size s) {
    const stroke = 22.0;
    final rect = const Offset(stroke / 2, stroke / 2) &
        Size(s.width - stroke, s.height - stroke);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, base..color = track);
    if (p > 0) {
      canvas.drawArc(
          rect, -math.pi / 2, math.pi * 2 * p, false, base..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter o) =>
      o.p != p || o.color != color || o.track != track;
}
