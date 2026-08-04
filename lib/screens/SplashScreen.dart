import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:rdiary/services/app_lock_service.dart';


// ═══════════════════════════════════════════════════════════════════
// 📖 RDIARY SPLASH SCREEN
//
// Animation sequence:
//
// 1. Diary appears
// 2. Diary opens
// 3. Goal card appears
// 4. Checkbox gets checked ✓
// 5. Sparkle appears ✨
// 6. Rocky's Diary branding appears
// 7. Version + creator appear
// 8. Login / App Lock check
// ═══════════════════════════════════════════════════════════════════

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // ═════════════════════════════════════════════════════════════
    // 📱 TRANSPARENT STATUS BAR
    // ═════════════════════════════════════════════════════════════

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    // ═════════════════════════════════════════════════════════════
    // ✨ MAIN SPLASH CONTROLLER
    // ═════════════════════════════════════════════════════════════

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    // Navigation is handled ONLY here.
    _handleNavigation();
  }


  // ═════════════════════════════════════════════════════════════════
  // 🚀 LOGIN + APP LOCK NAVIGATION
  // ═════════════════════════════════════════════════════════════════

  Future<void> _handleNavigation() async {

    // Enough time for diary + goal animation.
    await Future.delayed(
      const Duration(milliseconds: 3300),
    );

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    // ─────────────────────────────────────────────────────────────
    // 👤 USER NOT LOGGED IN
    // ─────────────────────────────────────────────────────────────

    if (user == null) {
      Get.offAllNamed('/login');
      return;
    }

    // ─────────────────────────────────────────────────────────────
    // 🔐 CHECK APP LOCK
    // ─────────────────────────────────────────────────────────────

    final lockService = AppLockService();

    final isLockEnabled =
    await lockService.isLockEnabled();

    if (!mounted) return;

    if (isLockEnabled) {
      Get.offAllNamed('/lock');
    } else {
      Get.offAllNamed('/home');
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  // ═════════════════════════════════════════════════════════════════
  // 🎨 SPLASH UI
  // ═════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {

    final primary =
        Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: primary,

      body: SafeArea(
        child: Stack(
          children: [

            // ═════════════════════════════════════════════════════
            // ✨ BACKGROUND DECORATION
            // ═════════════════════════════════════════════════════

            Positioned(
              top: -120,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            Positioned(
              bottom: -150,
              left: -100,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.07),
                ),
              ),
            ),


            // ═════════════════════════════════════════════════════
            // 📖 MAIN CONTENT
            // ═════════════════════════════════════════════════════

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // ═══════════════════════════════════════════════
                  // 📖 OPENING DIARY + GOAL CHECK
                  // ═══════════════════════════════════════════════

                  DiaryOpeningAnimation(
                    primaryColor: primary,
                  )
                      .animate()
                      .fadeIn(
                    duration: 400.ms,
                  )
                      .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1, 1),
                    curve: Curves.easeOutBack,
                  ),


                  const SizedBox(height: 24),


                  // ═══════════════════════════════════════════════
                  // 💜 APP NAME
                  // ═══════════════════════════════════════════════

                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeIn,
                    ),
                    child: const Text(
                      "Rocky's Diary",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(
                    delay: 900.ms,
                    duration: 600.ms,
                  )
                      .slideY(
                    begin: 0.25,
                    end: 0,
                  ),


                  const SizedBox(height: 10),


                  // ═══════════════════════════════════════════════
                  // ✨ TAGLINE
                  // ═══════════════════════════════════════════════

                  const Text(
                    'Reflect. Write. Grow.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                      letterSpacing: 1.1,
                    ),
                  )
                      .animate()
                      .fadeIn(
                    delay: 1200.ms,
                    duration: 600.ms,
                  ),


                  const SizedBox(height: 18),


                  // ═══════════════════════════════════════════════
                  // ✦ DECORATIVE SPARKLE
                  // ═══════════════════════════════════════════════

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Container(
                        width: 28,
                        height: 1,
                        color: Colors.white.withOpacity(0.25),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 9,
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white70,
                          size: 14,
                        ),
                      ),

                      Container(
                        width: 28,
                        height: 1,
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(
                    delay: 1450.ms,
                  ),
                ],
              ),
            ),


            // ═════════════════════════════════════════════════════
            // 👨‍💻 VERSION + CREATOR
            // ═════════════════════════════════════════════════════

            Positioned(
              left: 0,
              right: 0,
              bottom: 25,

              child: Column(
                children: [

                  Text(
                    'Version 0.6.0',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                      color: Colors.white.withOpacity(0.55),
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    'Created by',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      color: Colors.white.withOpacity(0.45),
                    ),
                  ),

                  const SizedBox(height: 3),

                  const Text(
                    'ABHISEK NANDA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(
                delay: 1800.ms,
                duration: 700.ms,
              )
                  .slideY(
                begin: 0.30,
                end: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// ═══════════════════════════════════════════════════════════════════
// 📖 DIARY OPENING ANIMATION
// ═══════════════════════════════════════════════════════════════════

class DiaryOpeningAnimation extends StatefulWidget {

  final Color primaryColor;

  const DiaryOpeningAnimation({
    super.key,
    required this.primaryColor,
  });

  @override
  State<DiaryOpeningAnimation> createState() =>
      _DiaryOpeningAnimationState();
}


class _DiaryOpeningAnimationState
    extends State<DiaryOpeningAnimation>
    with TickerProviderStateMixin {

  late AnimationController _bookController;
  late AnimationController _goalController;

  late Animation<double> _bookOpen;
  late Animation<double> _goalAppear;
  late Animation<double> _checkAppear;


  @override
  void initState() {
    super.initState();


    // ═════════════════════════════════════════════════════════════
    // 📖 BOOK OPENING CONTROLLER
    // ═════════════════════════════════════════════════════════════

    _bookController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 900,
      ),
    );

    _bookOpen = CurvedAnimation(
      parent: _bookController,
      curve: Curves.easeOutCubic,
    );


    // ═════════════════════════════════════════════════════════════
    // 🎯 GOAL CHECK CONTROLLER
    // ═════════════════════════════════════════════════════════════

    _goalController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 850,
      ),
    );


    // Goal card appears first.
    _goalAppear = CurvedAnimation(
      parent: _goalController,
      curve: const Interval(
        0.0,
        0.45,
        curve: Curves.easeOutBack,
      ),
    );


    // Checkbox appears afterwards.
    _checkAppear = CurvedAnimation(
      parent: _goalController,
      curve: const Interval(
        0.45,
        1.0,
        curve: Curves.elasticOut,
      ),
    );


    _startAnimation();
  }


  // ═════════════════════════════════════════════════════════════════
  // 🚀 START SEQUENCE
  // ═════════════════════════════════════════════════════════════════

  Future<void> _startAnimation() async {

    await Future.delayed(
      const Duration(milliseconds: 250),
    );

    if (!mounted) return;


    // 📖 Open diary.
    await _bookController.forward();


    await Future.delayed(
      const Duration(milliseconds: 120),
    );

    if (!mounted) return;


    // 🎯 Show goal + check it.
    await _goalController.forward();
  }


  @override
  void dispose() {

    _bookController.dispose();
    _goalController.dispose();

    super.dispose();
  }


  // ═════════════════════════════════════════════════════════════════
  // 📖 ANIMATED DIARY
  // ═════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: 210,
      height: 165,

      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [

          // ═══════════════════════════════════════════════════════
          // ✨ BACKGROUND GLOW
          // ═══════════════════════════════════════════════════════

          Container(
            width: 150,
            height: 150,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.13),
                  blurRadius: 50,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),


          // ═══════════════════════════════════════════════════════
          // 📖 DIARY
          // ═══════════════════════════════════════════════════════

          Positioned(
            top: 8,

            child: AnimatedBuilder(
              animation: _bookOpen,

              builder: (
                  context,
                  child,
                  ) {

                final progress =
                    _bookOpen.value;

                return SizedBox(
                  width: 170,
                  height: 110,

                  child: Stack(
                    alignment: Alignment.center,
                    children: [

                      // ═══════════════════════════════════════════
                      // 📄 LEFT PAGE
                      // ═══════════════════════════════════════════

                      Transform(
                        alignment:
                        Alignment.centerRight,

                        transform:
                        Matrix4.identity()
                          ..setEntry(
                            3,
                            2,
                            0.001,
                          )
                          ..rotateY(
                            -0.60 * progress,
                          ),

                        child: Container(
                          width: 74,
                          height: 100,

                          margin:
                          const EdgeInsets.only(
                            right: 70,
                          ),

                          decoration:
                          BoxDecoration(
                            color:
                            const Color(0xFFF8F4EA),

                            borderRadius:
                            const BorderRadius.only(
                              topLeft:
                              Radius.circular(10),
                              bottomLeft:
                              Radius.circular(10),
                              topRight:
                              Radius.circular(3),
                              bottomRight:
                              Radius.circular(3),
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.18),
                                blurRadius: 10,
                                offset:
                                const Offset(
                                  -3,
                                  5,
                                ),
                              ),
                            ],
                          ),

                          child: Padding(
                            padding:
                            const EdgeInsets.fromLTRB(
                              12,
                              16,
                              8,
                              10,
                            ),

                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: [

                                _pageLine(38),

                                const SizedBox(height: 8),

                                _pageLine(45),

                                const SizedBox(height: 8),

                                _pageLine(32),

                                const SizedBox(height: 8),

                                _pageLine(42),

                                const Spacer(),

                                Icon(
                                  Icons.favorite_rounded,
                                  size: 10,
                                  color: widget
                                      .primaryColor
                                      .withOpacity(0.50),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),


                      // ═══════════════════════════════════════════
                      // 📄 RIGHT PAGE
                      // ═══════════════════════════════════════════

                      Transform(
                        alignment:
                        Alignment.centerLeft,

                        transform:
                        Matrix4.identity()
                          ..setEntry(
                            3,
                            2,
                            0.001,
                          )
                          ..rotateY(
                            0.60 * progress,
                          ),

                        child: Container(
                          width: 74,
                          height: 100,

                          margin:
                          const EdgeInsets.only(
                            left: 70,
                          ),

                          decoration:
                          BoxDecoration(
                            color:
                            const Color(0xFFFFFCF4),

                            borderRadius:
                            const BorderRadius.only(
                              topRight:
                              Radius.circular(10),
                              bottomRight:
                              Radius.circular(10),
                              topLeft:
                              Radius.circular(3),
                              bottomLeft:
                              Radius.circular(3),
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.15),
                                blurRadius: 10,
                                offset:
                                const Offset(
                                  3,
                                  5,
                                ),
                              ),
                            ],
                          ),

                          child: Padding(
                            padding:
                            const EdgeInsets.fromLTRB(
                              9,
                              16,
                              12,
                              10,
                            ),

                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: [

                                _pageLine(42),

                                const SizedBox(height: 8),

                                _pageLine(35),

                                const SizedBox(height: 8),

                                _pageLine(44),

                                const SizedBox(height: 8),

                                _pageLine(29),

                                const Spacer(),

                                Align(
                                  alignment:
                                  Alignment.centerRight,

                                  child: Icon(
                                    Icons
                                        .auto_awesome_rounded,
                                    size: 11,
                                    color: widget
                                        .primaryColor
                                        .withOpacity(0.55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),


                      // ═══════════════════════════════════════════
                      // 📕 CENTER SPINE
                      // ═══════════════════════════════════════════

                      Container(
                        width: 4,
                        height: 96,

                        decoration:
                        BoxDecoration(
                          color: widget.primaryColor
                              .withOpacity(0.55),

                          borderRadius:
                          BorderRadius.circular(
                            10,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.15),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),


          // ═══════════════════════════════════════════════════════
          // 🎯 GOAL COMPLETED CARD
          // ═══════════════════════════════════════════════════════

          Positioned(
            bottom: 0,

            child: FadeTransition(
              opacity: _goalAppear,

              child: ScaleTransition(
                scale: _goalAppear,

                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),

                  decoration:
                  BoxDecoration(
                    color: Colors.black.withOpacity(
                      0.25,
                    ),

                    borderRadius:
                    BorderRadius.circular(
                      22,
                    ),

                    border: Border.all(
                      color: Colors.white
                          .withOpacity(0.35),
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.12),
                        blurRadius: 12,
                      ),
                    ],
                  ),

                  child: Row(
                    mainAxisSize:
                    MainAxisSize.min,

                    children: [

                      // ═════════════════════════════════════════
                      // ☑ CHECKBOX
                      // ═════════════════════════════════════════

                      Stack(
                        alignment:
                        Alignment.center,

                        children: [

                          Container(
                            width: 23,
                            height: 23,

                            decoration:
                            BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(
                                6,
                              ),

                              border:
                              Border.all(
                                color:
                                Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),


                          ScaleTransition(
                            scale:
                            _checkAppear,

                            child:
                            Container(
                              width: 23,
                              height: 23,

                              decoration:
                              BoxDecoration(
                                color:
                                Colors.white,

                                borderRadius:
                                BorderRadius.circular(
                                  6,
                                ),
                              ),

                              child: Icon(
                                Icons
                                    .check_rounded,
                                size: 18,
                                color: widget
                                    .primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),


                      const SizedBox(width: 9),


                      const Text(
                        'Goal completed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight:
                          FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),


                      const SizedBox(width: 7),


                      // ═════════════════════════════════════════
                      // ✨ SUCCESS SPARKLE
                      // ═════════════════════════════════════════

                      ScaleTransition(
                        scale:
                        _checkAppear,

                        child:
                        const Icon(
                          Icons
                              .auto_awesome_rounded,
                          color:
                          Colors.white,
                          size: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ═════════════════════════════════════════════════════════════════
  // 📄 PAGE DECORATION
  // ═════════════════════════════════════════════════════════════════

  Widget _pageLine(double width) {

    return Container(
      width: width,
      height: 2,

      decoration:
      BoxDecoration(
        color: widget.primaryColor
            .withOpacity(0.22),

        borderRadius:
        BorderRadius.circular(10),
      ),
    );
  }
}