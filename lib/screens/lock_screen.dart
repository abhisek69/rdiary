import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/app_lock_service.dart';
import 'package:flutter/services.dart';
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final AppLockService _lockService = AppLockService();
  String _enteredPin = "";
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    bool success = await _lockService.authenticateWithBiometrics();
    print("Trying biometric...");
    if (success && mounted) {
      Get.offAllNamed('/home');
    }
  }


  void _onNumberTap(String number) async {
    if (_enteredPin.length >= 4) return;

    setState(() {
      _enteredPin += number;
    });

    if (_enteredPin.length == 4) {
      setState(() => _isChecking = true);

      bool correct = await _lockService.verifyPin(_enteredPin);

      if (correct && mounted) {
        Get.offAllNamed('/home');
      } else {
        await Future.delayed(const Duration(milliseconds: 200));

        setState(() {
          _enteredPin = "";
          _isChecking = false;
        });
        HapticFeedback.mediumImpact();
        Get.snackbar(
          "Access Denied",
          "Incorrect PIN. Try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _enteredPin =
          _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 60),

            /// 🔒 TITLE WITH GLOW
            Column(
              children: [
                Container(
                  decoration: isDark
                      ? BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withOpacity(0.6),
                        blurRadius: 25,
                        spreadRadius: 2,
                      ),
                    ],
                  )
                      : null,
                  child: Icon(
                    Icons.lock,
                    size: 70,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Unlock Diary",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter your 4-digit PIN",
                  style: TextStyle(
                    color: colors.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),

            const Spacer(),

            /// 🔵 PIN DOTS (WITH SOFT GLOW IN DARK MODE)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                bool filled = index < _enteredPin.length;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(8),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled
                        ? colors.primary
                        : colors.outline.withOpacity(0.3),
                    boxShadow: isDark && filled
                        ? [
                      BoxShadow(
                        color: colors.primary.withOpacity(0.8),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                        : [],
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),

            /// 🔢 KEYPAD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  for (var row in [
                    ['1','2','3'],
                    ['4','5','6'],
                    ['7','8','9'],
                  ])
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: row.map((num) {
                        return _buildKey(num, colors);
                      }).toList(),
                    ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 60),
                      _buildKey('0', colors),
                      IconButton(
                        onPressed: _onBackspace,
                        icon: Icon(Icons.backspace,
                            color: colors.onSurface),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            /// 👇 FINGERPRINT BUTTON BOTTOM CENTERED
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: GestureDetector(
                onTap: _tryBiometric,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary.withOpacity(0.1),
                    boxShadow: isDark
                        ? [
                      BoxShadow(
                        color: colors.primary.withOpacity(0.7),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ]
                        : [],
                  ),
                  child: Icon(
                    Icons.fingerprint,
                    size: 42, // bigger
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildKey(String number, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () => _onNumberTap(number),
        child: Container(
          width: 70,
          height: 70,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary.withOpacity(0.1),
          ),
          child: Text(
            number,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
