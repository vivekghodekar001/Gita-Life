import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits `true` when the device has network connectivity, `false` when offline.
final connectivityProvider = StreamProvider<bool>((ref) {
  final connectivity = Connectivity();

  // Transform the connectivity stream into a simple bool
  return connectivity.onConnectivityChanged.map((results) {
    // connectivity_plus v5+ returns List<ConnectivityResult>
    return results.any((r) => r != ConnectivityResult.none);
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
