import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  final String id;
  final String title;
  final List<String> goalDays;
  final DateTime? deadline;
  final List<String> completedDates; // 🔥 NEW
  final DateTime createdAt;

  Goal({
    required this.id,
    required this.title,
    required this.goalDays,
    this.deadline,
    required this.completedDates,
    required this.createdAt,
  });

  factory Goal.fromFirestore(Map<String, dynamic> data, String id) {
    return Goal(
      id: id,
      title: data['title'],
      goalDays: List<String>.from(data['goalDays'] ?? []),
      deadline: data['deadline'] != null
          ? (data['deadline'] as Timestamp).toDate()
          : null,
      completedDates:
      List<String>.from(data['completedDates'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'goalDays': goalDays,
      'deadline': deadline != null
          ? Timestamp.fromDate(deadline!)
          : null,
      'completedDates': completedDates,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
