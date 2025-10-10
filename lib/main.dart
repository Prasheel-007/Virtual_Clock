import 'package:flutter/material.dart';
import 'package:time_and_tide/alarm_module/alarm_service.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;
import 'package:time_and_tide/welcome_module/welcome_screen.dart';

void main() async {
  // Ensure Flutter engine is initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data, essential for scheduling alarms correctly.
  tz_data.initializeTimeZones();

  // Set the local timezone for the app.
  try {
    // Platform-specific way to get the timezone name.
    if (Platform.isAndroid || Platform.isIOS) {
      final String timeZoneName = DateTime.now().timeZoneName;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } else {
      // Fallback for desktop platforms which may not provide a timezone name.
      tz.setLocalLocation(tz.UTC);
    }
  } catch (e) {
    debugPrint("Could not set local timezone, falling back to UTC: $e");
    tz.setLocalLocation(tz.UTC);
  }

  // Initialize the AlarmService which now handles notifications.
  await AlarmService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time & Tide',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
