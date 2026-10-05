import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/app_defaults.dart';
import '../../core/app_keys.dart';
import '../../core/app_strings.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDefaults.splashAnimMs))
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final t = _c.value;
          final logoFade =
              Curves.easeOutCubic.transform(((t - .25) / .45).clamp(0.0, 1.0));
          final textFade =
              Curves.easeOutCubic.transform(((t - .45) / .4).clamp(0.0, 1.0));
          final logoScale = 0.92 + 0.08 * logoFade;

          return Stack(fit: StackFit.expand, children: [
            CustomPaint(painter: _SplashPainter(t)),
            Align(
              alignment: const Alignment(0, -.12),
              child: Opacity(
                opacity: logoFade,
                child: Transform.scale(
                  scale: logoScale,
                  child: Image.asset(
                    AppKeys.logoAsset,
                    width: 168,
                    height: 168,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, .72),
              child: Opacity(
                opacity: textFade,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - textFade)),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text(AppStrings.appName,
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1,
                            shadows: [
                              Shadow(
                                  color: Color(0x66000000),
                                  blurRadius: 12,
                                  offset: Offset(0, 2)),
                            ])),
                    const SizedBox(height: 8),
                    Text(AppStrings.tagline,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: .85))),
                  ]),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

/// Gold solar-panel atmosphere — no painted sun (logo already has one).
class _SplashPainter extends CustomPainter {
  _SplashPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size s) {
    final k = Curves.easeInOut.transform((t / .7).clamp(0.0, 1.0));
    final top = Color.lerp(const Color(0xFF0A1628), const Color(0xFF1A2A44), k)!;
    final mid = Color.lerp(const Color(0xFF1B2F4A), const Color(0xFF3D4A28), k)!;
    final bottom =
        Color.lerp(const Color(0xFF2A2818), const Color(0xFFFFB300), k)!;
    final all = Offset.zero & s;
    canvas.drawRect(
      all,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, mid, bottom.withValues(alpha: .55)],
          stops: const [0, .55, 1],
        ).createShader(all),
    );

    // Soft gold wash behind logo area (not a sun disc).
    final wash = Offset(s.width / 2, s.height * .38);
    canvas.drawCircle(
      wash,
      s.width * .42,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0x33FFB300),
            const Color(0x00FFB300),
          ],
        ).createShader(Rect.fromCircle(center: wash, radius: s.width * .42)),
    );

    final appear = Curves.easeOutCubic.transform((t / .5).clamp(0.0, 1.0));
    _drawPanel(
      canvas,
      s,
      center: Offset(s.width * .5, s.height * .58),
      width: s.width * .72,
      tilt: -0.08,
      alpha: appear * .92,
      shineT: t,
    );
    _drawPanel(
      canvas,
      s,
      center: Offset(s.width * .72, s.height * .78),
      width: s.width * .48,
      tilt: 0.14,
      alpha: appear * .55,
      shineT: t,
      cols: 3,
      rows: 2,
    );
  }

  void _drawPanel(
    Canvas canvas,
    Size s, {
    required Offset center,
    required double width,
    required double tilt,
    required double alpha,
    required double shineT,
    int cols = 4,
    int rows = 3,
  }) {
    if (alpha <= 0.01) return;
    final height = width * .58;
    final rect = Rect.fromCenter(center: center, width: width, height: height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tilt);
    canvas.translate(-center.dx, -center.dy);

    // Gold frame
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFFC9A227).withValues(alpha: alpha)
        ..style = PaintingStyle.fill,
    );
    final inset = rect.deflate(5);
    final glass = RRect.fromRectAndRadius(inset, const Radius.circular(12));
    canvas.drawRRect(
      glass,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF3A4A1A).withValues(alpha: alpha),
            const Color(0xFF1A2838).withValues(alpha: alpha),
          ],
        ).createShader(inset),
    );

    const gap = 4.0;
    final cellW = (inset.width - gap * (cols + 1)) / cols;
    final cellH = (inset.height - gap * (rows + 1)) / rows;
    for (var i = 0; i < cols; i++) {
      for (var j = 0; j < rows; j++) {
        final cell = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            inset.left + gap + i * (cellW + gap),
            inset.top + gap + j * (cellH + gap),
            cellW,
            cellH,
          ),
          const Radius.circular(4),
        );
        final gold = Color.lerp(
          const Color(0xFF8B7355),
          const Color(0xFFE8C547),
          ((i + j) % 3) / 3,
        )!;
        canvas.drawRRect(
          cell,
          Paint()..color = gold.withValues(alpha: alpha * .9),
        );
        // subtle cell highlight
        canvas.drawRRect(
          cell,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: .12 * alpha),
                Colors.transparent,
              ],
            ).createShader(cell.outerRect),
        );
      }
    }

    // Shine sweep across glass
    final sh = Curves.easeInOut.transform(((shineT - .35) / .5).clamp(0.0, 1.0));
    if (sh > 0 && sh < 1) {
      final sx = inset.left + (-0.25 + 1.5 * sh) * inset.width;
      final band = Path()
        ..moveTo(sx, inset.top)
        ..lineTo(sx + 42, inset.top)
        ..lineTo(sx - 8, inset.bottom)
        ..lineTo(sx - 50, inset.bottom)
        ..close();
      canvas.save();
      canvas.clipRRect(glass);
      canvas.drawPath(
        band,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(sx - 20, inset.top),
            Offset(sx + 40, inset.bottom),
            [
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: .35 * alpha),
              Colors.white.withValues(alpha: 0),
            ],
            const [0, .5, 1],
          ),
      );
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SplashPainter old) => old.t != t;
}
