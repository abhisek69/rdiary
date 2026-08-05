import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'cosmic_config.dart';

class StarFieldPainter {
  final CosmicSceneConfig config;
  final Color accentColor;

  const StarFieldPainter({
    required this.config,
    required this.accentColor,
  });

  void paint(Canvas canvas, Size size) {
    final random = math.Random(config.starSeed);

    // ============================================================
    // 🌙 MOON EXCLUSION ZONE
    //
    // Uses the same moon position/radius from CosmicSceneConfig.
    // Dynamic stars inside this area will NOT be painted.
    //
    // Extra padding prevents glowing stars from touching the moon.
    // ============================================================

    final moonCenter = Offset(
      size.width * config.moonPosition.dx,
      size.height * config.moonPosition.dy,
    );

    final moonRadius = size.width * config.moonRadius;

    // Slightly larger than actual moon because star glows extend outward.
    final moonSafeRadius = moonRadius * 1.12;

    // More overlay stars than before.
    final count = (210 * config.starIntensity).round();

    for (int i = 0; i < count; i++) {
      final position = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );

      // ==========================================================
      // 🌙 DON'T DRAW DYNAMIC STARS ON THE MOON
      // ==========================================================

      if (config.showMoon &&
          _insideMoon(
            position,
            moonCenter,
            moonSafeRadius,
          )) {
        continue;
      }

      final type = random.nextDouble();

      if (type < .48) {
        _tinyStar(canvas, position, random);
      } else if (type < .64) {
        _coldStar(canvas, position, random);
      } else if (type < .75) {
        _warmStar(canvas, position, random);
      } else {
        // Around 25% accent influenced.
        _accentStar(canvas, position, random);
      }
    }

    // ============================================================
    // ⭐ FIXED HERO STARS
    // ============================================================

    _drawHeroIfSafe(
      canvas,
      Offset(size.width * .13, size.height * .18),
      2.2,
      moonCenter,
      moonSafeRadius,
    );

    _drawHeroIfSafe(
      canvas,
      Offset(size.width * .89, size.height * .30),
      1.8,
      moonCenter,
      moonSafeRadius,
    );

    _drawHeroIfSafe(
      canvas,
      Offset(size.width * .60, size.height * .07),
      1.4,
      moonCenter,
      moonSafeRadius,
    );

    // ============================================================
    // ✨ ACCENT HERO STARS
    // ============================================================

    _drawAccentHeroIfSafe(
      canvas,
      Offset(size.width * .18, size.height * .12),
      1.7,
      moonCenter,
      moonSafeRadius,
    );

    _drawAccentHeroIfSafe(
      canvas,
      Offset(size.width * .82, size.height * .42),
      1.5,
      moonCenter,
      moonSafeRadius,
    );

    _drawAccentHeroIfSafe(
      canvas,
      Offset(size.width * .28, size.height * .64),
      1.3,
      moonCenter,
      moonSafeRadius,
    );

