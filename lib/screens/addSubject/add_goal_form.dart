import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddGoalForm extends StatefulWidget {
  const AddGoalForm({super.key});

  @override
  State<AddGoalForm> createState() => _AddGoalFormState();
}

class _AddGoalFormState extends State<AddGoalForm> {
  final _goalController = TextEditingController();

  final List<String> _weekDays = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];

  List<String> _selectedDays = [];
  DateTime? _deadline;
  DateTime _startDate = DateTime.now();

  Future<void> _saveGoal() async {
    final goalName = _goalController.text.trim();

    if (goalName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Goal name can't be empty"),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final id = const Uuid().v4();

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('goals')
          .doc(id)
          .set({
            'title': goalName,
            'goalDays': _selectedDays,
            'startDate': Timestamp.fromDate(_startDate),
            'deadline':
                _deadline != null ? Timestamp.fromDate(_deadline!) : null,
            'isCompleted': false,
            'createdAt': Timestamp.now(),
          });

      // ✅ THEMED SNACKBAR WITH GOAL NAME
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "$goalName goal added 🎯",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));
      Get.back();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Set Your Goal",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 24),

          /// 🏷 Goal Title
          TextField(
            controller: _goalController,
            decoration: InputDecoration(
              labelText: "Goal (e.g., Go to Gym)",
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: colors.surface,
            ),
          ),

          const SizedBox(height: 30),

          /// 🗓 Start Date
          _dateTile(
            context,
            label: "Start",
            value: DateFormat.yMMMd().format(_startDate),
            icon: Icons.play_arrow_rounded,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );

              if (picked != null) {
                setState(() => _startDate = picked);
              }
            },
          ),

          const SizedBox(height: 30),

          /// 📅 Repeat Days
          const Text(
            "Repeat on Days",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                _weekDays.map((day) {
                  final isSelected = _selectedDays.contains(day);

                  return ChoiceChip(
                    label: Text(day),
                    selected: isSelected,
                    selectedColor: colors.primary,
                    backgroundColor: colors.surface,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : colors.onSurface,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
          ),

          const SizedBox(height: 30),

          /// 🗓 Deadline
          _dateTile(
            context,
            label: "Deadline",
            value:
                _deadline == null
                    ? "Select Deadline"
                    : DateFormat.yMMMd().format(_deadline!),
            icon: Icons.calendar_today_outlined,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _deadline ?? _startDate,
                firstDate: _startDate, // important fix
                lastDate: DateTime(2100),
              );

              if (picked != null) {
                setState(() => _deadline = picked);
              }
            },
          ),

          const SizedBox(height: 40),

          /// 💾 Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveGoal,
              icon: const Icon(Icons.flag),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  "Set Goal",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.primary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Icon(icon, color: colors.primary),
          ],
        ),
      ),
    );
  }
}
