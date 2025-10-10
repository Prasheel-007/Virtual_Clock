import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class FallingParticlesTheme extends StatefulWidget {
  final Widget child;

  const FallingParticlesTheme({super.key, required this.child});

  @override
  _FallingParticlesThemeState createState() => _FallingParticlesThemeState();
}

class _FallingParticlesThemeState extends State<FallingParticlesTheme> {
  final List<_Particle> _particles = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 50), _updateParticles);
    _addParticles();
  }

  void _addParticles() {
    for (int i = 0; i < 10; i++) {
      _particles.add(_Particle(
        x: Random().nextDouble(),
        y: Random().nextDouble(),
        size: Random().nextDouble() * 4 + 1,
        speed: Random().nextDouble() * 0.5 + 0.1,
        color: Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
      ));
    }
  }

  void _updateParticles(Timer timer) {
    setState(() {
      for (var particle in _particles) {
        particle.y += particle.speed / 10;
        if (particle.y > 1) {
          particle.x = Random().nextDouble();
          particle.y = 0;
        }
      }
      if (_particles.length < 50) {
        _addParticles();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ..._particles.map((particle) => Positioned(
          left: MediaQuery.of(context).size.width * particle.x,
          top: MediaQuery.of(context).size.height * particle.y,
          child: Container(
            width: particle.size,
            height: particle.size,
            decoration: BoxDecoration(
              color: particle.color,
              shape: BoxShape.circle,
            ),
          ),
        )),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class _Particle {
  double x;
  double y;
  double size;
  double speed;
  Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
  });
}