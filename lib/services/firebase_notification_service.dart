import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart' show RemoteMessage, FirebaseMessaging, NotificationSettings, AuthorizationStatus;
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import '../utils/app_logger.dart' show devLog, simpleLog;
import 'notification_service.dart';

/// firebase_messaging_service.dart
/// Integrated with your NotificationService (flutter_local_notifications wrapper).
/// - Singleton service for Firebase Messaging
/// - Uses your NotificationService to show local notifications for foreground messages
/// - Exposes streams: onMessage, onMessageOpenedApp, onNotificationTap (payload string), onTokenRefresh
/// - Handles token management, topic subscribe/unsubscribe, initial message
///
/// Usage (in main.dart before runApp):
/// WidgetsFlutterBinding.ensureInitialized();
/// await Firebase.initializeApp();
/// FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
/// await FirebaseMessagingService.instance.initialize();
/// runApp(MyApp());
class FirebaseNotificationService {
  FirebaseNotificationService._internal();
  static final FirebaseNotificationService instance = FirebaseNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Streams
  final StreamController<RemoteMessage> _onMessageController = StreamController.broadcast();
  Stream<RemoteMessage> get onMessage => _onMessageController.stream;

  final StreamController<RemoteMessage> _onMessageOpenedController = StreamController.broadcast();
  Stream<RemoteMessage> get onMessageOpenedApp => _onMessageOpenedController.stream;

  // Emits the payload (String?) when user taps a local notification created by NotificationService
  final StreamController<String?> _onNotificationTapController = StreamController.broadcast();
  Stream<String?> get onNotificationTap => _onNotificationTapController.stream;

  final StreamController<String> _tokenRefreshController = StreamController.broadcast();
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  // FCM subscription handles — stored so they can be cancelled in dispose()
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedSub;
  StreamSubscription<String>? _tokenRefreshSub;

  /// The most recently obtained FCM token.
  /// Null until [initialize] completes or until iOS APNs becomes available.
  // Cached FCM token — updated on first fetch and on every refresh.
  String? fcmToken;

  /// Message that launched the app from a **terminated** state (user tapped a
  /// notification while the app was not running).
  ///
  /// Because [initialize] is called before [runApp], the broadcast stream has
  /// no listeners yet — so we store the initial message here instead.
  ///
  /// Check this in your root widget's [State.initState] and call
  /// [clearInitialMessage] once handled to avoid processing it again.
  RemoteMessage? initialMessage;

  /// Clears [initialMessage] after the app has handled it.
  void clearInitialMessage() => initialMessage = null;

  bool _isFlutterLocalNotificationsInitialized = false;
  bool _initialized = false;
  bool _permissionRequested = false;

  // iOS APNs retry config
  static const int _apnsMaxRetries = 3;
  static const Duration _apnsRetryDelay = Duration(seconds: 2);

  /// Initializes core services — safe to call before [runApp].
  ///
  /// Sets up: local notification plugin, timezone, iOS foreground presentation
  /// options, FCM message stream listeners, and the token-refresh listener.
  ///
  /// Does NOT request permission or fetch the FCM token — call
  /// [requestPermissionAndFetchToken] from the first visible screen instead.
  Future<void> initialize() async {
    if (_initialized) return;

    await _setupFlutterLocalNotifications();

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _setupInteractedMessage();

    // Register the refresh listener early so no token-refresh event is missed.
    _setupTokenRefreshListener();

    _initialized = true;
  }

  /// Requests notification permission and fetches the FCM token.
  ///
  /// Call this from the first visible screen (e.g. [SplashPage]) so the
  /// system permission dialog appears over a real UI — not a black screen.
  /// Safe to call multiple times; only executes once.
  Future<void> requestPermissionAndFetchToken() async {
    if (_permissionRequested) return;
    _permissionRequested = true;

    await _requestNotificationPermission();
    await _fetchFCMToken();
  }

  Future<void> _setupFlutterLocalNotifications() async {
    _configureLocalTimeZone();
    if (_isFlutterLocalNotificationsInitialized) {
      return;
    }

    await NotificationService.instance.initPlatformSetting(
        onSelectNotification: (notificationRes) {
          _onNotificationTapController.add(notificationRes);
        }
    );
    _isFlutterLocalNotificationsInitialized = true;
  }

