import 'package:flutter/material.dart';

import '../diary_world.dart';
import 'cosmic_config.dart';
import 'cosmic_base_painter.dart';

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

  String _backgroundForScene() {
    switch (scene) {
      case DiaryScene.home:
        return 'assets/backgrounds/cosmic/cosmic_home.webp';

      case DiaryScene.notes:
        return 'assets/backgrounds/cosmic/cosmic_notes.webp';

      case DiaryScene.goals:
        return 'assets/backgrounds/cosmic/cosmic_goals.webp';

      default:
        return 'assets/backgrounds/cosmic/cosmic_home.webp';
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = cosmicConfigFor(scene);
    final backgroundAsset = _backgroundForScene();

    return Stack(
      fit: StackFit.expand,
      children: [

        // =========================================================
        // 1. STATIC REALISTIC COSMIC SCENE
        // =========================================================
        Image.asset(
          backgroundAsset,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          filterQuality: FilterQuality.high,
        ),

        // =========================================================
        // 2. READABILITY LAYER
        // Keeps UI readable without destroying background details.
        // =========================================================
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(.03),
                Colors.black.withOpacity(.08),
                Colors.black.withOpacity(.14),
              ],
              stops: const [
                0.0,
                0.55,
                1.0,
              ],
            ),
          ),
        ),

        // =========================================================
        // 3. DYNAMIC COSMIC ENERGY
        // Accent color affects stars/dust/rays/etc.
        // Static artwork itself remains untouched.
        // =========================================================
        IgnorePointer(
          child: CustomPaint(
            painter: CosmicBasePainter(
              config: config,
              accentColor: accentColor,
            ),
          ),
        ),

        // =========================================================
        // 4. ACTUAL APP UI
        // =========================================================
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}