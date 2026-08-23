import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String? title;
  final String content;
  final DateTime date;
  final String? imagePath;
  final String? mood;
  final List<String>? drawingPaths;
  final String? status;
  final String? drawingData; 
  final String? drawingPreviewUrl;

  const Note({
    required this.id,
    this.title,
    required this.content,
    required this.date,
    this.imagePath,
    this.mood,
    this.drawingPaths,
    this.status,
    this.drawingData,
    this.drawingPreviewUrl,
  });

  // FROM FIRESTORE
  factory Note.fromFirestore(Map<String, dynamic> data, String id) {
    return Note(
      id: id,
      title: data['title'],
      content: data['content'],
      date: (data['date'] as Timestamp).toDate(),
      imagePath: data['imagePath'],
      drawingPaths:
          data['drawingPaths'] != null
              ? List<String>.from(data['drawingPaths'])
              : (data['images'] != null ? List<String>.from(data['images']) : []),
      mood: data['mood'],
      status: data['status'],
      drawingData: data['drawingData'],
      drawingPreviewUrl: data['drawingPreviewUrl'],
    );
  }

  // TO FIRESTORE
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'date': Timestamp.fromDate(date),
      'imagePath': imagePath,
      'drawingPaths': drawingPaths,
      'mood': mood,
      'status': status,
      'drawingData': drawingData,
      'drawingPreviewUrl': drawingPreviewUrl,
    };
  }

  // 🔥 PROFESSIONAL UPDATE METHOD
  Note copyWith({
    String? title,
    String? content,
    DateTime? date,
    String? imagePath,
    String? mood,
    List<String>? drawingPaths,
    String? status,
    String? drawingData,
    String? drawingPreviewUrl,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      imagePath: imagePath ?? this.imagePath,
      mood: mood ?? this.mood,
      drawingPaths: drawingPaths ?? this.drawingPaths,
      status: status ?? this.status,
      drawingData: drawingData ?? this.drawingData,
      drawingPreviewUrl: drawingPreviewUrl ?? this.drawingPreviewUrl,
    );
  }
}
