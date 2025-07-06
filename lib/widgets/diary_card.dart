import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../models/note.dart';
import '../models/note_provider.dart';
import '../screens/view_note_screen.dart';
import 'package:provider/provider.dart';

class DiaryCard extends StatelessWidget {
  final Note note;
  const DiaryCard({super.key, required this.note});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Note"),
        content: const Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              Provider.of<NoteProvider>(context, listen: false).deleteNote(note.id);
              Navigator.pop(context); // close dialog
            },
            child: const Text("Delete" , style: TextStyle(color: Colors.white),),
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
      onLongPress: () => _confirmDelete(context), // Long press triggers delete dialog
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
                : const Icon(Icons.book, size: 36)),
          ),

          title: Text(
            note.title?.trim().isNotEmpty == true
                ? note.title!
                : note.content.trim().split('\n').first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(DateFormat.yMMMd().format(note.date)),
        ),
      ),
    );
  }
}
