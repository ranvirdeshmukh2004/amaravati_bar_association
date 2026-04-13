import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/app_session.dart';

/// Provider for Firestore Paths.
/// Reacts to changes in AppSession (Environment).
final firestorePathsProvider = Provider<FirestorePaths>((ref) {
  final session = ref.watch(appSessionProvider);
  return FirestorePaths(session.environment);
});

class FirestorePaths {
  final AppEnvironment _environment;

  FirestorePaths(this._environment);

  bool get _useDevPaths => _environment == AppEnvironment.dev;

  String get members => _useDevPaths ? 'dev_members' : 'members';
  String get subscriptions => _useDevPaths ? 'dev_subscriptions' : 'subscriptions';
  String get donations => _useDevPaths ? 'dev_donations' : 'donations';
  String get pastOutstanding => _useDevPaths ? 'dev_arrears' : 'arrears';
  String get config => _useDevPaths ? 'dev_config' : 'config';
}
