import 'package:flutter/material.dart';

import '../../models/goal.dart';
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

  /// Removes hour/minute/second information so goal comparisons
  /// are based purely on calendar dates.
  DateTime _normalize(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🌌 GOALS SECTION
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    final selected = _normalize(selectedDay);

    // ───────────────────────────────────────────────────────────
    // Only show goals that are active on the selected date.
    // ───────────────────────────────────────────────────────────

    final visibleGoals = goals.where(
      (goal) {
        if (goal.startDate == null) {
          return true;
        }

        final start = _normalize(goal.startDate!);

        // Goal hasn't started yet.
        if (selected.isBefore(start)) {
          return false;
        }

        if (goal.deadline != null) {
          final end = _normalize(goal.deadline!);

          // Goal remains visible ON its deadline.
          // It disappears only after the deadline.
          if (selected.isAfter(end)) {
            return false;
          }
        }

        return true;
      },
    ).toList();

    if (visibleGoals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ═══════════════════════════════════════════════════════
        // 🎯 SECTION HEADER
        // ═══════════════════════════════════════════════════════
        Row(
          children: [
            if (isDark) ...[
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary,
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.75),
                      blurRadius: 7,
                      spreadRadius: 1,
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
                color: isDark ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),

        // Much tighter than before.
        const SizedBox(height: 8),

        // ═══════════════════════════════════════════════════════
        // GOAL CARDS
        // ═══════════════════════════════════════════════════════
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: visibleGoals.length,
          itemBuilder: (context, index) {
            return GoalCard(
              goal: visibleGoals[index],
              selectedDay: selectedDay,
              refreshCallback: refreshCallback,
            );
          },
        ),

        // Small breathing room before Notes.
        const SizedBox(height: 4),
      ],
    );
  }
}
