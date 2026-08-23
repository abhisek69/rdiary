import 'package:flutter/material.dart';

import 'cosmic_config.dart';
import 'nebula_painter.dart';
import 'star_field_painter.dart';
import 'cosmic_dust_painter.dart';
import 'cosmic_ray_painter.dart';

class CosmicBasePainter extends CustomPainter {
  final CosmicSceneConfig config;
  final Color accentColor;

  CosmicBasePainter({
    required this.config,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {

    // ═══════════════════════════════════════════════════
    // DYNAMIC LIGHT ONLY
    //
    // The actual universe already exists in the WebP.
    // These painters only add accent-responsive energy.
    // ═══════════════════════════════════════════════════

    // 1. Very subtle colored illumination
    NebulaPainter(
      config: config,
      accentColor: accentColor,
    ).paint(canvas, size);

    // 2. Additional dynamic stars
    StarFieldPainter(
      config: config,
      accentColor: accentColor,
    ).paint(canvas, size);

    // 3. Dynamic cosmic particles
    CosmicDustPainter(
      config: config,
      accentColor: accentColor,
    ).paint(canvas, size);

    // 4. Accent-responsive cosmic energy/rays
    CosmicRayPainter(
      config: config,
      accentColor: accentColor,
    ).paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CosmicBasePainter oldDelegate) {
    return oldDelegate.accentColor != accentColor ||
        oldDelegate.config != config;
  }
}