import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/note.dart';
import '../widgets/diary_card.dart';
import '../widgets/diary_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('date', descending: true)
        .get();

    final notes = snapshot.docs.map((doc) {
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
      _notesForSelectedDate = notes;
      _isLoading = false;
    });
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
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
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
                refreshCallback: _fetchNotesForDate, // Callback to refresh
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
            arguments: _selectedDay, // Pass selected day
          );
          _fetchNotesForDate(_selectedDay); // Refresh after return
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