    _drawAccentHeroIfSafe(
      canvas,
      Offset(size.width * .72, size.height * .78),
      1.4,
      moonCenter,
      moonSafeRadius,
    );
  }

  // ==============================================================
  // 🌙 MOON COLLISION CHECK
  // ==============================================================

  bool _insideMoon(
      Offset position,
      Offset moonCenter,
      double moonRadius,
      ) {
    final dx = position.dx - moonCenter.dx;
    final dy = position.dy - moonCenter.dy;

    return (dx * dx + dy * dy) <
        (moonRadius * moonRadius);
  }

  // ==============================================================
  // ⭐ SAFE HERO STAR
  // ==============================================================

  void _drawHeroIfSafe(
      Canvas canvas,
      Offset position,
      double radius,
      Offset moonCenter,
      double moonSafeRadius,
      ) {
    if (config.showMoon &&
        _insideMoon(
          position,
          moonCenter,
          moonSafeRadius,
        )) {
      return;
    }

    _heroStar(
      canvas,
      position,
      radius,
    );
  }

  // ==============================================================
  // ✨ SAFE ACCENT HERO STAR
  // ==============================================================

  void _drawAccentHeroIfSafe(
      Canvas canvas,
      Offset position,
      double radius,
      Offset moonCenter,
      double moonSafeRadius,
      ) {
    if (config.showMoon &&
        _insideMoon(
          position,
          moonCenter,
          moonSafeRadius,
        )) {
      return;
    }

    _accentHeroStar(
      canvas,
      position,
      radius,
    );
  }

  // ==============================================================
  // ✦ TINY STAR
  // ==============================================================

  void _tinyStar(
      Canvas canvas,
      Offset position,
      math.Random random,
      ) {
    final radius =
        .25 + random.nextDouble() * .65;

    canvas.drawCircle(
      position,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(
          .20 + random.nextDouble() * .48,
        ),
    );
  }

  // ==============================================================
  // ❄️ COLD STAR
  // ==============================================================

  void _coldStar(
      Canvas canvas,
      Offset position,
      math.Random random,
      ) {
    final radius =
        .55 + random.nextDouble() * .7;

    const color = Color(0xFFB9D9FF);

    canvas.drawCircle(
      position,
      radius * 3.2,
      Paint()
        ..color = color.withOpacity(.07)
        ..maskFilter =
        const MaskFilter.blur(
          BlurStyle.normal,
          4,
        ),
    );

    canvas.drawCircle(
      position,
      radius,
      Paint()
        ..color = color.withOpacity(.82),
    );
  }

  // ==============================================================
  // ☀️ WARM STAR
  // ==============================================================

  void _warmStar(
      Canvas canvas,
      Offset position,
      math.Random random,
      ) {
    final radius =
        .5 + random.nextDouble() * .65;

    const color = Color(0xFFFFE4B0);

    canvas.drawCircle(
      position,
      radius * 3,
      Paint()
        ..color = color.withOpacity(.055)
        ..maskFilter =
        const MaskFilter.blur(
          BlurStyle.normal,
          4,
        ),
    );

    canvas.drawCircle(
      position,
      radius,
      Paint()
        ..color = color.withOpacity(.78),
    );
  }

  // ==============================================================
  // 🎨 ACCENT STAR
  // ==============================================================

  void _accentStar(
      Canvas canvas,
      Offset position,
      math.Random random,
      ) {
    final radius =
        .45 + random.nextDouble() * .85;

    // Wide accent glow.
    canvas.drawCircle(
      position,
      radius * 6,
      Paint()
        ..color =
        accentColor.withOpacity(.10)
        ..maskFilter =
        const MaskFilter.blur(
          BlurStyle.normal,
          7,
        ),
    );

    // Concentrated accent glow.
    canvas.drawCircle(
      position,
      radius * 2.5,
      Paint()
        ..color =
        accentColor.withOpacity(.22)
        ..maskFilter =
        const MaskFilter.blur(
          BlurStyle.normal,
          3,
        ),
    );

    // Almost-white physical core.
    canvas.drawCircle(
      position,
      radius,
      Paint()
        ..color = Color.lerp(
          Colors.white,
          accentColor,
          .38,
        )!
            .withOpacity(.92),
    );
  }

  // ==============================================================
  // ✨ ACCENT HERO STAR
  // ==============================================================

  void _accentHeroStar(
      Canvas canvas,
      Offset center,
      double radius,
      ) {
    canvas.drawCircle(
      center,
      radius * 7,
      Paint()
        ..color =
        accentColor.withOpacity(.15)
        ..maskFilter =
        const MaskFilter.blur(
          BlurStyle.normal,
          10,
        ),
    );

    canvas.drawCircle(
      center,
      radius * 3,
      Paint()
        ..color =
        accentColor.withOpacity(.32)
        ..maskFilter =
        const MaskFilter.blur(
          BlurStyle.normal,
          4,
        ),
    );

    final linePaint = Paint()
      ..color =
      accentColor.withOpacity(.60)
      ..strokeWidth = .55;

    canvas.drawLine(
      Offset(
        center.dx - radius * 2.2,
        center.dy,
      ),
      Offset(
        center.dx + radius * 2.2,
        center.dy,
      ),
      linePaint,
    );

    canvas.drawLine(
      Offset(
        center.dx,
        center.dy - radius * 2.2,
      ),
      Offset(
        center.dx,
        center.dy + radius * 2.2,
      ),
      linePaint,
    );

    canvas.drawCircle(
      center,
      radius * .60,
      Paint()
        ..color =
        Colors.white.withOpacity(.95),
    );
  }

  // ==============================================================
  // ⭐ NEUTRAL HERO STAR
  // ==============================================================

  void _heroStar(
      Canvas canvas,
      Offset center,
      double radius,
      ) {
    canvas.drawCircle(
      center,
      radius * 4,
      Paint()
        ..color =
        Colors.white.withOpacity(.10)
        ..maskFilter =
        const MaskFilter.blur(
          BlurStyle.normal,
          7,
        ),
    );

    final linePaint = Paint()
      ..color =
      Colors.white.withOpacity(.9)
      ..strokeWidth = .7;

    canvas.drawLine(
      Offset(
        center.dx - radius * 2.5,
        center.dy,
      ),
      Offset(
        center.dx + radius * 2.5,
        center.dy,
      ),
      linePaint,
    );

    canvas.drawLine(
      Offset(
        center.dx,
        center.dy - radius * 2.5,
      ),
      Offset(
        center.dx,
        center.dy + radius * 2.5,
      ),
      linePaint,
    );

    canvas.drawCircle(
      center,
      radius * .65,
      Paint()
        ..color = Colors.white,
    );
  }
}