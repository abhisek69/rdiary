import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/pulseLoader.dart';
import 'widgets/goal_card.dart';
import 'widgets/graph_section.dart';
import 'widgets/analytics_bar_chart.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  bool _showGoals = true;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Goal Analytics")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('goals')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: AppLoader(
                loadingColor: Theme.of(context).colorScheme.primary,
                type: LoaderType.threeRotatingDots,
                size: 80,
              ),
            );
          }

          final goals = snapshot.data!.docs;

          if (goals.isEmpty) {
            return const Center(child: Text("No goals yet"));
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [

              /// COLLAPSIBLE HEADER
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showGoals = !_showGoals;
                  });
                },
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Your Goals",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AnimatedRotation(
                      duration:
                      const Duration(milliseconds: 300),
                      turns: _showGoals ? 0.5 : 0,
                      child:
                      const Icon(Icons.expand_more),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              if (_showGoals)
                ...goals.map((doc) {
                  final data =
                  doc.data() as Map<String, dynamic>;

                  return GoalCard(
                    title: data['title'] ?? '',
                    goalDays: List<String>.from(
                        data['goalDays'] ?? []),
                    completedDates:
                    List<String>.from(
                        data['completedDates'] ??
                            []),
                    startDate:
                    data['startDate'] != null
                        ? (data['startDate']
                    as Timestamp)
                        .toDate()
                        : null,
                    deadline:
                    data['deadline'] != null
                        ? (data['deadline']
                    as Timestamp)
                        .toDate()
                        : null,
                  );
                }),

              const SizedBox(height: 40),

              // GraphSection(
              //   title: "Weekly Analysis",
              //   child: AnalyticsBarChart(
              //     isWeekly: true,
              //     goals: goals,
              //   ),
              // ),

              GraphSection(
                title: "Monthly Analysis",
                child: AnalyticsBarChart(
                  isWeekly: false,
                  goals: goals,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
