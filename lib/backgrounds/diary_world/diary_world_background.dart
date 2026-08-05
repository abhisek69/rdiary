import 'package:flutter/material.dart';

import 'diary_world.dart';
import 'cosmic/cosmic_world.dart';

/// ═════════════════════════════════════════════════════════════════
/// 🌍 DIARY WORLD BACKGROUND
///
/// Central background router for RDiary.
///
/// Available:
/// • Theme-less
/// • Cosmic Universe
///
/// Coming later:
/// • Moonlight Ocean
/// • Forest Fireflies
/// • Butterfly Garden
/// • Rainy Street
/// ═════════════════════════════════════════════════════════════════

class DiaryWorldBackground extends StatelessWidget {
  final Widget child;
  final DiaryWorld world;
  final DiaryScene scene;
  final Color accentColor;
  final Brightness? brightness;

  const DiaryWorldBackground({
    super.key,
    required this.child,
    this.world = DiaryWorld.cosmicUniverse,
    required this.scene,
    required this.accentColor,
    this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBrightness =
        brightness ?? Theme.of(context).brightness;

    switch (world) {
    // ─────────────────────────────────────────────────────────
    // THEME-LESS
    // ─────────────────────────────────────────────────────────
      case DiaryWorld.simple:
        return _SimpleWorldBackground(
          brightness: effectiveBrightness,
          child: child,
        );

    // ─────────────────────────────────────────────────────────
    // COSMIC UNIVERSE
    // ─────────────────────────────────────────────────────────
      case DiaryWorld.cosmicUniverse:
        return CosmicWorldBackground(
          accentColor: accentColor,
          scene: scene,
          brightness: effectiveBrightness,
          child: child,
        );

    // ─────────────────────────────────────────────────────────
    // COMING SOON WORLDS
    //
    // Until these are implemented, safely fall back to Cosmic.
    // ─────────────────────────────────────────────────────────
      case DiaryWorld.moonlightOcean:
      case DiaryWorld.forestFireflies:
      case DiaryWorld.butterflyGarden:
      case DiaryWorld.rainyStreet:
        return CosmicWorldBackground(
          accentColor: accentColor,
          scene: scene,
          brightness: effectiveBrightness,
          child: child,
        );
    }
  }
}

/// ═════════════════════════════════════════════════════════════════
/// ⚪ THEME-LESS BACKGROUND
///
/// Removes all special world effects and uses the normal Flutter
/// scaffold background.
/// ═════════════════════════════════════════════════════════════════

class _SimpleWorldBackground extends StatelessWidget {
  final Brightness brightness;
  final Widget child;

  const _SimpleWorldBackground({
    required this.brightness,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }
}