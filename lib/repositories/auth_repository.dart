import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import '../services/secure_storage_service.dart';

class AuthRepository {
  AuthRepository({required SecureStorageService storage})
      : _storage = storage;

  final SecureStorageService _storage;
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your trading journal',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> setPin(String profileId, String pin) async {
    final hash = _hashPin(pin);
    await _storage.write(SecureStorageService.pinKey(profileId), hash);
  }

  Future<bool> verifyPin(String profileId, String pin) async {
    final storedHash = await _storage.read(SecureStorageService.pinKey(profileId));
    if (storedHash == null) return false;
    return storedHash == _hashPin(pin);
  }

  Future<void> removePin(String profileId) async {
    await _storage.delete(SecureStorageService.pinKey(profileId));
  }

  Future<bool> hasPinSet(String profileId) async {
    return _storage.containsKey(SecureStorageService.pinKey(profileId));
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
