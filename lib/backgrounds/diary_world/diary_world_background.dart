import 'package:flutter/material.dart';
import 'diary_world.dart';
import 'cosmic_world.dart';

/// ═════════════════════════════════════════════════════════════════
/// 🌍 DIARY WORLD BACKGROUND
///
/// The main orchestrator for app backgrounds. It decides which
/// "World" to render based on user settings or defaults.
/// ═════════════════════════════════════════════════════════════════

class DiaryWorldBackground extends StatelessWidget {
  final Widget child;
  final DiaryWorld world;
  final DiaryScene scene;
  final Color accentColor;

  const DiaryWorldBackground({
    super.key,
    required this.child,
    this.world = DiaryWorld.cosmic, // Default to cosmic as it's the current theme
    required this.scene,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    switch (world) {
      case DiaryWorld.simple:
        return _SimpleWorldBackground(
          scene: scene,
          child: child,
        );
      case DiaryWorld.cosmic:
        return CosmicWorldBackground(
          accentColor: accentColor,
          scene: scene,
          child: child,
        );
    }
  }
}

/// ═════════════════════════════════════════════════════════════════
/// ⚪ SIMPLE WORLD BACKGROUND
///
/// A clean, minimal background for users who prefer focus.
/// ═════════════════════════════════════════════════════════════════

class _SimpleWorldBackground extends StatelessWidget {
  final DiaryScene scene;
  final Widget child;

  const _SimpleWorldBackground({
    required this.scene,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: child,
    );
  }
}
