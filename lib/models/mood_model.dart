import 'package:flutter/material.dart';

class Mood {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const Mood({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class MoodData {
  static const List<Mood> moods = [
    Mood(
      id: 'happy',
      label: 'Happy',
      icon: Icons.sentiment_very_satisfied_rounded,
      color: Color(0xFFFFC107),
    ),
    Mood(
      id: 'sad',
      label: 'Sad',
      icon: Icons.sentiment_dissatisfied_rounded,
      color: Color(0xFF42A5F5),
    ),
    Mood(
      id: 'angry',
      label: 'Angry',
      icon: Icons.sentiment_very_dissatisfied_rounded,
      color: Color(0xFFEF5350),
    ),
    Mood(
      id: 'calm',
      label: 'Calm',
      icon: Icons.self_improvement_rounded,
      color: Color(0xFF26A69A),
    ),
    Mood(
      id: 'excited',
      label: 'Excited',
      icon: Icons.celebration_rounded,
      color: Color(0xFFAB47BC),
    ),
    Mood(
      id: 'neutral',
      label: 'Neutral',
      icon: Icons.remove_rounded,
      color: Color(0xFF9E9E9E),
    ),
  ];
}
