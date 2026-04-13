import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { admin, viewer }
enum AppEnvironment { dev, prod }

class AppSession {
  final UserRole role;
  final AppEnvironment environment;

  const AppSession({
    required this.role,
    required this.environment,
  });

  AppSession copyWith({
    UserRole? role,
    AppEnvironment? environment,
  }) {
    return AppSession(
      role: role ?? this.role,
      environment: environment ?? this.environment,
    );
  }
}

/// Manages the current User Role and Environment.
class AppSessionNotifier extends StateNotifier<AppSession> {
  AppSessionNotifier() : super(AppSession(
    role: UserRole.admin, // Default to admin until auth logic sets it
    environment: kDebugMode ? AppEnvironment.dev : AppEnvironment.prod, // Default env
  ));

  void setRole(UserRole role) {
    state = state.copyWith(role: role);
  }

  void setEnvironment(AppEnvironment env) {
    if (state.environment != env) {
      state = state.copyWith(environment: env);
    }
  }
}

final appSessionProvider = StateNotifierProvider<AppSessionNotifier, AppSession>((ref) {
  return AppSessionNotifier();
});
