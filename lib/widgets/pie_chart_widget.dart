// lib/widgets/pie_chart_widget.dart

import 'dart:math';
import 'package:flutter/material.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> data;
  final Map<String, Color> colors;
  final double size;

  const PieChartWidget({
    super.key,
    required this.data,
    required this.colors,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: PieChartPainter(data, colors, Theme.of(context).colorScheme.surface),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final Map<String, Color> colors;
  final Color backgroundColor;

  PieChartPainter(this.data, this.colors, this.backgroundColor);

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);
    double startAngle = -pi / 2;

    if (total <= 0) {
      final paint = Paint()..color = Colors.grey.shade300;
      canvas.drawCircle(center, radius, paint);
      final tp = TextPainter(
        text: const TextSpan(text: 'Brak', style: TextStyle(color: Colors.black54, fontSize: 14)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
      return;
    }

    data.forEach((key, value) {
      final sweep = (value / total) * 2 * pi;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[key] ?? Colors.grey;
      canvas.drawArc(rect, startAngle, sweep, true, paint);
      startAngle += sweep;
    });

    final holePaint = Paint()..color = backgroundColor;
    canvas.drawCircle(center, radius * 0.5, holePaint);

    final totalText = TextPainter(
      text: TextSpan(
        text: '${total.toStringAsFixed(0)} zł',
        style: TextStyle(color: Colors.black87, fontSize: radius * 0.18, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: radius);
    totalText.paint(canvas, center - Offset(totalText.width / 2, totalText.height / 2));
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.colors != colors;
  }
}