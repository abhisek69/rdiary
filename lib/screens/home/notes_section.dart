import 'package:flutter/material.dart';

import '../../models/note.dart';
import '../../widgets/diary_card.dart';

class NotesSection extends StatelessWidget {
  final List<Note> notes;
  final Function(DateTime) refreshCallback;
  final DateTime selectedDay;

  const NotesSection({
    super.key,
    required this.notes,
    required this.refreshCallback,
    required this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    // Nothing to display for the selected date.
    if (notes.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ═══════════════════════════════════════════════════════
        // 📖 NOTES HEADER
        //
        // In cosmic mode we use a tiny glowing accent dot so
        // Notes visually belongs to the same system as Goals.
        // ═══════════════════════════════════════════════════════
        Row(
          children: [
            if (isDark) ...[
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary,
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.80),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
            ],

            Text(
              'Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(width: 7),

            // ─────────────────────────────────────────────────
            // Small cosmic book icon
            // ─────────────────────────────────────────────────
            if (isDark)
              Icon(
                Icons.auto_stories_rounded,
                size: 18,
                color: primary.withOpacity(0.85),
                shadows: [
                  Shadow(color: primary.withOpacity(0.50), blurRadius: 8),
                ],
              ),
          ],
        ),

        // Less empty space between title and first diary entry.
        const SizedBox(height: 8),

        // ═══════════════════════════════════════════════════════
        // 📓 DIARY ENTRIES
        // ═══════════════════════════════════════════════════════
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          padding: EdgeInsets.zero,

          itemCount: notes.length,

          separatorBuilder: (_, __) => const SizedBox(height: 10),

          itemBuilder: (context, index) {
            return DiaryCard(
              note: notes[index],
              refreshCallback: refreshCallback,
            );
          },
        ),

        // Small breathing room at the bottom.
        const SizedBox(height: 6),
      ],
    );
  }
}
