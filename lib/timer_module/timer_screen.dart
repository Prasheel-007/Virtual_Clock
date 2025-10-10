import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _remainingSeconds = 0;
  bool _isRunning = false;
  Timer? _timer;
  final AudioPlayer _startSoundPlayer = AudioPlayer();
  final AudioPlayer _finishSoundPlayer = AudioPlayer();
  final TextEditingController _minutesController =
  TextEditingController(text: '00');
  final TextEditingController _secondsController =
  TextEditingController(text: '00');

  @override
  void dispose() {
    _timer?.cancel();
    _minutesController.dispose();
    _secondsController.dispose();
    _startSoundPlayer.dispose();
    _finishSoundPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    int minutes = int.tryParse(_minutesController.text) ?? 0;
    int seconds = int.tryParse(_secondsController.text) ?? 0;
    _remainingSeconds = (minutes * 60) + seconds;
    if (_remainingSeconds > 0) {
      _playStartSound();
      _startTimerInterval();
    }
  }

  void _resumeTimer() {
    if (_remainingSeconds > 0) {
      _playStartSound();
      _startTimerInterval();
    }
  }

  void _startTimerInterval() {
    setState(() {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0 && _isRunning) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          _stopTimer();
          _stopStartSound();
          _playFinishSound();
        }
      });
    });
  }

  Future<void> _playStartSound() async {
    try {
      await _startSoundPlayer.play(AssetSource('sounds/timer.aac'));
    } catch (e) {
      debugPrint("Error playing timer start sound: $e");
    }
  }

  Future<void> _stopStartSound() async {
    try {
      await _startSoundPlayer.stop();
      await _startSoundPlayer.seek(Duration.zero);
    } catch (e) {
      debugPrint("Error stopping timer start sound: $e");
    }
  }

  Future<void> _playFinishSound() async {
    try {
      await _finishSoundPlayer.play(AssetSource('sounds/timer_finish.aac'));
    } catch (e) {
      debugPrint("Error playing timer finish sound: $e");
    }
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
      _timer?.cancel();
      _stopStartSound();
    });
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _timer?.cancel();
      _remainingSeconds = 0;
      _minutesController.text = '00';
      _secondsController.text = '00';
      _stopStartSound();
    });
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _timer?.cancel();
    });
  }

  String _formatTime(int seconds) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 60.0,
                child: TextField(
                  controller: _minutesController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: 'mm',
                  ),
                ),
              ),
              const Text(':', style: TextStyle(fontSize: 30.0)),
              SizedBox(
                width: 60.0,
                child: TextField(
                  controller: _secondsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: 'ss',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Text(
            _formatTime(_remainingSeconds),
            style: const TextStyle(fontSize: 60.0),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: (!_isRunning && _remainingSeconds > 0)
                    ? _resumeTimer
                    : (!_isRunning && _remainingSeconds == 0)
                    ? _startTimer
                    : null,
                child: Text(!_isRunning
                    ? (_remainingSeconds > 0 ? 'Resume' : 'Start')
                    : 'Start'),
              ),
              const SizedBox(width: 20.0),
              ElevatedButton(
                onPressed: _isRunning ? _pauseTimer : null,
                child: const Text('Pause'),
              ),
              const SizedBox(width: 20.0),
              ElevatedButton(
                onPressed: _remainingSeconds > 0 || !_isRunning
                    ? _resetTimer
                    : null,
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}