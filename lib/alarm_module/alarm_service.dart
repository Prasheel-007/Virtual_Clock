import 'dart:async';
import 'dart:convert';
import 'dart:typed_data'; // ADDED: This import is required for Int64List.
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'alarm.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings();

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await loadAndRescheduleAlarms();
    _isInitialized = true;
  }

  Future<void> loadAndRescheduleAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = prefs.getStringList('alarms') ?? [];
    List<Alarm> alarms = alarmsJson.map((json) => Alarm.fromJson(jsonDecode(json))).toList();

    await flutterLocalNotificationsPlugin.cancelAll();

    for (final alarm in alarms) {
      if (alarm.isEnabled) {
        await scheduleAlarm(alarm);
      }
    }
  }

  tz.TZDateTime _getNextAlarmTime(Alarm alarm) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, alarm.time.hour, alarm.time.minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    if (alarm.repeatDays.any((day) => day)) {
      while (!alarm.repeatDays[scheduledDate.weekday % 7]) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    }

    return scheduledDate;
  }

  Future<void> scheduleAlarm(Alarm alarm) async {
    final scheduledTime = _getNextAlarmTime(alarm);
    final int notificationId = alarm.id.hashCode;
    final String soundName = alarm.ringtone.split('.').first;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      alarm.label.isNotEmpty ? alarm.label : 'Time & Tide Alarm',
      'It\'s time!',
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          'Alarms',
          channelDescription: 'Notifications for Time & Tide alarms.',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound(soundName),
          fullScreenIntent: true,
          // CORRECTED: Added the required import for Int64List
          vibrationPattern: Int64List.fromList([0, 1000, 5000, 1000]),
        ),
        iOS: DarwinNotificationDetails(
          sound: '$soundName.caf',
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: alarm.repeatDays.any((day) => day)
          ? DateTimeComponents.dayOfWeekAndTime
          : null,
    );
  }

  Future<void> cancelAlarm(String alarmId) async {
    final int notificationId = alarmId.hashCode;
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }
}

