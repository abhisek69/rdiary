import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  final String id;
  final String title;
  final List<String> goalDays;
  final DateTime? startDate;
  final DateTime? deadline;
  final List<String> completedDates;
  final DateTime createdAt;

  Goal({
    required this.id,
    required this.title,
    required this.goalDays,
    this.startDate,
    this.deadline,
    required this.completedDates,
    required this.createdAt,
  });

  /// 🔥 Remove time helper
  static DateTime _normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  factory Goal.fromFirestore(Map<String, dynamic> data, String id) {
    return Goal(
      id: id,
      title: data['title'] ?? '',
      goalDays: List<String>.from(data['goalDays'] ?? []),

      /// ✅ Normalize startDate
      startDate:
          data['startDate'] != null
              ? _normalize((data['startDate'] as Timestamp).toDate().toLocal())
              : null,

      /// ✅ Normalize deadline
      deadline:
          data['deadline'] != null
              ? _normalize((data['deadline'] as Timestamp).toDate().toLocal())
              : null,

      completedDates: List<String>.from(data['completedDates'] ?? []),

      createdAt: _normalize(
        (data['createdAt'] as Timestamp).toDate().toLocal(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'goalDays': goalDays,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'completedDates': completedDates,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
