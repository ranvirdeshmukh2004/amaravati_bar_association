import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Key for storing the password
const String _kPasswordKey = 'admin_password';
const String _kDefaultPassword = 'admin'; // Default password

final authProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController();
});

class AuthController extends StateNotifier<bool> {
  AuthController() : super(false) {
    _init();
  }

  final _storage = const FlutterSecureStorage();

  Future<void> _init() async {
    // Check if password exists, if not set default
    final password = await _storage.read(key: _kPasswordKey);
    if (password == null) {
      await _storage.write(key: _kPasswordKey, value: _kDefaultPassword);
    }
  }

  Future<bool> login(String password) async {
    final storedPassword = await _storage.read(key: _kPasswordKey);
    if (password == storedPassword) {
      state = true;
      return true;
    }
    return false;
  }

  void logout() {
    state = false;
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final storedPassword = await _storage.read(key: _kPasswordKey);
    if (currentPassword == storedPassword) {
      await _storage.write(key: _kPasswordKey, value: newPassword);
      return true;
    }
    return false;
  }

  Future<bool> validatePassword(String password) async {
    final storedPassword = await _storage.read(key: _kPasswordKey);
    return password == storedPassword;
  }

  // --- Security Question Logic ---

  static const String _kSecurityQuestionKey = 'security_question';
  static const String _kSecurityAnswerKey = 'security_answer';

  Future<String?> getSecurityQuestion() async {
    return await _storage.read(key: _kSecurityQuestionKey);
  }

  Future<bool> setSecurityQuestion(String question, String answer) async {
    try {
      await _storage.write(key: _kSecurityQuestionKey, value: question);
      // In a real app, hash this. For local simplified use, storing as is but SecureStorage is encrypted.
      await _storage.write(
        key: _kSecurityAnswerKey,
        value: answer.trim().toLowerCase(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> validateSecurityAnswer(String answer) async {
    final storedAnswer = await _storage.read(key: _kSecurityAnswerKey);
    if (storedAnswer == null) return false;
    return storedAnswer == answer.trim().toLowerCase();
  }

  Future<bool> resetPassword(String newPassword) async {
    try {
      await _storage.write(key: _kPasswordKey, value: newPassword);
      return true;
    } catch (e) {
      return false;
    }
  }
}
