import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits `true` when the device has network connectivity, `false` when offline.
final connectivityProvider = StreamProvider<bool>((ref) {
  final connectivity = Connectivity();

  // connectivity_plus may return List<ConnectivityResult> or single ConnectivityResult
  // depending on version. Handle both by checking the runtime type.
  return connectivity.onConnectivityChanged.map((result) {
    if (result is List) {
      return (result as List).any((r) => r != ConnectivityResult.none);
    }
    return result != ConnectivityResult.none;
  });
});

/// Simple synchronous read of the latest connectivity state.
/// Returns `true` if online or if state hasn't been determined yet.
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).when(
    data: (isOnline) => isOnline,
    loading: () => true, // Assume online until proven otherwise
    error: (_, __) => true,
  );
});
