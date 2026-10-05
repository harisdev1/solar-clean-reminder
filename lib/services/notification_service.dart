import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/app_defaults.dart';
import '../core/app_keys.dart';
import '../core/app_strings.dart';

/// Alarm-style local notifications (Android focus).
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  void Function(String actionId)? onAction;
  String? _launchAction;

  static final _actions = <AndroidNotificationAction>[
    AndroidNotificationAction(
      AppKeys.actionClean,
      AppStrings.notifActionClean,
      showsUserInterface: true,
    ),
    AndroidNotificationAction(
      AppKeys.actionTomorrow,
      AppStrings.notifActionTomorrow,
      showsUserInterface: true,
    ),
  ];

  Future<void> init() async {
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {}
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (r) =>
          onAction?.call(r.actionId ?? AppKeys.actionOpen),
    );
    await _ensureChannels();
    final d = await _plugin.getNotificationAppLaunchDetails();
    if (d?.didNotificationLaunchApp ?? false) {
      _launchAction = d!.notificationResponse?.actionId;
    }
  }

  Future<void> _ensureChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;
    await android.createNotificationChannel(
      AndroidNotificationChannel(
        AppKeys.channelAlarm,
        AppStrings.channelAlarmName,
        description: AppStrings.channelAlarmDesc,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
      ),
    );
    await android.createNotificationChannel(
      AndroidNotificationChannel(
        AppKeys.channelSoft,
        AppStrings.channelSoftName,
        description: AppStrings.channelSoftDesc,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  String? takeLaunchAction() {
    final a = _launchAction;
    _launchAction = null;
    return a;
  }

  Future<bool> isNotificationGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted || status.isLimited;
  }

  Future<bool> requestPermissions() async {
    final current = await Permission.notification.status;
    if (current.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    final notification = await Permission.notification.request();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
    await android?.requestFullScreenIntentPermission();
    try {
      await Permission.scheduleExactAlarm.request();
    } catch (_) {}
    return notification.isGranted || notification.isLimited;
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  AndroidNotificationDetails _ring() => AndroidNotificationDetails(
        AppKeys.channelAlarm,
        AppStrings.channelAlarmName,
        channelDescription: AppStrings.channelAlarmDesc,
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        playSound: true,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
        additionalFlags: Int32List.fromList(<int>[4]),
        vibrationPattern: Int64List.fromList(<int>[0, 800, 400, 800, 400, 800]),
        timeoutAfter: 120000,
        actions: _actions,
      );

  AndroidNotificationDetails _soft({bool withActions = false}) =>
      AndroidNotificationDetails(
        AppKeys.channelSoft,
        AppStrings.channelSoftName,
        channelDescription: AppStrings.channelSoftDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        actions: withActions ? _actions : null,
      );

  Future<void> _at(
    int id,
    DateTime when,
    String title,
    String body,
    AndroidNotificationDetails d,
  ) async {
    final t = tz.TZDateTime.from(when, tz.local);
    final nd = NotificationDetails(android: d);
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        t,
        nd,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } on PlatformException {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        t,
        nd,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> scheduleAll({
    required DateTime due,
    required int hour,
    required int minute,
  }) async {
    await _plugin.cancelAll();
    final now = DateTime.now();
    var first = due;
    final late = !due.isAfter(now);
    if (late) {
      first = DateTime(now.year, now.month, now.day, hour, minute);
      if (!first.isAfter(now)) {
        first = DateTime(now.year, now.month, now.day + 1, hour, minute);
      }
    }
    for (var i = 0; i < AppDefaults.alarmChainDays; i++) {
      final t = DateTime(first.year, first.month, first.day + i, hour, minute);
      final isLate = late || i > 0;
      await _at(
        AppKeys.notificationAlarmBaseId + i,
        t,
        AppStrings.alarmTitle,
        isLate ? AppStrings.alarmBodyLate : AppStrings.alarmBodyDue,
        _ring(),
      );
    }
    final soft = DateTime(
      due.year,
      due.month,
      due.day - AppDefaults.softReminderDaysBefore,
      hour,
      minute,
    );
    if (soft.isAfter(now)) {
      await _at(
        AppKeys.notificationSoftId,
        soft,
        AppStrings.softTitle,
        AppStrings.softBody,
        _soft(),
      );
    }
  }

  Future<void> confirmIn(Duration d) => _at(
        AppKeys.notificationConfirmId,
        DateTime.now().add(d),
        AppStrings.confirmTitle,
        AppStrings.confirmBody,
        _soft(withActions: true),
      );

  Future<void> testIn(Duration d) => _at(
        AppKeys.notificationTestId,
        DateTime.now().add(d),
        AppStrings.testTitle,
        AppStrings.testBody,
        _ring(),
      );
}
