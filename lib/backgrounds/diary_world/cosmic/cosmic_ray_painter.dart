import 'package:flutter/material.dart';
import 'cosmic_config.dart';

class CosmicRayPainter {
  final CosmicSceneConfig config;
  final Color accentColor;

  const CosmicRayPainter({
    required this.config,
    required this.accentColor,
  });

  void paint(Canvas canvas, Size size) {
    final intensity = config.rayIntensity;

    // Main sweeping cosmic ray.
    _ray(
      canvas,
      size,
      start: Offset(-size.width * .15, size.height * .62),
      control1: Offset(size.width * .18, size.height * .51),
      control2: Offset(size.width * .58, size.height * .47),
      end: Offset(size.width * 1.12, size.height * .29),
      intensity: intensity,
    );

    // Upper shooting ray.
    _shootingRay(
      canvas,
      start: Offset(size.width * .35, size.height * .18),
      end: Offset(size.width * .68, size.height * .08),
      intensity: intensity,
    );

    // Smaller atmospheric streak.
    _shootingRay(
      canvas,
      start: Offset(size.width * .70, size.height * .55),
      end: Offset(size.width * .91, size.height * .49),
      intensity: intensity * .60,
    );
  }

  void _ray(
      Canvas canvas,
      Size size, {
        required Offset start,
        required Offset control1,
        required Offset control2,
        required Offset end,
        required double intensity,
      }) {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        control1.dx,
        control1.dy,
        control2.dx,
        control2.dy,
        end.dx,
        end.dy,
      );

    // Huge but extremely soft atmospheric illumination.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * .13
        ..strokeCap = StrokeCap.round
        ..color =
        accentColor.withOpacity(.035 * intensity)
        ..maskFilter =
        const MaskFilter.blur(BlurStyle.normal, 30),
    );

    // Visible accent energy.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * .022
        ..strokeCap = StrokeCap.round
        ..color =
        accentColor.withOpacity(.12 * intensity)
        ..maskFilter =
        const MaskFilter.blur(BlurStyle.normal, 13),
    );

    // Inner accent.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..color =
        accentColor.withOpacity(.18 * intensity)
        ..maskFilter =
        const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Physical light core remains neutral.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .45
        ..strokeCap = StrokeCap.round
        ..color =
        Colors.white.withOpacity(.17 * intensity),
    );
  }

  void _shootingRay(
      Canvas canvas, {
        required Offset start,
        required Offset end,
        required double intensity,
      }) {
    final rect = Rect.fromPoints(start, end);

    // Outer colored glow.
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          accentColor.withOpacity(.05 * intensity),
          accentColor.withOpacity(.28 * intensity),
        ],
      ).createShader(rect)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..maskFilter =
      const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawLine(start, end, glowPaint);

    // Thin physical core.
    final corePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          accentColor.withOpacity(.35 * intensity),
          Colors.white.withOpacity(.88 * intensity),
        ],
      ).createShader(rect)
      ..strokeWidth = .7
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, end, corePaint);

    // End/star head.
    canvas.drawCircle(
      end,
      5,
      Paint()
        ..color =
        accentColor.withOpacity(.18 * intensity)
        ..maskFilter =
        const MaskFilter.blur(BlurStyle.normal, 6),
    );

    canvas.drawCircle(
      end,
      1.25,
      Paint()
        ..color =
        Colors.white.withOpacity(.95 * intensity),
    );
  }
}