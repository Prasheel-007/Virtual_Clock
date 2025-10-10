import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analogue_clock_screen.dart'; // Ensure this path is correct
import 'digital_clock.dart';
import '../settings_module/settings_enums.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart'; // Import audioplayers
import 'rotating_colors_theme.dart';
import 'falling_particles_theme.dart';
import 'package:timezone/timezone.dart' as tz;

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> with WidgetsBindingObserver {
  ClockDisplayMode _displayMode = ClockDisplayMode.both;
  TimeFormat _timeFormat = TimeFormat.hour12;
  DigitalEffects _digitalEffect = DigitalEffects.none;
  Color _selectedColor = Colors.blue;
  DateTime _currentTime = DateTime.now();
  String? _secondaryClockTimezone;
  Timer? _timer;
  bool _isInitialized = false;
  final AudioPlayer _tickPlayer = AudioPlayer(); // Initialize AudioPlayer
  bool _isTickingEnabled = false;
  ClockFrameStyle _clockFrameStyle = ClockFrameStyle.circle;
  ClockHandStyle _clockHandStyle = ClockHandStyle.standard;
  MinuteMarkerStyle _minuteMarkerStyle = MinuteMarkerStyle.fivesOnly;
  String _selectedBackgroundTheme = 'Rotating Colors';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _loadPreferences();
      _startTimer();
      await _loadTickingPreference();
      _startOrStopTickingSound();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint("Initialization error: $e");
      // Fallback to default values if loading fails
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _displayMode = ClockDisplayMode.both;
          _timeFormat = TimeFormat.hour12;
          _digitalEffect = DigitalEffects.none;
          _selectedColor = Colors.blue;
          _clockFrameStyle = ClockFrameStyle.circle;
          _clockHandStyle = ClockHandStyle.standard;
          _minuteMarkerStyle = MinuteMarkerStyle.fivesOnly;
          _selectedBackgroundTheme = 'Rotating Colors';
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadTickingPreference().then((_) => _startOrStopTickingSound());
    } else if (state == AppLifecycleState.paused) {
      _stopTickingSound();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
        _loadTickingPreference();
      }
    });
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Safe enum loading with fallback values
      final displayModeIndex = _safeGetInt(prefs, 'clockDisplayMode', 2);
      final timeFormatIndex = _safeGetInt(prefs, 'timeFormat', 0);
      final digitalEffectIndex = _safeGetInt(prefs, 'digitalEffect', 0);
      final clockFrameIndex = _safeGetInt(prefs, 'clockFrameStyle', 0);
      final clockHandIndex = _safeGetInt(prefs, 'clockHandStyle', 0);
      final minuteMarkerIndex = _safeGetInt(prefs, 'minuteMarkerStyle', 0);
      _selectedBackgroundTheme =
          prefs.getString('backgroundTheme') ?? 'Rotating Colors';
      _secondaryClockTimezone = prefs.getString('secondary_clock_timezone');

      setState(() {
        _displayMode =
            ClockDisplayMode.values[_clampIndex(
              displayModeIndex,
              ClockDisplayMode.values.length,
            )];
        _timeFormat =
            TimeFormat.values[_clampIndex(
              timeFormatIndex,
              TimeFormat.values.length,
            )];
        _digitalEffect =
            DigitalEffects.values[_clampIndex(
              digitalEffectIndex,
              DigitalEffects.values.length,
            )];
        _clockFrameStyle =
            ClockFrameStyle.values[_clampIndex(
              clockFrameIndex,
              ClockFrameStyle.values.length,
            )];
        _clockHandStyle =
            ClockHandStyle.values[_clampIndex(
              clockHandIndex,
              ClockHandStyle.values.length,
            )];
        _minuteMarkerStyle =
            MinuteMarkerStyle.values[_clampIndex(
              minuteMarkerIndex,
              MinuteMarkerStyle.values.length,
            )];

        final savedColor = _safeGetInt(prefs, 'clockColor', Colors.blue.value);
        _selectedColor = Color(savedColor);
      });
    } catch (e) {
      debugPrint("Error loading preferences: $e");
      rethrow; // Rethrow to be caught in _initialize
    }
  }

  int _safeGetInt(SharedPreferences prefs, String key, int fallback) {
    try {
      return prefs.getInt(key) ?? fallback;
    } catch (e) {
      debugPrint("Error reading $key: $e");
      return fallback;
    }
  }

  int _clampIndex(int index, int length) {
    return index.clamp(0, length - 1);
  }

  Future<void> _loadTickingPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newValue = prefs.getBool('enableTickingSound') ?? false;
      if (newValue != _isTickingEnabled) {
        setState(() => _isTickingEnabled = newValue);
        _startOrStopTickingSound();
      }
    } catch (e) {
      debugPrint("Error loading ticking preference: $e");
    }
  }

  void _startTickingSound() async {
    try {
      await _tickPlayer.stop();
      await _tickPlayer.play(
        AssetSource('sounds/tick.aac'),
        volume: 0.1,
      ); // Use AssetSource
      await _tickPlayer.setReleaseMode(ReleaseMode.loop); // Use ReleaseMode
    } catch (e) {
      debugPrint("Error playing tick sound: $e");
    }
  }

  void _stopTickingSound() async {
    try {
      await _tickPlayer.stop();
    } catch (e) {
      debugPrint("Error stopping tick sound: $e");
    }
  }

  void _startOrStopTickingSound() {
    if (_isTickingEnabled) {
      _startTickingSound();
    } else {
      _stopTickingSound();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopTickingSound();
    _tickPlayer.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget _buildClockWidget(DateTime time) {
    if (_displayMode == ClockDisplayMode.analog) {
      return SizedBox(
        width: 250,
        height: 250,
        child: CustomPaint(
          painter: AnalogClock(
            currentTime: time,
            hourHandColor: _selectedColor,
            minuteHandColor: _selectedColor.withAlpha((0.7 * 255).round()),
            secondHandColor: _selectedColor.withAlpha((0.5 * 255).round()),
            frameStyle: _clockFrameStyle,
            handStyle: _clockHandStyle,
            markerStyle: _minuteMarkerStyle,
          ),
        ),
      );
    } else if (_displayMode == ClockDisplayMode.digital) {
      return DigitalClock(
        currentTime: time,
        textColor: _selectedColor,
        fontSize: 48,
        use24HourFormat: _timeFormat == TimeFormat.hour24,
        digitalEffect: _digitalEffect,
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 250,
            height: 250,
            child: CustomPaint(
              painter: AnalogClock(
                currentTime: time,
                hourHandColor: _selectedColor,
                minuteHandColor: _selectedColor.withAlpha((0.7 * 255).round()),
                secondHandColor: _selectedColor.withAlpha((0.5 * 255).round()),
                frameStyle: _clockFrameStyle,
                handStyle: _clockHandStyle,
                markerStyle: _minuteMarkerStyle,
              ),
            ),
          ),
          const SizedBox(height: 30),
          DigitalClock(
            currentTime: time,
            textColor: _selectedColor,
            fontSize: 36,
            use24HourFormat: _timeFormat == TimeFormat.hour24,
            digitalEffect: _digitalEffect,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Main clock widget (local time)
    Widget mainClockWidget = _buildClockWidget(_currentTime);
    Widget themedMainClockWidget;
    if (_selectedBackgroundTheme == 'Rotating Colors') {
      themedMainClockWidget = RotatingColorsTheme(child: mainClockWidget);
    } else if (_selectedBackgroundTheme == 'Falling Particles') {
      themedMainClockWidget = FallingParticlesTheme(child: mainClockWidget);
    } else {
      themedMainClockWidget = mainClockWidget;
    }

    // Secondary clock widget (timezone time)
    Widget? secondaryClockWidget;
    if (_secondaryClockTimezone != null) {
      final location = tz.getLocation(_secondaryClockTimezone!);
      final now = DateTime.now();
      final secondaryTime = tz.TZDateTime.from(now, location);
      secondaryClockWidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _secondaryClockTimezone!,
            style: TextStyle(
              color: _selectedColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildClockWidget(secondaryTime),
        ],
      );
    }

    // Build the list of pages for the PageView
    final List<Widget> pages = [Center(child: themedMainClockWidget)];
    if (secondaryClockWidget != null) {
      pages.add(Center(child: secondaryClockWidget));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView(scrollDirection: Axis.vertical, children: pages),
      ),
    );
  }
}
