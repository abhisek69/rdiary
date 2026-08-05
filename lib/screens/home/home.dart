import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/goal.dart';
import '../../models/note.dart';
import '../../utils/pulseLoader.dart';

import 'calendar_section.dart';
import 'goals_section.dart';
import 'notes_section.dart';
import '../../backgrounds/diary_world/diary_world.dart';
import '../../backgrounds/diary_world/diary_world_background.dart';

class HomeScreen extends StatefulWidget {
  final DateTime? initialDate;

  const HomeScreen({
    super.key,
    this.initialDate,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ============================================================
  // CALENDAR STATE
  // ============================================================

  late DateTime _focusedDay;
  late DateTime _selectedDay;

  // ============================================================
  // DATA
  // ============================================================

  List<Note> _notesForSelectedDate = [];
  List<Goal> _goalsForSelectedDate = [];

  bool _isLoading = false;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Use initialDate when HomeScreen was opened for
    // a particular date. Otherwise use today.
    final initialDate =
        widget.initialDate ?? DateTime.now();

    _focusedDay = initialDate;
    _selectedDay = initialDate;

    final user =
        FirebaseAuth.instance.currentUser;

    // ----------------------------------------------------------
    // USER NOT LOGGED IN
    // ----------------------------------------------------------

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback(
            (_) {
          if (!mounted) return;

          Get.offAllNamed('/login');
        },
      );

      return;
    }

    // Load today's notes and goals.
    _fetchNotesForDate(
      _selectedDay,
    );
  }

  // ============================================================
  // CALENDAR DATE SELECTED
  // ============================================================

  void _onDaySelected(
      DateTime selected,
      DateTime focused,
      ) {
    if (!mounted) return;

    setState(() {
      _selectedDay = selected;
      _focusedDay = focused;
    });

    _fetchNotesForDate(
      selected,
    );
  }

  // ============================================================
  // FETCH NOTES + GOALS FOR SELECTED DATE
  // ============================================================

  Future<void> _fetchNotesForDate(
      DateTime date,
      ) async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    // ----------------------------------------------------------
    // START LOADING
    // ----------------------------------------------------------

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    // Normalize selected date.
    final selected = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final startOfDay = selected;

    final endOfDay = selected.add(
      const Duration(days: 1),
    );

