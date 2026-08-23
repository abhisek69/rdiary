import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/goal.dart';
import '../../../theme/app_theme.dart';
import '../../../backgrounds/diary_world/diary_world.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final DateTime selectedDay;
  final VoidCallback refreshCallback;

  const GoalCard({
    super.key,
    required this.goal,
    required this.selectedDay,
    required this.refreshCallback,
  });

  // ═══════════════════════════════════════════════════════════════
  // 📅 DATE HELPERS
  // ═══════════════════════════════════════════════════════════════

  DateTime _normalize(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🗑️ DELETE GOAL
  // ═══════════════════════════════════════════════════════════════

  Future<void> _deleteGoal(
      BuildContext context,
      Goal goal,
      ) async {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark =
        theme.brightness == Brightness.dark;

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark
              ? const Color(0xFF101016)
              : theme.colorScheme.surface,

          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20),
            side: isDark
                ? BorderSide(
              color:
              primary.withOpacity(0.35),
            )
                : BorderSide.none,
          ),

          title: Text(
            'Delete Goal?',
            style: TextStyle(
              color:
              theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),

          content: Text(
            'Are you sure you want to delete this goal?',
            style: TextStyle(
              color: theme.colorScheme.onSurface
                  .withOpacity(0.70),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                'Cancel',
                style:
                TextStyle(color: primary),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('goals')
        .doc(goal.id)
        .delete();

    refreshCallback();
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎯 BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colors = theme.colorScheme;
    final primary = colors.primary;
    final surface = colors.surface;
    final onSurface = colors.onSurface;

    final isDark =
        theme.brightness == Brightness.dark;

    // ═════════════════════════════════════════════════════════════
    // 🌍 DIARY WORLD
    // ═════════════════════════════════════════════════════════════

    final themeProvider =
    context.watch<ThemeProvider>();

    final selectedWorld =
        themeProvider.diaryWorld;

    final isCosmic =
        selectedWorld ==
            DiaryWorld.cosmicUniverse;

    final isCosmicDark =
        isCosmic && isDark;

    final isCosmicLight =
        isCosmic && !isDark;

    // ═════════════════════════════════════════════════════════════
    // 📅 COMPLETION STATE
    // ═════════════════════════════════════════════════════════════

    final selected =
    _normalize(selectedDay);

    final dateKey =
    DateFormat('yyyy-MM-dd')
        .format(selected);

    final isCompleted =
    goal.completedDates
        .contains(dateKey);

    // ═════════════════════════════════════════════════════════════
    // 🎨 CARD SURFACE
    // ═════════════════════════════════════════════════════════════

    Color cardColor;

    if (isCosmicDark) {
      // Keep existing Dark Cosmic appearance.
      cardColor = Colors.black.withOpacity(
        isCompleted ? 0.28 : 0.40,
      );
    } else if (isCosmicLight) {
      // ☀️ LIGHT COSMIC GLASS
      //
      // Slightly more transparent than text-heavy Notes cards.
      cardColor = Colors.white.withOpacity(
        isCompleted ? 0.30 : 0.42,
      );
    } else {
      // Theme-less / normal Material appearance.
      cardColor = surface;
    }

    // ═════════════════════════════════════════════════════════════
    // 🖼️ BORDER
    // ═════════════════════════════════════════════════════════════

    final borderColor = primary.withOpacity(
      isCompleted
          ? 0.30
          : isCosmicDark
          ? 0.68
          : isCosmicLight
          ? 0.52
          : 0.80,
    );

    final borderWidth =
    isCosmicDark || isCosmicLight
        ? 1.15
        : 1.5;

    // ═════════════════════════════════════════════════════════════
    // ✨ SHADOW
    // ═════════════════════════════════════════════════════════════

    List<BoxShadow> cardShadow;

    if (isCosmicDark) {
      cardShadow = [
        BoxShadow(
          color: primary.withOpacity(
            isCompleted ? 0.07 : 0.16,
          ),
          blurRadius: 18,
        ),
      ];
    } else if (isCosmicLight) {
      cardShadow = [
        BoxShadow(
          color:
          Colors.black.withOpacity(0.07),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
        BoxShadow(
          color:
          primary.withOpacity(0.08),
          blurRadius: 10,
        ),
      ];
    } else {
      cardShadow = [
        BoxShadow(
          color: primary.withOpacity(0.12),
          blurRadius: 10,
        ),
      ];
    }

    // ═════════════════════════════════════════════════════════════
    // 📝 TEXT COLOR
    // ═════════════════════════════════════════════════════════════

    final normalTextColor =
    isCosmicDark
        ? Colors.white.withOpacity(0.92)
        : onSurface;

    // ═════════════════════════════════════════════════════════════
    // 🪟 CARD
    // ═════════════════════════════════════════════════════════════

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();

        _deleteGoal(
          context,
          goal,
        );
      },

      child: Padding(
        padding:
        const EdgeInsets.only(bottom: 10),

        child: ClipRRect(
          borderRadius:
          BorderRadius.circular(18),

          child: BackdropFilter(
            // Light Cosmic:
            // low blur so the artwork is STILL visible.
            filter: ImageFilter.blur(
              sigmaX:
              isCosmicLight ? 3 : 0,
              sigmaY:
              isCosmicLight ? 3 : 0,
            ),

            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 280,
              ),
              curve: Curves.easeOut,

              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(18),

                color: cardColor,

                border: Border.all(
                  color: borderColor,
                  width: borderWidth,
                ),

                boxShadow: cardShadow,
              ),

              child: Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),

                child: Row(
                  children: [
                    // ═══════════════════════════════════════════
                    // ☑️ CHECKBOX
                    // ═══════════════════════════════════════════

                    Transform.scale(
                      scale: 1.02,

                      child: Checkbox(
                        value: isCompleted,

                        activeColor: primary,

                        checkColor: Colors.white,

                        side: BorderSide(
                          color:
                          primary.withOpacity(
                            isCompleted
                                ? 0.55
                                : 0.95,
                          ),
                          width: 1.5,
                        ),

                        onChanged: (value) async {
                          final user =
                              FirebaseAuth
                                  .instance
                                  .currentUser;

                          if (user == null) {
                            return;
                          }

                          final updatedDates =
                          List<String>.from(
                            goal.completedDates,
                          );

                          if (value == true) {
                            if (!updatedDates
                                .contains(dateKey)) {
                              updatedDates.add(
                                dateKey,
                              );
                            }
                          } else {
                            updatedDates.remove(
                              dateKey,
                            );
                          }

                          await FirebaseFirestore
                              .instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('goals')
                              .doc(goal.id)
                              .update({
                            'completedDates':
                            updatedDates,
                          });

                          refreshCallback();
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ═══════════════════════════════════════════
                    // 🎯 TITLE
                    // ═══════════════════════════════════════════

                    Expanded(
                      child:
                      AnimatedDefaultTextStyle(
                        duration:
                        const Duration(
                          milliseconds: 280,
                        ),

                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w600,

                          color: isCompleted
                              ? normalTextColor
                              .withOpacity(
                            0.42,
                          )
                              : normalTextColor,

                          decoration:
                          isCompleted
                              ? TextDecoration
                              .lineThrough
                              : TextDecoration
                              .none,

                          decorationColor:
                          primary.withOpacity(
                            0.55,
                          ),
                        ),

                        child:
                        Text(goal.title),
                      ),
                    ),

                    // ═══════════════════════════════════════════
                    // ✨ COMPLETED
                    // ═══════════════════════════════════════════

                    if (isCompleted) ...[
                      const SizedBox(width: 8),

                      Icon(
                        Icons
                            .auto_awesome_rounded,
                        size: 15,
                        color:
                        primary.withOpacity(
                          0.65,
                        ),
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