import 'package:flutter/material.dart';
import 'dart:async';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  int _elapsedMilliseconds = 0;
  bool _isRunning = false;
  Timer? _timer;
  final List<String> _laps = [];

  String get _formattedTime {
    final int hundreds = (_elapsedMilliseconds / 10).floor() % 100;
    final int seconds = (_elapsedMilliseconds / 1000).floor() % 60;
    final int minutes = (_elapsedMilliseconds / 60000).floor() % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${hundreds.toString().padLeft(2, '0')}';
  }

  void _startStopwatch() {
    setState(() {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        setState(() {
          _elapsedMilliseconds += 10;
        });
      });
    });
  }

  void _pauseStopwatch() {
    setState(() {
      _isRunning = false;
      _timer?.cancel();
    });
  }

  void _lap() {
    setState(() {
      _laps.insert(0, _formattedTime);
    });
  }

  void _resetStopwatch() {
    setState(() {
      _elapsedMilliseconds = 0;
      _isRunning = false;
      _timer?.cancel();
      _laps.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            _formattedTime,
            style: const TextStyle(fontSize: 60.0),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _isRunning ? _pauseStopwatch : _startStopwatch,
                child: Text(_isRunning ? 'Pause' : 'Start'),
              ),
              const SizedBox(width: 10.0),
              ElevatedButton(
                onPressed: _isRunning ? _lap : null,
                child: const Text('Lap'),
              ),
              const SizedBox(width: 10.0),
              ElevatedButton(
                onPressed: !_isRunning && _elapsedMilliseconds > 0 ? _resetStopwatch : null,
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Expanded(
            child: ListView.builder(
              itemCount: _laps.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Lap ${index + 1}'),
                  trailing: Text(_laps[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}