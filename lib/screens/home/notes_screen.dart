import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rdiary/utils/pulseLoader.dart';

import '../../models/note.dart';
import '../../widgets/diary_card.dart';
import '../../widgets/mood_selector.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _sortType = "date_desc";
  String? _selectedMood;

  String _groupTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final noteDate = DateTime(date.year, date.month, date.day);

    if (noteDate == today) return "Today";
    if (noteDate == today.subtract(const Duration(days: 1))) {
      return "Yesterday";
    }
    if (date.month == now.month && date.year == now.year) {
      return "This Month";
    }
    return DateFormat('MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Notes"),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _sortType = value),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: "date_desc",
                child: Text("Newest First"),
              ),
              PopupMenuItem(
                value: "date_asc",
                child: Text("Oldest First"),
              ),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          /// 🔥 Mood Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MoodSelector(
              selectedMoodId: _selectedMood,
              showLabel: false,
              includeAll: true,// 👈 we add this
              onSelected: (moodId) {
                setState(() => _selectedMood = moodId);
              },
            ),
          ),
          const SizedBox(height: 8),

          /// 🔥 Notes List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('notes')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: AppLoader(
                      loadingColor: colors.primary,
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("No notes available"));
                }

                List<QueryDocumentSnapshot> docs =
                List.from(snapshot.data!.docs);

                /// 🔥 Mood Filter
                if (_selectedMood != null) {
                  docs = docs.where((doc) {
                    final mood = (doc['mood'] ?? "neutral")
                        .toString()
                        .toLowerCase();
                    return mood == _selectedMood;
                  }).toList();
                }

                /// 🔥 Sorting
                docs.sort((a, b) {
                  final aDate = a['date'] as Timestamp;
                  final bDate = b['date'] as Timestamp;

                  return _sortType == "date_asc"
                      ? aDate.compareTo(bDate)
                      : bDate.compareTo(aDate);
                });

                if (docs.isEmpty) {
                  return const Center(
                      child: Text("No notes found"));
                }

                return AnimatedSwitcher(
                  duration:
                  const Duration(milliseconds: 300),
                  child: ListView.builder(
                    key: ValueKey(
                        "$_sortType-${_selectedMood ?? "all"}"),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data =
                      docs[index].data()
                      as Map<String, dynamic>;

                      final date =
                      (data['date'] as Timestamp)
                          .toDate();

                      final currentGroup =
                      _groupTitle(date);

                      String? previousGroup;
                      if (index > 0) {
                        final prevDate =
                        (docs[index - 1]['date']
                        as Timestamp)
                            .toDate();
                        previousGroup =
                            _groupTitle(prevDate);
                      }

                      /// ✅ Convert Firestore doc to Note model
                      final note = Note(
                        id: docs[index].id,
                        title: data['title'],
                        content:
                        data['content'] ?? "",
                        date: date,
                        mood:
                        data['mood'] ?? "neutral",
                        imagePath:
                        data['imagePath'],
                        drawingPaths:
                        List<String>.from(
                          data['drawingPaths'] ??
                              [],
                        ),
                        status: data['status'],
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0 || currentGroup != previousGroup)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                currentGroup,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary,
                                ),
                              ),
                            ),

                          SizedBox(
                            width: double.infinity,
                            child: DiaryCard(
                              note: note,
                              refreshCallback: (_) {
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }




}
