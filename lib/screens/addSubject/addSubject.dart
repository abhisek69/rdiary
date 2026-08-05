import 'dart:math';
import 'package:flutter/material.dart';
import 'add_note_form.dart';
import 'add_goal_form.dart';

class AddSubjectScreen extends StatefulWidget {
  final DateTime? selectedDate;

  const AddSubjectScreen({super.key, this.selectedDate});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  int _selectedIndex = 0; // 0 = Note, 1 = Goal

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Add")),
      body: Column(
        children: [
          /// 🔹 Toggle Tabs
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _buildTabButton("Note", 0),
                  _buildTabButton("Goal", 1),
                ],
              ),
            ),
          ),

          /// 🔹 Body with Flip Animation
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              transitionBuilder: (child, animation) {
                final rotate = Tween(begin: 0.8, end: 1.0).animate(animation);

                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: rotate, child: child),
                );
              },
              child:
                  _selectedIndex == 0
                      ? AddNoteForm(
                        key: const ValueKey(0),
                        selectedDate: widget.selectedDate,
                      )
                      : const AddGoalForm(key: ValueKey(1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedIndex == index;
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color:
                  isSelected ? Colors.white : colors.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }
}
