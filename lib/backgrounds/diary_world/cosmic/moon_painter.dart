import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'cosmic_config.dart';

class MoonPainter {
  final CosmicSceneConfig config;
  final Color accentColor;

  const MoonPainter({required this.config, required this.accentColor});

  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width * config.moonPosition.dx,
      size.height * config.moonPosition.dy,
    );

    final radius = size.width * config.moonRadius;

    // OUTSIDE HALO
    canvas.drawCircle(
      center,
      radius * 1.35,
      Paint()
        ..color = accentColor.withOpacity(.055)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );

    canvas.save();

    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );

    // PHYSICAL MOON BASE
    final moonRect = Rect.fromCircle(center: center, radius: radius);

    final baseShader = RadialGradient(
      center: const Alignment(-.35, -.30),
      radius: 1.15,
      colors: const [Color(0xFFE5E6E8), Color(0xFFB8BBC1), Color(0xFF777B83)],
      stops: [0, .58, 1],
    ).createShader(moonRect);

    canvas.drawCircle(center, radius, Paint()..shader = baseShader);

    // PERMANENT MOON TERRAIN
    _paintTerrain(canvas, center, radius);

    // LARGE SHADOW
    //
    // Offset circle creates natural crescent.
    final shadowCenter = Offset(
      center.dx - radius * .52,
      center.dy - radius * .03,
    );

    canvas.drawCircle(
      shadowCenter,
      radius * 1.03,
      Paint()..color = const Color(0xFF020205).withOpacity(.96),
    );

    // SOFT TERMINATOR
    canvas.drawCircle(
      shadowCenter,
      radius * 1.015,
      Paint()
        ..color = const Color(0xFF090A0F).withOpacity(.40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    canvas.restore();

    // PRIMARY COLOR ONLY AS EDGE LIGHT
    final rimRect = Rect.fromCircle(center: center, radius: radius);

    final rimShader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.transparent,
        Colors.transparent,
        accentColor.withOpacity(.10),
        accentColor.withOpacity(.32),
      ],
      stops: const [0, .68, .88, 1],
    ).createShader(rimRect);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = rimShader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
  }

  void _paintTerrain(Canvas canvas, Offset center, double radius) {
    // Fixed seed = same lunar geography every time.
    final random = math.Random(81992);

    // ─────────────────────────────────────────────
    // 1. SMALL / MEDIUM CRATERS
    // ─────────────────────────────────────────────
    for (int i = 0; i < 24; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final distance = random.nextDouble() * radius * .82;

      final craterCenter = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );

      final craterRadius = radius * (.018 + random.nextDouble() * .055);

      // Soft crater floor
      canvas.drawCircle(
        craterCenter,
        craterRadius,
        Paint()
          ..color = const Color(0xFF252930).withOpacity(.16)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.7),
      );

      // Slight darker lower-right interior
      canvas.drawCircle(
        Offset(
          craterCenter.dx + craterRadius * .12,
          craterCenter.dy + craterRadius * .12,
        ),
        craterRadius * .72,
        Paint()..color = const Color(0xFF171A20).withOpacity(.09),
      );

      // Tiny upper-left rim highlight
      canvas.drawArc(
        Rect.fromCircle(center: craterCenter, radius: craterRadius * .90),
        math.pi * 1.05,
        math.pi * .75,
        false,
        Paint()
          ..color = Colors.white.withOpacity(.10)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(radius * .008, .35),
      );
    }

    // ─────────────────────────────────────────────
    // 2. LARGE LUNAR MARIA
    //
    // These are deliberately irregular rather than
    // perfect circles.
    // ─────────────────────────────────────────────

    _irregularMaria(
      canvas,
      Offset(center.dx + radius * .18, center.dy - radius * .25),
      radius * .28,
      radius * .19,
      -0.35,
      .19,
    );

    _irregularMaria(
      canvas,
      Offset(center.dx + radius * .34, center.dy + radius * .05),
      radius * .21,
      radius * .27,
      0.40,
      .17,
    );

    _irregularMaria(
      canvas,
      Offset(center.dx + radius * .12, center.dy + radius * .34),
      radius * .24,
      radius * .14,
      -0.15,
      .15,
    );

    _irregularMaria(
      canvas,
      Offset(center.dx - radius * .12, center.dy + radius * .18),
      radius * .17,
      radius * .12,
      0.25,
      .12,
    );

    // ─────────────────────────────────────────────
    // 3. A FEW SMALL FIXED DARK PATCHES
    // ─────────────────────────────────────────────

    _terrainPatch(
      canvas,
      Offset(center.dx + radius * .48, center.dy - radius * .18),
      radius * .095,
      .18,
    );

    _terrainPatch(
      canvas,
      Offset(center.dx + radius * .40, center.dy + radius * .34),
      radius * .075,
      .16,
    );

    _terrainPatch(
      canvas,
      Offset(center.dx + radius * .05, center.dy - radius * .46),
      radius * .065,
      .14,
    );
  }

  void _irregularMaria(
    Canvas canvas,
    Offset center,
    double width,
    double height,
    double rotation,
    double opacity,
  ) {
    canvas.save();

    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    // Main dark lunar region
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: width * 2,
        height: height * 2,
      ),
      Paint()
        ..color = const Color(0xFF34383F).withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8),
    );

    // Second overlapping shape breaks the perfect oval appearance.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(width * .28, -height * .12),
        width: width * 1.15,
        height: height * 1.35,
      ),
      Paint()
        ..color = const Color(0xFF252930).withOpacity(opacity * .55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.3),
    );

    canvas.restore();
  }

  void _terrainPatch(
    Canvas canvas,
    Offset center,
    double radius,
    double opacity,
  ) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF30343A).withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );
  }
}
