import 'package:flutter/material.dart';
import '../../models/note.dart';
import '../../widgets/diary_card.dart';

class NotesSection extends StatelessWidget {
  final List<Note> notes;
  final Function(DateTime) refreshCallback;
  final DateTime selectedDay;

  const NotesSection({
    super.key,
    required this.notes,
    required this.refreshCallback,
    required this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
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
          itemCount: notes.length,
          itemBuilder: (_, i) {
            return DiaryCard(
              note: notes[i],
              refreshCallback:
              refreshCallback,
            );
          },
        ),
      ],
    );
  }
}
