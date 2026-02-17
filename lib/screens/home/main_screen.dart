import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import 'home.dart';
import '../settings/settings.dart';
import '../goals_screen.dart';
import 'notes_screen.dart';
class MainScreen extends StatefulWidget {
  final DateTime? initialDate;

  const MainScreen({super.key, this.initialDate});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = const [
    HomeScreen(),
    NotesScreen(),
    GoalsScreen(),
    SettingsScreen(),
  ];


  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),

      bottomNavigationBar: Container(
        decoration: isDark
            ? BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: colors.primary.withOpacity(0.3),
              blurRadius: 20,
            ),
          ],
        )
            : null,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });

            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: colors.primary,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded),
              label: "Notes",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: "Goals",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: "Settings",
            ),
          ],
        )
      ),
    );
  }
}
