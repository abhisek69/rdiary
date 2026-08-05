import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'diary_world.dart';

/// ═════════════════════════════════════════════════════════════════
/// 🌌 COSMIC WORLD BACKGROUND
/// ═════════════════════════════════════════════════════════════════

class CosmicWorldBackground extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final DiaryScene scene;

  const CosmicWorldBackground({
    super.key,
    required this.child,
    required this.accentColor,
    required this.scene,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ═══════════════════════════════════════════════════════
        // 🌑 DEEP SPACE
        // ═══════════════════════════════════════════════════════

        const Positioned.fill(
          child: ColoredBox(
            color: Color(0xFF020205),
          ),
        ),

        // ═══════════════════════════════════════════════════════
        // 🌌 UNIVERSE
        // ═══════════════════════════════════════════════════════

        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _CosmicPainter(
                accentColor: accentColor,
                scene: scene,
              ),
            ),
          ),
        ),

        // ═══════════════════════════════════════════════════════
        // 🌑 READABILITY GRADIENT
        // ═══════════════════════════════════════════════════════

        const Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black12,
                    Color(0x44000000),
                  ],
                  stops: [
                    0.0,
                    0.55,
                    1.0,
                  ],
                ),
              ),
            ),
          ),
        ),

        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// 🌌 COSMIC PAINTER
// ═════════════════════════════════════════════════════════════════

class _CosmicPainter extends CustomPainter {
  final Color accentColor;
  final DiaryScene scene;

  _CosmicPainter({
    required this.accentColor,
    required this.scene,
  });

  // ═══════════════════════════════════════════════════════════════
  // 🎲 UNIQUE SCENE SEEDS
  // ═══════════════════════════════════════════════════════════════

  int get _starSeed {
    switch (scene) {
      case DiaryScene.home:
      case DiaryScene.editor:
        return 42;

      case DiaryScene.notes:
      case DiaryScene.viewNote:
        return 927;

      case DiaryScene.goals:
      case DiaryScene.viewGoal:
        return 1643;
    }
  }

