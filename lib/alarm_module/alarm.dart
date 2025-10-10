import 'package:flutter/material.dart';

class Alarm {
  final String id;
  TimeOfDay time;
  bool isEnabled;
  String ringtone;
  bool isCustomRingtone;
  String? customRingtonePath;
  List<bool> repeatDays; // [Sun, Mon, Tue, Wed, Thu, Fri, Sat]
  int snoozeDuration; // in minutes
  int snoozeCount;
  DateTime? lastTriggered;
  String label;

  Alarm({
    String? id,
    required this.time,
    this.isEnabled = true,
    // CORRECTED: Default ringtone is now lowercase
    this.ringtone = 'titanic.aac',
    this.isCustomRingtone = false,
    this.customRingtonePath,
    List<bool>? repeatDays,
    this.snoozeDuration = 5,
    this.snoozeCount = 0,
    this.lastTriggered,
    this.label = '',
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        repeatDays = repeatDays ?? List.filled(7, false);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': '${time.hour}:${time.minute}',
      'isEnabled': isEnabled,
      'ringtone': ringtone,
      'isCustomRingtone': isCustomRingtone,
      'customRingtonePath': customRingtonePath,
      'repeatDays': repeatDays,
      'lastTriggered': lastTriggered?.toIso8601String(),
      'snoozeDuration': snoozeDuration,
      'label': label,
    };
  }

  factory Alarm.fromJson(Map<String, dynamic> json) {
    final timeStr = json['time'] as String? ?? '00:00';
    final timeParts = timeStr.split(':');
    return Alarm(
      id: json['id']?.toString(),
      time: TimeOfDay(
        hour: int.tryParse(timeParts[0]) ?? 0,
        minute: int.tryParse(timeParts[1]) ?? 0,
      ),
      isEnabled: json['isEnabled'] as bool? ?? true,
      ringtone: json['ringtone'] as String? ?? 'alarm.mp3',
      isCustomRingtone: json['isCustomRingtone'] as bool? ?? false,
      customRingtonePath: json['customRingtonePath']?.toString(),
      repeatDays:
      (json['repeatDays'] as List<dynamic>?)?.cast<bool>() ??
          List.filled(7, false),
      lastTriggered:
      json['lastTriggered'] != null
          ? DateTime.parse(json['lastTriggered'] as String)
          : null,
      snoozeDuration: json['snoozeDuration'] as int? ?? 5,
      label: json['label'] as String? ?? '',
    );
  }

// ... (rest of the file is unchanged)
}
