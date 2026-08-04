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
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        12,
        12,
        0,
      ),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 300,
        ),
        curve: Curves.easeInOut,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),

          // ======================================================
          // GLASS / NORMAL SURFACE
          // ======================================================

          color: isDark
              ? Colors.black.withOpacity(0.48)
              : surface,

          // ======================================================
          // PRIMARY COLOR BORDER
          // ======================================================

          border: Border.all(
            color: isDark
                ? primary.withOpacity(0.75)
                : primary.withOpacity(0.8),
            width: isDark ? 1.2 : 1.5,
          ),

          // ======================================================
          // COSMIC GLOW
          // ======================================================

          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(
                isDark ? 0.22 : 0.25,
              ),
              blurRadius: isDark ? 30 : 25,
              spreadRadius: isDark ? 1 : 2,
            ),
          ],
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),

          child: Padding(
            padding: const EdgeInsets.all(14),

            child: Column(
              children: [
                // ==================================================
                // HEADER
                // ==================================================

                GestureDetector(
                  behavior: HitTestBehavior.opaque,

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
                          // ------------------------------------------
                          // CALENDAR ICON
                          // ------------------------------------------

                          Container(
                            width: 34,
                            height: 34,

                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(9),

                              color: isDark
                                  ? primary.withOpacity(0.15)
                                  : primary.withOpacity(0.10),

                              boxShadow: isDark
                                  ? [
                                BoxShadow(
                                  color: primary
                                      .withOpacity(0.22),
                                  blurRadius: 12,
                                ),
                              ]
                                  : null,
                            ),

                            child: Icon(
                              Icons.calendar_month_rounded,
                              color: primary,
                              size: 20,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Text(
                            'Your Journal',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : primary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),

                      // --------------------------------------------
                      // COLLAPSE BUTTON
                      // --------------------------------------------

                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(
                          milliseconds: 300,
                        ),
                        child: Icon(
                          Icons.expand_more_rounded,
                          color: primary,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),

                // ==================================================
                // CALENDAR
                // ==================================================

                AnimatedCrossFade(
                  duration: const Duration(
                    milliseconds: 300,
                  ),

                  crossFadeState: _isExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,

                  firstChild: Column(
                    children: [
                      const SizedBox(height: 12),

                      DiaryCalendar(
                        selectedDay:
                        widget.selectedDay,
                        focusedDay:
                        widget.focusedDay,
                        onDaySelected:
                        widget.onDaySelected,
                      ),
                    ],
                  ),

                  secondChild:
                  const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
