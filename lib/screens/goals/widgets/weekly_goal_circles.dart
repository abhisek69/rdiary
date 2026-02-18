import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyGoalCircles extends StatelessWidget {
  final List<String> goalDays;
  final List<String> completedDates;
  final DateTime? startDate;
  final DateTime? deadline;

  const WeeklyGoalCircles({
    super.key,
    required this.goalDays,
    required this.completedDates,
    this.startDate,
    this.deadline,
  });

  DateTime _normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    final now = _normalize(DateTime.now());
    final startOfWeek =
    now.subtract(Duration(days: now.weekday - 1));

    return Row(
      children: List.generate(7, (i) {
        final dayDate =
        _normalize(startOfWeek.add(Duration(days: i)));

        final dayName =
        DateFormat('EEE').format(dayDate);

        final formattedDate =
        DateFormat('yyyy-MM-dd').format(dayDate);

        final isScheduled =
        goalDays.contains(dayName);

        final isCompleted =
        completedDates.contains(formattedDate);

        Color bgColor;

        // 🚫 BEFORE START DATE
        if (startDate != null &&
            dayDate.isBefore(_normalize(startDate!))) {
          bgColor = Colors.grey.withOpacity(0.2);
        }

        // 🚫 AFTER DEADLINE
        else if (deadline != null &&
            dayDate.isAfter(_normalize(deadline!))) {
          bgColor = Colors.grey.withOpacity(0.2);
        }

        // NOT A SCHEDULED DAY
        else if (!isScheduled) {
          bgColor = Colors.grey.withOpacity(0.2);
        }

        // COMPLETED
        else if (isCompleted) {
          bgColor = Colors.green;
        }

        // FUTURE DAY
        else if (dayDate.isAfter(now)) {
          bgColor = Colors.grey;
        }

        // MISSED
        else {
          bgColor = Colors.red;
        }

        return Expanded(
          child: Center(
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                dayName.substring(0, 1),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
