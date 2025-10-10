import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_and_tide/alarm_module/alarm.dart';
import 'package:time_and_tide/alarm_module/alarm_screen.dart';
import 'package:time_and_tide/clock_module/clock_screen.dart';
import 'package:time_and_tide/settings_module/settings_screen.dart';
import 'package:time_and_tide/stopwatch_module/stopwatch_screen.dart';
import 'package:time_and_tide/timezones_module/timezones_screen.dart';
import 'package:time_and_tide/timer_module/timer_screen.dart';
// REMOVED: Unnecessary import of alarm_service.dart

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  final ValueNotifier<List<Alarm>> _alarms = ValueNotifier<List<Alarm>>([]);
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animationController.forward();
    // CORRECTED: The _loadAlarms method now handles this logic.
    _loadAlarms();
  }

  // REMOVED: The didChangeDependencies method and the call to setContext
  // are no longer needed with the new AlarmService.

  Future<void> _loadAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alarmsJson = prefs.getStringList('alarms') ?? [];
      if (mounted) {
        _alarms.value =
            alarmsJson.map((json) => Alarm.fromJson(jsonDecode(json))).toList();
      }
    } catch (e) {
      debugPrint('Error loading alarms: $e');
    }
  }

  Future<void> _saveAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alarmsJson =
      _alarms.value.map((alarm) => jsonEncode(alarm.toJson())).toList();
      await prefs.setStringList('alarms', alarmsJson);
    } catch (e) {
      debugPrint('Error saving alarms: $e');
    }
  }

  void _updateAlarms(List<Alarm> updatedAlarms) {
    _alarms.value = updatedAlarms;
    _saveAlarms();
    // REMOVED: The call to AlarmService().loadAlarms() is no longer needed.
    // The service now handles its state internally.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time & Tide')),
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          const ClockScreen(),
          ValueListenableBuilder<List<Alarm>>(
            valueListenable: _alarms,
            builder: (context, alarms, _) {
              return AlarmsScreen(
                alarms: alarms,
                onAlarmsUpdated: _updateAlarms,
              );
            },
          ),
          const StopwatchScreen(),
          const TimerScreen(),
          const TimezonesScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.watch),
            label: 'Clock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Alarms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Stopwatch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hourglass_empty),
            label: 'Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Time Zones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _alarms.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
