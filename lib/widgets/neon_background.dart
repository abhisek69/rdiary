import 'package:flutter/material.dart';

class NeonBackground extends StatelessWidget {
  const NeonBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -60,
            child: _neonCircle(
              color: colors.primary.withOpacity(isDark ? 0.4 : 0.25),
              size: 250,
            ),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: _neonCircle(
              color: colors.secondary.withOpacity(isDark ? 0.3 : 0.2),
              size: 300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _neonCircle({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
