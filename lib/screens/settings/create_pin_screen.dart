import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/app_lock_service.dart';

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  final AppLockService _lockService = AppLockService();

  String _firstPin = "";
  String _confirmPin = "";
  bool _isConfirming = false;

  void _onNumberTap(String number) async {
    if (!_isConfirming) {
      if (_firstPin.length >= 4) return;

      setState(() {
        _firstPin += number;
      });

      if (_firstPin.length == 4) {
        await Future.delayed(const Duration(milliseconds: 300));
        setState(() {
          _isConfirming = true;
        });
      }
    } else {
      if (_confirmPin.length >= 4) return;

      setState(() {
        _confirmPin += number;
      });

      if (_confirmPin.length == 4) {
        if (_firstPin == _confirmPin) {
          await _lockService.savePin(_firstPin);
          await _lockService.setLockEnabled(true);
          Get.offAllNamed('/home');
        } else {
          // Reset if mismatch
          await Future.delayed(const Duration(milliseconds: 300));
          setState(() {
            _firstPin = "";
            _confirmPin = "";
            _isConfirming = false;
          });

          Get.snackbar(
            "PIN Mismatch",
            "Pins do not match. Try again.",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    }
  }

  void _onBackspace() {
    setState(() {
      if (!_isConfirming && _firstPin.isNotEmpty) {
        _firstPin = _firstPin.substring(0, _firstPin.length - 1);
      } else if (_isConfirming && _confirmPin.isNotEmpty) {
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final currentPin = _isConfirming ? _confirmPin : _firstPin;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 40),

            /// 🔒 TITLE
            Column(
              children: [
                Icon(Icons.lock_outline, size: 60, color: colors.primary),
                const SizedBox(height: 16),
                Text(
                  _isConfirming ? "Confirm PIN" : "Create PIN",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isConfirming ? "Re-enter your PIN" : "Enter a 4-digit PIN",
                  style: TextStyle(color: colors.onSurface.withOpacity(0.6)),
                ),
              ],
            ),

            /// 🔵 PIN DOTS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.all(8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        index < currentPin.length
                            ? colors.primary
                            : colors.outline.withOpacity(0.3),
                  ),
                );
              }),
            ),

            /// 🔢 KEYPAD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  for (var row in [
                    ['1', '2', '3'],
                    ['4', '5', '6'],
                    ['7', '8', '9'],
                  ])
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          row.map((num) {
                            return _buildKey(num, colors);
                          }).toList(),
                    ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 48),
                      _buildKey('0', colors),
                      IconButton(
                        onPressed: _onBackspace,
                        icon: Icon(Icons.backspace, color: colors.onSurface),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
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
