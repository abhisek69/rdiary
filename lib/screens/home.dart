import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/note_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);
    final notes = noteProvider.notes.where((note) {
      return isSameDay(note.date, _selectedDay);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Diary"),
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
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
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
            child: notes.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No entries for this date yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  // ElevatedButton.icon(
                  //   onPressed: () => Navigator.pushNamed(
                  //     context,
                  //     '/add',
                  //     arguments: _selectedDay, // Pass selected date
                  //   ),
                  //   icon: const Icon(Icons.add),
                  //   label: const Text("Add Entry"),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor:
                  //     Theme.of(context).colorScheme.primary,
                  //     foregroundColor: Colors.white,
                  //   ),
                  // ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notes.length,
              itemBuilder: (_, i) => DiaryCard(note: notes[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () => Navigator.pushNamed(
          context,
          '/add',
          arguments: _selectedDay, // Pass selected day
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
