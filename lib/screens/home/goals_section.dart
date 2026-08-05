import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/goal.dart';
import '../../theme/app_theme.dart';
import '../../backgrounds/diary_world/diary_world.dart';

import 'widgets/goal_card.dart';

class GoalsSection extends StatelessWidget {
  final List<Goal> goals;
  final DateTime selectedDay;
  final VoidCallback refreshCallback;

  const GoalsSection({
    super.key,
    required this.goals,
    required this.selectedDay,
    required this.refreshCallback,
  });

  // ═══════════════════════════════════════════════════════════════
  // 📅 DATE HELPERS
  // ═══════════════════════════════════════════════════════════════

  DateTime _normalize(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎯 GOALS SECTION
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return const SizedBox.shrink();
    }

    // ============================================================
    // APP THEME
    // ============================================================

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final primary = colors.primary;

    final isDark =
        theme.brightness == Brightness.dark;

    // ============================================================
    // DIARY WORLD
    // ============================================================

    final themeProvider =
    context.watch<ThemeProvider>();

    final selectedWorld =
        themeProvider.diaryWorld;

    final worldEnabled =
        selectedWorld != DiaryWorld.simple;

    final isCosmic =
        selectedWorld == DiaryWorld.cosmicUniverse;

    final isCosmicDark =
        isCosmic && isDark;

    final isCosmicLight =
        isCosmic && !isDark;

    final selected =
    _normalize(selectedDay);

    // ============================================================
    // ACTIVE GOALS
    // ============================================================

    final visibleGoals =
    goals.where((goal) {
      if (goal.startDate == null) {
        return true;
      }

      final start =
      _normalize(goal.startDate!);

      if (selected.isBefore(start)) {
        return false;
      }

      if (goal.deadline != null) {
        final end =
        _normalize(goal.deadline!);

        if (selected.isAfter(end)) {
          return false;
        }
      }

      return true;
    }).toList();

    if (visibleGoals.isEmpty) {
      return const SizedBox.shrink();
    }

    // ============================================================
    // HEADER TEXT COLOR
    // ============================================================

    final Color headerColor;

    if (isCosmicDark) {
      headerColor = Colors.white;
    } else if (isCosmicLight) {
      // Dark readable text over daytime Cosmic artwork.
      headerColor = colors.onSurface;
    } else {
      headerColor = colors.onSurface;
    }

    // ============================================================
    // BUILD
    // ============================================================

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,

      children: [
        // ========================================================
        // 🎯 SECTION HEADER
        // ========================================================

        Row(
          children: [
            // ----------------------------------------------------
            // WORLD ACCENT DOT
            //
            // Show for any visual Diary World.
            // Theme-less remains clean.
            // ----------------------------------------------------

            if (worldEnabled) ...[
              Container(
                width: 5,
                height: 5,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary,

                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(
                        isCosmicDark
                            ? 0.75
                            : 0.35,
                      ),
                      blurRadius:
                      isCosmicDark ? 7 : 4,
                      spreadRadius:
                      isCosmicDark ? 1 : 0,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
            ],

            Text(
              'Goals',

              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: headerColor,

                // Dark Cosmic gets a tiny readability shadow.
                shadows: isCosmicDark
                    ? [
                  Shadow(
                    color: Colors.black
                        .withOpacity(0.55),
                    blurRadius: 5,
                  ),
                ]
                    : null,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // ========================================================
        // 🎯 GOAL CARDS
        // ========================================================

        ListView.builder(
          shrinkWrap: true,
          physics:
          const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,

          itemCount:
          visibleGoals.length,

          itemBuilder:
              (context, index) {
            return GoalCard(
              goal:
              visibleGoals[index],

              selectedDay:
              selectedDay,

              refreshCallback:
              refreshCallback,
            );
          },
        ),

        const SizedBox(height: 4),
      ],
    );
  }
}