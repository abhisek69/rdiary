import 'package:flutter/material.dart';

class Note {
  final String id;
  final String? title;
  final String content;
  final DateTime date;
  final String? imagePath;
  final String? mood;
  final List? drawingPaths;

  Note({
    required this.id,
    this.title,
    required this.content,
    required this.date,
    this.imagePath,
    this.mood,
    this.drawingPaths,
  });
}
