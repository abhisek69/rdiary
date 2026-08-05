import 'dart:ui';

import 'package:flutter/material.dart';

class NotesArchiveHeader extends StatelessWidget {
  final Color primary;

  const NotesArchiveHeader({
    super.key,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: isDark ? 5 : 4,
            sigmaY: isDark ? 5 : 4,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),

              // 🌙 / ☀️ Adaptive glass
              color: isDark
                  ? Colors.black.withOpacity(0.48)
                  : Colors.white.withOpacity(0.46),

              border: Border.all(
                color: primary.withOpacity(
                  isDark ? 0.72 : 0.60,
                ),
                width: 1.3,
              ),

              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(
                    isDark ? 0.15 : 0.10,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Row(
              children: [
                // ═══════════════════════════════════════════════
                // 📖 ICON
                // ═══════════════════════════════════════════════

                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    color: primary.withOpacity(
                      isDark ? 0.16 : 0.12,
                    ),

                    border: Border.all(
                      color: primary.withOpacity(
                        isDark ? 0.80 : 0.70,
                      ),
                      width: 1.4,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(
                          isDark ? 0.24 : 0.15,
                        ),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: primary,
                    size: 25,
                  ),
                ),

                const SizedBox(width: 14),

                // ═══════════════════════════════════════════════
                // TEXT
                // ═══════════════════════════════════════════════

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Memory Archive',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Every moment becomes part of your universe.',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.25,
                          color: isDark
                              ? Colors.white.withOpacity(0.65)
                              : theme.colorScheme.onSurface
                              .withOpacity(0.68),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}