import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/goal.dart';

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

  /// DELETE GOAL
  Future<void> _deleteGoal(
      BuildContext context,
      Goal goal,
      ) async {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Delete Goal?",
            style: TextStyle(
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this goal?\nThis action cannot be undone.",
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: theme.colorScheme.primary,
                ),
              ),
              onPressed: () =>
                  Navigator.pop(context, false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                theme.colorScheme.primary,
                foregroundColor:
                theme.colorScheme.onPrimary,
              ),
              child: const Text("Delete"),
              onPressed: () =>
                  Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('goals')
          .doc(goal.id)
          .delete();

      refreshCallback();
    }
  }

  Widget _buildGoalCard(
      BuildContext context,
      Goal goal,
      ) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;

    final dateKey =
    DateFormat('yyyy-MM-dd').format(selectedDay);

    final isCompleted =
    goal.completedDates.contains(dateKey);

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _deleteGoal(context, goal);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
            primary.withOpacity(isCompleted ? 0.4 : 0.8),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: primary
                  .withOpacity(isCompleted ? 0.15 : 0.3),
              blurRadius: 12,
            ),
          ],
          color: surface, // 🔥 theme adaptive
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [

              /// Checkbox
              Transform.scale(
                scale: 1.1,
                child: Checkbox(
                  value: isCompleted,
                  activeColor: primary,
                  side: BorderSide(
                    color: primary,
                    width: 1.5,
                  ),
                  onChanged: (val) async {
                    final user =
                        FirebaseAuth.instance.currentUser;

                    final updatedDates =
                    List<String>.from(
                        goal.completedDates);

                    if (val == true) {
                      updatedDates.add(dateKey);
                    } else {
                      updatedDates.remove(dateKey);
                    }

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .collection('goals')
                        .doc(goal.id)
                        .update({
                      'completedDates': updatedDates,
                    });

                    refreshCallback();
                  },
                ),
              ),

              const SizedBox(width: 16),

              /// Goal Text
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration:
                  const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? onSurface.withOpacity(0.5)
                        : onSurface,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                  child: Text(goal.title),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          "Goals",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color:
            Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 12),

        ListView.builder(
          shrinkWrap: true,
          physics:
          const NeverScrollableScrollPhysics(),
          itemCount: goals.length,
          itemBuilder: (_, i) {
            return _buildGoalCard(
              context,
              goals[i],
            );
          },
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
