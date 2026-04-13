import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sync_service.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService(ref);
});

class ConnectivityService {
  final Ref _ref;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityService(this._ref);

  void initialize() {
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
        // If any result is mobile or wifi, trigger sync
        bool isOnline = results.any((r) => r == ConnectivityResult.mobile || r == ConnectivityResult.wifi || r == ConnectivityResult.ethernet);
        
        if (isOnline) {
          print('Network restored. Triggering Auto-Sync...');
          _ref.read(syncServiceProvider).syncData();
        }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}