  int get _dustSeed {
    switch (scene) {
      case DiaryScene.home:
      case DiaryScene.editor:
        return 731;

      case DiaryScene.notes:
      case DiaryScene.viewNote:
        return 284;

      case DiaryScene.goals:
      case DiaryScene.viewGoal:
        return 1987;
    }
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    _paintNebulaClouds(
      canvas,
      size,
    );

    _paintCosmicDust(
      canvas,
      size,
    );

    _paintStars(
      canvas,
      size,
    );

    _paintPlanet(
      canvas,
      size,
    );

    _paintShootingStar(
      canvas,
      size,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🌌 NEBULA
  // ═══════════════════════════════════════════════════════════════

  void _paintNebulaClouds(
    Canvas canvas,
    Size size,
  ) {
    switch (scene) {
      case DiaryScene.home:
      case DiaryScene.editor:
        _nebula(
          canvas,
          center: Offset(
            size.width * 0.86,
            size.height * 0.13,
          ),
          radius: size.width * 0.62,
          opacity: 0.34,
        );

        _nebula(
          canvas,
          center: Offset(
            size.width * -0.05,
            size.height * 0.46,
          ),
          radius: size.width * 0.58,
          opacity: 0.20,
        );

        _nebula(
          canvas,
          center: Offset(
            size.width * 0.90,
            size.height * 0.72,
          ),
          radius: size.width * 0.68,
          opacity: 0.19,
        );

        _nebula(
          canvas,
          center: Offset(
            size.width * 0.52,
            size.height * 0.32,
          ),
          radius: size.width * 0.38,
          opacity: 0.12,
        );

        _paintNebulaStreak(
          canvas,
          size,
          start: Offset(
            size.width * -0.15,
            size.height * 0.68,
          ),
          control1: Offset(
            size.width * 0.18,
            size.height * 0.53,
          ),
          control2: Offset(
            size.width * 0.60,
            size.height * 0.48,
          ),
          end: Offset(
            size.width * 1.12,
            size.height * 0.30,
          ),
        );
        break;

      case DiaryScene.notes:
      case DiaryScene.viewNote:
        _nebula(
          canvas,
          center: Offset(
            size.width * 0.12,
            size.height * 0.17,
          ),
          radius: size.width * 0.58,
          opacity: 0.29,
        );

        _nebula(
          canvas,
          center: Offset(
            size.width * 0.78,
            size.height * 0.43,
          ),
          radius: size.width * 0.62,
          opacity: 0.22,
        );

        _nebula(
          canvas,
          center: Offset(
            size.width * 0.18,
            size.height * 0.78,
          ),
          radius: size.width * 0.67,
          opacity: 0.17,
        );

        _nebula(
          canvas,
          center: Offset(
            size.width * 0.52,
            size.height * 0.27,
          ),
          radius: size.width * 0.34,
          opacity: 0.11,
        );

        _paintNebulaStreak(
          canvas,
          size,
          start: Offset(
            size.width * 1.15,
            size.height * 0.62,
          ),
          control1: Offset(
            size.width * 0.80,
            size.height * 0.50,
          ),
          control2: Offset(
            size.width * 0.38,
            size.height * 0.42,
          ),
          end: Offset(
            size.width * -0.12,
            size.height * 0.25,
          ),
        );
        break;

      case DiaryScene.goals:
      case DiaryScene.viewGoal:
        _nebula(
          canvas,
          center: Offset(
            size.width * 0.72,
            size.height * 0.20,
          ),
          radius: size.width * 0.55,
          opacity: 0.26,
        );

        _nebula(
          canvas,
          center: Offset(
            size.width * 0.08,
            size.height * 0.38,
          ),
          radius: size.width * 0.54,
          opacity: 0.18,
        );

        _nebula(
          canvas,
          center: Offset(
            size.width * 0.65,
            size.height * 0.72,
          ),
          radius: size.width * 0.72,
          opacity: 0.22,
        );

        _nebula(
          canvas,
          center: Offset(
            size.width * 0.36,
            size.height * 0.52,
          ),
          radius: size.width * 0.32,
          opacity: 0.10,
        );

        _paintNebulaStreak(
          canvas,
          size,
          start: Offset(
            size.width * -0.10,
            size.height * 0.22,
          ),
          control1: Offset(
            size.width * 0.25,
            size.height * 0.34,
          ),
          control2: Offset(
            size.width * 0.65,
            size.height * 0.52,
          ),
          end: Offset(
            size.width * 1.15,
            size.height * 0.72,
          ),
        );
        break;
    }
  }

  void _paintNebulaStreak(
    Canvas canvas,
    Size size, {
    required Offset start,
    required Offset control1,
    required Offset control2,
    required Offset end,
  }) {
    final path = Path()
      ..moveTo(
        start.dx,
        start.dy,
      )
      ..cubicTo(
        control1.dx,
        control1.dy,
        control2.dx,
        control2.dy,
        end.dx,
        end.dy,
      );

    final streakPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.16
      ..strokeCap = StrokeCap.round
      ..color = accentColor.withOpacity(0.055)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        32,
      );

    canvas.drawPath(
      path,
      streakPaint,
    );

    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.035
      ..strokeCap = StrokeCap.round
      ..color = accentColor.withOpacity(0.10)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        18,
      );

    canvas.drawPath(
      path,
      corePaint,
    );
  }

