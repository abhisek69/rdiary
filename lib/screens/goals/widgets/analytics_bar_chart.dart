import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsBarChart extends StatefulWidget {
  final bool isWeekly;
  final List<QueryDocumentSnapshot> goals;

  const AnalyticsBarChart({
    super.key,
    required this.isWeekly,
    required this.goals,
  });

  @override
  State<AnalyticsBarChart> createState() => _AnalyticsBarChartState();
}

class _AnalyticsBarChartState extends State<AnalyticsBarChart> {
  DateTime _selectedMonth = DateTime.now();

  DateTime _normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final now = DateTime.now();

    final referenceDate = widget.isWeekly ? now : _selectedMonth;

    List<int> data = List.filled(widget.isWeekly ? 7 : 5, 0);

    final startOfWeek = referenceDate.subtract(
      Duration(days: referenceDate.weekday - 1),
    );

    for (var doc in widget.goals) {
      final map = doc.data() as Map<String, dynamic>;

      final completed = List<String>.from(map['completedDates'] ?? []);

      for (var dateString in completed) {
        final date = _normalize(DateFormat('yyyy-MM-dd').parse(dateString));

        if (widget.isWeekly) {
          for (int i = 0; i < 7; i++) {
            final checkDate = _normalize(startOfWeek.add(Duration(days: i)));

            if (date == checkDate) {
              data[i]++;
            }
          }
        } else {
          if (date.year == _selectedMonth.year &&
              date.month == _selectedMonth.month) {
            int weekIndex = ((date.day - 1) ~/ 7);
            if (weekIndex < 5) {
              data[weekIndex]++;
            }
          }
        }
      }
    }

    final labels =
        widget.isWeekly
            ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
            : ['W1', 'W2', 'W3', 'W4', 'W5'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔥 MONTH SELECTOR (only for monthly)
        if (!widget.isWeekly)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat.yMMMM().format(_selectedMonth),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        _selectedMonth = DateTime(
                          _selectedMonth.year,
                          _selectedMonth.month - 1,
                        );
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _selectedMonth = DateTime(
                          _selectedMonth.year,
                          _selectedMonth.month + 1,
                        );
                      });
                    },
                  ),
                ],
              ),
            ],
          ),

        const SizedBox(height: 20),

        /// 🔥 HORIZONTAL BAR CHART
        SizedBox(
          height: 260,
          child: Row(
            children: [
              /// 🔹 LEFT SIDE LABELS (Mon, Tue, etc.)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    labels.map((e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(e, style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
              ),

              const SizedBox(width: 12),

              /// 🔹 HORIZONTAL BARS
              Expanded(
                child: RotatedBox(
                  quarterTurns: 1,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: const FlTitlesData(
                        leftTitles: AxisTitles(),
                        rightTitles: AxisTitles(),
                        topTitles: AxisTitles(),
                        bottomTitles: AxisTitles(),
                      ),
                      barGroups: List.generate(
                        data.length,
                        (i) => BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: data[i].toDouble(),
                              width: 18,
                              borderRadius: BorderRadius.circular(8),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                      maxY:
                          (data.isEmpty
                                  ? 5
                                  : data.reduce((a, b) => a > b ? a : b) + 1)
                              .toDouble(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
