import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../backgrounds/diary_world/diary_world.dart';
import '../../backgrounds/diary_world/diary_world_background.dart';
import '../../theme/app_theme.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  bool _showAllGoals = true;

  // ═══════════════════════════════════════════════════════════════
  // 📅 DATE HELPERS
  // ═══════════════════════════════════════════════════════════════

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime? _timestampToDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎯 GOAL CALCULATIONS
  // ═══════════════════════════════════════════════════════════════

  int _calculateTotalGoalDays({
    required DateTime? startDate,
    required DateTime? deadline,
    required List<String> goalDays,
  }) {
    if (startDate == null || goalDays.isEmpty) {
      return 0;
    }

    final today = _normalizeDate(DateTime.now());
    final start = _normalizeDate(startDate);

    DateTime end =
    deadline != null ? _normalizeDate(deadline) : today;

    if (end.isAfter(today)) {
      end = today;
    }

    if (start.isAfter(end)) {
      return 0;
    }

    const weekdayNames = <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    int total = 0;
    DateTime current = start;

    while (!current.isAfter(end)) {
      final weekday = weekdayNames[current.weekday - 1];

      if (goalDays.contains(weekday)) {
        total++;
      }

      current = current.add(
        const Duration(days: 1),
      );
    }

    return total;
  }

  int _calculateCompletedCount({
    required List<String> completedDates,
    required DateTime? startDate,
    required DateTime? deadline,
    required List<String> goalDays,
  }) {
    if (completedDates.isEmpty) {
      return 0;
    }

    const weekdayNames = <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    final today = _normalizeDate(DateTime.now());

    final start =
    startDate != null
        ? _normalizeDate(startDate)
        : null;

    final end =
    deadline != null
        ? _normalizeDate(deadline)
        : null;

    int count = 0;

    for (final dateString in completedDates.toSet()) {
      final parsed = DateTime.tryParse(dateString);

      if (parsed == null) {
        continue;
      }

      final date = _normalizeDate(parsed);

      if (date.isAfter(today)) {
        continue;
      }

      if (start != null && date.isBefore(start)) {
        continue;
      }

      if (end != null && date.isAfter(end)) {
        continue;
      }

      if (goalDays.isNotEmpty) {
        final weekday =
        weekdayNames[date.weekday - 1];

        if (!goalDays.contains(weekday)) {
          continue;
        }
      }

      count++;
    }

    return count;
  }

  // ═══════════════════════════════════════════════════════════════
  // 📊 TOP STAT CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildStatCard({
    required BuildContext context,
    required String value,
    required String label,
    required IconData icon,
    required bool worldEnabled,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final isDark =
        theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color:
          isDark && worldEnabled
              ? Colors.black.withOpacity(0.52)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: primary.withOpacity(0.35),
            width: 1,
          ),
          boxShadow:
          isDark && worldEnabled
              ? [
            BoxShadow(
              color: primary.withOpacity(0.12),
              blurRadius: 14,
            ),
          ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: primary,
              size: 22,
            ),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface
                    .withOpacity(0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎯 GOAL CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildGoalCard(
      BuildContext context,
      QueryDocumentSnapshot goalDocument, {
        required bool worldEnabled,
      }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final primary = colors.primary;

    final isDark =
        theme.brightness == Brightness.dark;

    final data =
    goalDocument.data()
    as Map<String, dynamic>;

    final String title =
    data['title']
        ?.toString()
        .trim()
        .isNotEmpty ==
        true
        ? data['title'].toString()
        : 'Untitled Goal';

    final List<String> goalDays =
    List<String>.from(
      data['goalDays'] ?? [],
    );

    final List<String> completedDates =
    List<String>.from(
      data['completedDates'] ?? [],
    );

    final DateTime? startDate =
    _timestampToDate(
      data['startDate'],
    );

    final DateTime? deadline =
    _timestampToDate(
      data['deadline'],
    );

    // ─────────────────────────────────────────────────────────────
    // 📈 PROGRESS
    // ─────────────────────────────────────────────────────────────

    final totalDays =
    _calculateTotalGoalDays(
      startDate: startDate,
      deadline: deadline,
      goalDays: goalDays,
    );

    final completed =
    _calculateCompletedCount(
      completedDates: completedDates,
      startDate: startDate,
      deadline: deadline,
      goalDays: goalDays,
    );

    final remaining =
    (totalDays - completed).clamp(
      0,
      totalDays,
    );

    final double progress =
    totalDays == 0
        ? 0
        : (completed / totalDays).clamp(
      0.0,
      1.0,
    );

    final percentage =
    (progress * 100).round();

    const allDays = <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    // ─────────────────────────────────────────────────────────────
    // 📅 DATE LABEL
    // ─────────────────────────────────────────────────────────────

    String dateText = '';

    if (startDate != null) {
      dateText =
          DateFormat(
            'MMM d, yyyy',
          ).format(startDate);
    }

    if (deadline != null) {
      final formattedDeadline =
      DateFormat(
        'MMM d, yyyy',
      ).format(deadline);

      dateText =
      dateText.isEmpty
          ? formattedDeadline
          : '$dateText  •  $formattedDeadline';
    }

    return Container(
      margin: const EdgeInsets.only(
        bottom: 20,
      ),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(
              isDark && worldEnabled
                  ? 0.22
                  : 0.10,
            ),
            blurRadius: 22,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(24),
          color:
          isDark && worldEnabled
              ? Colors.black.withOpacity(0.58)
              : colors.surface,
          border: Border.all(
            color: primary.withOpacity(0.68),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════════════════════════
            // 🎯 HEADER
            // ═══════════════════════════════════════════════════

            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                    primary.withOpacity(
                      0.10,
                    ),
                    border: Border.all(
                      color:
                      primary.withOpacity(
                        0.75,
                      ),
                      width: 1.2,
                    ),
                    boxShadow:
                    worldEnabled
                        ? [
                      BoxShadow(
                        color:
                        primary
                            .withOpacity(
                          0.25,
                        ),
                        blurRadius:
                        12,
                      ),
                    ]
                        : null,
                  ),
                  child: Icon(
                    Icons
                        .track_changes_rounded,
                    color: primary,
                    size: 25,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        title,
                        style: theme
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontWeight:
                          FontWeight
                              .w700,
                        ),
                      ),

                      if (dateText
                          .isNotEmpty) ...[
                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          dateText,
                          style: TextStyle(
                            fontSize: 11,
                            color: colors
                                .onSurface
                                .withOpacity(
                              0.60,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color:
                    primary.withOpacity(
                      0.10,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                    border: Border.all(
                      color:
                      primary.withOpacity(
                        0.45,
                      ),
                    ),
                    boxShadow:
                    worldEnabled
                        ? [
                      BoxShadow(
                        color:
                        primary
                            .withOpacity(
                          0.15,
                        ),
                        blurRadius: 8,
                      ),
                    ]
                        : null,
                  ),
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      color: primary,
                      fontWeight:
                      FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ═══════════════════════════════════════════════════
            // 🚀 PROGRESS BAR
            // ═══════════════════════════════════════════════════

            Stack(
              children: [
                Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color:
                    primary.withOpacity(
                      0.10,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                  ),
                ),

                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                      boxShadow:
                      worldEnabled
                          ? [
                        BoxShadow(
                          color:
                          primary
                              .withOpacity(
                            0.55,
                          ),
                          blurRadius:
                          10,
                        ),
                      ]
                          : null,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ═══════════════════════════════════════════════════
            // 📊 STATS
            // ═══════════════════════════════════════════════════

            Row(
              children: [
                Expanded(
                  child: _buildCyberStat(
                    context,
                    '$completed',
                    'Completed',
                  ),
                ),

                _verticalDivider(context),

                Expanded(
                  child: _buildCyberStat(
                    context,
                    '$remaining',
                    'Remaining',
                  ),
                ),

                _verticalDivider(context),

                Expanded(
                  child: _buildCyberStat(
                    context,
                    '$totalDays',
                    'Scheduled',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            Text(
              'Schedule',
              style: theme
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                fontWeight:
                FontWeight.w600,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
              children:
              allDays.map((day) {
                return _buildCyberDayChip(
                  context,
                  day,
                  goalDays.contains(day),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 📊 SMALL GOAL STAT
  // ═══════════════════════════════════════════════════════════════

  Widget _buildCyberStat(
      BuildContext context,
      String value,
      String label,
      ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme
              .textTheme
              .titleMedium
              ?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: theme
                .colorScheme
                .onSurface
                .withOpacity(0.55),
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider(
      BuildContext context,
      ) {
    final theme = Theme.of(context);

    return Container(
      width: 1,
      height: 42,
      color: theme.colorScheme.primary
          .withOpacity(0.20),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 📅 WEEKDAY CHIP
  // ═══════════════════════════════════════════════════════════════

  Widget _buildCyberDayChip(
      BuildContext context,
      String day,
      bool active,
      ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final primary = colors.primary;

    return AnimatedContainer(
      duration:
      const Duration(
        milliseconds: 250,
      ),
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
        active
            ? primary.withOpacity(0.18)
            : colors.onSurface
            .withOpacity(0.06),
        border: Border.all(
          color:
          active
              ? primary
              : colors.onSurface
              .withOpacity(0.10),
          width: active ? 1.4 : 1,
        ),
        boxShadow:
        active
            ? [
          BoxShadow(
            color:
            primary.withOpacity(
              0.30,
            ),
            blurRadius: 10,
          ),
        ]
            : null,
      ),
      child: Text(
        day.substring(0, 1),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color:
          active
              ? primary
              : colors.onSurface
              .withOpacity(0.45),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🌍 MAIN GOALS SCREEN
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    // ------------------------------------------------------------
    // CURRENT USER-SELECTED DIARY WORLD
    // ------------------------------------------------------------

    final themeProvider =
    context.watch<ThemeProvider>();

    final selectedWorld =
        themeProvider.diaryWorld;

    // Theme-less means no special visual world.
    final worldEnabled =
        selectedWorld != DiaryWorld.simple;

    final user =
        FirebaseAuth.instance.currentUser;

    final theme = Theme.of(context);

    final primary =
        theme.colorScheme.primary;

    final isDark =
        theme.brightness ==
            Brightness.dark;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please log in to view your goals.',
          ),
        ),
      );
    }

    // ═════════════════════════════════════════════════════════════
    // SCREEN
    //
    // When a visual world is active, the Scaffold becomes
    // transparent so the world can be seen underneath.
    //
    // Theme-less uses the normal Scaffold background.
    // ═════════════════════════════════════════════════════════════

    final screen = Scaffold(
      backgroundColor:
      worldEnabled
          ? Colors.transparent
          : theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'Goal Analytics',
        ),
        centerTitle: true,
        backgroundColor:
        worldEnabled
            ? Colors.transparent
            : null,
        surfaceTintColor:
        Colors.transparent,
        elevation: 0,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream:
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('goals')
            .snapshots(),

        builder: (context, snapshot) {
          // ═════════════════════════════════════════════════════
          // ❌ ERROR
          // ═════════════════════════════════════════════════════

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                const EdgeInsets.all(
                  24,
                ),
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Icon(
                      Icons
                          .error_outline_rounded,
                      size: 50,
                      color:
                      theme
                          .colorScheme
                          .error,
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    const Text(
                      'Could not load goal analytics.',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      snapshot.error
                          .toString(),
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme
                            .colorScheme
                            .onSurface
                            .withOpacity(
                          0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ═════════════════════════════════════════════════════
          // ⏳ LOADING
          // ═════════════════════════════════════════════════════

          if (snapshot
              .connectionState ==
              ConnectionState.waiting) {
            return Center(
              child:
              CircularProgressIndicator(
                color: primary,
              ),
            );
          }

          final goals =
              snapshot.data?.docs ?? [];

          // ═════════════════════════════════════════════════════
          // EMPTY
          // ═════════════════════════════════════════════════════

          if (goals.isEmpty) {
            return Center(
              child: Padding(
                padding:
                const EdgeInsets.all(
                  30,
                ),
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 64,
                      color:
                      primary.withOpacity(
                        0.8,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    const Text(
                      'No goals yet',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Create your first goal and your progress will appear here.',
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        color: theme
                            .colorScheme
                            .onSurface
                            .withOpacity(
                          0.65,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ═════════════════════════════════════════════════════
          // 📈 OVERALL ANALYTICS
          // ═════════════════════════════════════════════════════

          int totalCompleted = 0;
          int totalScheduled = 0;

          for (final goalDocument
          in goals) {
            final data =
            goalDocument.data()
            as Map<
                String,
                dynamic
            >;

            final goalDays =
            List<String>.from(
              data['goalDays'] ?? [],
            );

            final completedDates =
            List<String>.from(
              data['completedDates'] ??
                  [],
            );

            final startDate =
            _timestampToDate(
              data['startDate'],
            );

            final deadline =
            _timestampToDate(
              data['deadline'],
            );

            totalScheduled +=
                _calculateTotalGoalDays(
                  startDate: startDate,
                  deadline: deadline,
                  goalDays: goalDays,
                );

            totalCompleted +=
                _calculateCompletedCount(
                  completedDates:
                  completedDates,
                  startDate: startDate,
                  deadline: deadline,
                  goalDays: goalDays,
                );
          }

          final overallProgress =
          totalScheduled == 0
              ? 0
              : ((totalCompleted /
              totalScheduled) *
              100)
              .round();

          return ListView(
            padding:
            const EdgeInsets.fromLTRB(
              18,
              12,
              18,
              30,
            ),
            children: [
              // ═════════════════════════════════════════════════
              // 🚀 HEADER
              // ═════════════════════════════════════════════════

              Text(
                'Your Progress',
                style: theme
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                  fontWeight:
                  FontWeight.bold,
                  color:
                  isDark &&
                      worldEnabled
                      ? Colors.white
                      : null,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Small progress is still progress ✨',
                style: TextStyle(
                  color:
                  isDark &&
                      worldEnabled
                      ? Colors.white
                      .withOpacity(
                    0.65,
                  )
                      : theme
                      .colorScheme
                      .onSurface
                      .withOpacity(
                    0.6,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ═════════════════════════════════════════════════
              // 📊 OVERALL STAT CARDS
              // ═════════════════════════════════════════════════

              Row(
                children: [
                  _buildStatCard(
                    context: context,
                    value:
                    '${goals.length}',
                    label: 'Goals',
                    icon:
                    Icons.flag_outlined,
                    worldEnabled:
                    worldEnabled,
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  _buildStatCard(
                    context: context,
                    value:
                    '$totalCompleted',
                    label: 'Completed',
                    icon: Icons
                        .check_circle_outline,
                    worldEnabled:
                    worldEnabled,
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  _buildStatCard(
                    context: context,
                    value:
                    '$overallProgress%',
                    label: 'Progress',
                    icon: Icons
                        .trending_up_rounded,
                    worldEnabled:
                    worldEnabled,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ═════════════════════════════════════════════════
              // 🎯 YOUR GOALS
              // ═════════════════════════════════════════════════

              InkWell(
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
                onTap: () {
                  setState(() {
                    _showAllGoals =
                    !_showAllGoals;
                  });
                },
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Your Goals',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),
                      ),

                      AnimatedRotation(
                        duration:
                        const Duration(
                          milliseconds:
                          250,
                        ),
                        turns:
                        _showAllGoals
                            ? 0.5
                            : 0,
                        child: Icon(
                          Icons
                              .keyboard_arrow_down_rounded,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              AnimatedCrossFade(
                duration:
                const Duration(
                  milliseconds: 250,
                ),
                crossFadeState:
                _showAllGoals
                    ? CrossFadeState
                    .showFirst
                    : CrossFadeState
                    .showSecond,
                firstChild: Column(
                  children:
                  goals
                      .map(
                        (goal) =>
                        _buildGoalCard(
                          context,
                          goal,
                          worldEnabled:
                          worldEnabled,
                        ),
                  )
                      .toList(),
                ),
                secondChild:
                const SizedBox
                    .shrink(),
              ),

              const SizedBox(height: 10),

              // ═════════════════════════════════════════════════
              // 🔭 FUTURE ANALYTICS
              // ═════════════════════════════════════════════════

              Container(
                padding:
                const EdgeInsets.all(
                  18,
                ),
                decoration: BoxDecoration(
                  color:
                  isDark &&
                      worldEnabled
                      ? Colors.black
                      .withOpacity(
                    0.52,
                  )
                      : theme
                      .colorScheme
                      .surface,
                  borderRadius:
                  BorderRadius.circular(
                    18,
                  ),
                  border: Border.all(
                    color:
                    primary.withOpacity(
                      0.30,
                    ),
                  ),
                  boxShadow:
                  isDark &&
                      worldEnabled
                      ? [
                    BoxShadow(
                      color:
                      primary
                          .withOpacity(
                        0.10,
                      ),
                      blurRadius:
                      15,
                    ),
                  ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.insights_rounded,
                      color: primary,
                    ),

                    const SizedBox(
                      width: 14,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          const Text(
                            'Advanced Analytics',
                            style: TextStyle(
                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),

                          const SizedBox(
                            height: 3,
                          ),

                          Text(
                            'Weekly trends, streaks and deeper insights are coming soon.',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(
                                0.65,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // ═════════════════════════════════════════════════════════════
    // 🌍 SELECTED DIARY WORLD
    // ═════════════════════════════════════════════════════════════
    //
    // IMPORTANT:
    // The selected world from ThemeProvider is passed here.
    //
    // Theme-less:
    // DiaryWorld.simple -> normal background
    //
    // Cosmic:
    // DiaryWorld.cosmicUniverse -> CosmicWorldBackground
    //
    // Future worlds will automatically enter through the same
    // DiaryWorldBackground router.
    // ═════════════════════════════════════════════════════════════

    return DiaryWorldBackground(
      world: selectedWorld,
      scene: DiaryScene.goals,
      accentColor: primary,
      brightness: theme.brightness,
      child: screen,
    );
  }
}