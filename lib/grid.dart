import 'package:flutter/material.dart';

class CustomGridLines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridPainter(),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final double cellWidth = size.width / 3;
    final double cellHeight = size.height / 5;

    for (int i = 1; i < 3; i++) {
      canvas.drawLine(Offset(cellWidth * i, 0),
          Offset(cellWidth * i, size.height), linePaint);
    }

    for (int i = 1; i < 5; i++) {
      canvas.drawLine(Offset(0, cellHeight * i),
          Offset(size.width, cellHeight * i), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
