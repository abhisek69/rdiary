import 'package:flutter/material.dart';
import 'cosmic_config.dart';

class NebulaPainter {
  final CosmicSceneConfig config;
  final Color accentColor;

  const NebulaPainter({
    required this.config,
    required this.accentColor,
  });

  void paint(Canvas canvas, Size size) {
    final intensity = config.nebulaIntensity;

    // Subtle neutral depth.
    // These should NOT repaint the static background.
    _neutralDepth(
      canvas,
      center: Offset(size.width * .78, size.height * .25),
      radius: size.width * .55,
      intensity: intensity,
    );

    // Primary-color illumination zones.
    _accentIllumination(
      canvas,
      center: Offset(size.width * .78, size.height * .20),
      radius: size.width * .42,
      opacity: .085 * intensity,
    );

    _accentIllumination(
      canvas,
      center: Offset(size.width * .17, size.height * .50),
      radius: size.width * .36,
      opacity: .060 * intensity,
    );

    _accentIllumination(
      canvas,
      center: Offset(size.width * .72, size.height * .70),
      radius: size.width * .46,
      opacity: .055 * intensity,
    );

    // Small concentrated cosmic energy regions.
    _energyPocket(
      canvas,
      Offset(size.width * .17, size.height * .29),
      size.width * .12,
      intensity,
    );

    _energyPocket(
      canvas,
      Offset(size.width * .76, size.height * .48),
      size.width * .10,
      intensity * .8,
    );

    _energyPocket(
      canvas,
      Offset(size.width * .34, size.height * .73),
      size.width * .13,
      intensity * .7,
    );
  }

  void _neutralDepth(
      Canvas canvas, {
        required Offset center,
        required double radius,
        required double intensity,
      }) {
    final rect =
    Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF162040)
                .withOpacity(.035 * intensity),
            const Color(0xFF0B1020)
                .withOpacity(.018 * intensity),
            Colors.transparent,
          ],
          stops: const [0, .55, 1],
        ).createShader(rect),
    );
  }

  void _accentIllumination(
      Canvas canvas, {
        required Offset center,
        required double radius,
        required double opacity,
      }) {
    final rect =
    Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            accentColor.withOpacity(opacity),
            accentColor.withOpacity(opacity * .35),
            accentColor.withOpacity(opacity * .08),
            Colors.transparent,
          ],
          stops: const [
            0,
            .32,
            .68,
            1,
          ],
        ).createShader(rect),
    );
  }

  void _energyPocket(
      Canvas canvas,
      Offset center,
      double radius,
      double intensity,
      ) {
    final rect =
    Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(.025 * intensity),
            accentColor.withOpacity(.11 * intensity),
            accentColor.withOpacity(.025 * intensity),
            Colors.transparent,
          ],
          stops: const [
            0,
            .18,
            .52,
            1,
          ],
        ).createShader(rect)
        ..maskFilter =
        const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }
}