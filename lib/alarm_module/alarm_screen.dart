import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'alarm.dart';
import 'alarm_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AlarmsScreen extends StatefulWidget {
  final List<Alarm> alarms;
  final Function(List<Alarm>) onAlarmsUpdated;

  const AlarmsScreen({
    super.key,
    required this.alarms,
    required this.onAlarmsUpdated,
  });

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen> {
  late List<Alarm> _alarms;
  final AudioPlayer _previewPlayer = AudioPlayer();
  final AlarmService _alarmService = AlarmService();
  // CORRECTED: Replaced hyphens with underscores
  final List<String> _predefinedRingtones = [
    'aashiqui_2.aac',
    'titanic.aac',
    'james_bond_2.aac',
    'mission_impossible.aac',
    'pink_panther.aac',
    'pirates_of_caribbean.aac',
    'james_bond_1.aac',
  ];
  bool _isPlaying = false;
  int? _currentlyPlayingAlarmIndex;

  @override
  void initState() {
    super.initState();
    _alarms = List.from(widget.alarms);
    _previewPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentlyPlayingAlarmIndex = null;
        });
      }
    });
  }

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson =
    _alarms.map((alarm) => jsonEncode(alarm.toJson())).toList();
    await prefs.setStringList('alarms', alarmsJson);
    widget.onAlarmsUpdated(_alarms);
  }

  Future<void> _pickCustomRingtone(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      setState(() {
        _alarms[index].isCustomRingtone = true;
        _alarms[index].customRingtonePath = result.files.single.path;
        _alarms[index].ringtone = 'Custom Ringtone';
      });
      await _saveAlarms();
    }
  }

  Future<void> _previewRingtone(int index) async {
    final alarm = _alarms[index];
    try {
      if (_isPlaying && _currentlyPlayingAlarmIndex == index) {
        await _previewPlayer.stop();
        setState(() {
          _isPlaying = false;
          _currentlyPlayingAlarmIndex = null;
        });
      } else {
        await _previewPlayer.stop(); // Stop any previous playback first

        if (alarm.isCustomRingtone && alarm.customRingtonePath != null) {
          await _previewPlayer.play(
            DeviceFileSource(alarm.customRingtonePath!),
          );
        } else {
          // Preview from assets, not the raw folder
          await _previewPlayer.play(AssetSource('sounds/${alarm.ringtone}'));
        }

        setState(() {
          _isPlaying = true;
          _currentlyPlayingAlarmIndex = index;
        });
      }
    } catch (e) {
      debugPrint("Error previewing ringtone: $e");
      if(mounted) {
        setState(() {
          _isPlaying = false;
          _currentlyPlayingAlarmIndex = null;
        });
      }
    }
  }

  void _updateAlarmRingtone(int index, String ringtone) async {
    setState(() {
      _alarms[index].isCustomRingtone = false;
      _alarms[index].customRingtonePath = null;
      _alarms[index].ringtone = ringtone;
    });
    await _saveAlarms();
  }

  void _addNewAlarm() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      final newAlarm = Alarm(time: selectedTime);
      setState(() {
        _alarms.add(newAlarm);
      });
      await _saveAlarms();
      if (newAlarm.isEnabled) {
        await _alarmService.scheduleAlarm(newAlarm);
      }
    }
  }

  void _toggleAlarm(int index, bool value) async {
    setState(() {
      _alarms[index].isEnabled = value;
    });

    await _saveAlarms();

    if (value) {
      await _alarmService.scheduleAlarm(_alarms[index]);
    } else {
      await _alarmService.cancelAlarm(_alarms[index].id);
    }
  }

  void _editAlarm(int index) async {
    final alarm = _alarms[index];
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlarmEditDialog(alarm: alarm),
    );

    if (result != null) {
      // Create a new alarm object with the updated properties
      final updatedAlarm = Alarm(
        id: alarm.id,
        time: result['time'] as TimeOfDay,
        repeatDays: result['repeatDays'] as List<bool>,
        snoozeDuration: result['snoozeDuration'] as int,
        isEnabled: alarm.isEnabled, // Preserve the original enabled state
        ringtone: alarm.ringtone,
        isCustomRingtone: alarm.isCustomRingtone,
        customRingtonePath: alarm.customRingtonePath,
        label: result['label'] as String,
      );

      setState(() {
        _alarms[index] = updatedAlarm;
      });
      await _saveAlarms();

      // Cancel the old alarm and reschedule the new one if it's enabled
      await _alarmService.cancelAlarm(alarm.id);
      if (updatedAlarm.isEnabled) {
        await _alarmService.scheduleAlarm(updatedAlarm);
      }
    }
  }

  void _deleteAlarm(int index) async {
    final alarmToDelete = _alarms[index];
    // First, cancel the scheduled notification
    await _alarmService.cancelAlarm(alarmToDelete.id);
    // Then, remove it from the list and save
    setState(() {
      _alarms.removeAt(index);
    });
    await _saveAlarms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewAlarm,
        child: const Icon(Icons.add),
      ),
      body: _alarms.isEmpty
          ? const Center(
        child: Text(
          'No alarms set.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _alarms.length,
        itemBuilder: (context, index) {
          final alarm = _alarms[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              onTap: () => _editAlarm(index),
              leading: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteAlarm(index),
              ),
              title: Text(
                alarm.time.format(context),
                style: const TextStyle(fontSize: 20.0),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alarm.ringtone.replaceAll('.aac', '').replaceAll('_', ' ')),
                  if (alarm.repeatDays.any((day) => day))
                    Text(_getRepeatDaysText(alarm.repeatDays)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _isPlaying && _currentlyPlayingAlarmIndex == index
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    onPressed: () => _previewRingtone(index),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.music_note),
                    onSelected: (String ringtone) {
                      if (ringtone == 'custom') {
                        _pickCustomRingtone(index);
                      } else {
                        _updateAlarmRingtone(index, ringtone);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        ..._predefinedRingtones.map((ringtone) {
                          return PopupMenuItem<String>(
                            value: ringtone,
                            child: Text(ringtone.replaceAll('.aac', '').replaceAll('_', ' ')),
                          );
                        }),
                        const PopupMenuItem<String>(
                          value: 'custom',
                          child: Text('Custom Ringtone'),
                        ),
                      ];
                    },
                  ),
                  Switch(
                    value: alarm.isEnabled,
                    onChanged: (bool newValue) {
                      _toggleAlarm(index, newValue);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getRepeatDaysText(List<bool> repeatDays) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final selectedDays = <String>[];
    for (var i = 0; i < repeatDays.length; i++) {
      if (repeatDays[i]) {
        selectedDays.add(days[i]);
      }
    }
    return selectedDays.join(', ');
  }

  @override
  void dispose() {
    _previewPlayer.dispose();
    super.dispose();
  }
}

class AlarmEditDialog extends StatefulWidget {
  final Alarm alarm;

  const AlarmEditDialog({super.key, required this.alarm});

  @override
  State<AlarmEditDialog> createState() => _AlarmEditDialogState();
}

class _AlarmEditDialogState extends State<AlarmEditDialog> {
  late TimeOfDay _time;
  late List<bool> _repeatDays;
  late int _snoozeDuration;
  late TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    _time = widget.alarm.time;
    _repeatDays = List.from(widget.alarm.repeatDays);
    _snoozeDuration = widget.alarm.snoozeDuration;
    _labelController = TextEditingController(text: widget.alarm.label);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Alarm'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Label',
                hintText: 'e.g., Wake up',
              ),
            ),
            ListTile(
              title: const Text('Time'),
              trailing: TextButton(
                onPressed: () async {
                  final TimeOfDay? selectedTime = await showTimePicker(
                    context: context,
                    initialTime: _time,
                  );
                  if (selectedTime != null) {
                    setState(() => _time = selectedTime);
                  }
                },
                child: Text(_time.format(context)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Repeat Days'),
            Wrap(
              spacing: 8,
              children: [
                for (var i = 0; i < 7; i++)
                  FilterChip(
                    label: Text(
                      ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][i],
                    ),
                    selected: _repeatDays[i],
                    onSelected: (bool selected) {
                      setState(() => _repeatDays[i] = selected);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Snooze Duration'),
              trailing: DropdownButton<int>(
                value: _snoozeDuration,
                items:
                [5, 10, 15, 20, 30].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value minutes'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() => _snoozeDuration = newValue);
                  }
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              'time': _time,
              'repeatDays': _repeatDays,
              'snoozeDuration': _snoozeDuration,
              'label': _labelController.text,
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

