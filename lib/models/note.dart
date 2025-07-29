import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Note {
  final String id;
  final String? title;
  final String content;
  final DateTime date;
  final String? imagePath;
  final String? mood;
  final List? drawingPaths;
  String? status;

  Note({
    required this.id,
    this.title,
    required this.content,
    required this.date,
    this.imagePath,
    this.mood,
    this.drawingPaths,
    this.status
  });
  factory Note.fromFirestore(Map<String, dynamic> data, String id) {
    return Note(
      id: id,
      title: data['title'],
      content: data['content'],
      date: (data['date'] as Timestamp).toDate(),
      imagePath: data['imagePath'],
      drawingPaths: List<String>.from(data['drawingPaths'] ?? []),
      mood: data['mood'],
    );
  }
}
