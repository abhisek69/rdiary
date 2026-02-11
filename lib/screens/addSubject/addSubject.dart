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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add"),
      ),
      body: Column(
        children: [

          // 🔹 Toggle Tabs
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
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

          // 🔹 Body
          Expanded(
            child: _selectedIndex == 0
                ? AddNoteForm(selectedDate: widget.selectedDate)
                : AddGoalForm(),
          )
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }
}
