import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DiaryCalendar extends StatefulWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final void Function(DateTime, DateTime) onDaySelected;

  const DiaryCalendar({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
  });

  @override
  State<DiaryCalendar> createState() => _DiaryCalendarState();
}

class _DiaryCalendarState extends State<DiaryCalendar> {
  late DateTime _currentFocusedDay;
  late int _selectedMonth;
  late int _selectedYear;

  final List<int> years = List.generate(100, (index) => 1980 + index);
  final List<String> months = const [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _currentFocusedDay = widget.focusedDay;
    _selectedMonth = widget.focusedDay.month;
    _selectedYear = widget.focusedDay.year;
  }

  void _updateFocusedDay() {
    setState(() {
      _currentFocusedDay = DateTime(_selectedYear, _selectedMonth);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔽 Month & Year Dropdowns
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
          child: Row(
            children: [
              // Year Dropdown (50% width)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedYear,
                      dropdownColor: Theme.of(context).colorScheme.primary,
                      iconEnabledColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) {
                        if (val != null) {
                          _selectedYear = val;
                          _updateFocusedDay();
                        }
                      },
                      items: years.map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Month Dropdown (50% width)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedMonth,
                      dropdownColor: Theme.of(context).colorScheme.primary,
                      iconEnabledColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) {
                        if (val != null) {
                          _selectedMonth = val;
                          _updateFocusedDay();
                        }
                      },
                      items: List.generate(12, (i) {
                        return DropdownMenuItem(
                          value: i + 1,
                          child: Text(months[i]),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 📆 TableCalendar
        TableCalendar(
          firstDay: DateTime.utc(1980, 1, 1),
          lastDay: DateTime.utc(2099, 12, 31),
          focusedDay: _currentFocusedDay,
          selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
          onDaySelected: (selected, focused) {
            widget.onDaySelected(selected, focused);
          },
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          headerVisible: false, // We are using our own header now
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
          },
        ),
      ],
    );
  }
}
