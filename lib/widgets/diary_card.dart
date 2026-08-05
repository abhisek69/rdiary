import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../models/mood_model.dart';
import '../models/note.dart';
import '../models/note_provider.dart';
import '../screens/view_note_screen.dart';

class DiaryCard extends StatelessWidget {
  final Note note;
  final void Function(DateTime) refreshCallback;

  const DiaryCard({
    super.key,
    required this.note,
    required this.refreshCallback,
  });

  // ═══════════════════════════════════════════════════════════════
  // 🎨 MOOD COLOR SYSTEM
  //
  // These colors are used by the diary cards themselves.
  //
  // 😊 Happy  → Green
  // 😢 Sad    → Yellow
  // 😡 Anger  → Red
  // 🔥 Flame  → Original flame color
  // ✨ Others → White in dark mode
  //
  // This changes ONLY the visual appearance.
  // Your Firestore mood IDs remain untouched.
  // ═══════════════════════════════════════════════════════════════

  Color _getMoodColor(BuildContext context, dynamic mood) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final id = mood.id.toString().toLowerCase();

    switch (id) {
      // 😊 HAPPY
      case 'happy':
        return const Color(0xFF39E75F);

      // 😢 SAD
      case 'sad':
        return const Color(0xFFFFD740);

      // 😡 ANGER
      case 'anger':
      case 'angry':
        return const Color(0xFFFF3B3B);

      // 🔥 FLAME
      case 'flame':
      case 'fire':
        return mood.color;

      // ✨ OTHER MOODS
      default:
        return isDark ? Colors.white : mood.color;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🗑️ DELETE NOTE
  // Long press on a diary card.
  // ═══════════════════════════════════════════════════════════════

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Note'),

            content: const Text('Are you sure you want to delete this note?'),

            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),

                onPressed: () async {
                  await Provider.of<NoteProvider>(
                    context,
                    listen: false,
                  ).deleteNote(note.id);

                  Get.back();

                  refreshCallback(note.date);
                },

                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🏁 NOTE STATUS
  // Double tap → Completed / Failed
  // ═══════════════════════════════════════════════════════════════

