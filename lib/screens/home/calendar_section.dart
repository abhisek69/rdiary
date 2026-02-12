import 'package:flutter/material.dart';
import '../../widgets/diary_calendar.dart';

class CalendarSection extends StatefulWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Function(DateTime, DateTime) onDaySelected;

  const CalendarSection({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
  });

  @override
  State<CalendarSection> createState() =>
      _CalendarSectionState();
}

class _CalendarSectionState
    extends State<CalendarSection>
    with SingleTickerProviderStateMixin {

  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: primary.withOpacity(0.8),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.25),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
          color: surface,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [

              /// HEADER (Tap to collapse)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          color: primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Your Journal",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),

                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration:
                      const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.expand_more,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),

              /// COLLAPSIBLE CALENDAR
              AnimatedCrossFade(
                duration:
                const Duration(milliseconds: 300),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Column(
                  children: [
                    const SizedBox(height: 12),
                    DiaryCalendar(
                      selectedDay: widget.selectedDay,
                      focusedDay: widget.focusedDay,
                      onDaySelected:
                      widget.onDaySelected,
                    ),
                  ],
                ),
                secondChild: const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
