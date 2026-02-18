import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../models/mood_model.dart';
import '../models/note.dart';
import '../models/note_provider.dart';
import '../screens/view_note_screen.dart';
import 'package:provider/provider.dart';

class DiaryCard extends StatelessWidget {
  final Note note;
  final void Function(DateTime) refreshCallback;

  const DiaryCard(
      {super.key, required this.note, required this.refreshCallback});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: const Text("Delete Note"),
            content: const Text("Are you sure you want to delete this note?"),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                ),
                onPressed: () async {
                  await Provider.of<NoteProvider>(context, listen: false)
                      .deleteNote(note.id);
                  Get.back();
                  refreshCallback(note.date);
                },
                child: const Text(
                    "Delete", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  void _chooseStatus(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: const Text("Set Note Status"),
            content: const Text("Mark this note as Completed or Failed?"),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  final updatedNote = note.copyWith(status: "Failed");
                  await Provider.of<NoteProvider>(context, listen: false)
                      .updateNote(note);
                  Get.back();
                  refreshCallback(note.date);
                },
                child: const Text("Failed"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final updatedNote = note.copyWith(status: "Failed");
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
    final moodId = (note.mood ?? "neutral").toLowerCase();

    final mood = MoodData.moods.firstWhere(
          (m) => m.id == moodId,
      orElse: () => MoodData.moods.last,
    );

    final colors = Theme
        .of(context)
        .colorScheme;

    return GestureDetector(
      onTap: () =>
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ViewNoteScreen(note: note),
            ),
          ),
      onLongPress: () => _confirmDelete(context),
      onDoubleTap: () => _chooseStatus(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: mood.color.withOpacity(0.05),
          border: Border.all(
            color: mood.color.withOpacity(0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: mood.color.withOpacity(0.08),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🔥 Top Row (Mood + Date)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          mood.icon,
                          size: 16,
                          color: mood.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          mood.label,
                          style: TextStyle(
                            color: mood.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),


                    const SizedBox(height: 12),

                    /// 🔥 Title
                    if (note.title != null &&
                        note.title!.trim().isNotEmpty)
                      Text(
                        note.title!,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    if (note.title != null &&
                        note.title!.trim().isNotEmpty)
                      const SizedBox(height: 6),

                    /// 🔥 Content Preview
                    if (note.content
                        .trim()
                        .isNotEmpty)
                      Text(
                        note.content.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),

                    const SizedBox(height: 10),

                    /// 🔥 Image / Drawing Preview
                    if (note.imagePath != null ||
                        (note.drawingPaths != null &&
                            note.drawingPaths!.isNotEmpty))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(
                              note.imagePath ??
                                  note.drawingPaths!.first,
                            ),
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    /// 🔥 Status Indicator
                    if (note.status != null)
                      Text(
                        "Status: ${note.status}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: note.status == "Completed"
                              ? Colors.green
                              : Colors.redAccent,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


