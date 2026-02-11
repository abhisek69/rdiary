import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../models/goal.dart';
import '../services/notification_service.dart';
import '../widgets/diary_card.dart';
import '../widgets/diary_calendar.dart';

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
  bool _isLoading = false;
  List<Goal> _goalsForSelectedDate = [];
  Widget _buildGoalCard(Goal goal) {
    final dateKey =
    DateFormat('yyyy-MM-dd').format(_selectedDay);

    final isCompleted =
    goal.completedDates.contains(dateKey);

    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.flag,
                  color: Theme.of(context)
                      .colorScheme
                      .primary),
              Checkbox(
                value: isCompleted,
                activeColor:
                Theme.of(context)
                    .colorScheme
                    .primary,
                onChanged: (val) async {
                  final user =
                      FirebaseAuth.instance.currentUser;

                  final updatedDates =
                  List<String>.from(
                      goal.completedDates);

                  if (val == true) {
                    updatedDates.add(dateKey);
                  } else {
                    updatedDates.remove(dateKey);
                  }

                  await FirebaseFirestore
                      .instance
                      .collection('users')
                      .doc(user!.uid)
                      .collection('goals')
                      .doc(goal.id)
                      .update({
                    'completedDates':
                    updatedDates,
                  });

                  _fetchNotesForDate(
                      _selectedDay);
                },
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(
            goal.title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

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

    final dateArg = Get.arguments as DateTime?;
    if (dateArg != null) {
      _selectedDay = dateArg;
      _focusedDay = dateArg;
    } else if (widget.initialDate != null) {
      _selectedDay = widget.initialDate!;
      _focusedDay = widget.initialDate!;
    } else {
      _selectedDay = DateTime.now();
      _focusedDay = DateTime.now();
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

    final startOfDay =
    DateTime(date.year, date.month, date.day);
    final endOfDay =
    DateTime(date.year, date.month, date.day + 1);

    try {
      // 📝 Fetch Notes
      final notesSnapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .where('date',
          isGreaterThanOrEqualTo:
          Timestamp.fromDate(startOfDay))
          .where('date',
          isLessThan:
          Timestamp.fromDate(endOfDay))
          .get();

      final notes = notesSnapshot.docs
          .map((doc) =>
          Note.fromFirestore(doc.data(), doc.id))
          .toList();

      // 🎯 Fetch Goals
      final goalsSnapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .collection('goals')
          .get();

      final weekday =
      ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
      [date.weekday - 1];

      final goals = goalsSnapshot.docs
          .map((doc) =>
          Goal.fromFirestore(doc.data(), doc.id))
          .where((goal) {
        if (!goal.goalDays.contains(weekday))
          return false;

        if (goal.deadline != null &&
            date.isAfter(goal.deadline!))
          return false;

        return true;
      }).toList();

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
      appBar: AppBar(
        title: const Icon(Icons.draw),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () =>
                Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          DiaryCalendar(
            selectedDay: _selectedDay,
            focusedDay: _focusedDay,
            onDaySelected: _onDaySelected,
          ),

          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 12),
            child: Divider(
              color: Colors.grey.withOpacity(0.4),
              thickness: 1,
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  // 🎯 GOALS SECTION
                  if (_goalsForSelectedDate.isNotEmpty) ...[
                    const Text(
                      "Goals",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection:
                        Axis.horizontal,
                        itemCount:
                        _goalsForSelectedDate.length,
                        itemBuilder: (_, i) {
                          return _buildGoalCard(
                              _goalsForSelectedDate[i]);
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],

                  // 📝 NOTES SECTION
                  if (_notesForSelectedDate.isNotEmpty) ...[
                    const Text(
                      "Notes",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    ListView.builder(
                      shrinkWrap: true,
                      physics:
                      const NeverScrollableScrollPhysics(),
                      itemCount:
                      _notesForSelectedDate.length,
                      itemBuilder: (_, i) {
                        return DiaryCard(
                          note:
                          _notesForSelectedDate[i],
                          refreshCallback:
                          _fetchNotesForDate,
                        );
                      },
                    ),
                  ],

                  if (_notesForSelectedDate.isEmpty &&
                      _goalsForSelectedDate.isEmpty)
                    const Center(
                      child: Padding(
                        padding:
                        EdgeInsets.only(top: 60),
                        child: Text(
                          'No entries for this date yet.',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:
        Theme.of(context).colorScheme.primary,
        onPressed: () async {
          await Navigator.pushNamed(
            context,
            '/add',
            arguments: _selectedDay,
          );
          _fetchNotesForDate(_selectedDay);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
