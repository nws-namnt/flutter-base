import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart' show RemoteMessage;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';

import '../common/app_constants.dart';
import '../utils/app_logger.dart' show simpleLog;

/// Callback invoked when the user taps a local notification.
///
/// [notificationResponse] is the tapped notification's payload string, or
/// `null` if none was attached.
typedef NotificationCallback = void Function(String? notificationResponse);

/// Default Android notification channel — values sourced from [AppConstants].
const defaultChannel = AndroidNotificationChannel(
  AppConstants.kAndroidChannelId,
  AppConstants.kAndroidChannelName,
  description: AppConstants.kAndroidChannelDescription,
  importance: Importance.max,
  showBadge: true,
  enableLights: false,
  enableVibration: true,
  playSound: true,
);

/// Singleton wrapper around [FlutterLocalNotificationsPlugin] for showing,
/// scheduling, and cancelling local notifications on Android/iOS/macOS.
///
/// Also used by [FirebaseNotificationService] to render foreground FCM
/// messages as local notifications (see [showFirebaseNotification]).
class NotificationService {
  // Private constructor
  NotificationService._();

  static final NotificationService _instance = NotificationService._();

  /// The global singleton instance.
  static NotificationService get instance => _instance;

  // Define FlutterLocalNotificationsPlugin instance
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Initialize the setting for each platform (Android, iOS)
  ///
  /// This method is used to setup the local notification plugin for each platform.
  /// The [onSelectNotification] is a callback that will be called when the user
  /// taps on the notification.
  ///
  /// The [onSelectNotification] callback will receive the payload of the notification
  /// as a parameter. This payload can be used to navigate to a specific page
  /// or to perform any other action.
  ///
  /// Note that this method is asynchronous and returns a [Future<void>].
  Future<void> initPlatformSetting({NotificationCallback? onSelectNotification}) async {
    // Android settings
    const AndroidInitializationSettings androidSetting = AndroidInitializationSettings('notification');

    // iOS settings
    const DarwinInitializationSettings iosSetting = DarwinInitializationSettings();

    // Initialize setting for android and ios
    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidSetting,
      iOS: iosSetting,
    );

