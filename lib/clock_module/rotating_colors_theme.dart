import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class RotatingColorsTheme extends StatefulWidget {
  final Widget child;

  const RotatingColorsTheme({super.key, required this.child});

  @override
  _RotatingColorsThemeState createState() => _RotatingColorsThemeState();
}

class _RotatingColorsThemeState extends State<RotatingColorsTheme> {
  Color _backgroundColor = Colors.blue;
  Color _textColor = Colors.white;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startColorRotation();
  }

  void _startColorRotation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _backgroundColor = _generateRandomColor();
        _textColor = _generateContrastingColor(_backgroundColor);
      });
    });
  }

  Color _generateRandomColor() {
    return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  Color _generateContrastingColor(Color background) {
    // Simple logic to choose between white or black based on luminance
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 3),
      color: _backgroundColor,
      child: Theme(
        data: ThemeData(
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: _textColor),
            bodyMedium: TextStyle(color: _textColor),
            titleLarge: TextStyle(color: _textColor),
            titleMedium: TextStyle(color: _textColor),
          ),
          iconTheme: IconThemeData(color: _textColor),
        ),
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}