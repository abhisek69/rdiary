import 'package:flutter/material.dart';

class NoteGroupTimelineHeader extends StatelessWidget {
  final String title;
  final Color primary;

  const NoteGroupTimelineHeader({
    super.key,
    required this.title,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(
        top: 12,
        bottom: 12,
      ),
      child: Row(
        children: [
          // ─────────────────────────────────────────────────────
          // ✨ Timeline star
          // ─────────────────────────────────────────────────────
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary,
              border: Border.all(
                color: Colors.white.withOpacity(
                  isDark ? 0.55 : 0.25,
                ),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(
                    0.75,
                  ),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ─────────────────────────────────────────────────────
          // 📅 Date label
          // ─────────────────────────────────────────────────────
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: isDark ? Colors.white.withOpacity(0.88) : primary,
            ),
          ),

          const SizedBox(width: 12),

          // ─────────────────────────────────────────────────────
          // 🌌 Fading cosmic line
          // ─────────────────────────────────────────────────────
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primary.withOpacity(
                      0.50,
                    ),
                    primary.withOpacity(
                      0.08,
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 5),

          Icon(
            Icons.auto_awesome_rounded,
            size: 13,
            color: primary.withOpacity(
              0.70,
            ),
          ),
        ],
      ),
    );
  }
}