    // Initialize the plugin
    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (notificationResponse) async {
        final String actionId = notificationResponse.actionId ?? '';

        if(Platform.isAndroid && actionId.isNotEmpty) {
          switch(actionId) {
            case 'action_1':
              simpleLog('User tapped on dismiss action');
              break;
            case 'action_2':
              simpleLog('User tapped on to setting action');
              break;
          }
        } else {
          if(onSelectNotification != null) {
            onSelectNotification(notificationResponse.payload);
          }
        }
      },
    );

    /// Create an Android Notification Channel.
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(defaultChannel);
  }

  /// Check if the permission to display notification is granted on Android.
  ///
  /// The permission status is checked using the
  /// [AndroidFlutterLocalNotificationsPlugin.areNotificationsEnabled] method.
  ///
  /// If the permission is granted, this method returns [true].
  /// Otherwise, it returns [false].
  ///
  /// Note that this method is only available on Android.
  ///
  /// Returns a [Future] that completes with [true] if the permission is granted,
  /// and [false] otherwise.
  Future<bool> _isAndroidPermissionGranted() async {
    return await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled() ?? false;
  }

  /// Request the platform permission to display notification.
  ///
  /// On Android, check if the permission to display notification is granted
  /// and if not, request the permission.
  ///
  /// On iOS, request the permission to display notification.
  Future<void> requestPlatformPermission() async {
    // Android 13+ permission
    if(Platform.isAndroid) {
      final hasPermission = await _isAndroidPermissionGranted();

      if(!hasPermission) {
        await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
      }
    } else if(Platform.isIOS) {
      await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if(Platform.isMacOS) {
      await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Renders an incoming Firebase [message] as a local notification.
  ///
  /// Used for foreground FCM messages, which the OS does not display
  /// automatically. Does nothing if [message] carries no `notification`
  /// payload. The [message]'s data (if any) is JSON-encoded into the
  /// notification's payload, and its `sentTime` is shown as the Android
  /// sub-text (see [_getNotificationDetails]).
  Future<void> showFirebaseNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final payload = message.data.isNotEmpty ? jsonEncode(message.data) : null;
      if(notification == null) return;

      await showNotification(
        id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF,
        title: notification.title ?? '',
        body: notification.body ?? '',
        payload: payload,
        message: message,
      );
    } catch (e) {
      simpleLog(e.toString());
    }
  }

  /// Show a local notification.
  ///
  /// [id] is the unique identifier of the notification.
  ///
  /// [title] is the title of the notification.
  ///
  /// [body] is the body of the notification.
  ///
  /// [payload] is a string used to pass data to the app when the user taps
  /// on the notification.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    RemoteMessage? message,
  }) async {
    final notificationDetails = _getNotificationDetails(message: message);
    await _flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  /// Schedule a local notification to be shown at a specified time in the future.
  ///
  /// [id] is the unique identifier of the notification.
  ///
  /// [title] is the title of the notification.
  ///
  /// [body] is the body of the notification.
  ///
  /// [nextInterval] is the duration from now until the notification should be shown.
  ///
  /// [payload] is a string used to pass data to the app when the user taps
  /// on the notification.
  ///
  /// The notification will be scheduled to be shown at [nextInterval] time from now.
  /// The [payload] will be passed to the app when the user taps on the notification.
  ///
  /// Note that this method is asynchronous and returns a [Future<void>].
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required Duration nextInterval,
    String? payload,
  }) async {
    final now = TZDateTime.now(local);
    final next = now.add(nextInterval);
    final notificationDetails = _getNotificationDetails();
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      scheduledDate: next,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      title: title,
      body: body,
      payload: payload,
    );
  }

  /// Schedules a notification to repeat at a fixed [RepeatInterval].
  ///
  /// The first occurrence fires one interval from now, then repeats indefinitely.
  /// Uses the native platform scheduler — works even when the app is killed.
  /// To cancel, call [cancelNotification] with the same [id].
  ///
  /// [id] is the unique identifier of the notification.
  ///
  /// [title] is the title of the notification.
  ///
  /// [body] is the body of the notification.
  ///
  /// [interval] is the fixed repeat interval (hourly, daily, weekly).
  ///
  /// [payload] is a string passed back to the app when the user taps
  /// on the notification.
  Future<void> periodicallyNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval interval,
    String? payload,
  }) async {
    final notificationDetails = _getNotificationDetails();
    await _flutterLocalNotificationsPlugin.periodicallyShow(
      id: id,
      repeatInterval: interval,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      title: title,
      body: body,
      payload: payload,
    );
  }

  /// Schedules a notification to repeat at a specified duration interval.
  ///
  /// Unlike [periodicallyNotification] which uses a fixed [RepeatInterval],
  /// this method accepts any [Duration] (e.g. every 90 minutes).
  ///
  /// Uses the native platform scheduler — works even when the app is killed.
  /// To cancel, call [cancelNotification] with the same [id].
  ///
  /// [id] is the unique identifier of the notification.
  ///
  /// [title] is the title of the notification.
  ///
  /// [body] is the body of the notification.
  ///
  /// [interval] is the duration between each notification.
  ///
  /// [payload] is a string passed back to the app when the user taps
  /// on the notification.
  Future<void> periodicallyNotificationWithDuration({
    required int id,
    required String title,
    required String body,
    required Duration interval,
    String? payload,
  }) async {
    final notificationDetails = _getNotificationDetails();
    await _flutterLocalNotificationsPlugin.periodicallyShowWithDuration(
      id: id,
      title: title,
      body: body,
      repeatDurationInterval: interval,
      notificationDetails: notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Returns the platform-specific notification details that should be used
  /// when showing notifications.
  ///
  /// This will be used as the default notification details when calling
  /// [showNotification] or [scheduleNotification].
  NotificationDetails _getNotificationDetails({RemoteMessage? message}) {
    final subTxt = message != null
      ? DateFormat('yyyy-MM-dd HH:mm:ss').format(message.sentTime ?? DateTime.now())
      : null;

    final androidDetails = AndroidNotificationDetails(
      defaultChannel.id,
      defaultChannel.name,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'action_1',
          'Dismiss',
          cancelNotification: true,
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'action_2',
          'Setting',
          cancelNotification: true,
          showsUserInterface: true,
        ),
      ],
      channelDescription: defaultChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: AppConstants.kAndroidNotificationIcon,
      playSound: true,
      showWhen: true,
      subText: subTxt,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Cancel a specific notification.
  ///
  /// [id] is the unique identifier of the notification to cancel.
  ///
  /// This is an asynchronous operation and will return a [Future<void>].
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id: id);
  }

  /// Cancels all notifications — both those already shown and those scheduled.
  Future<void> cancelNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Cancel all pending notifications.
  ///
  /// This is an asynchronous operation and will return a [Future<void>].
  ///
  /// This operation will cancel all notifications that are currently scheduled
  /// to be shown but have not yet been shown.
  ///
  /// This operation is separate from [cancelNotifications] which will cancel
  /// all notifications, whether they have been shown or not.
  Future<void> cancelPendingNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAllPendingNotifications();
  }
}