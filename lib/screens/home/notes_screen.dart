import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rdiary/utils/pulseLoader.dart';

import '../../models/note.dart';
import '../../widgets/diary_card.dart';
import '../../widgets/mood_selector.dart';

import '../../backgrounds/diary_world/diary_world.dart';
import '../../backgrounds/diary_world/diary_world_background.dart';
import '../../theme/app_theme.dart';

import 'widgets/notes_archive_header.dart';
import 'widgets/note_group_timeline_header.dart';
import 'widgets/notes_empty_state.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _sortType = 'date_desc';
  String? _selectedMood;

  // ═══════════════════════════════════════════════════════════════
  // 📅 NOTE GROUP TITLE
  // ═══════════════════════════════════════════════════════════════

  String _groupTitle(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final noteDate = DateTime(date.year, date.month, date.day);

    if (noteDate == today) {
      return 'Today';
    }

    if (noteDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }

    if (date.month == now.month && date.year == now.year) {
      return 'This Month';
    }

    return DateFormat('MMMM yyyy').format(date);
  }

  // ═══════════════════════════════════════════════════════════════
  // 🌍 MAIN NOTES SCREEN
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    // ------------------------------------------------------------
    // USER-SELECTED DIARY WORLD
    // ------------------------------------------------------------

    final themeProvider = context.watch<ThemeProvider>();

    final selectedWorld = themeProvider.diaryWorld;

    /// Theme-less = no environmental world.
    final worldEnabled = selectedWorld != DiaryWorld.simple;

    // ------------------------------------------------------------
    // NORMAL FLUTTER THEME
    // ------------------------------------------------------------

    final theme = Theme.of(context);

    final colors = theme.colorScheme;

    final primary = colors.primary;

    final isDark = theme.brightness == Brightness.dark;

    final user = FirebaseAuth.instance.currentUser;

    // ═════════════════════════════════════════════════════════════
    // 🔐 USER CHECK
    // ═════════════════════════════════════════════════════════════

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not logged in')));
    }

    // ═════════════════════════════════════════════════════════════
    // 📓 NOTES SCAFFOLD
    //
    // World active:
    // Transparent so the environmental world is visible.
    //
    // Theme-less:
    // Normal Flutter scaffold background.
    // ═════════════════════════════════════════════════════════════

    final screen = Scaffold(
      backgroundColor:
          worldEnabled ? Colors.transparent : theme.scaffoldBackgroundColor,

      // ═══════════════════════════════════════════════════════════
      // 📖 APP BAR
      // ═══════════════════════════════════════════════════════════
      appBar: AppBar(
        title: const Text('All Notes'),

        centerTitle: true,

        elevation: 0,

        scrolledUnderElevation: 0,

        surfaceTintColor: Colors.transparent,

        backgroundColor: worldEnabled ? Colors.transparent : null,

        actions: [
          // ─────────────────────────────────────────────────────
          // ↕️ SORT
          // ─────────────────────────────────────────────────────
          PopupMenuButton<String>(
            tooltip: 'Sort notes',

            onSelected: (value) {
              setState(() {
                _sortType = value;
              });
            },

            itemBuilder:
                (_) => const [
                  PopupMenuItem(
                    value: 'date_desc',
                    child: Row(
                      children: [
                        Icon(Icons.arrow_downward_rounded, size: 18),

                        SizedBox(width: 9),

                        Text('Newest First'),
                      ],
                    ),
                  ),

                  PopupMenuItem(
                    value: 'date_asc',
                    child: Row(
                      children: [
                        Icon(Icons.arrow_upward_rounded, size: 18),

                        SizedBox(width: 9),

                        Text('Oldest First'),
                      ],
                    ),
                  ),
                ],

            icon: Icon(
              Icons.sort_rounded,
              color: worldEnabled && isDark ? primary : null,
            ),
          ),

          const SizedBox(width: 5),
        ],
      ),

      // ═══════════════════════════════════════════════════════════
      // 📖 BODY
      // ═══════════════════════════════════════════════════════════
      body: Column(
        children: [
          // ═════════════════════════════════════════════════════
          // 🌌 MEMORY ARCHIVE HERO
          //
          // Only show the special environmental header while
          // a Diary World is enabled.
          // ═════════════════════════════════════════════════════
          if (worldEnabled)
            NotesArchiveHeader(primary: primary)
          else
            const SizedBox(height: 8),

          // ═════════════════════════════════════════════════════
          // 🎭 MOOD FILTER
          // ═════════════════════════════════════════════════════
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: isDark ? 5 : 4,
                  sigmaY: isDark ? 5 : 4,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),

                    color: isDark
                        ? Colors.black.withOpacity(0.38)
                        : Colors.white.withOpacity(0.34),

                    border: Border.all(
                      color: primary.withOpacity(
                        isDark ? 0.48 : 0.42,
                      ),
                      width: 1.1,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(
                          isDark ? 0.10 : 0.07,
                        ),
                        blurRadius: 12,
                      ),
                    ],
                  ),

                  child: MoodSelector(
                    selectedMoodId: _selectedMood,
                    showLabel: false,
                    includeAll: true,

                    onSelected: (moodId) {
                      setState(() {
                        _selectedMood = moodId;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // ═════════════════════════════════════════════════════
          // 📚 FIRESTORE NOTES
          // ═════════════════════════════════════════════════════
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('notes')
                      .orderBy('date', descending: true)
                      .snapshots(),

              builder: (context, snapshot) {
                // ═══════════════════════════════════════════════
                // ❌ ERROR
                // ═══════════════════════════════════════════════

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 50,
                            color: colors.error,
                          ),

                          const SizedBox(height: 14),

                          const Text(
                            'Could not load your notes.',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            snapshot.error.toString(),

                            textAlign: TextAlign.center,

                            style: TextStyle(
                              fontSize: 12,

                              color: colors.onSurface.withOpacity(0.60),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // ═══════════════════════════════════════════════
                // ⏳ LOADING
                // ═══════════════════════════════════════════════

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: AppLoader(loadingColor: primary));
                }

                // ═══════════════════════════════════════════════
                // 📭 NO NOTES
                // ═══════════════════════════════════════════════

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return NotesEmptyState(
                    primary: primary,
                    title: 'No memories yet',
                    subtitle:
                        'Your diary stories will appear here once you start writing.',
                  );
                }

                List<QueryDocumentSnapshot> docs = List.from(
                  snapshot.data!.docs,
                );

                // ═══════════════════════════════════════════════
                // 🎭 MOOD FILTER
                // ═══════════════════════════════════════════════

                if (_selectedMood != null) {
                  docs =
                      docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        final mood =
                            (data['mood'] ?? 'neutral')
                                .toString()
                                .toLowerCase();

                        return mood == _selectedMood;
                      }).toList();
                }

                // ═══════════════════════════════════════════════
                // ↕️ SORTING
                // ═══════════════════════════════════════════════

                docs.sort((a, b) {
                  final aDate = a['date'] as Timestamp;

                  final bDate = b['date'] as Timestamp;

                  return _sortType == 'date_asc'
                      ? aDate.compareTo(bDate)
                      : bDate.compareTo(aDate);
                });

                // ═══════════════════════════════════════════════
                // 🔎 FILTER RETURNED NOTHING
                // ═══════════════════════════════════════════════

                if (docs.isEmpty) {
                  return NotesEmptyState(
                    primary: primary,
                    title: 'No memories found',
                    subtitle: 'There are no diary entries for this mood yet.',
                  );
                }

                // ═══════════════════════════════════════════════
                // ✨ MEMORY LIST
                // ═══════════════════════════════════════════════

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),

                  child: ListView.builder(
                    key: ValueKey('$_sortType-${_selectedMood ?? "all"}'),

                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),

                    itemCount: docs.length,

                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;

                      // ─────────────────────────────────────────
                      // 📅 DATE
                      // ─────────────────────────────────────────

                      final date = (data['date'] as Timestamp).toDate();

                      final currentGroup = _groupTitle(date);

                      String? previousGroup;

                      if (index > 0) {
                        final previousData =
                            docs[index - 1].data() as Map<String, dynamic>;

                        final prevDate =
                            (previousData['date'] as Timestamp).toDate();

                        previousGroup = _groupTitle(prevDate);
                      }

                      // ═════════════════════════════════════════
                      // 🔥 FIRESTORE → NOTE MODEL
                      // ═════════════════════════════════════════

                      final note = Note.fromFirestore(data, docs[index].id);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // ═════════════════════════════════════
                          // 📅 GROUP HEADER
                          // ═════════════════════════════════════
                          if (index == 0 || currentGroup != previousGroup)
                            NoteGroupTimelineHeader(
                              title: currentGroup,
                              primary: primary,
                            ),

                          // ═════════════════════════════════════
                          // 📖 DIARY CARD
                          // ═════════════════════════════════════
                          SizedBox(
                            width: double.infinity,

                            child: DiaryCard(
                              note: note,

                              refreshCallback: (_) {
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    // ═════════════════════════════════════════════════════════════
    // 🌍 DIARY WORLD ROUTER
    //
    // This is now controlled by ThemeProvider.
    //
    // Theme-less
    //     ↓
    // DiaryWorld.simple
    //
    // Cosmic Universe
    //     ↓
    // DiaryWorld.cosmicUniverse
    //
    // Future:
    // Moonlight Ocean
    // Forest Fireflies
    // Butterfly Garden
    // Rainy Street
    // ═════════════════════════════════════════════════════════════

    return DiaryWorldBackground(
      world: selectedWorld,
      scene: DiaryScene.notes,
      accentColor: primary,
      brightness: theme.brightness,
      child: screen,
    );
  }
}
