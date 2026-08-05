import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../models/goal.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final DateTime selectedDay;
  final VoidCallback refreshCallback;

  const GoalCard({
    super.key,
    required this.goal,
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
  // 🗑️ DELETE GOAL
  // ═══════════════════════════════════════════════════════════════

  Future<void> _deleteGoal(
    BuildContext context,
    Goal goal,
  ) async {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF101016) : theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isDark ? BorderSide(color: primary.withOpacity(0.35)) : BorderSide.none,
          ),
          title: Text(
            'Delete Goal?',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this goal?',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.70),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: primary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('goals')
        .doc(goal.id)
        .delete();

    refreshCallback();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;

    final isDark = theme.brightness == Brightness.dark;

    final selected = _normalize(selectedDay);

    final dateKey = DateFormat('yyyy-MM-dd').format(selected);

    final isCompleted = goal.completedDates.contains(dateKey);

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _deleteGoal(context, goal);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          // ─────────────────────────────────────────────────────
          // COSMIC GLASS
          // ─────────────────────────────────────────────────────
          color: isDark ? Colors.black.withOpacity(isCompleted ? 0.28 : 0.40) : surface,
          // ─────────────────────────────────────────────────────
          // ACCENT BORDER
          // ─────────────────────────────────────────────────────
          border: Border.all(
            color: primary.withOpacity(
              isCompleted
                  ? 0.30
                  : isDark
                      ? 0.68
                      : 0.80,
            ),
            width: isDark ? 1.15 : 1.5,
          ),
          // ─────────────────────────────────────────────────────
          // SOFT COSMIC GLOW
          // ─────────────────────────────────────────────────────
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(
                isCompleted
                    ? 0.07
                    : isDark
                        ? 0.16
                        : 0.25,
              ),
              blurRadius: isDark ? 18 : 12,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 13,
          ),
          child: Row(
            children: [
              // ═════════════════════════════════════════════════
              // ☑️ COMPLETION CHECKBOX
              // ═════════════════════════════════════════════════
              Transform.scale(
                scale: 1.02,
                child: Checkbox(
                  value: isCompleted,
                  activeColor: primary,
                  checkColor: Colors.white,
                  side: BorderSide(
                    color: primary.withOpacity(
                      isCompleted ? 0.55 : 0.95,
                    ),
                    width: 1.5,
                  ),
                  onChanged: (value) async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    final updatedDates = List<String>.from(goal.completedDates);

                    if (value == true) {
                      if (!updatedDates.contains(dateKey)) {
                        updatedDates.add(dateKey);
                      }
                    } else {
                      updatedDates.remove(dateKey);
                    }

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('goals')
                        .doc(goal.id)
                        .update({
                      'completedDates': updatedDates,
                    });

                    refreshCallback();
                  },
                ),
              ),

              const SizedBox(width: 12),

              // ═════════════════════════════════════════════════
              // 🎯 GOAL TITLE
              // ═════════════════════════════════════════════════
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 280),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? onSurface.withOpacity(0.42)
                        : isDark
                            ? Colors.white.withOpacity(0.92)
                            : onSurface,
                    decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                    decorationColor: primary.withOpacity(0.55),
                  ),
                  child: Text(goal.title),
                ),
              ),

              // ═════════════════════════════════════════════════
              // ✨ COMPLETED INDICATOR
              // ═════════════════════════════════════════════════
              if (isCompleted) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 15,
                  color: primary.withOpacity(0.65),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
