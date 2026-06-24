import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

import '../utils/app_logger.dart' as logger;

/// Global read-only accessor for the [NetworkService] singleton.
///
/// ```dart
/// import 'package:flutter_base/services/network_service.dart';
///
/// // Initialize once at startup
/// await networkService.initialize();
///
/// // Listen for changes
/// networkService.connectStream.listen((isConnected) { ... });
///
/// // Read current state
/// if (networkService.isConnected) { ... }
/// ```
NetworkService get networkService => NetworkService.instance;

/// A singleton service that monitors internet connectivity in real time.
///
/// ## How it works
///
/// Network monitoring is a two-step process:
///
/// 1. **Interface check** — [connectivity_plus] reports which network interface
///    is active (Wi-Fi, mobile, VPN, etc.).
/// 2. **DNS probe** — resolves `example.com` to confirm actual internet access.
///
/// The two-step approach is required because both Android and iOS can report
/// an active interface while still having no real internet (captive portal,
/// router with no WAN, DNS outage, etc.).
///
/// ## Platform notes
///
/// - **Android**: `ACCESS_NETWORK_STATE` permission is declared automatically
///   by the `connectivity_plus` plugin manifest merge — no manual entry needed
///   in `AndroidManifest.xml`.
/// - **iOS**: uses `NWPathMonitor` (iOS 12+); no extra permissions or
///   entitlements required. **Caveat**: iOS throttles or suspends background
///   callbacks — call [checkConnection] manually on foreground resume
///   (e.g., in a [WidgetsBindingObserver.didChangeAppLifecycleState] handler)
///   if your UI relies on an up-to-date value.
///
/// ## Usage
///
/// ### 1. Initialize once at app startup (in `main()`, before `runApp`)
/// ```dart
/// await networkService.initialize();
/// ```
///
/// ### 2. Listen for real-time status changes
/// ```dart
/// networkService.connectStream.listen((isConnected) {
///   if (isConnected) {
///     // resume pending requests
///   } else {
///     // show offline banner
///   }
/// });
/// ```
///
/// ### 3. Read the current status synchronously (after [initialize])
/// ```dart
/// if (networkService.isConnected) {
///   // safe to start a network request
/// }
/// ```
///
/// ### 4. On-demand check (e.g., on app resume from background)
/// ```dart
/// final online = await networkService.checkConnection();
/// ```
///
/// ### 5. Clean up (optional — the singleton lives for the app's lifetime)
/// ```dart
/// networkService.dispose();
/// ```
class NetworkService {
  NetworkService._internal();

  /// The global singleton instance.
  static final NetworkService instance = NetworkService._internal();

  final _connectivity = Connectivity();

  /// Broadcast so multiple widgets / blocs can subscribe independently.
  final _controller = StreamController<bool>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isConnected = false;

  // Public API
  /// Emits `true` when the device has internet access, `false` otherwise.
  ///
  /// - The **first event** is emitted synchronously during [initialize].
  /// - **Subsequent events** fire only when the status *changes* — no duplicate
  ///   emissions for consecutive identical results.
  Stream<bool> get connectStream => _controller.stream;

  /// The most recent known connection status.
  ///
  /// Reflects the last DNS probe result. Returns `false` before [initialize]
  /// has completed.
  bool get isConnected => _isConnected;

  /// Starts the service: probes the current state, emits it on [connectStream],
  /// then subscribes to future network-interface changes.
  ///
  /// Safe to call multiple times — subsequent calls are no-ops if a
  /// subscription is already active.
  Future<void> initialize() async {
    if (_subscription != null) return;
    try {
      _isConnected = await checkConnection();
      _controller.sink.add(_isConnected);

      _subscription =
          _connectivity.onConnectivityChanged.listen(_onConnectionChanged);
    } on PlatformException catch (e) {
      logger.err('NetworkService: initialize failed', e);
    }
  }

  /// Performs a full on-demand connectivity check.
  ///
  /// Returns `true` only when a non-`none` interface is reported **and**
  /// a DNS lookup of `example.com` succeeds within 5 seconds.
  ///
  /// Suitable for manual checks such as app-foreground resume on iOS.
  Future<bool> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.contains(ConnectivityResult.none)) return false;
      return await _dnsLookup();
    } catch (e) {
      logger.err('NetworkService: checkConnection failed', e);
      return false;
    }
  }

  /// Cancels the connectivity subscription and closes the stream controller.
  ///
  /// The singleton instance itself is not destroyed; call [initialize] again
  /// to restart monitoring.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _controller.close();
  }

  // Private helpers
  /// Resolves `example.com` to verify real internet reachability.
  ///
  /// Returns `false` on [SocketException] (DNS server unreachable / no route)
  /// or [TimeoutException] (no response within 5 s).
  Future<bool> _dnsLookup() async {
    try {
      final addresses = await InternetAddress.lookup('example.com')
          .timeout(const Duration(seconds: 5));
      return addresses.isNotEmpty && addresses[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }

  /// Invoked by [connectivity_plus] on every network-interface change.
  ///
  /// Skips the DNS probe entirely when [results] is `[ConnectivityResult.none]`
  /// (no interface). Emits on [connectStream] only when status differs from
  /// [_isConnected] to suppress redundant events.
  Future<void> _onConnectionChanged(List<ConnectivityResult> results) async {
    final hasInternet =
        results.contains(ConnectivityResult.none) ? false : await _dnsLookup();

    if (hasInternet != _isConnected) {
      _isConnected = hasInternet;
      _controller.sink.add(_isConnected);
    }
  }
}