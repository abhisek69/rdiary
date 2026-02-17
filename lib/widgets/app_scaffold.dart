import 'package:flutter/material.dart';
import 'neon_background.dart';

class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,

      // 🔥 IMPORTANT FIX
      body: SafeArea(
        child: Stack(
          children: [
            const NeonBackground(),
            body,
          ],
        ),
      ),
    );
  }
}
