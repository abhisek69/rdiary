import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../models/note.dart';
import '../models/note_provider.dart';
import '../screens/view_note_screen.dart';
import 'package:provider/provider.dart';

class DiaryCard extends StatelessWidget {
  final Note note;
  final void Function(DateTime) refreshCallback;

  const DiaryCard({super.key, required this.note, required this.refreshCallback});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Note"),
        content: const Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () async {
              await Provider.of<NoteProvider>(context, listen: false)
                  .deleteNote(note.id);
              Get.back();
              refreshCallback(note.date);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _chooseStatus(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Set Note Status"),
        content: const Text("Mark this note as Completed or Failed?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              note.status = "Failed";
              await Provider.of<NoteProvider>(context, listen: false)
                  .updateNote(note);
              Get.back();
              refreshCallback(note.date);
            },
            child: const Text("Failed"),
          ),
          ElevatedButton(
            onPressed: () async {
              note.status = "Completed";
              await Provider.of<NoteProvider>(context, listen: false)
                  .updateNote(note);
              Get.back();
              refreshCallback(note.date);
            },
            child: const Text("Completed"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ViewNoteScreen(note: note),
        ),
      ),
      onLongPress: () => _confirmDelete(context),
      onDoubleTap: () => _chooseStatus(context), // ✅ Double-tap support
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: note.imagePath != null
                ? Image.file(
              File(note.imagePath!),
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            )
                : (note.drawingPaths!.isNotEmpty
                ? Image.file(
              File(note.drawingPaths!.first),
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            )
                : Icon(Icons.book, size: 36, color: Theme.of(context).colorScheme.primary)),
          ),
          title: Text(
            style: const TextStyle(fontSize: 18),
            note.title?.trim().isNotEmpty == true
                ? note.title!
                : note.content.trim().split('\n').first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Content + Mood (aligned properly)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Content (flexible to avoid overflow)
                    if (note.content.trim().isNotEmpty)
                      Expanded(
                        child: Text(
                          note.content.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    const SizedBox(width: 8),
                    // Mood badge
                    if (note.mood != null && note.mood!.trim().isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          note.mood!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                // Status
                if (note.status != null)
                  Text(
                    "Status: ${note.status}",
                    style: TextStyle(
                      fontSize: 13,
                      color: note.status == "Completed" ? Colors.green : Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),

        ),
      ),
    );
  }
}



