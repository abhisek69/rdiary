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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        title: const Text(
          "Rocky's Diary",
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Column(
        children: [
          // ----------------------------------------------------
          // CALENDAR
          // ----------------------------------------------------

          CalendarSection(
            selectedDay: _selectedDay,
            focusedDay: _focusedDay,
            onDaySelected: _onDaySelected,
          ),

          // ----------------------------------------------------
          // CONTENT
          // ----------------------------------------------------

          Expanded(
            child: _isLoading
                ? Center(
              child: AppLoader(
                loadingColor:
                Theme.of(context)
                    .colorScheme
                    .primary,
                type:
                LoaderType
                    .halfTriangleDot,
                size: 120,
              ),
            )
                : SingleChildScrollView(
              padding:
              const EdgeInsets.all(
                12,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  // ======================================
                  // GOALS
                  // ======================================

                  GoalsSection(
                    goals:
                    _goalsForSelectedDate,
                    selectedDay:
                    _selectedDay,
                    refreshCallback: () =>
                        _fetchNotesForDate(
                          _selectedDay,
                        ),
                  ),

                  // ======================================
                  // NOTES
                  // ======================================

                  NotesSection(
                    notes:
                    _notesForSelectedDate,
                    selectedDay:
                    _selectedDay,
                    refreshCallback:
                    _fetchNotesForDate,
                  ),

                  // ======================================
                  // EMPTY STATE
                  // ======================================

                  if (_notesForSelectedDate
                      .isEmpty &&
                      _goalsForSelectedDate
                          .isEmpty)
                    const Center(
                      child: Padding(
                        padding:
                        EdgeInsets.only(
                          top: 60,
                        ),
                        child: Text(
                          'No entries for this date yet.',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                            Colors.grey,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ========================================================
      // ADD NOTE BUTTON
      // ========================================================

      floatingActionButton:
      FloatingActionButton(
        backgroundColor:
        Theme.of(context)
            .colorScheme
            .primary,

        onPressed: () async {
          await Navigator.pushNamed(
            context,
            '/add',
            arguments: _selectedDay,
          );

          // User could navigate away while AddNote
          // screen was open.
          if (!mounted) return;

          // Refresh after returning from AddNote.
          await _fetchNotesForDate(
            _selectedDay,
          );
        },

        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}