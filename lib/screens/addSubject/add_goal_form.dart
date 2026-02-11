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
    "Mon","Tue","Wed","Thu","Fri","Sat","Sun"
  ];

  List<String> _selectedDays = [];
  DateTime? _deadline;

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
        'deadline': _deadline != null
            ? Timestamp.fromDate(_deadline!)
            : null,
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
          backgroundColor:
          Theme.of(context).colorScheme.primary,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Set Your Goal",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 16),

          // 🏷 Goal Title
          TextField(
            controller: _goalController,
            decoration: const InputDecoration(
              labelText: "Goal (e.g., Go to Gym)",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          // 📅 Repeat Days
          const Text(
            "Repeat on Days",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _weekDays.map((day) {
              final isSelected =
              _selectedDays.contains(day);

              return ChoiceChip(
                label: Text(
                  day,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.grey[300],
                  ),
                ),
                selected: isSelected,
                selectedColor:
                Theme.of(context).colorScheme.primary,
                backgroundColor: Colors.grey[850],
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(10),
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

          const SizedBox(height: 24),

          // 🗓 Deadline
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate:
                _deadline ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );

              if (picked != null) {
                setState(() => _deadline = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius:
                BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _deadline == null
                        ? "Select Deadline"
                        : "Deadline: ${DateFormat.yMMMd().format(_deadline!)}",
                    style:
                    const TextStyle(fontSize: 16),
                  ),
                  Icon(
                    Icons.calendar_today_outlined,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // 💾 Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveGoal,
              icon: const Icon(Icons.flag),
              label: const Padding(
                padding:
                EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  "Set Goal",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                Theme.of(context)
                    .colorScheme
                    .primary,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