  void _chooseStatus(BuildContext context) {
    showDialog(
      context: context,

      builder:
          (_) => AlertDialog(
            title: const Text('Set Note Status'),

            content: const Text('Mark this note as Completed or Failed?'),

            actions: [
              // ─────────────────────────────────────────────────────
              // CANCEL
              // ─────────────────────────────────────────────────────
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),

              // ─────────────────────────────────────────────────────
              // FAILED
              // ─────────────────────────────────────────────────────
              TextButton(
                onPressed: () async {
                  final updatedNote = note.copyWith(status: 'Failed');

                  await Provider.of<NoteProvider>(
                    context,
                    listen: false,
                  ).updateNote(updatedNote);

                  Get.back();

                  refreshCallback(note.date);
                },

                child: const Text(
                  'Failed',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),

              // ─────────────────────────────────────────────────────
              // COMPLETED
              // ─────────────────────────────────────────────────────
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),

                onPressed: () async {
                  final updatedNote = note.copyWith(status: 'Completed');

                  await Provider.of<NoteProvider>(
                    context,
                    listen: false,
                  ).updateNote(updatedNote);

                  Get.back();

                  refreshCallback(note.date);
                },

                child: const Text('Completed'),
              ),
            ],
          ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 📓 DIARY CARD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    // ───────────────────────────────────────────────────────────
    // Find the MoodData object belonging to this note.
    // ───────────────────────────────────────────────────────────

    final moodId = (note.mood ?? 'neutral').toLowerCase();

    final mood = MoodData.moods.firstWhere(
      (m) => m.id == moodId,
      orElse: () => MoodData.moods.last,
    );

    // This is the IMPORTANT value.
    //
    // From this point onward the card uses moodColor,
    // NOT mood.color.
    final moodColor = _getMoodColor(context, mood);

    return GestureDetector(
      // ═════════════════════════════════════════════════════════
      // TAP → OPEN NOTE
      // ═════════════════════════════════════════════════════════
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ViewNoteScreen(note: note)),
        );
      },

      // ═════════════════════════════════════════════════════════
      // LONG PRESS → DELETE
      // ═════════════════════════════════════════════════════════
      onLongPress: () {
        _confirmDelete(context);
      },

      // ═════════════════════════════════════════════════════════
      // DOUBLE TAP → STATUS
      // ═════════════════════════════════════════════════════════
      onDoubleTap: () {
        _chooseStatus(context);
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),

        curve: Curves.easeOut,

        margin: const EdgeInsets.only(bottom: 10),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),

          // ═════════════════════════════════════════════════════
          // 🌌 MOOD-TINTED GLASS
          //
          // Only a VERY small amount of the mood color is used
          // in the background. This prevents Happy from becoming
          // a giant green rectangle or Sad becoming bright yellow.
          // ═════════════════════════════════════════════════════
          color:
              isDark
                  ? Color.alphaBlend(
                    moodColor.withOpacity(0.055),
                    Colors.black.withOpacity(0.72),
                  )
                  : moodColor.withOpacity(0.045),

          // ═════════════════════════════════════════════════════
          // ✨ MOOD BORDER
          // ═════════════════════════════════════════════════════
          border: Border.all(
            color: moodColor.withOpacity(isDark ? 0.58 : 0.38),
            width: 1.1,
          ),

          // ═════════════════════════════════════════════════════
          // 🌟 SUBTLE MOOD GLOW
          // ═════════════════════════════════════════════════════
          boxShadow: [
            BoxShadow(
              color: moodColor.withOpacity(isDark ? 0.11 : 0.07),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),

          child: Material(
            color: Colors.transparent,

            child: InkWell(
              borderRadius: BorderRadius.circular(19),

              splashColor: moodColor.withOpacity(0.08),

              highlightColor: moodColor.withOpacity(0.035),

              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // ═══════════════════════════════════════════
                    // 😊 MOOD HEADER
                    // ═══════════════════════════════════════════
                    Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        // ───────────────────────────────────────
                        // Larger mood icon
                        // ───────────────────────────────────────
                        Container(
                          width: 30,
                          height: 30,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,

                            color: moodColor.withOpacity(0.10),

                            border: Border.all(
                              color: moodColor.withOpacity(0.25),
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: moodColor.withOpacity(0.15),
                                blurRadius: 8,
                              ),
                            ],
                          ),

                          child: Icon(mood.icon, size: 19, color: moodColor),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          mood.label,

                          style: TextStyle(
                            color: moodColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,

                            shadows:
                                isDark
                                    ? [
                                      Shadow(
                                        color: moodColor.withOpacity(0.30),
                                        blurRadius: 6,
                                      ),
                                    ]
                                    : null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 11),

                    // ═══════════════════════════════════════════
                    // 📝 TITLE
                    // ═══════════════════════════════════════════
                    if (note.title != null && note.title!.trim().isNotEmpty)
                      Text(
                        note.title!,

                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,

                          color:
                              isDark
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                        ),

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,
                      ),

                    if (note.title != null && note.title!.trim().isNotEmpty)
                      const SizedBox(height: 6),

                    // ═══════════════════════════════════════════
                    // 📖 CONTENT PREVIEW
                    // ═══════════════════════════════════════════
                    if (note.content.trim().isNotEmpty)
                      Text(
                        note.content.trim(),

                        maxLines: 2,

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,

                          color:
                              isDark
                                  ? Colors.white.withOpacity(0.78)
                                  : theme.colorScheme.onSurface.withOpacity(
                                    0.75,
                                  ),
                        ),
                      ),

                    // ═══════════════════════════════════════════
                    // 🖼️ IMAGE / DRAWING
                    // ═══════════════════════════════════════════
                    if (note.imagePath != null ||
                        (note.drawingPaths != null &&
                            note.drawingPaths!.isNotEmpty)) ...[
                      const SizedBox(height: 10),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),

                        child: Image.file(
                          File(note.imagePath ?? note.drawingPaths!.first),

                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],

                    // ═══════════════════════════════════════════
                    // 🏁 STATUS
                    // ═══════════════════════════════════════════
                    if (note.status != null) ...[
                      const SizedBox(height: 10),

                      Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Icon(
                            note.status == 'Completed'
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,

                            size: 16,

                            color:
                                note.status == 'Completed'
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                          ),

                          const SizedBox(width: 5),

                          Text(
                            note.status!,

                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,

                              color:
                                  note.status == 'Completed'
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
