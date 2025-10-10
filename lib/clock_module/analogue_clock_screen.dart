import 'package:flutter/material.dart';
import 'dart:math';
import '../settings_module/settings_enums.dart'; // Import the enums

class AnalogClock extends CustomPainter {
  final DateTime currentTime;
  final Color hourHandColor;
  final Color minuteHandColor;
  final Color secondHandColor;
  final bool use24HourFormat;
  final ClockFrameStyle frameStyle;
  final ClockHandStyle handStyle;
  final MinuteMarkerStyle markerStyle;

  AnalogClock({
    required this.currentTime,
    required this.hourHandColor,
    required this.minuteHandColor,
    required this.secondHandColor,
    this.use24HourFormat = false,
    this.frameStyle = ClockFrameStyle.circle, // Default style
    this.handStyle = ClockHandStyle.standard, // Default style
    this.markerStyle = MinuteMarkerStyle.fivesOnly, // Default
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: radius * 0.1,
      fontWeight: FontWeight.bold,
    );

    // Draw clock face/frame
    _drawClockFrame(canvas, center, radius);

    // Draw minute markers
    _drawMinuteMarkers(canvas, center, radius);

    // Draw hour numbers (1-12) - No change here
    final numbers = [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
    for (var i = 0; i < numbers.length; i++) {
      final angle = -pi / 2 + (i * (2 * pi / 12));
      final textPainter = TextPainter(
        text: TextSpan(text: numbers[i].toString(), style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(
          center.dx + 0.72 * radius * cos(angle) - textPainter.width / 2,
          center.dy + 0.72 * radius * sin(angle) - textPainter.height / 2,
        ),
      );
    }

    // Draw clock hands
    final hourAngle =
        (currentTime.hour % 12 + currentTime.minute / 60) * 30 * pi / 180;
    final minuteAngle = currentTime.minute * 6 * pi / 180;
    final secondAngle = currentTime.second * 6 * pi / 180;

    _drawHand(
      canvas: canvas,
      center: center,
      angle: hourAngle,
      length: radius * 0.5,
      color: hourHandColor,
      width: 6,
      handStyle: handStyle, // Pass the hand style
    );
    _drawHand(
      canvas: canvas,
      center: center,
      angle: minuteAngle,
      length: radius * 0.7,
      color: minuteHandColor,
      width: 4,
      handStyle: handStyle, // Pass the hand style
    );
    _drawHand(
      canvas: canvas,
      center: center,
      angle: secondAngle,
      length: radius * 0.85,
      color: secondHandColor,
      width: 2,
      handStyle: handStyle, // Pass the hand style
    );

    // Draw center dot
    canvas.drawCircle(center, 6, Paint()..color = Colors.black);
  }

  // New methods to draw based on style
  void _drawClockFrame(Canvas canvas, Offset center, double radius) {
    Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    switch (frameStyle) {
      case ClockFrameStyle.circle:
        canvas.drawCircle(center, radius, paint);
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
        );
        break;
      case ClockFrameStyle.square:
        final rect = Rect.fromCircle(center: center, radius: radius);
        canvas.drawRect(rect, paint);
        break;
      case ClockFrameStyle.none:
      // Don't draw a frame
        break;
    }
  }

  void _drawMinuteMarkers(Canvas canvas, Offset center, double radius) {
    for (var i = 0; i < 60; i++) {
      final angle = i * 6 * pi / 180;
      final isHourMarker = i % 5 == 0;
      final markerLength = isHourMarker ? 15.0 : 8.0;
      final markerPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = isHourMarker ? 2.5 : 1.5;

      // Draw minute markers based on the selected style
      if (markerStyle == MinuteMarkerStyle.fivesOnly) {
        if (i % 5 == 0) {
          canvas.drawLine(
            center + Offset(0.85 * radius * cos(angle),
                0.85 * radius * sin(angle)),
            center + Offset((0.85 + markerLength / radius) * radius * cos(angle),
                (0.85 + markerLength / radius) * radius * sin(angle)),
            markerPaint,
          );
        }
      } else if (markerStyle == MinuteMarkerStyle.allWithHighlight) {
        canvas.drawLine(
          center + Offset(0.85 * radius * cos(angle),
              0.85 * radius * sin(angle)),
          center + Offset((0.85 + markerLength / radius) * radius * cos(angle),
              (0.85 + markerLength / radius) * radius * sin(angle)),
          markerPaint,
        );
        if (i % 5 == 0) {
          // Highlight multiples of 5
          final highlightPaint = Paint()
            ..color = Colors.red
            ..strokeWidth = 3.0;
          canvas.drawCircle(
              center + Offset(0.85 * radius * cos(angle),
                  0.85 * radius * sin(angle)),
              3,
              highlightPaint);
        }
      } else if (markerStyle == MinuteMarkerStyle.none) {
        // Don't draw markers
      }
    }
  }

  void _drawHand({
    required Canvas canvas,
    required Offset center,
    required double angle,
    required double length,
    required Color color,
    required double width,
    required ClockHandStyle handStyle, // Take the style
  }) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    Offset endPoint = center + Offset(
      length * cos(angle - pi / 2),
      length * sin(angle - pi / 2),
    );

    // Draw hands based on the selected style
    switch (handStyle) {
      case ClockHandStyle.standard:
      // Draw a simple line
        canvas.drawLine(center, endPoint, paint);
        break;
      case ClockHandStyle.elegant:
      // Draw a more stylized hand (e.g., with a rounded base)
        Path path = Path();
        path.moveTo(center.dx - width / 2, center.dy);
        path.lineTo(center.dx + width / 2, center.dy);
        path.lineTo(endPoint.dx, endPoint.dy);
        path.lineTo(center.dx, center.dy - width);
        path.close();
        canvas.drawPath(path, paint);
        break;
      case ClockHandStyle.arrow:
      // Draw an arrow-shaped hand
        Path path = Path();
        path.moveTo(center.dx - width * 1.5, center.dy);
        path.lineTo(center.dx + width * 1.5, center.dy);
        path.lineTo(endPoint.dx, endPoint.dy);
        path.lineTo(center.dx, center.dy - width * 3);
        path.close();
        final arrowPaint = Paint() // Create a new Paint object for filling
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, arrowPaint); // Use the new Paint object
        break;
    }
  }

  @override
  bool shouldRepaint(covariant AnalogClock oldDelegate) {
    return currentTime != oldDelegate.currentTime ||
        frameStyle != oldDelegate.frameStyle ||
        handStyle != oldDelegate.handStyle ||
        markerStyle != oldDelegate.markerStyle ||
        hourHandColor != oldDelegate.hourHandColor ||
        minuteHandColor != oldDelegate.minuteHandColor ||
        secondHandColor != oldDelegate.secondHandColor ||
        use24HourFormat != oldDelegate.use24HourFormat;
  }
}