import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../settings_module/settings_enums.dart';

class DigitalClock extends StatefulWidget {
  final DateTime currentTime;
  final Color textColor;
  final double fontSize;
  final bool showSeconds;
  final bool use24HourFormat;
  final DigitalEffects digitalEffect;

  const DigitalClock({
    super.key,
    required this.currentTime,
    required this.textColor,
    this.fontSize = 48,
    this.showSeconds = true,
    this.use24HourFormat = false,
    this.digitalEffect = DigitalEffects.none,
  });

  @override
  State<DigitalClock> createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  @override
  Widget build(BuildContext context) {
    final hourFormat = widget.use24HourFormat ? 'HH' : 'hh';
    final hour = DateFormat(hourFormat).format(widget.currentTime);
    final minute = DateFormat('mm').format(widget.currentTime);
    final second = DateFormat('ss').format(widget.currentTime);
    final amPm =
        widget.use24HourFormat
            ? ''
            : DateFormat('a').format(widget.currentTime);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _getBackgroundDecoration(),
      child: FittedBox(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hours
            for (int i = 0; i < hour.length; i++) _buildDigit(hour[i]),

            // Colon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(':', style: _getTextStyle()),
            ),

            // Minutes
            for (int i = 0; i < minute.length; i++) _buildDigit(minute[i]),

            // Seconds
            if (widget.showSeconds) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(':', style: _getTextStyle()),
              ),
              for (int i = 0; i < second.length; i++) _buildDigit(second[i]),
            ],

            // AM/PM
            if (!widget.use24HourFormat)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  amPm,
                  style: _getTextStyle().copyWith(
                    fontSize: widget.fontSize * 0.6,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  TextStyle _getTextStyle() {
    final baseStyle = TextStyle(
      fontSize: widget.fontSize,
      fontWeight: FontWeight.bold,
      color: widget.textColor,
    );

    switch (widget.digitalEffect) {
      case DigitalEffects.neon:
        return baseStyle.copyWith(
          shadows: [
            Shadow(
              color: widget.textColor,
              blurRadius: 20,
              offset: Offset.zero,
            ),
            Shadow(
              color: widget.textColor.withOpacity(0.5),
              blurRadius: 40,
              offset: Offset.zero,
            ),
          ],
          fontFamily: 'Digital',
        );
      case DigitalEffects.lcd:
        return baseStyle.copyWith(
          color: Colors.black,
          fontFamily: 'FlipFont',
          backgroundColor: Colors.green[100],
        );
      case DigitalEffects.matrix:
        return baseStyle.copyWith(color: Colors.green, fontFamily: 'Matrix');
      case DigitalEffects.glowPulse:
        return baseStyle.copyWith(
          fontFamily: 'Digital',
          shadows: [
            Shadow(color: widget.textColor.withOpacity(0.7), blurRadius: 15),
          ],
        );
      default:
        return baseStyle.copyWith(fontFamily: 'Digital');
    }
  }

  Widget _buildDigit(String digit) {
    if (widget.digitalEffect == DigitalEffects.glowPulse) {
      return _GlowPulseDigit(digit: digit, textStyle: _getTextStyle());
    }
    return Text(digit, style: _getTextStyle());
  }

  BoxDecoration? _getBackgroundDecoration() {
    switch (widget.digitalEffect) {
      case DigitalEffects.lcd:
        return BoxDecoration(
          color: Colors.green[800],
          borderRadius: BorderRadius.circular(8),
        );
      default:
        return null;
    }
  }
}

class _GlowPulseDigit extends StatefulWidget {
  final String digit;
  final TextStyle textStyle;

  const _GlowPulseDigit({required this.digit, required this.textStyle});

  @override
  State<_GlowPulseDigit> createState() => _GlowPulseDigitState();
}

class _GlowPulseDigitState extends State<_GlowPulseDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.scale(
            scale: _animation.value,
            child: Text(widget.digit, style: widget.textStyle),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
