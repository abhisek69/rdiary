import 'package:flutter/material.dart';

import 'home.dart';
import '../settings/settings.dart';
import '../goals/goals_screen.dart';
import 'notes_screen.dart';

class MainScreen extends StatefulWidget {
  final DateTime? initialDate;

  const MainScreen({super.key, this.initialDate});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final PageController _pageController;

  // ============================================================
  // SCREENS
  // ============================================================

  late final List<Widget> _screens;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: _currentIndex);

    // IMPORTANT:
    // Pass the initial date through to HomeScreen.
    _screens = [
      HomeScreen(initialDate: widget.initialDate),
      const NotesScreen(),
      const GoalsScreen(),
      const SettingsScreen(),
    ];
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ============================================================
  // CHANGE TAB
  // ============================================================

  void _changeTab(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colors = theme.colorScheme;

    final primary = colors.primary;

    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // ========================================================
      // BODY
      // ========================================================
      body: PageView(
        controller: _pageController,

        onPageChanged: (index) {
          if (!mounted) return;

          setState(() {
            _currentIndex = index;
          });
        },

        children: _screens,
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================
      bottomNavigationBar:
          isDark
              ? _buildCosmicNavigation(primary)
              : _buildLightNavigation(primary),
    );
  }

  // ============================================================
  // DARK MODE COSMIC NAVIGATION
  // ============================================================

  Widget _buildCosmicNavigation(Color primary) {
    return Container(
      decoration: BoxDecoration(
        // Deep neutral cosmic surface.
        color: const Color(0xFF09090D),

        border: Border(
          top: BorderSide(color: primary.withOpacity(0.45), width: 1),
        ),

        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.22),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ],
      ),

      child: SafeArea(
        top: false,

        child: SizedBox(
          height: 64,

          child: Row(
            children: [
              _CosmicNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                index: 0,
                currentIndex: _currentIndex,
                primary: primary,
                onTap: _changeTab,
              ),

              _CosmicNavItem(
                icon: Icons.menu_book_rounded,
                label: 'Notes',
                index: 1,
                currentIndex: _currentIndex,
                primary: primary,
                onTap: _changeTab,
              ),

              _CosmicNavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Goals',
                index: 2,
                currentIndex: _currentIndex,
                primary: primary,
                onTap: _changeTab,
              ),

              _CosmicNavItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                index: 3,
                currentIndex: _currentIndex,
                primary: primary,
                onTap: _changeTab,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LIGHT MODE NAVIGATION
  // ============================================================

  Widget _buildLightNavigation(Color primary) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,

      onTap: _changeTab,

      type: BottomNavigationBarType.fixed,

      backgroundColor: primary,

      selectedItemColor: Colors.white,

      unselectedItemColor: Colors.white.withOpacity(0.72),

      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),

        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_rounded),
          label: 'Notes',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_rounded),
          label: 'Goals',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.settings_rounded),
          label: 'Settings',
        ),
      ],
    );
  }
}

// ============================================================
// COSMIC NAVIGATION ITEM
// ============================================================

class _CosmicNavItem extends StatelessWidget {
  final IconData icon;
  final String label;

  final int index;
  final int currentIndex;

  final Color primary;

  final ValueChanged<int> onTap;

  const _CosmicNavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = index == currentIndex;

    return Expanded(
      child: InkWell(
        onTap: () {
          onTap(index);
        },

        splashColor: primary.withOpacity(0.10),

        highlightColor: Colors.transparent,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),

          curve: Curves.easeOut,

          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),

            color: selected ? primary.withOpacity(0.14) : Colors.transparent,

            boxShadow:
                selected
                    ? [
                      BoxShadow(
                        color: primary.withOpacity(0.20),
                        blurRadius: 15,
                      ),
                    ]
                    : null,
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Icon(
                icon,

                size: selected ? 25 : 23,

                color: selected ? primary : Colors.white.withOpacity(0.55),

                shadows:
                    selected
                        ? [
                          Shadow(
                            color: primary.withOpacity(0.65),
                            blurRadius: 12,
                          ),
                        ]
                        : null,
              ),

              const SizedBox(height: 2),

              Text(
                label,

                style: TextStyle(
                  fontSize: 11,

                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,

                  color: selected ? primary : Colors.white.withOpacity(0.50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