    try {
      // ========================================================
      // FETCH NOTES
      // ========================================================

      final notesSnapshot =
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .where(
        'date',
        isGreaterThanOrEqualTo:
        Timestamp.fromDate(
          startOfDay,
        ),
      )
          .where(
        'date',
        isLessThan:
        Timestamp.fromDate(
          endOfDay,
        ),
      )
          .get();

      // --------------------------------------------------------
      // IMPORTANT
      //
      // The screen might have been removed while Firestore
      // was loading.
      // --------------------------------------------------------

      if (!mounted) return;

      final notes = notesSnapshot.docs
          .map(
            (doc) => Note.fromFirestore(
          doc.data(),
          doc.id,
        ),
      )
          .toList();

      // ========================================================
      // FETCH GOALS
      // ========================================================

      final goalsSnapshot =
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('goals')
          .get();

      // Another async request happened.
      // Check again before touching this screen's state.
      if (!mounted) return;

      // ========================================================
      // DETERMINE WEEKDAY
      // ========================================================

      const weekdays = [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ];

      final weekday =
      weekdays[selected.weekday - 1];

      // ========================================================
      // FILTER GOALS FOR SELECTED DATE
      // ========================================================

      final goals = goalsSnapshot.docs
          .map(
            (doc) => Goal.fromFirestore(
          doc.data(),
          doc.id,
        ),
      )
          .where(
            (goal) {
          // ------------------------------------------------
          // WEEKDAY CHECK
          // ------------------------------------------------

          if (!goal.goalDays.contains(
            weekday,
          )) {
            return false;
          }

          // ------------------------------------------------
          // START DATE CHECK
          // ------------------------------------------------

          if (goal.startDate != null) {
            final start = DateTime(
              goal.startDate!.year,
              goal.startDate!.month,
              goal.startDate!.day,
            );

            if (selected.isBefore(start)) {
              return false;
            }
          }

          // ------------------------------------------------
          // DEADLINE CHECK
          // ------------------------------------------------

          if (goal.deadline != null) {
            final deadline = DateTime(
              goal.deadline!.year,
              goal.deadline!.month,
              goal.deadline!.day,
            );

            // Goal remains visible ON deadline.
            // Hide only after deadline.
            if (selected.isAfter(
              deadline,
            )) {
              return false;
            }
          }

          return true;
        },
      )
          .toList();

      // ========================================================
      // UPDATE SCREEN
      // ========================================================

      if (!mounted) return;

      setState(() {
        _notesForSelectedDate = notes;
        _goalsForSelectedDate = goals;
        _isLoading = false;
      });
    } catch (e) {
      // --------------------------------------------------------
      // ERROR HANDLING
      // --------------------------------------------------------

      debugPrint(
        '❌ Error loading HomeScreen data: $e',
      );

      // Never call setState on a disposed HomeScreen.
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    // ==========================================================
    // HOME CONTENT
    // ==========================================================

    final homeContent = Column(
      children: [
        // ------------------------------------------------------
        // CALENDAR
        // ------------------------------------------------------

        CalendarSection(
          selectedDay: _selectedDay,
          focusedDay: _focusedDay,
          onDaySelected: _onDaySelected,
        ),

        // ------------------------------------------------------
        // GOALS + NOTES
        // ------------------------------------------------------

        Expanded(
          child: _isLoading
              ? Center(
            child: AppLoader(
              loadingColor: primary,
              type: LoaderType.halfTriangleDot,
              size: 120,
            ),
          )
              : SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // ========================================
                // GOALS
                // ========================================

                GoalsSection(
                  goals: _goalsForSelectedDate,
                  selectedDay: _selectedDay,
                  refreshCallback: () =>
                      _fetchNotesForDate(
                        _selectedDay,
                      ),
                ),

                // ========================================
                // NOTES
                // ========================================

                NotesSection(
                  notes: _notesForSelectedDate,
                  selectedDay: _selectedDay,
                  refreshCallback:
                  _fetchNotesForDate,
                ),

                // ========================================
                // EMPTY STATE
                // ========================================

                if (_notesForSelectedDate.isEmpty &&
                    _goalsForSelectedDate.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 60,
                    ),
                    child: Center(
                      child: Text(
                        'No entries for this date yet.',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? Colors.white.withOpacity(
                            0.45,
                          )
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );

    // ==========================================================
    // ACTUAL HOME SCAFFOLD
    // ==========================================================

    final scaffold = Scaffold(
      // IMPORTANT:
      // CosmicBackground is OUTSIDE this Scaffold in dark mode.
      backgroundColor:
      isDark ? Colors.transparent : null,

      extendBodyBehindAppBar: isDark,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,

        backgroundColor:
        isDark ? Colors.transparent : primary,

        toolbarHeight: isDark ? 100 : null,

        titleSpacing: 20,

        title: isDark
            ? Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Rocky's Diary",
                  style: TextStyle(
                    color: primary,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    shadows: [
                      Shadow(
                        color:
                        primary.withOpacity(0.45),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 7),

                Icon(
                  Icons.auto_awesome_rounded,
                  color: primary,
                  size: 16,
                ),
              ],
            ),

            const SizedBox(height: 3),

            Text(
              'Capture today, plan tomorrow.',
              style: TextStyle(
                color:
                Colors.white.withOpacity(0.62),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        )
            : const Text(
          "Rocky's Diary",
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: isDark
          ? Padding(
        // AppBar is transparent and body extends behind it.
        padding: EdgeInsets.only(
          top:
          MediaQuery.of(context).padding.top +
              100,
        ),
        child: homeContent,
      )
          : homeContent,

      // ========================================================
      // ADD NOTE BUTTON
      // ========================================================

      floatingActionButton: Container(
        decoration: isDark
            ? BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:
              primary.withOpacity(0.45),
              blurRadius: 22,
              spreadRadius: 2,
            ),
          ],
        )
            : null,

        child: FloatingActionButton(
          backgroundColor: primary,
          foregroundColor: Colors.white,

          onPressed: () async {
            await Navigator.pushNamed(
              context,
              '/add',
              arguments: _selectedDay,
            );

            if (!mounted) return;

            await _fetchNotesForDate(
              _selectedDay,
            );
          },

          child: const Icon(
            Icons.add_rounded,
            size: 30,
          ),
        ),
      ),
    );

    // ==========================================================
    // LIGHT MODE
    // ==========================================================

    if (!isDark) {
      return scaffold;
    }

    // ==========================================================
    // DARK MODE — COSMIC UNIVERSE
    //
    // The important architecture:
    //
    // DiaryWorldBackground
    //      ↓
    // transparent Scaffold
    //      ↓
    // actual interactive UI
    // ==========================================================

    return DiaryWorldBackground(
      scene: DiaryScene.home,
      accentColor: primary,
      child: scaffold,
    );
  }
}
