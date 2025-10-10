import 'package:flutter/material.dart';
import 'dart:math';

class FlippingDigit extends StatefulWidget {
  final int currentDigit;
  final int nextDigit;
  final TextStyle textStyle;

  const FlippingDigit({
    super.key,
    required this.currentDigit,
    required this.nextDigit,
    required this.textStyle,
  });

  @override
  State<FlippingDigit> createState() => _FlippingDigitState();
}

class _FlippingDigitState extends State<FlippingDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _visibleDigit;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _visibleDigit = widget.nextDigit;
      }
    });
    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(FlippingDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentDigit != oldWidget.currentDigit) {
      _visibleDigit = null;
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: widget.textStyle.fontSize! * 1.4,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isFirstHalf = angle < pi / 2;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Bottom half (next digit)
              if (!isFirstHalf)
                Transform(
                  alignment: Alignment.topCenter,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(angle - pi),
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      heightFactor: 0.5,
                      child: Text(
                        (_visibleDigit ?? widget.nextDigit).toString(),
                        style: widget.textStyle,
                      ),
                    ),
                  ),
                ),

              // Top half (current digit)
              Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(isFirstHalf ? angle : pi),
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: 0.5,
                    child: Text(
                      widget.currentDigit.toString(),
                      style: widget.textStyle,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}