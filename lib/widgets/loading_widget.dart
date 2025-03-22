import 'package:flutter/material.dart';
import 'dart:math' show pi, cos, sin, min;

class Polygon extends CustomPainter {
  final int sides;
  final BuildContext context;
  Polygon({
    required this.sides,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Theme.of(context).colorScheme.secondary
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    final path = Path();

    final center = Offset(size.width / 2, size.height / 2);
    final angle = (2 * pi) / sides;

    final angles = List.generate(sides, (index) => index * angle);

    final radius = min(size.width, size.height) / 2;

    path.moveTo(
      center.dx + radius * cos(0),
      center.dy + radius * sin(0),
    );

    for (final angle in angles) {
      path.lineTo(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
    }

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      oldDelegate is Polygon && oldDelegate.sides != sides;
}

class LoadingWidget extends StatefulWidget {
  final Duration? duration;
  const LoadingWidget({
    super.key,
    this.duration = const Duration(milliseconds: 3000),
  });

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _sidesController;
  late Animation<int> _sidesAnimation;

  late AnimationController _radiusController;
  late Animation<double> _radiusAnimation;

  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _sidesController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _sidesAnimation = IntTween(
      begin: 3,
      end: 10,
    ).animate(_sidesController);

    _radiusController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _radiusAnimation = Tween(
      begin: 20.0,
      end: 1.0,
    )
        .chain(
          CurveTween(
            curve: Curves.bounceInOut,
          ),
        )
        .animate(_radiusController);

    _rotationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _rotationAnimation = Tween(
      begin: 0.0,
      end: 2 * pi,
    )
        .chain(
          CurveTween(
            curve: Curves.easeInOut,
          ),
        )
        .animate(_rotationController);
  }

  @override
  void dispose() {
    _sidesController.dispose();
    _radiusController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sidesController.repeat(reverse: true);
    _radiusController.repeat(reverse: true);
    _rotationController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    // return LayoutBuilder(
    //   builder: (context, constraints) {
    //     final maxSize = min(constraints.maxWidth, constraints.maxHeight);

    //     return AnimatedBuilder(
    //       animation: Listenable.merge(
    //         [
    //           _sidesController,
    //           _radiusController,
    //           _rotationController,
    //         ],
    //       ),
    //       builder: (context, child) {
    //         return Transform(
    //           alignment: Alignment.center,
    //           transform: Matrix4.identity()
    //             ..rotateX(_rotationAnimation.value)
    //             ..rotateY(_rotationAnimation.value)
    //             ..rotateZ(_rotationAnimation.value),
    //           child: CustomPaint(
    //             painter:
    //                 Polygon(sides: _sidesAnimation.value, context: context),
    //             child: SizedBox(
    //               width: maxSize * _radiusAnimation.value,
    //               height: maxSize * _radiusAnimation.value,
    //             ),
    //           ),
    //         );
    //       },
    //     );
    //   },
    // );
    return AnimatedBuilder(
      animation: Listenable.merge(
        [
          _sidesController,
          _radiusController,
          _rotationController,
        ],
      ),
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateX(_rotationAnimation.value)
            ..rotateY(_rotationAnimation.value)
            ..rotateZ(_rotationAnimation.value),
          child: CustomPaint(
            painter: Polygon(sides: _sidesAnimation.value, context: context),
          ),
        );
      },
    );
  }
}
