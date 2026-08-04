import 'package:flutter/material.dart';
import '../models/mood_model.dart';

class MoodSelector extends StatelessWidget {
  final String? selectedMoodId;
  final Function(String?) onSelected;
  final bool showLabel;
  final bool includeAll;

  const MoodSelector({
    super.key,
    required this.selectedMoodId,
    required this.onSelected,
    this.showLabel = true,
    this.includeAll = false,
  });

  // ═══════════════════════════════════════════════════════════════
  // 🎨 MOOD COLORS
  //
  // Mood colors are independent from the user's app primary color.
  //
  // 😊 Happy  → Green
  // 😢 Sad    → Yellow
  // 😡 Anger  → Red
  // 🔥 Flame  → Keep its original MoodData color
  // ✨ Others → White in dark mode
  //
  // IMPORTANT:
  // This only changes how the mood LOOKS.
  // The mood ID saved in Firestore remains exactly the same.
  // ═══════════════════════════════════════════════════════════════

  Color _getMoodColor(
      BuildContext context,
      dynamic mood,
      ) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final id = mood.id.toString().toLowerCase();

    switch (id) {
    // ─────────────────────────────────────────────────────────
    // 😊 HAPPY
    // ─────────────────────────────────────────────────────────
      case 'happy':
        return const Color(0xFF39E75F);

    // ─────────────────────────────────────────────────────────
    // 😢 SAD
    // ─────────────────────────────────────────────────────────
      case 'sad':
        return const Color(0xFFFFD740);

    // ─────────────────────────────────────────────────────────
    // 😡 ANGER
    // Support both possible IDs just in case.
    // ─────────────────────────────────────────────────────────
      case 'anger':
      case 'angry':
        return const Color(0xFFFF3B3B);

    // ─────────────────────────────────────────────────────────
    // 🔥 FLAME
    // Keep the color already defined in MoodData.
    // ─────────────────────────────────────────────────────────
      case 'flame':
      case 'fire':
        return mood.color;

    // ─────────────────────────────────────────────────────────
    // ✨ REMAINING MOODS
    // ─────────────────────────────────────────────────────────
      default:
        return isDark
            ? Colors.white
            : mood.color;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🌈 MOOD SELECTOR
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // ─────────────────────────────────────────────────────
          // 🧩 ALL MOODS
          // ─────────────────────────────────────────────────────

          if (includeAll)
            _buildAllChip(
              context,
              colors,
            ),

          if (includeAll)
            const SizedBox(width: 12),

          // ─────────────────────────────────────────────────────
          // 😊 😢 😡 🔥 INDIVIDUAL MOODS
          // ─────────────────────────────────────────────────────

          ...MoodData.moods.map(
                (mood) {
              final isSelected =
                  mood.id == selectedMoodId;

              final moodColor =
              _getMoodColor(
                context,
                mood,
              );

              return Padding(
                padding:
                const EdgeInsets.only(
                  right: 12,
                ),

                child: GestureDetector(
                  onTap: () {
                    onSelected(mood.id);
                  },

                  child: AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 250,
                    ),

                    curve: Curves.easeOut,

                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),

                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(20),

                      // ═════════════════════════════════════════
                      // GLASS BACKGROUND
                      // ═════════════════════════════════════════

                      color: isSelected
                          ? moodColor.withOpacity(0.15)
                          : isDark
                          ? Colors.black.withOpacity(0.30)
                          : colors.surface.withOpacity(0.50),

                      // ═════════════════════════════════════════
                      // MOOD BORDER
                      // ═════════════════════════════════════════

                      border: Border.all(
                        color: isSelected
                            ? moodColor
                            : isDark
                            ? moodColor.withOpacity(0.25)
                            : Colors.grey.withOpacity(0.20),
                        width: isSelected
                            ? 1.5
                            : 1.0,
                      ),

                      // ═════════════════════════════════════════
                      // ✨ SELECTED MOOD GLOW
                      // ═════════════════════════════════════════

                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: moodColor.withOpacity(0.30),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ]
                          : null,
                    ),

                    child: Row(
                      mainAxisSize:
                      MainAxisSize.min,

                      children: [
                        // ───────────────────────────────────────
                        // MOOD ICON
                        // Bigger than the previous 16px icon.
                        // ───────────────────────────────────────

                        Icon(
                          mood.icon,
                          size: 22,
                          color: moodColor,

                          shadows: isSelected
                              ? [
                            Shadow(
                              color: moodColor.withOpacity(0.60),
                              blurRadius: 8,
                            ),
                          ]
                              : null,
                        ),

                        // ───────────────────────────────────────
                        // MOOD LABEL
                        // ───────────────────────────────────────

                        if (showLabel) ...[
                          const SizedBox(
                            width: 7,
                          ),

                          Text(
                            mood.label,
                            style: TextStyle(
                              color: moodColor,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🧩 ALL MOODS CHIP
  // ═══════════════════════════════════════════════════════════════

  Widget _buildAllChip(
      BuildContext context,
      ColorScheme colors,
      ) {
    final isSelected =
        selectedMoodId == null;

    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    // "All" still follows the user's primary theme color.
    final allColor = colors.primary;

    return GestureDetector(
      onTap: () {
        onSelected(null);
      },

      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 250,
        ),

        curve: Curves.easeOut,

        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),

        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(20),

          color: isSelected
              ? allColor.withOpacity(0.15)
              : isDark
              ? Colors.black.withOpacity(0.30)
              : colors.surface.withOpacity(0.50),

          border: Border.all(
            color: isSelected
                ? allColor
                : Colors.grey.withOpacity(0.20),
            width: isSelected ? 1.5 : 1,
          ),

          boxShadow: isSelected
              ? [
            BoxShadow(
              color: allColor.withOpacity(0.30),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ]
              : null,
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(
              Icons.apps_rounded,
              size: 22,

              color: isSelected
                  ? allColor
                  : isDark
                  ? Colors.white
                  : colors.onSurface.withOpacity(0.70),

              shadows: isSelected
                  ? [
                Shadow(
                  color: allColor.withOpacity(0.60),
                  blurRadius: 8,
                ),
              ]
                  : null,
            ),

            if (showLabel) ...[
              const SizedBox(width: 7),

              Text(
                'All',
                style: TextStyle(
                  color: isSelected
                      ? allColor
                      : isDark
                      ? Colors.white
                      : colors.onSurface.withOpacity(0.70),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}