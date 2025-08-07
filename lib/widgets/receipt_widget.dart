import 'package:flutter/material.dart';

class ZigZagClipper extends CustomClipper<Path> {
  final double borderRadius;

  ZigZagClipper({required this.borderRadius});

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - borderRadius);

    double x = 0;
    double y = size.height - borderRadius;
    double increment = size.width / 40;

    while (x < size.width) {
      x += increment;
      y = (y == size.height - borderRadius)
          ? size.height * 0.99
          : size.height - borderRadius;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, borderRadius);
    path.quadraticBezierTo(size.width, 0, size.width - borderRadius, 0);
    path.lineTo(borderRadius, 0);
    path.quadraticBezierTo(0, 0, 0, borderRadius);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return oldClipper != this;
  }
}

class ZigZagContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final double width;
  final Color color;

  final double borderRadius;

  const ZigZagContainer({
    Key? key,
    required this.child,
    required this.height,
    required this.width,
    required this.color,
    required this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ZigZagClipper(borderRadius: borderRadius),
      child: Container(
        height: height,
        width: width,
        color: color,
        child: child,
      ),
    );
  }
}
