import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rdiary/utils/pulseLoader.dart';

import '../../models/note.dart';
import '../../widgets/diary_card.dart';
import '../../widgets/mood_selector.dart';

import 'designs/cosmic_bg.dart';

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
  //
  // Notes are automatically separated into:
  // Today
  // Yesterday
  // This Month
  // Older months
  // ═══════════════════════════════════════════════════════════════

  String _groupTitle(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final noteDate = DateTime(
      date.year,
      date.month,
      date.day,
    );

    if (noteDate == today) {
      return 'Today';
    }

    if (noteDate ==
        today.subtract(
          const Duration(days: 1),
        )) {
      return 'Yesterday';
    }

    if (date.month == now.month &&
        date.year == now.year) {
      return 'This Month';
    }

    return DateFormat(
      'MMMM yyyy',
    ).format(date);
  }

  // ═══════════════════════════════════════════════════════════════
  // ✨ SMALL COSMIC STAR
  // ═══════════════════════════════════════════════════════════════

  Widget _star(
      Color color,
      double size,
      ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.8),
            blurRadius: 7,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🌌 MEMORY ARCHIVE HERO
  //
  // Gives Notes its own identity while still belonging to the
  // same cosmic universe as Home and Goals.
  // ═══════════════════════════════════════════════════════════════

  Widget _buildCosmicNotesHeader(
      BuildContext context,
      Color primary,
      ) {
    final theme = Theme.of(context);

    final isDark =
        theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        14,
      ),

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(24),

          // 🌌 Glass effect
          color: isDark
              ? Colors.black.withOpacity(0.38)
              : theme.colorScheme.surface,

          border: Border.all(
            color:
            primary.withOpacity(0.32),
            width: 1.1,
          ),

          boxShadow: [
            BoxShadow(
              color:
              primary.withOpacity(
                isDark ? 0.15 : 0.08,
              ),
              blurRadius: 25,
              spreadRadius: 1,
            ),
          ],
        ),

        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ═══════════════════════════════════════════════════
            // 🌈 SOFT COSMIC GLOW
            // ═══════════════════════════════════════════════════

            if (isDark)
              Positioned(
                right: -15,
                top: -25,

                child: Container(
                  width: 105,
                  height: 105,

                  decoration:
                  BoxDecoration(
                    shape: BoxShape.circle,

                    gradient:
                    RadialGradient(
                      colors: [
                        primary
                            .withOpacity(
                          0.28,
                        ),
                        primary
                            .withOpacity(
                          0.07,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

            // ═══════════════════════════════════════════════════
            // ✨ DECORATIVE STARS
            // ═══════════════════════════════════════════════════

            if (isDark) ...[
              Positioned(
                right: 5,
                top: 4,
                child: _star(
                  primary,
                  5,
                ),
              ),

              Positioned(
                right: 31,
                top: 27,
                child: _star(
                  Colors.white,
                  3,
                ),
              ),

              Positioned(
                right: 10,
                bottom: 4,
                child: _star(
                  primary.withOpacity(
                    0.8,
                  ),
                  3,
                ),
              ),
            ],

            // ═══════════════════════════════════════════════════
            // 📖 HEADER CONTENT
            // ═══════════════════════════════════════════════════

            Row(
              children: [
                // ───────────────────────────────────────────────
                // 📖 Glowing diary icon
                // ───────────────────────────────────────────────

                Container(
                  width: 56,
                  height: 56,

                  decoration:
                  BoxDecoration(
                    shape: BoxShape.circle,

                    color:
                    primary.withOpacity(
                      0.12,
                    ),

                    border: Border.all(
                      color:
                      primary.withOpacity(
                        0.55,
                      ),
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: primary
                            .withOpacity(
                          0.28,
                        ),
                        blurRadius: 16,
                      ),
                    ],
                  ),

                  child: Icon(
                    Icons
                        .auto_stories_rounded,
                    color: primary,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 14),

                // ───────────────────────────────────────────────
                // TEXT
                // ───────────────────────────────────────────────

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [
                      Text(
                        'Memory Archive',

                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                          FontWeight.w800,
                          letterSpacing: 0.2,

                          color: isDark
                              ? Colors.white
                              : theme
                              .colorScheme
                              .onSurface,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        'Every moment becomes part of your universe.',

                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.35,

                          color: isDark
                              ? Colors.white
                              .withOpacity(
                            0.60,
                          )
                              : theme
                              .colorScheme
                              .onSurface
                              .withOpacity(
                            0.60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Leave some room for stars.
                if (isDark)
                  const SizedBox(
                    width: 22,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 📅 COSMIC TIMELINE HEADER
  //
  // TODAY ✦ ─────────────────────
  // YESTERDAY ✦ ─────────────────
  // ═══════════════════════════════════════════════════════════════

  Widget _buildGroupHeader(
      BuildContext context,
      String title,
      Color primary,
      ) {
    final theme = Theme.of(context);

    final isDark =
        theme.brightness == Brightness.dark;

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
                color:
                Colors.white.withOpacity(
                  isDark ? 0.55 : 0.25,
                ),
                width: 1,
              ),

              boxShadow: [
                BoxShadow(
                  color:
                  primary.withOpacity(
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
              fontWeight:
              FontWeight.w800,
              letterSpacing: 1.4,

              color: isDark
                  ? Colors.white
                  .withOpacity(0.88)
                  : primary,
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
                gradient:
                LinearGradient(
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
            color:
            primary.withOpacity(
              0.70,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🌑 EMPTY NOTES STATE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildEmptyState(
      BuildContext context,
      Color primary,
      String title,
      String subtitle,
      ) {
    final theme =
    Theme.of(context);

    final isDark =
        theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisSize:
          MainAxisSize.min,

          children: [
            // ───────────────────────────────────────────────────
            // 📖 Empty diary icon
            // ───────────────────────────────────────────────────

            Container(
              width: 72,
              height: 72,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color:
                primary.withOpacity(
                  0.10,
                ),

                border: Border.all(
                  color:
                  primary.withOpacity(
                    0.40,
                  ),
                ),

                boxShadow: isDark
                    ? [
                  BoxShadow(
                    color: primary
                        .withOpacity(
                      0.20,
                    ),
                    blurRadius: 25,
                  ),
                ]
                    : null,
              ),

              child: Icon(
                Icons
                    .auto_stories_rounded,
                size: 32,
                color: primary,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              title,

              style: const TextStyle(
                fontSize: 19,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              subtitle,

              textAlign:
              TextAlign.center,

              style: TextStyle(
                fontSize: 13,
                height: 1.4,

                color: isDark
                    ? Colors.white
                    .withOpacity(
                  0.55,
                )
                    : theme
                    .colorScheme
                    .onSurface
                    .withOpacity(
                  0.60,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🌌 MAIN NOTES SCREEN
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme =
    Theme.of(context);

    final colors =
        theme.colorScheme;

    final primary =
        colors.primary;

    final isDark =
        theme.brightness == Brightness.dark;

    final user =
        FirebaseAuth.instance.currentUser;

    // ═════════════════════════════════════════════════════════════
    // 🔐 USER CHECK
    // ═════════════════════════════════════════════════════════════

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'User not logged in',
          ),
        ),
      );
    }

    // ═════════════════════════════════════════════════════════════
    // 📓 NOTES SCAFFOLD
    //
    // Transparent in dark mode so CosmicBackground can remain
    // visible behind the entire screen.
    // ═════════════════════════════════════════════════════════════

    final screen = Scaffold(
      backgroundColor: isDark
          ? Colors.transparent
          : theme.scaffoldBackgroundColor,

      // ═══════════════════════════════════════════════════════════
      // 📖 APP BAR
      // ═══════════════════════════════════════════════════════════

      appBar: AppBar(
        title: const Text(
          'All Notes',
        ),

        centerTitle: true,

        elevation: 0,

        scrolledUnderElevation: 0,

        surfaceTintColor:
        Colors.transparent,

        backgroundColor: isDark
            ? Colors.transparent
            : null,

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

            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'date_desc',

                child: Row(
                  children: [
                    Icon(
                      Icons
                          .arrow_downward_rounded,
                      size: 18,
                    ),

                    SizedBox(width: 9),

                    Text(
                      'Newest First',
                    ),
                  ],
                ),
              ),

              PopupMenuItem(
                value: 'date_asc',

                child: Row(
                  children: [
                    Icon(
                      Icons
                          .arrow_upward_rounded,
                      size: 18,
                    ),

                    SizedBox(width: 9),

                    Text(
                      'Oldest First',
                    ),
                  ],
                ),
              ),
            ],

            icon: Icon(
              Icons.sort_rounded,

              color: isDark
                  ? primary
                  : null,
            ),
          ),

          const SizedBox(width: 5),
        ],
      ),

      // ═══════════════════════════════════════════════════════════
      // 🌌 BODY
      // ═══════════════════════════════════════════════════════════

      body: Column(
        children: [
          // ═════════════════════════════════════════════════════
          // 🌌 MEMORY ARCHIVE HERO
          // ═════════════════════════════════════════════════════

          if (isDark)
            _buildCosmicNotesHeader(
              context,
              primary,
            )
          else
            const SizedBox(height: 8),

          // ═════════════════════════════════════════════════════
          // 🎭 MOOD CONSTELLATION / FILTER
          //
          // Mood colors stay independent:
          //
          // 😊 Happy → Green
          // 😢 Sad   → Yellow
          // 😡 Angry → Red
          // 🔥 Flame → Original
          //
          // The universe itself still follows primaryColor.
          // ═════════════════════════════════════════════════════

          Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            child: MoodSelector(
              selectedMoodId:
              _selectedMood,

              showLabel: false,

              includeAll: true,

              onSelected: (moodId) {
                setState(() {
                  _selectedMood =
                      moodId;
                });
              },
            ),
          ),

          const SizedBox(height: 6),

          // ═════════════════════════════════════════════════════
          // 📚 FIRESTORE NOTES
          // ═════════════════════════════════════════════════════

          Expanded(
            child:
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore
                  .instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('notes')
                  .orderBy(
                'date',
                descending: true,
              )
                  .snapshots(),

              builder: (
                  context,
                  snapshot,
                  ) {
                // ═══════════════════════════════════════════════
                // ❌ FIRESTORE ERROR
                // ═══════════════════════════════════════════════

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding:
                      const EdgeInsets.all(
                        24,
                      ),

                      child: Column(
                        mainAxisSize:
                        MainAxisSize.min,

                        children: [
                          Icon(
                            Icons
                                .error_outline_rounded,
                            size: 50,
                            color:
                            colors.error,
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          const Text(
                            'Could not load your notes.',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          Text(
                            snapshot.error
                                .toString(),

                            textAlign:
                            TextAlign.center,

                            style: TextStyle(
                              fontSize: 12,

                              color: colors
                                  .onSurface
                                  .withOpacity(
                                0.60,
                              ),
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

                if (snapshot
                    .connectionState ==
                    ConnectionState
                        .waiting) {
                  return Center(
                    child: AppLoader(
                      loadingColor:
                      primary,
                    ),
                  );
                }

                // ═══════════════════════════════════════════════
                // 📭 NO NOTES
                // ═══════════════════════════════════════════════

                if (!snapshot.hasData ||
                    snapshot
                        .data!.docs.isEmpty) {
                  return _buildEmptyState(
                    context,
                    primary,
                    'No memories yet',
                    'Your diary stories will appear here once you start writing.',
                  );
                }

                List<QueryDocumentSnapshot>
                docs = List.from(
                  snapshot.data!.docs,
                );

                // ═══════════════════════════════════════════════
                // 🎭 MOOD FILTER
                // ═══════════════════════════════════════════════

                if (_selectedMood !=
                    null) {
                  docs = docs.where(
                        (doc) {
                      final data =
                      doc.data()
                      as Map<
                          String,
                          dynamic>;

                      final mood =
                      (data['mood'] ??
                          'neutral')
                          .toString()
                          .toLowerCase();

                      return mood ==
                          _selectedMood;
                    },
                  ).toList();
                }

                // ═══════════════════════════════════════════════
                // ↕️ SORTING
                // ═══════════════════════════════════════════════

                docs.sort(
                      (a, b) {
                    final aDate =
                    a['date']
                    as Timestamp;

                    final bDate =
                    b['date']
                    as Timestamp;

                    return _sortType ==
                        'date_asc'
                        ? aDate.compareTo(
                      bDate,
                    )
                        : bDate.compareTo(
                      aDate,
                    );
                  },
                );

                // ═══════════════════════════════════════════════
                // 🔎 FILTER RETURNED NOTHING
                // ═══════════════════════════════════════════════

                if (docs.isEmpty) {
                  return _buildEmptyState(
                    context,
                    primary,
                    'No memories found',
                    'There are no diary entries for this mood yet.',
                  );
                }

                // ═══════════════════════════════════════════════
                // ✨ ANIMATED MEMORY LIST
                // ═══════════════════════════════════════════════

                return AnimatedSwitcher(
                  duration:
                  const Duration(
                    milliseconds: 300,
                  ),

                  child:
                  ListView.builder(
                    key: ValueKey(
                      '$_sortType-${_selectedMood ?? "all"}',
                    ),

                    padding:
                    const EdgeInsets
                        .fromLTRB(
                      16,
                      4,
                      16,
                      30,
                    ),

                    itemCount:
                    docs.length,

                    itemBuilder: (
                        context,
                        index,
                        ) {
                      final data =
                      docs[index]
                          .data()
                      as Map<
                          String,
                          dynamic>;

                      // ─────────────────────────────────────────
                      // 📅 NOTE DATE
                      // ─────────────────────────────────────────

                      final date =
                      (data['date']
                      as Timestamp)
                          .toDate();

                      final currentGroup =
                      _groupTitle(
                        date,
                      );

                      String?
                      previousGroup;

                      if (index > 0) {
                        final previousData =
                        docs[index - 1]
                            .data()
                        as Map<
                            String,
                            dynamic>;

                        final prevDate =
                        (previousData[
                        'date']
                        as Timestamp)
                            .toDate();

                        previousGroup =
                            _groupTitle(
                              prevDate,
                            );
                      }

                      // ═════════════════════════════════════════
                      // 🔥 FIRESTORE → NOTE MODEL
                      // ═════════════════════════════════════════

                      final note = Note(
                        id:
                        docs[index].id,

                        title:
                        data['title'],

                        content:
                        data['content'] ??
                            '',

                        date: date,

                        mood:
                        data['mood'] ??
                            'neutral',

                        imagePath:
                        data['imagePath'],

                        drawingPaths:
                        List<String>.from(
                          data['drawingPaths'] ??
                              [],
                        ),

                        status:
                        data['status'],
                      );

                      return Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                        children: [
                          // ═════════════════════════════════════
                          // ✨ NEW DATE GROUP
                          // ═════════════════════════════════════

                          if (index == 0 ||
                              currentGroup !=
                                  previousGroup)
                            _buildGroupHeader(
                              context,
                              currentGroup,
                              primary,
                            ),

                          // ═════════════════════════════════════
                          // 📖 MEMORY / DIARY CARD
                          // ═════════════════════════════════════

                          SizedBox(
                            width:
                            double.infinity,

                            child:
                            DiaryCard(
                              note: note,

                              refreshCallback:
                                  (_) {
                                setState(
                                      () {},
                                );
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
    // 🌌 COSMIC NOTES UNIVERSE
    //
    // We use the EXACT SAME background engine as Home and Goals,
    // but the Notes content gives this screen its own identity.
    //
    // Change primary color:
    //
    // 💜 Purple → Purple nebula
    // 🩷 Pink   → Pink nebula
    // 💙 Blue   → Blue nebula
    // 🧡 Orange → Orange nebula
    // 💚 Green  → Green nebula
    //
    // Mood colors remain independent.
    // ═════════════════════════════════════════════════════════════

    if (isDark) {
      return CosmicBackground(
        accentColor: primary,
        child: screen,
      );
    }

    // ☀️ Light mode remains clean.
    return screen;
  }
}