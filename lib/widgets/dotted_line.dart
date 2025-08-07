import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class DottedDivider extends StatelessWidget {
  const DottedDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      width: double.infinity,
      child: CustomPaint(
        painter: DrawDottedHorizontalLine(),
      ),
    );
  }
}

class DrawDottedHorizontalLine extends CustomPainter {
  Paint _paint;

  DrawDottedHorizontalLine() : _paint = Paint() {
    _paint.color = Colors.black26;
    _paint.strokeWidth = 1;
    _paint.strokeCap = StrokeCap.square;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double margin = 0;
    final double startX = margin;
    final double endX = size.width - margin;

    for (double i = startX; i < endX; i = i + 15) {
      if (i % 3 == 0)
        canvas.drawLine(Offset(i, size.height / 2),
            Offset(i + 10, size.height / 2), _paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DrawDottedHorizontalLine(),
    );
  }
}
