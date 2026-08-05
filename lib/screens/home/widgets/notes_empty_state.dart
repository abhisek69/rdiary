import 'package:flutter/material.dart';

class NotesEmptyState extends StatelessWidget {
  final Color primary;
  final String title;
  final String subtitle;

  const NotesEmptyState({
    super.key,
    required this.primary,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ───────────────────────────────────────────────────
            // 📖 Empty diary icon
            // ───────────────────────────────────────────────────
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.10),
                border: Border.all(
                  color: primary.withOpacity(0.40),
                ),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: primary.withOpacity(0.20),
                          blurRadius: 25,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                Icons.auto_stories_rounded,
                size: 32,
                color: primary,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark
                    ? Colors.white.withOpacity(0.55)
                    : theme.colorScheme.onSurface.withOpacity(0.60),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
