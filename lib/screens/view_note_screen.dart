import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rdiary/screens/addNotes.dart';
import '../models/note.dart';

class ViewNoteScreen extends StatelessWidget {
  final Note note;
  const ViewNoteScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Note',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddNoteScreen(existingNote: note),
                ),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.mood != null)
              Row(
                children: [
                  const Text("Mood: ",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(note.mood!, style: const TextStyle(fontSize: 16)),
                ],
              ),
            const SizedBox(height: 6),
            Text(
              DateFormat.yMMMMd().format(note.date),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            if (note.title != null)
              Text(note.title!,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),

            const SizedBox(height: 12),
            Text(
              note.content,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            if (note.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(note.imagePath!),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 20),

            if (note.drawingPaths!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: note.drawingPaths!.map((path) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(path),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),

              ),
          ],
        ),
      ),
    );
  }
}
