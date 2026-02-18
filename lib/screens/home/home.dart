import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/note.dart';
import '../../models/goal.dart';

import '../../utils/pulseLoader.dart';
import 'calendar_section.dart';
import 'goals_section.dart';
import 'notes_section.dart';

class HomeScreen extends StatefulWidget {
  final DateTime? initialDate;

  const HomeScreen({super.key, this.initialDate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  List<Note> _notesForSelectedDate = [];
  List<Goal> _goalsForSelectedDate = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/login');
      });
      return;
    }

    _fetchNotesForDate(_selectedDay);
  }

  void _onDaySelected(DateTime selected, DateTime focused) {
    setState(() {
      _selectedDay = selected;
      _focusedDay = focused;
    });

    _fetchNotesForDate(selected);
  }

  Future<void> _fetchNotesForDate(DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day + 1);

    try {
      // 📝 NOTES
      final notesSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('notes')
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
              )
              .where('date', isLessThan: Timestamp.fromDate(endOfDay))
              .get();

      final notes =
          notesSnapshot.docs
              .map((doc) => Note.fromFirestore(doc.data(), doc.id))
              .toList();

      // 🎯 GOALS
      // 🎯 GOALS
      final goalsSnapshot =
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('goals')
          .get();

// Normalize selected date
      DateTime selected =
      DateTime(date.year, date.month, date.day);

      final weekday =
      ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
      [selected.weekday - 1];

      final goals = goalsSnapshot.docs
          .map((doc) => Goal.fromFirestore(doc.data(), doc.id))
          .where((goal) {

        // Must be scheduled on that weekday
        if (!goal.goalDays.contains(weekday)) {
          return false;
        }

        // Normalize start date
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

        // Normalize deadline
        if (goal.deadline != null) {
          final end = DateTime(
            goal.deadline!.year,
            goal.deadline!.month,
            goal.deadline!.day,
          );

          // IMPORTANT: show ON end date, hide only AFTER
          if (selected.isAfter(end)) {
            return false;
          }
        }

        return true;
      })
          .toList();


      setState(() {
        _notesForSelectedDate = notes;
        _goalsForSelectedDate = goals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rocky's Diary"), actions: []),

      body: Column(
        children: [
          /// 📅 CALENDAR
          CalendarSection(
            selectedDay: _selectedDay,
            focusedDay: _focusedDay,
            onDaySelected: _onDaySelected,
          ),

          /// 📦 CONTENT
          Expanded(
            child:
                _isLoading
                    ? Center(
                      child: AppLoader(
                        loadingColor: Theme.of(context).colorScheme.primary,
                        type: LoaderType.halfTriangleDot,
                        size: 120,
                      ),
                    )
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 🎯 GOALS
                          GoalsSection(
                            goals: _goalsForSelectedDate,
                            selectedDay: _selectedDay,
                            refreshCallback:
                                () => _fetchNotesForDate(_selectedDay),
                          ),

                          /// 📝 NOTES
                          NotesSection(
                            notes: _notesForSelectedDate,
                            selectedDay: _selectedDay,
                            refreshCallback: _fetchNotesForDate,
                          ),

                          if (_notesForSelectedDate.isEmpty &&
                              _goalsForSelectedDate.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 60),
                                child: Text(
                                  'No entries for this date yet.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
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

      /// ➕ ADD BUTTON (YOU WERE MISSING THIS)
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () async {
          await Navigator.pushNamed(context, '/add', arguments: _selectedDay);

          _fetchNotesForDate(_selectedDay);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
