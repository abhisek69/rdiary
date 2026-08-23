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

  final List<int> years = List.generate(120, (index) => 1980 + index);

  final List<String> months = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();

    _currentFocusedDay = widget.focusedDay;
    _selectedMonth = widget.focusedDay.month;
    _selectedYear = widget.focusedDay.year;
  }

  // ============================================================
  // UPDATE CALENDAR MONTH / YEAR
  // ============================================================

  void _updateFocusedDay() {
    setState(() {
      _currentFocusedDay = DateTime(_selectedYear, _selectedMonth, 1);
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    final textColor =
        isDark ? Colors.white.withOpacity(0.90) : theme.colorScheme.onSurface;

    final mutedTextColor =
        isDark
            ? Colors.white.withOpacity(0.42)
            : theme.colorScheme.onSurface.withOpacity(0.45);

    return Column(
      children: [
        // ======================================================
        // YEAR + MONTH
        // ======================================================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              // ==================================================
              // YEAR
              // ==================================================
              Expanded(
                child: _CosmicDropdown<int>(
                  value: _selectedYear,
                  primary: primary,
                  isDark: isDark,
                  items:
                      years
                          .map(
                            (year) => DropdownMenuItem<int>(
                              value: year,
                              child: Text(year.toString()),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    _selectedYear = value;
                    _updateFocusedDay();
                  },
                ),
              ),

              const SizedBox(width: 10),

              // ==================================================
              // MONTH
              // ==================================================
              Expanded(
                child: _CosmicDropdown<int>(
                  value: _selectedMonth,
                  primary: primary,
                  isDark: isDark,
                  items: List.generate(
                    12,
                    (index) => DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text(
                        months[index],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value == null) return;

                    _selectedMonth = value;
                    _updateFocusedDay();
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ======================================================
        // CALENDAR
        // ======================================================
        TableCalendar(
          firstDay: DateTime.utc(1980, 1, 1),
          lastDay: DateTime.utc(2099, 12, 31),

          focusedDay: _currentFocusedDay,

          headerVisible: false,

          availableCalendarFormats: const {CalendarFormat.month: 'Month'},

          selectedDayPredicate: (day) {
            return isSameDay(widget.selectedDay, day);
          },

          // ====================================================
          // DATE SELECTED
          // ====================================================
          onDaySelected: (selected, focused) {
            setState(() {
              _currentFocusedDay = focused;
              _selectedMonth = focused.month;
              _selectedYear = focused.year;
            });

            widget.onDaySelected(selected, focused);
          },

          // ====================================================
          // WEEKDAY STYLE
          // ====================================================
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: isDark ? primary.withOpacity(0.95) : primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            weekendStyle: TextStyle(
              color: isDark ? primary.withOpacity(0.95) : primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),

          // ====================================================
          // CALENDAR STYLE
          // ====================================================
          calendarStyle: CalendarStyle(
            outsideDaysVisible: true,

            defaultTextStyle: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),

            weekendTextStyle: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),

            outsideTextStyle: TextStyle(color: mutedTextColor),

            // --------------------------------------------------
            // SELECTED DAY
            // --------------------------------------------------
            selectedDecoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary,
              boxShadow:
                  isDark
                      ? [
                        BoxShadow(
                          color: primary.withOpacity(0.75),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: primary.withOpacity(0.30),
                          blurRadius: 28,
                          spreadRadius: 5,
                        ),
                      ]
                      : null,
            ),

            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),

            // --------------------------------------------------
            // TODAY
            // --------------------------------------------------
            todayDecoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isDark
                      ? Colors.white.withOpacity(0.10)
                      : Colors.grey.withOpacity(0.35),

              border: Border.all(color: primary.withOpacity(0.65), width: 1),
            ),

            todayTextStyle: TextStyle(
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),

            cellMargin: const EdgeInsets.all(5),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// COSMIC DROPDOWN
// ============================================================

class _CosmicDropdown<T> extends StatelessWidget {
  final T value;
  final Color primary;
  final bool isDark;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _CosmicDropdown({
    required this.value,
    required this.primary,
    required this.isDark,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),

        // ======================================================
        // DARK MODE
        // ======================================================
        color: isDark ? primary.withOpacity(0.12) : primary,

        border:
            isDark
                ? Border.all(color: primary.withOpacity(0.55), width: 1)
                : null,

        boxShadow:
            isDark
                ? [
                  BoxShadow(
                    color: primary.withOpacity(0.18),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
                : null,
      ),

      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,

          isExpanded: true,

          dropdownColor: isDark ? const Color(0xFF15111D) : primary,

          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark ? primary : Colors.white,
          ),

          style: TextStyle(
            color: isDark ? Colors.white : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),

          items: items,

          onChanged: onChanged,
        ),
      ),
    );
  }
}
