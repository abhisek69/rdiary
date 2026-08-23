import 'dart:ui';

import 'package:flutter/material.dart';

import '../../backgrounds/diary_world/diary_world.dart';
import '../../theme/app_theme.dart';
import '../../widgets/diary_calendar.dart';

import 'package:provider/provider.dart';

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
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // APP THEME
    // ============================================================

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final primary = colors.primary;
    final isDark = theme.brightness == Brightness.dark;

    // ============================================================
    // DIARY WORLD
    // ============================================================

    final themeProvider = context.watch<ThemeProvider>();
    final selectedWorld = themeProvider.diaryWorld;

    final worldEnabled = selectedWorld != DiaryWorld.simple;

    final isCosmic =
        selectedWorld == DiaryWorld.cosmicUniverse;

    final isCosmicDark =
        isCosmic && isDark;

    final isCosmicLight =
        isCosmic && !isDark;

    // ============================================================
    // SURFACE STYLE
    // ============================================================

    Color panelColor;

    if (isCosmicDark) {
      panelColor = Colors.black.withOpacity(0.48);
    } else if (isCosmicLight) {
      // MUCH more transparent.
      panelColor = Colors.white.withOpacity(0.42);
    } else {
      panelColor = colors.surface;
    }
    // ============================================================
    // BORDER
    // ============================================================

    final borderColor = worldEnabled
        ? primary.withOpacity(
      isDark ? 0.72 : 0.48,
    )
        : primary.withOpacity(0.40);

    // ============================================================
    // SHADOW / WORLD GLOW
    // ============================================================

    List<BoxShadow>? shadows;

    if (isCosmicDark) {
      shadows = [
        BoxShadow(
          color: primary.withOpacity(0.22),
          blurRadius: 30,
          spreadRadius: 1,
        ),
      ];
    } else if (isCosmicLight) {
      shadows = [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
        BoxShadow(
          color: primary.withOpacity(0.08),
          blurRadius: 10,
        ),
      ];
    }
     else {
      shadows = [
        BoxShadow(
          color: Colors.black.withOpacity(
            isDark ? 0.15 : 0.05,
          ),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        12,
        12,
        0,
      ),

      // ==========================================================
      // CLIP FIRST SO BACKDROP BLUR STAYS INSIDE THE CARD
      // ==========================================================

      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),

        child: BackdropFilter(
          // Only meaningful for environmental worlds.
          //
          // Light Cosmic gets a little more blur because the
          // daytime artwork contains more visible detail.
          filter: ImageFilter.blur(
            sigmaX: worldEnabled
                ? (isCosmicLight ? 3 : 7)
                : 0,
            sigmaY: worldEnabled
                ? (isCosmicLight ? 3 : 7)
                : 0,
          ),

          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 300,
            ),
            curve: Curves.easeInOut,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),

              // ==================================================
              // FROSTED SURFACE
              // ==================================================

              color: panelColor,

              // ==================================================
              // ACCENT BORDER
              // ==================================================

              border: Border.all(
                color: borderColor,
                width: worldEnabled ? 1.2 : 1,
              ),

              // ==================================================
              // SHADOW / COSMIC GLOW
              // ==================================================

              boxShadow: shadows,
            ),

            child: Padding(
              padding: const EdgeInsets.all(14),

              child: Column(
                children: [
                  // ==============================================
                  // HEADER
                  // ==============================================

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
                            // ====================================
                            // CALENDAR ICON
                            // ====================================

                            Container(
                              width: 34,
                              height: 34,

                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(9),

                                color: primary.withOpacity(
                                  isCosmicDark
                                      ? 0.15
                                      : 0.10,
                                ),

                                border: isCosmicLight
                                    ? Border.all(
                                  color: primary.withOpacity(
                                    0.12,
                                  ),
                                )
                                    : null,

                                boxShadow: isCosmicDark
                                    ? [
                                  BoxShadow(
                                    color:
                                    primary.withOpacity(
                                      0.22,
                                    ),
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

                            // ====================================
                            // TITLE
                            // ====================================

                            Text(
                              'Your Journal',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,

                                color: isCosmicDark
                                    ? Colors.white
                                    : isCosmicLight
                                    ? colors.onSurface
                                    : colors.onSurface,

                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),

                        // ========================================
                        // COLLAPSE BUTTON
                        // ========================================

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

                  // ==============================================
                  // CALENDAR
                  // ==============================================

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
                          selectedDay: widget.selectedDay,
                          focusedDay: widget.focusedDay,
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
      ),
    );
  }
}