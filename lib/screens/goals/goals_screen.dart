import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  bool _showAllGoals = true;

  // ------------------------------------------------------------
  // DATE HELPERS
  // ------------------------------------------------------------

  /// Removes time from a DateTime.
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Converts Firestore Timestamp safely to DateTime.
  DateTime? _timestampToDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  // ------------------------------------------------------------
  // GOAL CALCULATIONS
  // ------------------------------------------------------------

  /// Counts how many scheduled goal days exist between
  /// startDate and deadline/today.
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

    DateTime end = deadline != null
        ? _normalizeDate(deadline)
        : today;

    // Do not calculate future progress beyond today.
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

      current = current.add(const Duration(days: 1));
    }

    return total;
  }

  /// Counts valid completed dates.
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
    startDate != null ? _normalizeDate(startDate) : null;
    final end =
    deadline != null ? _normalizeDate(deadline) : null;

    int count = 0;

    for (final dateString in completedDates.toSet()) {
      final parsed = DateTime.tryParse(dateString);

      if (parsed == null) {
        continue;
      }

      final date = _normalizeDate(parsed);

      // Ignore future completion dates.
      if (date.isAfter(today)) {
        continue;
      }

      // Ignore dates before goal started.
      if (start != null && date.isBefore(start)) {
        continue;
      }

      // Ignore dates after deadline.
      if (end != null && date.isAfter(end)) {
        continue;
      }

      // Completion should belong to one of the goal's scheduled days.
      if (goalDays.isNotEmpty) {
        final weekday = weekdayNames[date.weekday - 1];

        if (!goalDays.contains(weekday)) {
          continue;
        }
      }

      count++;
    }

    return count;
  }

  // ------------------------------------------------------------
  // UI HELPERS
  // ------------------------------------------------------------

  Widget _buildStatCard({
    required BuildContext context,
    required String value,
    required String label,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: primary.withOpacity(0.18),
          ),
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
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayChip(
      BuildContext context,
      String day,
      bool active,
      ) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? primary
            : theme.colorScheme.onSurface.withOpacity(0.08),
      ),
      child: Text(
        day.substring(0, 1),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: active
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface.withOpacity(0.55),
        ),
      ),
    );
  }

  Widget _buildGoalCard(
      BuildContext context,
      QueryDocumentSnapshot goalDocument,
      ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final primary = colors.primary;

    final data =
    goalDocument.data() as Map<String, dynamic>;

    final String title =
    data['title']?.toString().trim().isNotEmpty == true
        ? data['title'].toString()
        : 'Untitled Goal';

    final List<String> goalDays =
    List<String>.from(data['goalDays'] ?? []);

    final List<String> completedDates =
    List<String>.from(data['completedDates'] ?? []);

    final DateTime? startDate =
    _timestampToDate(data['startDate']);

    final DateTime? deadline =
    _timestampToDate(data['deadline']);

    // ============================================================
    // PROGRESS CALCULATION
    // ============================================================

    final totalDays = _calculateTotalGoalDays(
      startDate: startDate,
      deadline: deadline,
      goalDays: goalDays,
    );

    final completed = _calculateCompletedCount(
      completedDates: completedDates,
      startDate: startDate,
      deadline: deadline,
      goalDays: goalDays,
    );

    final remaining =
    (totalDays - completed).clamp(0, totalDays);

    final double progress = totalDays == 0
        ? 0
        : (completed / totalDays).clamp(0.0, 1.0);

    final percentage = (progress * 100).round();

    const allDays = <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    // ============================================================
    // DATE TEXT
    // ============================================================

    String dateText = '';

    if (startDate != null) {
      dateText =
          DateFormat('MMM d, yyyy').format(startDate);
    }

    if (deadline != null) {
      final formattedDeadline =
      DateFormat('MMM d, yyyy').format(deadline);

      dateText = dateText.isEmpty
          ? formattedDeadline
          : '$dateText  •  $formattedDeadline';
    }

    // ============================================================
    // FUTURISTIC GOAL CARD
    // ============================================================

    return Container(
      margin: const EdgeInsets.only(bottom: 22),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),

        // Subtle glow using ONLY the selected primary color.
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(
              theme.brightness == Brightness.dark
                  ? 0.18
                  : 0.10,
            ),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),

      child: Container(
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),

          // Keep the card dark/light depending on theme.
          color: colors.surface,

          // Single-color cyber border.
          border: Border.all(
            color: primary.withOpacity(0.65),
            width: 1.2,
          ),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ====================================================
            // HEADER
            // ====================================================

            Row(
              children: [
                // ------------------------------------------------
                // GOAL ICON
                // ------------------------------------------------

                Container(
                  width: 48,
                  height: 48,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    color: primary.withOpacity(0.08),

                    border: Border.all(
                      color: primary.withOpacity(0.75),
                      width: 1.2,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.20),
                        blurRadius: 10,
                      ),
                    ],
                  ),

                  child: Icon(
                    Icons.track_changes_rounded,
                    color: primary,
                    size: 25,
                  ),
                ),

                const SizedBox(width: 14),

                // ------------------------------------------------
                // TITLE + DATE
                // ------------------------------------------------

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,

                        style:
                        theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      if (dateText.isNotEmpty) ...[
                        const SizedBox(height: 4),

                        Text(
                          dateText,

                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurface
                                .withOpacity(0.55),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ------------------------------------------------
                // PERCENTAGE
                // ------------------------------------------------

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),

                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.08),

                    borderRadius:
                    BorderRadius.circular(20),

                    border: Border.all(
                      color: primary.withOpacity(0.40),
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.12),
                        blurRadius: 8,
                      ),
                    ],
                  ),

                  child: Text(
                    '$percentage%',

                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ====================================================
            // PROGRESS BAR
            // ====================================================

            Stack(
              children: [
                Container(
                  height: 7,

                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.10),
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                ),

                FractionallySizedBox(
                  widthFactor: progress,

                  child: Container(
                    height: 7,

                    decoration: BoxDecoration(
                      color: primary,

                      borderRadius:
                      BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color:
                          primary.withOpacity(0.45),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ====================================================
            // STATS
            // ====================================================

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

            // ====================================================
            // SCHEDULE
            // ====================================================

            Text(
              'Schedule',

              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

              children: allDays.map((day) {
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

          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          label,

          style: TextStyle(
            fontSize: 10,
            color:
            theme.colorScheme.onSurface.withOpacity(0.55),
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 1,
      height: 42,
      color:
      theme.colorScheme.primary.withOpacity(0.20),
    );
  }

  Widget _buildCyberDayChip(
      BuildContext context,
      String day,
      bool active,
      ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final primary = colors.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),

      width: 38,
      height: 38,

      alignment: Alignment.center,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        color: active
            ? primary.withOpacity(0.18)
            : colors.onSurface.withOpacity(0.06),

        border: Border.all(
          color: active
              ? primary
              : colors.onSurface.withOpacity(0.10),
          width: active ? 1.4 : 1,
        ),

        boxShadow: active
            ? [
          BoxShadow(
            color: primary.withOpacity(0.25),
            blurRadius: 9,
          ),
        ]
            : null,
      ),

      child: Text(
        day.substring(0, 1),

        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,

          color: active
              ? primary
              : colors.onSurface.withOpacity(0.45),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // MAIN SCREEN
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    // User must be logged in.
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view your goals.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Analytics'),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('goals')
            .snapshots(),

        builder: (context, snapshot) {
          // ----------------------------------------------------
          // FIRESTORE ERROR
          // ----------------------------------------------------

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 50,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Could not load goal analytics.',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ----------------------------------------------------
          // LOADING
          // ----------------------------------------------------

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final goals = snapshot.data?.docs ?? [];

          // ----------------------------------------------------
          // EMPTY STATE
          // ----------------------------------------------------

          if (goals.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 64,
                      color: primary.withOpacity(0.7),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No goals yet',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first goal and your progress will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ----------------------------------------------------
          // OVERALL ANALYTICS
          // ----------------------------------------------------

          int totalCompleted = 0;
          int totalScheduled = 0;

          for (final goalDocument in goals) {
            final data =
            goalDocument.data() as Map<String, dynamic>;

            final goalDays =
            List<String>.from(data['goalDays'] ?? []);

            final completedDates =
            List<String>.from(
                data['completedDates'] ?? []);

            final startDate =
            _timestampToDate(data['startDate']);

            final deadline =
            _timestampToDate(data['deadline']);

            totalScheduled += _calculateTotalGoalDays(
              startDate: startDate,
              deadline: deadline,
              goalDays: goalDays,
            );

            totalCompleted += _calculateCompletedCount(
              completedDates: completedDates,
              startDate: startDate,
              deadline: deadline,
              goalDays: goalDays,
            );
          }

          final overallProgress =
          totalScheduled == 0
              ? 0
              : ((totalCompleted / totalScheduled) * 100)
              .round();

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              18,
              16,
              18,
              30,
            ),
            children: [
              // ------------------------------------------------
              // HEADER
              // ------------------------------------------------

              Text(
                'Your Progress',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Small progress is still progress 💜',
                style: TextStyle(
                  color: theme.colorScheme.onSurface
                      .withOpacity(0.6),
                ),
              ),

              const SizedBox(height: 22),

              // ------------------------------------------------
              // OVERALL STATISTICS
              // ------------------------------------------------

              Row(
                children: [
                  _buildStatCard(
                    context: context,
                    value: '${goals.length}',
                    label: 'Goals',
                    icon: Icons.flag_outlined,
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    context: context,
                    value: '$totalCompleted',
                    label: 'Completed',
                    icon: Icons.check_circle_outline,
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    context: context,
                    value: '$overallProgress%',
                    label: 'Progress',
                    icon: Icons.trending_up_rounded,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ------------------------------------------------
              // GOALS HEADER
              // ------------------------------------------------

              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() {
                    _showAllGoals = !_showAllGoals;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Your Goals',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        duration:
                        const Duration(milliseconds: 250),
                        turns: _showAllGoals ? 0.5 : 0,
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ------------------------------------------------
              // GOAL CARDS
              // ------------------------------------------------

              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: _showAllGoals
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,

                firstChild: Column(
                  children: goals
                      .map(
                        (goal) =>
                        _buildGoalCard(context, goal),
                  )
                      .toList(),
                ),

                secondChild: const SizedBox.shrink(),
              ),

              const SizedBox(height: 15),

              // ------------------------------------------------
              // FUTURE ANALYTICS PLACEHOLDER
              // ------------------------------------------------

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: primary.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.insights_rounded,
                      color: primary,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Advanced Analytics',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Weekly trends, streaks and deeper insights are coming soon.',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.6),
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
  }
}