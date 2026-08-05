import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'cosmic_config.dart';

class CosmicDustPainter {
  final CosmicSceneConfig config;
  final Color accentColor;

  const CosmicDustPainter({
    required this.config,
    required this.accentColor,
  });

  void paint(Canvas canvas, Size size) {
    final random = math.Random(config.dustSeed);

    final count = (150 * config.dustIntensity).round();

    for (int i = 0; i < count; i++) {
      final progress = random.nextDouble();

      // Keep dust following a loose cosmic diagonal.
      final x =
          size.width * progress +
              random.nextDouble() * 130 -
              65;

      final y =
          size.height * (.76 - progress * .46) +
              random.nextDouble() * 190 -
              95;

      final position = Offset(x, y);

      final radius =
          .25 + random.nextDouble() * 1.05;

      final type = random.nextDouble();

      Color color;
      double opacity;

      if (type < .48) {

        // Neutral cosmic dust
        color = Colors.white;
        opacity = .07 + random.nextDouble() * .15;

      } else if (type < .63) {

        // Natural cold-space dust
        color = const Color(0xFFB9D9FF);
        opacity = .06 + random.nextDouble() * .13;

      } else {

        // PRIMARY COLOR AFFECTED DUST
        color = accentColor;
        opacity = .10 + random.nextDouble() * .25;
      }

      // Normal particle
      canvas.drawCircle(
        position,
        radius,
        Paint()
          ..color = color.withOpacity(opacity),
      );

      // Only a few particles receive glow
      if (type > .88) {
        canvas.drawCircle(
          position,
          radius * 4.5,
          Paint()
            ..color =
            accentColor.withOpacity(.10)
            ..maskFilter =
            const MaskFilter.blur(
              BlurStyle.normal,
              5,
            ),
        );
      }
    }
  }
}