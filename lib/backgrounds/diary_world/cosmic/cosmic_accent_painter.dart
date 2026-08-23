import 'dart:math' as math;
import 'package:flutter/material.dart';

class CosmicAccentPainter extends CustomPainter {
  final Color accentColor;

  CosmicAccentPainter({
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42819);

    // ─────────────────────────────────────────────
    // 1. VERY SUBTLE ATMOSPHERIC GLOW
    // ─────────────────────────────────────────────

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withOpacity(.10),
          accentColor.withOpacity(.035),
          Colors.transparent,
        ],
        stops: const [0.0, .45, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * .28,
            size.height * .38,
          ),
          radius: size.width * .70,
        ),
      );

    canvas.drawCircle(
      Offset(
        size.width * .28,
        size.height * .38,
      ),
      size.width * .70,
      glowPaint,
    );

    // ─────────────────────────────────────────────
    // 2. ACCENT STARS
    //
    // Only a FEW stars react to primary color.
    // ─────────────────────────────────────────────

    for (int i = 0; i < 24; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * .82;

      final radius =
          .45 + random.nextDouble() * 1.15;

      final position = Offset(x, y);

      // soft glow
      canvas.drawCircle(
        position,
        radius * 4,
        Paint()
          ..color = accentColor.withOpacity(.07)
          ..maskFilter =
          const MaskFilter.blur(BlurStyle.normal, 5),
      );

      // star center
      canvas.drawCircle(
        position,
        radius,
        Paint()
          ..color = accentColor.withOpacity(.75),
      );
    }

    // ─────────────────────────────────────────────
    // 3. COSMIC RAYS
    // ─────────────────────────────────────────────

    final rayPaint = Paint()
      ..color = accentColor.withOpacity(.12)
      ..strokeWidth = .7
      ..style = PaintingStyle.stroke;

    final ray1 = Path()
      ..moveTo(size.width * -.05, size.height * .33)
      ..lineTo(size.width * .73, size.height * .10);

    canvas.drawPath(ray1, rayPaint);

    final ray2 = Path()
      ..moveTo(size.width * .20, size.height * .55)
      ..lineTo(size.width * 1.05, size.height * .29);

    canvas.drawPath(ray2, rayPaint);

    // ─────────────────────────────────────────────
    // 4. SMALL NEBULA ACCENT
    //
    // This doesn't recolor the Milky Way.
    // It adds colored illumination over PART of it.
    // ─────────────────────────────────────────────

    final nebulaRect = Rect.fromCircle(
      center: Offset(
        size.width * .50,
        size.height * .48,
      ),
      radius: size.width * .65,
    );

    final nebulaPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withOpacity(.075),
          accentColor.withOpacity(.025),
          Colors.transparent,
        ],
        stops: const [
          0,
          .48,
          1,
        ],
      ).createShader(nebulaRect);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          size.width * .48,
          size.height * .47,
        ),
        width: size.width * .85,
        height: size.height * .25,
      ),
      nebulaPaint,
    );
  }

  @override
  bool shouldRepaint(CosmicAccentPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor;
  }
}