import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rdiary/utils/pulseLoader.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _sortType = "date_desc";
  String _selectedMood = "All";

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
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Notes"),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _sortType = value);
            },
            itemBuilder:
                (_) => const [
                  PopupMenuItem(
                    value: "date_desc",
                    child: Text("Newest First"),
                  ),
                  PopupMenuItem(value: "date_asc", child: Text("Oldest First")),
                ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 8),

          /// Mood Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildChip("All"),
                _buildChip("Happy"),
                _buildChip("Sad"),
                _buildChip("Angry"),
              ],
            ),
          ),

          const SizedBox(height: 8),

          /// Notes List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('notes')
                      .orderBy('date', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: AppLoader(loadingColor: colors.primary));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No notes available"));
                }

                /// 🔥 Convert Docs
                List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

                /// 🔥 Local Mood Filter
                if (_selectedMood != "All") {
                  docs =
                      docs.where((doc) {
                        return (doc['mood'] ?? "") == _selectedMood;
                      }).toList();
                }

                /// 🔥 Local Date Sort
                if (_sortType == "date_asc") {
                  docs.sort(
                    (a, b) => (a['date'] as Timestamp).compareTo(
                      b['date'] as Timestamp,
                    ),
                  );
                } else {
                  docs.sort(
                    (a, b) => (b['date'] as Timestamp).compareTo(
                      a['date'] as Timestamp,
                    ),
                  );
                }

                if (docs.isEmpty) {
                  return const Center(child: Text("No notes found"));
                }

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: ListView.builder(
                    key: ValueKey(_sortType + _selectedMood),
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;

                      final date = (data['date'] as Timestamp).toDate();

                      final formattedDate = DateFormat(
                        'dd MMM yyyy • hh:mm a',
                      ).format(date);

                      final currentGroup = _groupTitle(date);

                      String? previousGroup;
                      if (index > 0) {
                        final prevDate =
                            (docs[index - 1]['date'] as Timestamp).toDate();
                        previousGroup = _groupTitle(prevDate);
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0 || currentGroup != previousGroup)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                currentGroup,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary,
                                ),
                              ),
                            ),

                          Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colors.primary.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          data['mood'] ?? "No Mood",
                                          style: TextStyle(
                                            color: colors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colors.onSurface.withOpacity(
                                            0.6,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    data['content'] ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
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

  Widget _buildChip(String mood) {
    final isSelected = _selectedMood == mood;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selectedColor: Theme.of(context).primaryColor,
        label: Text(mood),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedMood = mood;
          });
        },
      ),
    );
  }
}
