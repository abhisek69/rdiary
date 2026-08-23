import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AppLockService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _pinKey = "app_pin";
  static const _lockEnabledKey = "lock_enabled";

  Future<bool> isLockEnabled() async {
    return (await _storage.read(key: _lockEnabledKey)) == "true";
  }

  Future<void> setLockEnabled(bool value) async {
    await _storage.write(key: _lockEnabledKey, value: value.toString());
  }

  Future<void> savePin(String pin) async {
    final hashed = sha256.convert(utf8.encode(pin)).toString();
    await _storage.write(key: _pinKey, value: hashed);
  }

  Future<bool> verifyPin(String pin) async {
    final storedHash = await _storage.read(key: _pinKey);
    final inputHash = sha256.convert(utf8.encode(pin)).toString();
    return storedHash == inputHash;
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      bool canCheck = await _auth.canCheckBiometrics;
      bool isSupported = await _auth.isDeviceSupported();

      if (!canCheck || !isSupported) {
        print("Biometric not supported or not enrolled");
        print("canCheck: $canCheck");
        print("isSupported: $isSupported");
        return false;
      }

      bool authenticated = await _auth.authenticate(
        localizedReason: 'Unlock your diary',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      return authenticated;
    } catch (e) {
      print("Biometric error: $e");
      return false;
    }
  }
}
