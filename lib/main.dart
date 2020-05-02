import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Custom Painter',
      theme: ThemeData(primarySwatch: Colors.green),
      home: MyPainter(),
    );
  }
}

class MyPainter extends StatefulWidget {
  @override
  _MyPainterState createState() => _MyPainterState();
}

class _MyPainterState extends State<MyPainter> with TickerProviderStateMixin {
  Animation<double> rotationAnimation;
  AnimationController rotationAnimationController;

  Animation<double> radiusAnimation;
  AnimationController radiusAnimationController;

  Animation<double> colorAnimation;
  AnimationController colorAnimationController;

  final int colorCount = Colors.primaries.length;

  @override
  void initState() {
    super.initState();

    rotationAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8),
    );

    radiusAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );

    final Tween<double> _radiusTween = Tween(begin: 20, end: 400);
    final Tween<double> _rotationTween = Tween(begin: -math.pi, end: math.pi);

    rotationAnimation = _rotationTween.animate(rotationAnimationController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          rotationAnimationController.repeat();
        } else if (status == AnimationStatus.dismissed) {
          rotationAnimationController.forward();
        }
      });

    radiusAnimation = _radiusTween.animate(radiusAnimationController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          radiusAnimationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          radiusAnimationController.forward();
        }
      });

    rotationAnimationController.forward();
    radiusAnimationController.forward();
  }

  @override
  void dispose() {
    rotationAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Star Animation')),
      body: AnimatedBuilder(
        animation: rotationAnimation,
        builder: (context, snapshot) {
          return Stack(
            children: [
              for (int i = 0; i < colorCount; i++)
                Transform.rotate(
                  angle: rotationAnimation.value +
                      ((i / colorCount) * ((2 * math.pi)) / 3),
                  child: CustomPaint(
                    painter: ShapePainter(
                      radians: rotationAnimation.value,
                      radius: radiusAnimation.value,
                      color: Colors.primaries[i],
                    ),
                    child: Container(),
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}

// FOR PAINTING POLYGONS
class ShapePainter extends CustomPainter {
  ShapePainter({
    @required this.radius,
    @required this.radians,
    @required this.color,
  });
  final double radius;
  final double radians;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double sides = 3;

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path path = Path();

    final double angle = (math.pi * 2) / sides;

    Offset center = Offset(size.width / 2, size.height / 2);
    Offset startPoint =
        Offset(radius * math.cos(radians), radius * math.sin(radians));

    path.moveTo(startPoint.dx + center.dx, startPoint.dy + center.dy);

    for (int i = 1; i <= sides; i++) {
      double x = radius * math.cos(radians + angle * (i * 1)) + center.dx;
      double y = radius * math.sin(radians + angle * (i * 1)) + center.dy;
      path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