  void _nebula(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required double opacity,
  }) {
    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withOpacity(
            opacity,
          ),
          accentColor.withOpacity(
            opacity * 0.55,
          ),
          accentColor.withOpacity(
            opacity * 0.16,
          ),
          Colors.transparent,
        ],
        stops: const [
          0.0,
          0.28,
          0.58,
          1.0,
        ],
      ).createShader(rect);

    canvas.drawCircle(
      center,
      radius,
      paint,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ✨ COSMIC DUST
  // ═══════════════════════════════════════════════════════════════

  void _paintCosmicDust(
    Canvas canvas,
    Size size,
  ) {
    final random = math.Random(_dustSeed);

    for (int i = 0; i < 90; i++) {
      final progress = random.nextDouble();

      double x;
      double y;

      switch (scene) {
        case DiaryScene.home:
        case DiaryScene.editor:
          x = size.width * progress + random.nextDouble() * 100 - 50;

          y = size.height * (0.65 - progress * 0.32) + random.nextDouble() * 150 - 75;

          break;

        case DiaryScene.notes:
        case DiaryScene.viewNote:
          x = size.width * (1.0 - progress) + random.nextDouble() * 110 - 55;

          y = size.height * (0.22 + progress * 0.48) + random.nextDouble() * 150 - 75;

          break;

        case DiaryScene.goals:
        case DiaryScene.viewGoal:
          x = size.width * progress + random.nextDouble() * 120 - 60;

          y = size.height * (0.20 + progress * 0.58) + random.nextDouble() * 160 - 80;

          break;
      }

      final radius = 0.4 + random.nextDouble() * 1.5;

      final paint = Paint()
        ..color = accentColor.withOpacity(
          0.08 + random.nextDouble() * 0.25,
        );

      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ⭐ STARS
  // ═══════════════════════════════════════════════════════════════

  void _paintStars(
    Canvas canvas,
    Size size,
  ) {
    final random = math.Random(_starSeed);

    for (int i = 0; i < 145; i++) {
      final position = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );

      final radius = 0.35 + random.nextDouble() * 1.15;

      final accentStar = random.nextDouble() > 0.78;

      final opacity = 0.22 + random.nextDouble() * 0.65;

      final color = accentStar
          ? accentColor.withOpacity(
              opacity,
            )
          : Colors.white.withOpacity(
              opacity,
            );

      canvas.drawCircle(
        position,
        radius,
        Paint()..color = color,
      );

      if (radius > 1.15) {
        canvas.drawCircle(
          position,
          radius * 4,
          Paint()
            ..color = color.withOpacity(0.12)
            ..maskFilter = const MaskFilter.blur(
              BlurStyle.normal,
              5,
            ),
        );
      }
    }

    switch (scene) {
      case DiaryScene.home:
      case DiaryScene.editor:
        _brightStar(
          canvas,
          Offset(
            size.width * 0.12,
            size.height * 0.18,
          ),
          3,
        );

        _brightStar(
          canvas,
          Offset(
            size.width * 0.89,
            size.height * 0.29,
          ),
          2.4,
        );

        _brightStar(
          canvas,
          Offset(
            size.width * 0.16,
            size.height * 0.62,
          ),
          2,
        );
        break;

      case DiaryScene.notes:
      case DiaryScene.viewNote:
        _brightStar(
          canvas,
          Offset(
            size.width * 0.84,
            size.height * 0.18,
          ),
          2.8,
        );

        _brightStar(
          canvas,
          Offset(
            size.width * 0.20,
            size.height * 0.36,
          ),
          2.2,
        );

        _brightStar(
          canvas,
          Offset(
            size.width * 0.73,
            size.height * 0.68,
          ),
          2.6,
        );
        break;

      case DiaryScene.goals:
      case DiaryScene.viewGoal:
        _brightStar(
          canvas,
          Offset(
            size.width * 0.22,
            size.height * 0.14,
          ),
          2.5,
        );

        _brightStar(
          canvas,
          Offset(
            size.width * 0.88,
            size.height * 0.46,
          ),
          2.8,
        );

        _brightStar(
          canvas,
          Offset(
            size.width * 0.30,
            size.height * 0.76,
          ),
          2.1,
        );
        break;
    }
  }

  void _brightStar(
    Canvas canvas,
    Offset center,
    double radius,
  ) {
    final glow = Paint()
      ..color = accentColor.withOpacity(0.50)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        9,
      );

    canvas.drawCircle(
      center,
      radius * 3,
      glow,
    );

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(
        center.dx - radius * 2,
        center.dy,
      ),
      Offset(
        center.dx + radius * 2,
        center.dy,
      ),
      paint,
    );

    canvas.drawLine(
      Offset(
        center.dx,
        center.dy - radius * 2,
      ),
      Offset(
        center.dx,
        center.dy + radius * 2,
      ),
      paint,
    );

    canvas.drawCircle(
      center,
      radius * 0.7,
      Paint()..color = Colors.white,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🌙 PLANET POSITION
  // ═══════════════════════════════════════════════════════════════

  void _paintPlanet(
    Canvas canvas,
    Size size,
  ) {
    late Offset center;
    late double radius;

    switch (scene) {
      case DiaryScene.home:
      case DiaryScene.editor:
        center = Offset(
          size.width * 0.79,
          size.height * 0.105,
        );
        radius = size.width * 0.105;
        break;

      case DiaryScene.notes:
      case DiaryScene.viewNote:
        center = Offset(
          size.width * 0.20,
          size.height * 0.145,
        );
        radius = size.width * 0.083;
        break;

      case DiaryScene.goals:
      case DiaryScene.viewGoal:
        center = Offset(
          size.width * 0.84,
          size.height * 0.18,
        );
        radius = size.width * 0.088;
        break;
    }

    canvas.drawCircle(
      center,
      radius * 1.30,
      Paint()
        ..color = accentColor.withOpacity(0.20)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          28,
        ),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = const Color(0xFF020205),
    );

    final crescent = Path();
    crescent.moveTo(
      center.dx,
      center.dy - radius,
    );

    crescent.cubicTo(
      center.dx + radius * 0.65,
      center.dy - radius,
      center.dx + radius,
      center.dy - radius * 0.50,
      center.dx + radius,
      center.dy,
    );

    crescent.cubicTo(
      center.dx + radius,
      center.dy + radius * 0.50,
      center.dx + radius * 0.65,
      center.dy + radius,
      center.dx,
      center.dy + radius,
    );

    crescent.cubicTo(
      center.dx + radius * 0.50,
      center.dy + radius * 0.45,
      center.dx + radius * 0.50,
      center.dy - radius * 0.45,
      center.dx,
      center.dy - radius,
    );

    crescent.close();

    final crescentBounds = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    final crescentPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(
          0.65,
          -0.45,
        ),
        radius: 1.15,
        colors: [
          Colors.white.withOpacity(
            0.98,
          ),
          Color.lerp(
                Colors.white,
                accentColor,
                0.30,
              ) ??
              accentColor,
          accentColor,
          Color.lerp(
                accentColor,
                Colors.black,
                0.18,
              ) ??
              accentColor,
        ],
        stops: const [
          0.0,
          0.20,
          0.58,
          1.0,
        ],
      ).createShader(
        crescentBounds,
      );

    canvas.drawPath(
      crescent,
      Paint()
        ..color = accentColor.withOpacity(0.16)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          12,
        ),
    );

    canvas.drawPath(
      crescent,
      crescentPaint,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ☄️ SHOOTING STAR
  // ═══════════════════════════════════════════════════════════════

  void _paintShootingStar(
    Canvas canvas,
    Size size,
  ) {
    late Offset head;
    late Offset tail;

    switch (scene) {
      case DiaryScene.home:
      case DiaryScene.editor:
        head = Offset(
          size.width * 0.58,
          size.height * 0.13,
        );

        tail = Offset(
          size.width * 0.39,
          size.height * 0.18,
        );

        break;

      case DiaryScene.notes:
      case DiaryScene.viewNote:
        head = Offset(
          size.width * 0.72,
          size.height * 0.24,
        );

        tail = Offset(
          size.width * 0.88,
          size.height * 0.16,
        );

        break;

      case DiaryScene.goals:
      case DiaryScene.viewGoal:
        head = Offset(
          size.width * 0.48,
          size.height * 0.17,
        );

        tail = Offset(
          size.width * 0.23,
          size.height * 0.11,
        );

        break;
    }

    final rect = Rect.fromPoints(
      tail,
      head,
    );

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          accentColor.withOpacity(
            0.35,
          ),
          Colors.white.withOpacity(
            0.95,
          ),
        ],
      ).createShader(rect)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      tail,
      head,
      paint,
    );

    canvas.drawCircle(
      head,
      7,
      Paint()
        ..color = accentColor.withOpacity(
          0.45,
        )
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          8,
        ),
    );

    canvas.drawCircle(
      head,
      1.8,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(
    covariant _CosmicPainter oldDelegate,
  ) {
    return oldDelegate.accentColor != accentColor || oldDelegate.scene != scene;
  }
}