  Future<void> _requestNotificationPermission() async {
    // If you want to use flutter_local_notifications for ask permission, uncomment the line below
    // await NotificationService.instance.requestPlatformPermission();
    // Or you can rely on the Firebase messaging for ask permission
    /// Request permission
    try {
      NotificationSettings settings = await _messaging.requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false, // requires Apple special entitlement — do not enable unless approved
            provisional: false,   // provisional = silent delivery without explicit user consent; set true for soft permission flow
            sound: true,
          );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
            devLog('User granted permission');
          } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
            devLog('User granted provisional permission');
          } else {
            devLog('User declined or has not accepted permission');
            return;
          }
    } on FirebaseException catch (e) {
      // Swallow "already running" race condition on hot restart (development only).
      // In production this path is unreachable because the process is cold-started.
      devLog('⚠️ requestPermission skipped: ${e.message}');
    }
  }

  void _configureLocalTimeZone() {
    if (kIsWeb || Platform.isLinux) {
      return;
    }
    tz.initializeTimeZones();
  }

  Future<void> _setupInteractedMessage() async {
    // Foreground FCM message
    _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _onMessageController.add(message);

      if(Platform.isAndroid) {
        NotificationService.instance.showFirebaseNotification(message);
      }
    });

    // Background to foreground
    _onMessageOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _onMessageOpenedController.add(message);
    });

    // Terminated → opened: store the message so widgets can read it after runApp.
    // We also add to the stream for any late subscribers, but the field is the
    // reliable source since initialize() runs before runApp().
    try {
      final msg = await _messaging.getInitialMessage();
      if (msg != null) {
        initialMessage = msg;
        _onMessageOpenedController.add(msg);
      }
    } catch (e) {
      simpleLog(e);
    }
  }

  /// Registers the [FirebaseMessaging.onTokenRefresh] listener.
  /// Called during [initialize] so no refresh event is ever missed.
  void _setupTokenRefreshListener() {
    _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) {
      devLog('♻️ FCM token refreshed: $newToken');
      fcmToken = newToken;
      _tokenRefreshController.add(newToken);
    });
  }

  /// Fetches the FCM token. On iOS, waits for the APNs token first.
  /// Called from [requestPermissionAndFetchToken] after permission is granted.
  Future<void> _fetchFCMToken() async {
    if (Platform.isIOS) {
      final apnsToken = await _waitForAPNSToken();
      if (apnsToken == null) {
        devLog('⚠️ APNs token not available after $_apnsMaxRetries retries. '
            'FCM token will be captured via onTokenRefresh once APNs is ready.');
        return;
      }
    }

    final token = await _messaging.getToken();
    if (token != null) {
      fcmToken = token;
      devLog('🔑 FCM token: $token');
    } else {
      devLog('⚠️ FCM getToken() returned null.');
    }
  }

  /// Attempts to get the iOS APNs token, retrying up to [_apnsMaxRetries] times
  /// with [_apnsRetryDelay] between each attempt.
  ///
  /// Returns the token string if obtained, or null if all retries are exhausted.
  Future<String?> _waitForAPNSToken() async {
    for (int i = 0; i < _apnsMaxRetries; i++) {
      final token = await _messaging.getAPNSToken();
      if (token != null) return token;
      if (i < _apnsMaxRetries - 1) {
        devLog('⏳ APNs token attempt ${i + 1}/$_apnsMaxRetries — retrying in ${_apnsRetryDelay.inSeconds}s...');
        await Future.delayed(_apnsRetryDelay);
      }
    }
    devLog('⚠️ APNs token still null after $_apnsMaxRetries attempts.');
    return null;
  }

  Future<String?> getToken() => _messaging.getToken();
  Future<void> deleteToken() => _messaging.deleteToken();
  Future<void> subscribeToTopic(String topic) => _messaging.subscribeToTopic(topic);
  Future<void> unsubscribeFromTopic(String topic) => _messaging.unsubscribeFromTopic(topic);

  Future<void> dispose() async {
    await _onMessageSub?.cancel();
    await _onMessageOpenedSub?.cancel();
    await _tokenRefreshSub?.cancel();
    await _onMessageController.close();
    await _onMessageOpenedController.close();
    await _onNotificationTapController.close();
    await _tokenRefreshController.close();
    fcmToken = null;
    initialMessage = null;
    _initialized = false;
    _permissionRequested = false;
    _isFlutterLocalNotificationsInitialized = false;
  }
}