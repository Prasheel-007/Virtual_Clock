import 'package:flutter/material.dart';
import 'package:time_and_tide/home_screen.dart';
import 'package:time_and_tide/welcome_module/animated_clock.dart';
import 'package:audioplayers/audioplayers.dart'; // Import the audioplayers package

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final AudioPlayer _launchSoundPlayer = AudioPlayer(); // Create AudioPlayer instance

  @override
  void initState() {
    super.initState();
    _playSound(); // Call the play sound function
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  Future<void> _playSound() async {
    try {
      await _launchSoundPlayer.play(AssetSource('sounds/launch_sound.aac'));
    } catch (e) {
      debugPrint("Error playing launch sound: $e");
    }
  }

  @override
  void dispose() {
    _launchSoundPlayer.dispose(); // Dispose of the player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Time&Tide - waits for none',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            AnimatedClock(),
            SizedBox(height: 20.0),
            Text(
              'Loading...',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}