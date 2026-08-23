import 'package:flutter/material.dart';
import 'package:rdiary/backgrounds/diary_world/diary_world.dart';

class CosmicSceneConfig {
  final int starSeed;
  final int dustSeed;

  final Offset moonPosition;
  final double moonRadius;

  final double nebulaIntensity;
  final double starIntensity;
  final double dustIntensity;
  final double rayIntensity;

  final bool showMoon;
  final bool showShootingStar;

  const CosmicSceneConfig({
    required this.starSeed,
    required this.dustSeed,
    required this.moonPosition,
    required this.moonRadius,
    required this.nebulaIntensity,
    required this.starIntensity,
    required this.dustIntensity,
    required this.rayIntensity,
    this.showMoon = true,
    this.showShootingStar = true,
  });
}

/// Returns the Cosmic Universe configuration for each RDiary screen.
CosmicSceneConfig cosmicConfigFor(DiaryScene scene) {
  switch (scene) {
  // ============================================================
  // 🏠 HOME
  // ============================================================
    case DiaryScene.home:
      return const CosmicSceneConfig(
        starSeed: 42,
        dustSeed: 731,
        moonPosition: Offset(.79, .105),
        moonRadius: .105,
        nebulaIntensity: 1.0,
        starIntensity: 1.0,
        dustIntensity: 1.0,
        rayIntensity: 1.0,
      );

  // ============================================================
  // 📖 NOTES
  // ============================================================
    case DiaryScene.notes:
      return const CosmicSceneConfig(
        starSeed: 927,
        dustSeed: 284,
        moonPosition: Offset(.20, .145),
        moonRadius: .083,
        nebulaIntensity: .75,
        starIntensity: .85,
        dustIntensity: .7,
        rayIntensity: .65,
      );

  // ============================================================
  // 🎯 GOALS
  // ============================================================
    case DiaryScene.goals:
      return const CosmicSceneConfig(
        starSeed: 1643,
        dustSeed: 1987,
        moonPosition: Offset(.84, .18),
        moonRadius: .088,
        nebulaIntensity: .85,
        starIntensity: .9,
        dustIntensity: .8,
        rayIntensity: .85,
      );
  }
}