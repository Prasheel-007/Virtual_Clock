import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../settings_module/settings_enums.dart'; // Import the enums

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.settingsChanged});

  // ValueNotifier to notify HomeScreen of settings changes
  final ValueNotifier<bool>? settingsChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ClockDisplayMode _clockDisplayMode = ClockDisplayMode.values[0];
  late TimeFormat _timeFormat = TimeFormat.values[0];
  late DigitalEffects _digitalEffect = DigitalEffects.values[0];
  Color _clockColor = Colors.black;
  bool _enableTickingSound = false;

  // New variables for analog clock styles
  late ClockFrameStyle _clockFrameStyle = ClockFrameStyle.values[0];
  late ClockHandStyle _clockHandStyle = ClockHandStyle.values[0];
  late MinuteMarkerStyle _minuteMarkerStyle = MinuteMarkerStyle.values[0];

  final List<ClockDisplayMode> _clockDisplayOptions =
  ClockDisplayMode.values.toList();
  final List<TimeFormat> _timeFormatOptions = TimeFormat.values.toList();
  final List<DigitalEffects> _digitalEffectOptions =
  DigitalEffects.values.toList();
  final List<Color> _clockColorOptions = [
    Colors.black,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
  ];
  late Color _selectedClockColor = _clockColor;

  // New lists for analog clock style options
  final List<ClockFrameStyle> _clockFrameOptions = ClockFrameStyle.values.toList();
  final List<ClockHandStyle> _clockHandOptions = ClockHandStyle.values.toList();
  final List<MinuteMarkerStyle> _minuteMarkerOptions = MinuteMarkerStyle.values.toList();

  // New variables for background themes
  String _selectedBackgroundTheme = 'Rotating Colors'; // Default theme
  final List<String> _backgroundThemeOptions = [
    'None',
    'Rotating Colors',
    'Falling Particles',
    // ... Add more themes here
  ];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    debugPrint("SettingsScreen: _loadSettings() started");
    try {
      final prefs = await SharedPreferences.getInstance();
      debugPrint("SettingsScreen: SharedPreferences instance obtained");

      // Safe enum loading with bounds checking
      final clockDisplayIndex = prefs.getInt('clockDisplayMode') ?? 0;
      final timeFormatIndex = prefs.getInt('timeFormat') ?? 0;
      final digitalEffectIndex = prefs.getInt('digitalEffect') ?? 0;

      // Load new analog clock settings
      final clockFrameIndex = prefs.getInt('clockFrameStyle') ?? 0;
      final clockHandIndex = prefs.getInt('clockHandStyle') ?? 0;
      final minuteMarkerIndex = prefs.getInt('minuteMarkerStyle') ?? 0;

      // Load background theme
      _selectedBackgroundTheme = prefs.getString('backgroundTheme') ?? 'Rotating Colors';

      setState(() {
        _clockDisplayMode = _getEnumSafe(ClockDisplayMode.values, clockDisplayIndex);
        _timeFormat = _getEnumSafe(TimeFormat.values, timeFormatIndex);
        _digitalEffect = _getEnumSafe(DigitalEffects.values, digitalEffectIndex);

        _clockColor = Color(prefs.getInt('clockColor') ?? Colors.black.value);
        _selectedClockColor = _clockColor;

        _enableTickingSound = prefs.getBool('enableTickingSound') ?? false;

        // Load new analog clock settings
        _clockFrameStyle = _getEnumSafe(ClockFrameStyle.values, clockFrameIndex);
        _clockHandStyle = _getEnumSafe(ClockHandStyle.values, clockHandIndex);
        _minuteMarkerStyle = _getEnumSafe(MinuteMarkerStyle.values, minuteMarkerIndex);

        _isLoading = false;
        debugPrint("SettingsScreen: Settings loaded successfully");
      });
    } catch (e, stackTrace) {
      debugPrint("Error loading settings: $e");
      debugPrint("Stack trace: $stackTrace");
      setState(() => _isLoading = false); // Ensure UI recovers from error
    }
  }

  // Helper method for safe enum loading
  T _getEnumSafe<T>(List<T> values, int index) {
    return values[index.clamp(0, values.length - 1)];
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('clockDisplayMode', _clockDisplayMode.index);
      await prefs.setInt('timeFormat', _timeFormat.index);
      await prefs.setInt('digitalEffect', _digitalEffect.index);
      await prefs.setInt('clockColor', _clockColor.value);
      await prefs.setBool('enableTickingSound', _enableTickingSound);

      // Save new analog clock settings
      await prefs.setInt('clockFrameStyle', _clockFrameStyle.index);
      await prefs.setInt('clockHandStyle', _clockHandStyle.index);
      await prefs.setInt('minuteMarkerStyle', _minuteMarkerStyle.index);

      // Save background theme
      await prefs.setString('backgroundTheme', _selectedBackgroundTheme);

      debugPrint("Settings saved successfully");
      // Notify HomeScreen of settings change
      widget.settingsChanged?.value = !(widget.settingsChanged?.value ?? false);

    } catch (e) {
      debugPrint("Error saving settings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        const Text('Clock Settings',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
        ListTile(
          title: const Text('Clock Display Mode'),
          trailing: DropdownButton<ClockDisplayMode>(
            value: _clockDisplayMode,
            items: _clockDisplayOptions.map((ClockDisplayMode value) {
              return DropdownMenuItem<ClockDisplayMode>(
                value: value,
                child: Text(value.label),
              );
            }).toList(),
            onChanged: (ClockDisplayMode? newValue) {
              if (newValue != null) {
                setState(() {
                  _clockDisplayMode = newValue;
                  _saveSettings();
                });
              }
            },
          ),
        ),
        ListTile(
          title: const Text('Time Format'),
          trailing: DropdownButton<TimeFormat>(
            value: _timeFormat,
            items: _timeFormatOptions.map((TimeFormat value) {
              return DropdownMenuItem<TimeFormat>(
                value: value,
                child: Text(value.label),
              );
            }).toList(),
            onChanged: (TimeFormat? newValue) {
              if (newValue != null) {
                setState(() {
                  _timeFormat = newValue;
                  _saveSettings();
                });
              }
            },
          ),
        ),
        ListTile(
          title: const Text('Digital Effect'),
          trailing: DropdownButton<DigitalEffects>(
            value: _digitalEffect,
            items: _digitalEffectOptions.map((DigitalEffects value) {
              return DropdownMenuItem<DigitalEffects>(
                value: value,
                child: Text(value.name),
              );
            }).toList(),
            onChanged: (DigitalEffects? newValue) {
              if (newValue != null) {
                setState(() {
                  _digitalEffect = newValue;
                  _saveSettings();
                });
              }
            },
          ),
        ),
        const SizedBox(height: 20.0),
        const Text('Clock Color',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: _clockColorOptions.map((Color color) {
            return InkWell(
              onTap: () {
                setState(() {
                  _clockColor = color;
                  _selectedClockColor = color;
                  _saveSettings();
                });
              },
              child: Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _selectedClockColor == color
                        ? Colors.grey
                        : Colors.transparent,
                    width: 2.0,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20.0),
        SwitchListTile(
          title: const Text('Clock Ticking Sound'),
          value: _enableTickingSound,
          onChanged: (bool value) {
            setState(() {
              _enableTickingSound = value;
              _saveSettings();
            });
          },
        ),

        // New Analog Clock Style Options
        const SizedBox(height: 20.0),
        const Text('Analog Clock Style',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
        ListTile(
          title: const Text('Clock Frame Style'),
          trailing: DropdownButton<ClockFrameStyle>(
            value: _clockFrameStyle,
            items: _clockFrameOptions.map((ClockFrameStyle value) {
              return DropdownMenuItem<ClockFrameStyle>(
                value: value,
                child: Text(value.label),
              );
            }).toList(),
            onChanged: (ClockFrameStyle? newValue) {
              if (newValue != null) {
                setState(() {
                  _clockFrameStyle = newValue;
                  _saveSettings();
                });
              }
            },
          ),
        ),
        ListTile(
          title: const Text('Clock Hand Style'),
          trailing: DropdownButton<ClockHandStyle>(
            value: _clockHandStyle,
            items: _clockHandOptions.map((ClockHandStyle value) {
              return DropdownMenuItem<ClockHandStyle>(
                value: value,
                child: Text(value.label),
              );
            }).toList(),
            onChanged: (ClockHandStyle? newValue) {
              if (newValue != null) {
                setState(() {
                  _clockHandStyle = newValue;
                  _saveSettings();
                });
              }
            },
          ),
        ),
        ListTile(
          title: const Text('Minute Markers'),
          trailing: DropdownButton<MinuteMarkerStyle>(
            value: _minuteMarkerStyle,
            items: _minuteMarkerOptions.map((MinuteMarkerStyle value) {
              return DropdownMenuItem<MinuteMarkerStyle>(
                value: value,
                child: Text(value.label),
              );
            }).toList(),
            onChanged: (MinuteMarkerStyle? newValue) {
              if (newValue != null) {
                setState(() {
                  _minuteMarkerStyle = newValue;
                  _saveSettings();
                });
              }
            },
          ),
        ),

        // New Background Theme Option
        const SizedBox(height: 20.0),
        const Text('Background',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
        ListTile(
          title: const Text('Background Theme'),
          trailing: DropdownButton<String>(
            value: _selectedBackgroundTheme,
            items: _backgroundThemeOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedBackgroundTheme = newValue;
                  _saveSettings();
                });
              }
            },
          ),
        ),
      ],
    );
  }
}