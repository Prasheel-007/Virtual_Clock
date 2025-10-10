import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimezonesScreen extends StatefulWidget {
  const TimezonesScreen({super.key});

  @override
  State<TimezonesScreen> createState() => _TimezonesScreenState();
}

class _TimezonesScreenState extends State<TimezonesScreen> {
  List<String> _selectedTimezones = [
    'Asia/Kolkata',
    'America/New_York',
  ]; // Default timezones
  String? _secondaryClockTimezone; // New variable for secondary clock
  List<tz.Location> _availableTimezones = [];

  @override
  void initState() {
    super.initState();
    tzdata.initializeTimeZones();
    _availableTimezones = tz.timeZoneDatabase.locations.values.toList();
    _loadSelectedTimezones(); // Load previously selected timezones
    _loadSecondaryClockTimezone(); // Load secondary clock timezone
  }

  // Load saved timezones from SharedPreferences
  Future<void> _loadSelectedTimezones() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTimezones =
          prefs.getStringList('timezones') ?? _selectedTimezones;
    });
  }

  // Load secondary clock timezone
  Future<void> _loadSecondaryClockTimezone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _secondaryClockTimezone = prefs.getString('secondary_clock_timezone');
    });
  }

  // Save timezones to SharedPreferences
  Future<void> _saveSelectedTimezones() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('timezones', _selectedTimezones);
  }

  // Save secondary clock timezone
  Future<void> _saveSecondaryClockTimezone(String? timezone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (timezone != null) {
      prefs.setString('secondary_clock_timezone', timezone);
    } else {
      prefs.remove('secondary_clock_timezone');
    }
  }

  String _formatTime(tz.TZDateTime dateTime) {
    final format = DateFormat('EEE, MMM d, yyyy h:mm:ss a zzzz');
    return format.format(dateTime);
  }

  void _addTimezone() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Timezone'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _availableTimezones.length,
              itemBuilder: (context, index) {
                final timezoneName = _availableTimezones[index].name;
                return ListTile(
                  title: Text(timezoneName),
                  onTap: () => Navigator.pop(context, timezoneName),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    if (selected != null && !_selectedTimezones.contains(selected)) {
      setState(() {
        _selectedTimezones.add(selected);
        _saveSelectedTimezones();
      });
    }
  }

  void _removeTimezone(String timezone) {
    setState(() {
      _selectedTimezones.remove(timezone);
      if (_secondaryClockTimezone == timezone) {
        _secondaryClockTimezone = null;
        _saveSecondaryClockTimezone(null);
      }
      _saveSelectedTimezones();
    });
  }

  void _setSecondaryClock(String timezone) {
    setState(() {
      _secondaryClockTimezone = timezone;
      _saveSecondaryClockTimezone(timezone);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Zones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_outlined),
            onPressed: _addTimezone,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_secondaryClockTimezone != null)
            Card(
              margin: const EdgeInsets.all(8.0),
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: ListTile(
                title: Text('Secondary Clock: $_secondaryClockTimezone'),
                subtitle: Text(
                  _formatTime(
                    tz.TZDateTime.now(tz.getLocation(_secondaryClockTimezone!)),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _secondaryClockTimezone = null;
                      _saveSecondaryClockTimezone(null);
                    });
                  },
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedTimezones.length,
              itemBuilder: (context, index) {
                final timezoneName = _selectedTimezones[index];
                final now = tz.TZDateTime.now(tz.getLocation(timezoneName));
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(timezoneName),
                    subtitle: Text(_formatTime(now)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_secondaryClockTimezone != timezoneName)
                          IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () => _setSecondaryClock(timezoneName),
                            tooltip: 'Set as Secondary Clock',
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeTimezone(timezoneName),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
