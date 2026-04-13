import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../sync/sync_service.dart';
import '../../core/auth/app_session.dart';

enum AuthRole { none, admin, developer, viewer }

class AuthState {
  final bool isAuthenticated;
  final AuthRole role;
  final User? firebaseUser;

  const AuthState({
    this.isAuthenticated = false, 
    this.role = AuthRole.none,
    this.firebaseUser,
  });
}

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.read(syncServiceProvider), ref);
});

class AuthController extends StateNotifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final SyncService _syncService;
  final Ref _ref;

  AuthController(this._syncService, this._ref) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    // Listen to Firebase Auth Changes
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        // Fetch Role from Firestore
        final role = await _fetchUserRole(user.uid);
        
        // Update AppSession (Global State)
        _ref.read(appSessionProvider.notifier).setRole(
          role == AuthRole.admin ? UserRole.admin : UserRole.viewer
        );

        state = AuthState(isAuthenticated: true, role: role, firebaseUser: user);
        
        // Trigger Auto-Sync on Login
        _syncService.syncData();
        _syncService.startAutoSync(); 
      } else {
        if (state.role != AuthRole.developer) {
           state = const AuthState(isAuthenticated: false, role: AuthRole.none);
           _syncService.stopAutoSync(); 
        }
      }
    });
  }

  Future<AuthRole> _fetchUserRole(String uid) async {
    // HARDCODED RULE: Only 'viewer@adba.com' is forced as Viewer (or if Firestore says so).
    // All others default to Admin (to match "Works as before" behavior and handle offline).
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == 'viewer@adba.com') {
      return AuthRole.viewer;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      
      if (doc.exists && data?['role'] == 'viewer') {
        return AuthRole.viewer;
      }
      
      // Default to Admin for everyone else (including legacy/null role)
      return AuthRole.admin;
    } catch (e) {
      debugPrint("Error fetching role (Defaulting to Admin): $e");
      return AuthRole.admin; // Default to Admin on error (Offline, etc.)
    }
  }


  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> loginAsDeveloper(String pin) async {
     if (pin == 'dev123') {
       state = const AuthState(isAuthenticated: true, role: AuthRole.developer);
       _ref.read(appSessionProvider.notifier).setRole(UserRole.admin); // Dev is Admin-like
       _syncService.startAutoSync();
       return true;
     }
     return false;
  }

  Future<void> logout() async {
    await _auth.signOut();
    _syncService.stopAutoSync();
    state = const AuthState(isAuthenticated: false, role: AuthRole.none);
  }

  // --- Legacy Password Logic (Deprecated or kept for local pin fallback?) ---
  // Removing local "admin_password" logic as we are moving to Cloud Auth.
  
  // Security Question Logic - Keeping for optional use or deprecating? 
  // For now, removing complex local password reset logic as Firebase handles it.
  
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // --- Compatibility / Stubs for Legacy UI ---
  Future<bool> validatePassword(String password) async {
    if (state.role == AuthRole.developer) return password == 'dev123';
    
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      try {
        final credential = EmailAuthProvider.credential(email: user.email!, password: password);
        await user.reauthenticateWithCredential(credential);
        return true; 
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<void> changePassword(String current, String newPassword) async {
    debugPrint("🔐 Attempting Password Change...");
    final user = _auth.currentUser;
    
    if (user == null) {
       debugPrint("❌ User is null");
       throw FirebaseAuthException(code: 'user-not-found', message: 'No user logged in');
    }
    
    if (user.email == null) {
       debugPrint("❌ User email is null");
       throw FirebaseAuthException(code: 'invalid-email', message: 'User has no email');
    }

    try {
      debugPrint("🔐 Re-authenticating ${user.email}...");
      final credential = EmailAuthProvider.credential(email: user.email!, password: current);
      
      await user.reauthenticateWithCredential(credential).timeout(
        const Duration(seconds: 15), 
        onTimeout: () => throw FirebaseAuthException(code: 'network-request-failed', message: 'Connection timed out')
      );
      debugPrint("✅ Re-authentication successful");

      debugPrint("🔐 Updating Password...");
      await user.updatePassword(newPassword).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw FirebaseAuthException(code: 'network-request-failed', message: 'Update timed out')
      );
      debugPrint("✅ Password Update successful");
      
    } catch (e) {
      debugPrint("❌ Change Password Error: $e");
      rethrow;
    }
  }

  Future<bool> setSecurityQuestion(String q, String a) async => true; // No-op
  
  Future<String> getAdminPassword() async => "Managed by Firebase"; 

  Future<void> resetPassword({String? email}) async {} // No-op
}
