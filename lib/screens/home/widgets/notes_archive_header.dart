import 'package:flutter/material.dart';

class NotesArchiveHeader extends StatelessWidget {
  final Color primary;

  const NotesArchiveHeader({
    super.key,
    required this.primary,
  });

  Widget _star(
    Color color,
    double size,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.8),
            blurRadius: 7,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          // 🌌 Glass effect
          color: isDark
              ? Colors.black.withOpacity(0.38)
              : theme.colorScheme.surface,
          border: Border.all(
            color: primary.withOpacity(0.32),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(
                isDark ? 0.15 : 0.08,
              ),
              blurRadius: 25,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ═══════════════════════════════════════════════════
            // 🌈 SOFT COSMIC GLOW
            // ═══════════════════════════════════════════════════
            if (isDark)
              Positioned(
                right: -15,
                top: -25,
                child: Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primary.withOpacity(0.28),
                        primary.withOpacity(0.07),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

            // ═══════════════════════════════════════════════════
            // ✨ DECORATIVE STARS
            // ═══════════════════════════════════════════════════
            if (isDark) ...[
              Positioned(
                right: 5,
                top: 4,
                child: _star(primary, 5),
              ),
              Positioned(
                right: 31,
                top: 27,
                child: _star(Colors.white, 3),
              ),
              Positioned(
                right: 10,
                bottom: 4,
                child: _star(primary.withOpacity(0.8), 3),
              ),
            ],

            // ═══════════════════════════════════════════════════
            // 📖 HEADER CONTENT
            // ═══════════════════════════════════════════════════
            Row(
              children: [
                // ───────────────────────────────────────────────
                // 📖 Glowing diary icon
                // ───────────────────────────────────────────────
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withOpacity(0.12),
                    border: Border.all(
                      color: primary.withOpacity(0.55),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.28),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: primary,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 14),

                // ───────────────────────────────────────────────
                // TEXT
                // ───────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Memory Archive',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                          color: isDark ? Colors.white : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Every moment becomes part of your universe.',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          color: isDark
                              ? Colors.white.withOpacity(0.60)
                              : theme.colorScheme.onSurface.withOpacity(0.60),
                        ),
                      ),
                    ],
                  ),
                ),

                // Leave some room for stars.
                if (isDark) const SizedBox(width: 22),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
