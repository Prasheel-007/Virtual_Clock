import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedClock extends StatefulWidget {
  const AnimatedClock({super.key});

  @override
  State<AnimatedClock> createState() => _AnimatedClockState();
}

class _AnimatedClockState extends State<AnimatedClock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60), // Animate over 60 seconds
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.0, // Adjust size as needed
      height: 100.0,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final minuteValue = _controller.value;
          final hourValue = minuteValue / 12.0; // Simple ratio for hour hand

          return CustomPaint(
            painter: _ClockPainter(
              hourValue: hourValue,
              minuteValue: minuteValue,
              color: Theme.of(context).primaryColor, // Use your app's primary color
            ),
          );
        },
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  final double hourValue;
  final double minuteValue;
  final Color color;

  _ClockPainter({required this.hourValue, required this.minuteValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw clock face (simple circle)
    final paint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);

    // Hour hand
    final hourAngle = 2 * pi * hourValue - pi / 2; // -pi/2 to start at 12
    final hourHandLength = radius * 0.5;
    final hourHandPaint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    final hourHandEnd = center + Offset(hourHandLength * cos(hourAngle), hourHandLength * sin(hourAngle));
    canvas.drawLine(center, hourHandEnd, hourHandPaint);

    // Minute hand
    final minuteAngle = 2 * pi * minuteValue - pi / 2;
    final minuteHandLength = radius * 0.7;
    final minuteHandPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    final minuteHandEnd = center + Offset(minuteHandLength * cos(minuteAngle), minuteHandLength * sin(minuteAngle));
    canvas.drawLine(center, minuteHandEnd, minuteHandPaint);

    // Center dot
    final centerDotPaint = Paint()..color = color;
    canvas.drawCircle(center, 4.0, centerDotPaint);
  }

  @override
  bool shouldRepaint(_ClockPainter oldDelegate) {
    return oldDelegate.hourValue != hourValue || oldDelegate.minuteValue != minuteValue;
  }
}