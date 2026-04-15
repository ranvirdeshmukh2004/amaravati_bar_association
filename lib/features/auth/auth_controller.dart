import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/auth/app_session.dart';

enum AuthRole { none, admin, developer }

class AuthState {
  final bool isAuthenticated;
  final AuthRole role;

  const AuthState({
    this.isAuthenticated = false,
    this.role = AuthRole.none,
  });
}

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AuthState> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Ref _ref;

  // Storage keys
  static const _passwordKey = 'admin_password';

  AuthController(this._ref) : super(const AuthState());

  /// Encode password for storage (base64 — flutter_secure_storage already encrypts)
  String _encodePassword(String password) {
    return base64Encode(utf8.encode(password));
  }

  /// Check if this is the first run (no password set yet)
  Future<bool> isFirstRun() async {
    final stored = await _storage.read(key: _passwordKey);
    return stored == null;
  }

  /// Set the initial admin password (first run)
  Future<bool> setupPassword(String password) async {
    if (password.length < 4) return false;

    final encoded = _encodePassword(password);
    await _storage.write(key: _passwordKey, value: encoded);

    debugPrint('✅ Admin password set successfully');
    return true;
  }

  /// Login with password
  Future<bool> login(String password) async {
    final stored = await _storage.read(key: _passwordKey);
    if (stored == null) return false;

    final inputEncoded = _encodePassword(password);
    if (inputEncoded == stored) {
      _ref.read(appSessionProvider.notifier).setRole(UserRole.admin);
      state = const AuthState(isAuthenticated: true, role: AuthRole.admin);
      debugPrint('✅ Admin login successful');
      return true;
    }
    return false;
  }

  /// Login as developer with PIN
  Future<bool> loginAsDeveloper(String pin) async {
    if (pin == 'dev123') {
      _ref.read(appSessionProvider.notifier).setRole(UserRole.admin);
      state = const AuthState(isAuthenticated: true, role: AuthRole.developer);
      debugPrint('✅ Developer login successful');
      return true;
    }
    return false;
  }

  /// Logout
  Future<void> logout() async {
    state = const AuthState(isAuthenticated: false, role: AuthRole.none);
    debugPrint('🔒 Logged out');
  }

  /// Validate a password against the stored value
  Future<bool> validatePassword(String password) async {
    if (state.role == AuthRole.developer) return password == 'dev123';

    final stored = await _storage.read(key: _passwordKey);
    if (stored == null) return false;

    return _encodePassword(password) == stored;
  }

  /// Change the admin password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    debugPrint('🔐 Attempting Password Change...');

    final isValid = await validatePassword(currentPassword);
    if (!isValid) {
      throw Exception('Incorrect current password');
    }

    if (newPassword.length < 4) {
      throw Exception('New password must be at least 4 characters');
    }

    final encoded = _encodePassword(newPassword);
    await _storage.write(key: _passwordKey, value: encoded);
    debugPrint('✅ Password changed successfully');
  }

  /// Force reset password (Developer use only)
  Future<void> resetPassword(String newPassword) async {
    if (newPassword.length < 4) {
      throw Exception('Password must be at least 4 characters');
    }
    final encoded = _encodePassword(newPassword);
    await _storage.write(key: _passwordKey, value: encoded);
    debugPrint('✅ Password force-reset by developer');
  }

  /// Legacy stubs for compatibility
  Future<bool> setSecurityQuestion(String q, String a) async => true;
  Future<String> getAdminPassword() async => 'Stored locally (encrypted)';
}
