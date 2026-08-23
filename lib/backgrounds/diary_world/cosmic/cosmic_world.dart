import 'package:flutter/material.dart';

import '../diary_world.dart';
import 'cosmic_config.dart';
import 'cosmic_base_painter.dart';

/// ═════════════════════════════════════════════════════════════════
/// 🌌 COSMIC UNIVERSE WORLD
///
/// One world with two appearances:
///
///   🌙 Dark Cosmic
///   ☀️ Light Cosmic
///
/// DARK:
/// - Uses original dark artwork
/// - Keeps readability gradient
/// - Keeps procedural cosmic effects
///
/// LIGHT:
/// - Uses dedicated *_light.webp artwork
/// - NO ColorFilter
/// - NO white readability overlay
/// - NO procedural effects
///
/// Light artwork therefore keeps its original colors,
/// contrast and brightness.
/// ═════════════════════════════════════════════════════════════════

class CosmicWorldBackground extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final DiaryScene scene;
  final Brightness brightness;

  const CosmicWorldBackground({
    super.key,
    required this.child,
    required this.accentColor,
    required this.scene,
    required this.brightness,
  });

  // ═══════════════════════════════════════════════════════════════
  // 🌗 APPEARANCE
  // ═══════════════════════════════════════════════════════════════

  bool get _isDark => brightness == Brightness.dark;

  bool get _isLight => brightness == Brightness.light;

  // ═══════════════════════════════════════════════════════════════
  // 🖼️ SCENE ARTWORK
  //
  // Dark:
  // cosmic_home.webp
  //
  // Light:
  // cosmic_home_light.webp
  //
  // Same structure applies to Notes and Goals.
  // ═══════════════════════════════════════════════════════════════

  String _backgroundForScene() {
    final suffix = _isLight ? '_light' : '';

    switch (scene) {
      case DiaryScene.home:
        return 'assets/backgrounds/cosmic/cosmic_home$suffix.webp';

      case DiaryScene.notes:
        return 'assets/backgrounds/cosmic/cosmic_notes$suffix.webp';

      case DiaryScene.goals:
        return 'assets/backgrounds/cosmic/cosmic_goals$suffix.webp';
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🖼️ BACKGROUND ARTWORK
  //
  // IMPORTANT:
  //
  // Dedicated light artwork already contains the correct daytime
  // atmosphere.
  //
  // DO NOT:
  // - brighten it
  // - whiten it
  // - tint it
  // - ColorFilter it
  //
  // Display the actual asset.
  // ═══════════════════════════════════════════════════════════════

  Widget _buildBackgroundArtwork(
      String backgroundAsset,
      ) {
    return Image.asset(
      backgroundAsset,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      filterQuality: FilterQuality.high,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🌙 DARK READABILITY LAYER
  //
  // Only Dark Cosmic needs this treatment.
  //
  // Light Cosmic uses local glass cards for readability instead
  // of destroying the brightness/contrast of the whole artwork.
  // ═══════════════════════════════════════════════════════════════

  Widget _buildReadabilityLayer() {
    // ------------------------------------------------------------
    // ☀️ LIGHT COSMIC
    // ------------------------------------------------------------

    if (_isLight) {
      return const SizedBox.expand();
    }

    // ------------------------------------------------------------
    // 🌙 DARK COSMIC
    // ------------------------------------------------------------

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.03),
            Colors.black.withOpacity(0.08),
            Colors.black.withOpacity(0.14),
          ],
          stops: const [
            0.0,
            0.55,
            1.0,
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ✨ DYNAMIC COSMIC EFFECTS
  //
  // Dark Cosmic:
  // Procedural stars/dust/rays remain enabled.
  //
  // Light Cosmic:
  // Disabled because the dedicated artwork already contains its
  // own stars, planets, atmospheric lighting and celestial detail.
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDynamicEffects(
      CosmicSceneConfig config,
      ) {
    // ------------------------------------------------------------
    // ☀️ LIGHT COSMIC
    // ------------------------------------------------------------

    if (_isLight) {
      return const SizedBox.expand();
    }

    // ------------------------------------------------------------
    // 🌙 DARK COSMIC
    // ------------------------------------------------------------

    return IgnorePointer(
      child: CustomPaint(
        painter: CosmicBasePainter(
          config: config,
          accentColor: accentColor,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🌌 BUILD WORLD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final config = cosmicConfigFor(scene);

    final backgroundAsset = _backgroundForScene();

    return Stack(
      fit: StackFit.expand,
      children: [
        // ========================================================
        // 1️⃣ ORIGINAL WORLD ARTWORK
        //
        // Light and Dark assets are rendered directly.
        // ========================================================

        _buildBackgroundArtwork(
          backgroundAsset,
        ),

        // ========================================================
        // 2️⃣ READABILITY TREATMENT
        //
        // Dark → subtle black gradient
        // Light → NOTHING
        // ========================================================

        _buildReadabilityLayer(),

        // ========================================================
        // 3️⃣ PROCEDURAL COSMIC ENERGY
        //
        // Dark → enabled
        // Light → disabled
        // ========================================================

        _buildDynamicEffects(
          config,
        ),

        // ========================================================
        // 4️⃣ APPLICATION UI
        // ========================================================

        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}