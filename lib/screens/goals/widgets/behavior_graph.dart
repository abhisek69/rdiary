import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class BehaviorGraph extends StatelessWidget {
  final List<String> goalDays;
  final List<String> completedDates;
  final DateTime? startDate;
  final DateTime? deadline;

  const BehaviorGraph({
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
    final colors = Theme.of(context).colorScheme;
    final now = _normalize(DateTime.now());
    final startOfWeek =
    now.subtract(Duration(days: now.weekday - 1));

    List<double> progress = [];
    double value = 0;

    for (int i = 0; i < 7; i++) {
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

      // 🚫 BEFORE START DATE
      if (startDate != null &&
          dayDate.isBefore(_normalize(startDate!))) {
        progress.add(value);
        continue;
      }

      // 🚫 AFTER DEADLINE
      if (deadline != null &&
          dayDate.isAfter(_normalize(deadline!))) {
        progress.add(value);
        continue;
      }

      if (!isScheduled) {
        progress.add(value);
      }
      else if (isCompleted) {
        value += 1;
        progress.add(value);
      }
      else if (dayDate.isBefore(now)) {
        value -= 1;
        progress.add(value);
      }
      else {
        progress.add(value);
      }
    }

    return SizedBox(
      height: 120,
      child: LineChart(
        LineChartData(
          minY: -7,
          maxY: 7,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(),
            rightTitles: AxisTitles(),
            topTitles: AxisTitles(),
            bottomTitles: AxisTitles(),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                progress.length,
                    (index) => FlSpot(
                  index.toDouble(),
                  progress[index],
                ),
              ),
              isCurved: true,
              color: colors.primary,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: colors.primary.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
