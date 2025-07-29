import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/note.dart';
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

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User is not logged in — redirect
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/login');
      });
    }
    // If the initialDate is provided, use that; otherwise, default to the current date
    final dateArg = Get.arguments as DateTime?;
    if (dateArg != null) {
      _selectedDay = dateArg;
      _focusedDay = dateArg;
    } else {
      _selectedDay = DateTime.now();
      _focusedDay = DateTime.now();
    }
    if (widget.initialDate != null) {
      _selectedDay = widget.initialDate!;
      _focusedDay = widget.initialDate!;
    } else {
      _selectedDay = DateTime.now();
      _focusedDay = DateTime.now();
    }
    _fetchNotesForDate(_selectedDay);  // Fetch notes for the selected date
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
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('date', descending: true)
          .get();

      final fetchedNotes = snapshot.docs.map((doc) {
        final data = doc.data();
        return Note(
          id: data['id'],
          title: data['title'],
          content: data['content'],
          date: (data['date'] as Timestamp).toDate(),
          imagePath: data['imagePath'],
          drawingPaths: List<String>.from(data['drawingPaths'] ?? []),
          mood: data['mood'],
        );
      }).toList();

      setState(() {
        _notesForSelectedDate = fetchedNotes;
        _isLoading = false;
      });

      // 🔔 Notification logic
      final now = DateTime.now();
      final isToday = now.year == date.year &&
          now.month == date.month &&
          now.day == date.day;

      if (isToday) {
        if (fetchedNotes.isEmpty) {
          await NotificationService.scheduleReminderNotification();
        } else {
          await NotificationService.cancelAll();
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error fetching notes: $e");
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
            onPressed: () => Navigator.pushNamed(context, '/settings'),
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
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Divider(
              color: Colors.grey.withOpacity(0.4),
              thickness: 1,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notesForSelectedDate.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No entries for this date yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _notesForSelectedDate.length,
              itemBuilder: (_, i) => DiaryCard(
                note: _notesForSelectedDate[i],
                refreshCallback: _fetchNotesForDate,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () async {
          await Navigator.pushNamed(
            context,
            '/add',
            arguments: _selectedDay,  // Pass the selected date to the add screen
          );
          _fetchNotesForDate(_selectedDay); // Refresh notes after returning
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

