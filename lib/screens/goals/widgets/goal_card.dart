import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'weekly_goal_circles.dart';
import 'behavior_graph.dart';

class GoalCard extends StatelessWidget {
  final String title;
  final List<String> goalDays;
  final List<String> completedDates;
  final DateTime? startDate;
  final DateTime? deadline;

  const GoalCard({
    super.key,
    required this.title,
    required this.goalDays,
    required this.completedDates,
    this.startDate,
    this.deadline,
  });

  /// Convert weekday int to short name
  String _weekdayToString(int weekday) {
    const days = [
      "Mon","Tue","Wed","Thu","Fri","Sat","Sun"
    ];
    return days[weekday - 1];
  }

  int _calculateTotalScheduledDays() {
    if (startDate == null || deadline == null) return 0;

    final start = DateTime(
      startDate!.year,
      startDate!.month,
      startDate!.day,
    );

    final end = DateTime(
      deadline!.year,
      deadline!.month,
      deadline!.day,
    );

    if (end.isBefore(start)) return 0;

    int total = 0;

    for (
    DateTime day = start;
    !day.isAfter(end);
    day = day.add(const Duration(days: 1))
    ) {
      final dayName = _weekdayToString(day.weekday);

      if (goalDays.contains(dayName)) {
        total++;
      }
    }

    return total;
  }




  /// Calculate completed within range
  int _calculateCompletedInRange() {
    if (startDate == null || deadline == null) return 0;

    final start = DateTime(
      startDate!.year,
      startDate!.month,
      startDate!.day,
    );

    final end = DateTime(
      deadline!.year,
      deadline!.month,
      deadline!.day,
    );

    return completedDates.where((dateString) {
      final date = DateFormat('yyyy-MM-dd').parse(dateString);

      final normalized = DateTime(
        date.year,
        date.month,
        date.day,
      );

      return !normalized.isBefore(start) &&
          !normalized.isAfter(end);
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final totalScheduled =
    _calculateTotalScheduledDays();

    final completed =
    _calculateCompletedInRange();

    final remaining = totalScheduled > completed
        ? totalScheduled - completed
        : 0;

    double percentage =
    totalScheduled == 0
        ? 0
        : completed / totalScheduled;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: colors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          /// TITLE + %
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "${(percentage * 100).toInt()}%",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: percentage >= 0.7
                      ? Colors.green
                      : colors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// DATE RANGE
          if (startDate != null &&
              deadline != null)
            Text(
              "${DateFormat.yMMMd().format(startDate!)}  →  ${DateFormat.yMMMd().format(deadline!)}",
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurface
                    .withOpacity(0.6),
              ),
            ),

          const SizedBox(height: 12),

          /// STATS
          Row(
            children: [
              _statChip(
                context,
                label: "Total",
                value: totalScheduled,
                color: colors.primary,
              ),
              const SizedBox(width: 8),
              _statChip(
                context,
                label: "Done",
                value: completed,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              _statChip(
                context,
                label: "Left",
                value: remaining,
                color: Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 18),

          WeeklyGoalCircles(
            goalDays: goalDays,
            completedDates: completedDates,
            startDate: startDate,
            deadline: deadline,
          ),


          const SizedBox(height: 20),

          BehaviorGraph(
            goalDays: goalDays,
            completedDates: completedDates,
            startDate: startDate,
            deadline: deadline,
          ),
        ],
      ),
    );
  }

  Widget _statChip(
      BuildContext context, {
        required String label,
        required int value,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius:
        BorderRadius.circular(12),
      ),
      child: Text(
        "$label: $value",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
