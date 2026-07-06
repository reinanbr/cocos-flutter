import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ScoreRing extends StatelessWidget {
  final int pct;
  final Color cor;
  final double size;

  const ScoreRing({super.key, required this.pct, required this.cor, this.size = 90});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(pct: pct, cor: cor),
        child: Center(
          child: Text('$pct%',
              style: TextStyle(
                  fontSize: size * 0.22, fontWeight: FontWeight.w800, color: cor)),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final int pct;
  final Color cor;
  _RingPainter({required this.pct, required this.cor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final trackPaint = Paint()
      ..color = AppColors.gaugeTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    final sweep = 2 * math.pi * (pct.clamp(0, 100) / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.pct != pct || oldDelegate.cor != cor;
}
