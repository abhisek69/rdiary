import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../models/mood_model.dart';
import '../models/note.dart';
import '../models/note_provider.dart';
import '../screens/addSubject/addSubject.dart';
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
  // ═══════════════════════════════════════════════════════════════

  Color _getMoodColor(BuildContext context, dynamic mood) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = mood.id.toString().toLowerCase();

    switch (id) {
      case 'happy':
        // Darker in light mode so it stays readable.
        return isDark ? const Color(0xFF39E75F) : const Color(0xFF159447);

      case 'sad':
        // Bright yellow disappears on white glass.
        // Amber/gold works much better in light mode.
        return isDark ? const Color(0xFFFFD740) : const Color(0xFFD79500);

      case 'anger':
      case 'angry':
        return isDark ? const Color(0xFFFF5252) : const Color(0xFFD92C2C);

      case 'flame':
      case 'fire':
        return isDark ? mood.color : const Color(0xFFE66A18);

      case 'neutral':
        return isDark ? const Color(0xFFBFC5D2) : const Color(0xFF5D6470);

      default:
        return isDark ? Colors.white70 : const Color(0xFF5D6470);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🗑 DELETE NOTE
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
  // ═══════════════════════════════════════════════════════════════

  void _chooseStatus(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Set Note Status'),
            content: const Text('Mark this note as Completed or Failed?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),

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
  // 📓 BUILD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildImage(String path, {double height = 120, double? width}) {
    final bool isNetwork = path.startsWith('http');
    return isNetwork
        ? Image.network(
            path,
            height: height,
            width: width ?? double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) =>
                progress == null ? child : const Center(child: CircularProgressIndicator()),
          )
        : Image.file(
            File(path),
            height: height,
            width: width ?? double.infinity,
            fit: BoxFit.cover,
          );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    final onSurface = theme.colorScheme.onSurface;

    // ─────────────────────────────────────────────────────────────
    // MOOD
    // ─────────────────────────────────────────────────────────────

    final moodId = (note.mood ?? 'neutral').toLowerCase();

    final mood = MoodData.moods.firstWhere(
      (m) => m.id == moodId,
      orElse: () => MoodData.moods.last,
    );

    final moodColor = _getMoodColor(context, mood);

    final String? firstImagePath = note.imagePath ??
        note.drawingPreviewUrl ??
        (note.drawingPaths != null && note.drawingPaths!.isNotEmpty
            ? note.drawingPaths!.first
            : null);

    // ═════════════════════════════════════════════════════════════
    // GLASS COLORS
    // ═════════════════════════════════════════════════════════════

    final glassColor =
        isDark
            ? Color.alphaBlend(
              moodColor.withOpacity(0.055),
              Colors.black.withOpacity(0.64),
            )
            : Color.alphaBlend(
              moodColor.withOpacity(0.035),
              Colors.white.withOpacity(0.46),
            );

    final borderColor = moodColor.withOpacity(isDark ? 0.82 : 0.78);

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ViewNoteScreen(note: note)),
        );
        refreshCallback(note.date);
      },

      onLongPress: () {
        _confirmDelete(context);
      },

      onDoubleTap: () {
        _chooseStatus(context);
      },

      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),

          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: isDark ? 5 : 4,
              sigmaY: isDark ? 5 : 4,
            ),

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),

              curve: Curves.easeOut,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),

                // ─────────────────────────────────────────────
                // GLASS
                // ─────────────────────────────────────────────
                color: glassColor,

                // ─────────────────────────────────────────────
                // STRONGER MOOD BORDER
                // ─────────────────────────────────────────────
                border: Border.all(color: borderColor, width: 1.6),

                // ─────────────────────────────────────────────
                // MOOD GLOW
                // ─────────────────────────────────────────────
                boxShadow: [
                  BoxShadow(
                    color: moodColor.withOpacity(isDark ? 0.16 : 0.12),
                    blurRadius: isDark ? 16 : 12,
                    spreadRadius: 0.3,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),

              child: Material(
                color: Colors.transparent,

                child: InkWell(
                  borderRadius: BorderRadius.circular(20),

                  splashColor: moodColor.withOpacity(0.10),

                  highlightColor: moodColor.withOpacity(0.05),

                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // ═════════════════════════════════════
                        // 😊 MOOD HEADER
                        // ═════════════════════════════════════
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ─────────────────────────────────
                                // BIGGER MOOD BADGE
                                // ─────────────────────────────────
                                Container(
                                  width: 38,
                                  height: 38,

                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,

                                    color: moodColor.withOpacity(
                                      isDark ? 0.17 : 0.13,
                                    ),

                                    border: Border.all(
                                      color: moodColor.withOpacity(
                                        isDark ? 0.90 : 0.82,
                                      ),
                                      width: 1.5,
                                    ),

                                    boxShadow: [
                                      BoxShadow(
                                        color: moodColor.withOpacity(
                                          isDark ? 0.28 : 0.18,
                                        ),
                                        blurRadius: 10,
                                        spreadRadius: 0.5,
                                      ),
                                    ],
                                  ),

                                  child: Icon(
                                    mood.icon,

                                    // Bigger than old 19px.
                                    size: 22,

                                    // Full mood color.
                                    color: moodColor,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                // ─────────────────────────────────
                                // MOOD NAME
                                // ─────────────────────────────────
                                Text(
                                  mood.label,

                                  style: TextStyle(
                                    color: moodColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.1,

                                    shadows:
                                        isDark
                                            ? [
                                              Shadow(
                                                color: moodColor.withOpacity(
                                                  0.45,
                                                ),
                                                blurRadius: 7,
                                              ),
                                            ]
                                            : null,
                                  ),
                                ),
                              ],
                            ),
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: onSurface.withOpacity(0.5),
                              ),
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => AddSubjectScreen(
                                            selectedDate: note.date,
                                            existingNote: note,
                                          ),
                                    ),
                                  );
                                  refreshCallback(note.date);
                                } else if (value == 'delete') {
                                  _confirmDelete(context);
                                }
                              },
                              itemBuilder:
                                  (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 18),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 11),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ═════════════════════════════════════
                                  // 📝 TITLE
                                  // ═════════════════════════════════════
                                  if (note.title != null &&
                                      note.title!.trim().isNotEmpty) ...[
                                    Text(
                                      note.title!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            isDark
                                                ? Colors.white
                                                : onSurface.withOpacity(0.95),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                  ],

                                  // ═════════════════════════════════════
                                  // 📖 CONTENT
                                  // ═════════════════════════════════════
                                  if (note.content.trim().isNotEmpty)
                                    Text(
                                      note.content.trim(),
                                      maxLines: firstImagePath != null ? 3 : 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                        color:
                                            isDark
                                                ? Colors.white.withOpacity(0.82)
                                                : onSurface.withOpacity(0.90),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // ═════════════════════════════════════
                            // 🖼 SMALL IMAGE / DRAWING PREVIEW
                            // ═════════════════════════════════════
                            if (firstImagePath != null) ...[
                              const SizedBox(width: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _buildImage(
                                  firstImagePath,
                                  height: 70,
                                  width: 70,
                                ),
                              ),
                            ],
                          ],
                        ),

                        // ═════════════════════════════════════
                        // 🏁 STATUS
                        // ═════════════════════════════════════
                        if (note.status != null) ...[
                          const SizedBox(height: 10),

                          Row(
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              Icon(
                                note.status == 'Completed'
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,

                                size: 17,

                                color:
                                    note.status == 'Completed'
                                        ? Colors.green
                                        : Colors.redAccent,
                              ),

                              const SizedBox(width: 5),

                              Text(
                                note.status!,

                                style: TextStyle(
                                  fontSize: 13,

                                  fontWeight: FontWeight.w700,

                                  color:
                                      note.status == 'Completed'
                                          ? isDark
                                              ? Colors.greenAccent
                                              : Colors.green.shade800
                                          : isDark
                                          ? Colors.redAccent
                                          : Colors.red.shade800,
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
        ),
      ),
    );
  }
}
