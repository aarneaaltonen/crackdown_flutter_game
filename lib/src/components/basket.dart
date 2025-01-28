import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../crackdown_game.dart';

class Basket extends RectangleComponent
    with CollisionCallbacks, HasGameRef<CrackDown> {
  Basket({
    required super.position,
    required double width,
    required double height,
    required this.eggColor,
  }) : super(
          size: Vector2(width, height),
          anchor: Anchor.bottomCenter,
          children: [RectangleHitbox()],
        );

  final String eggColor;

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = eggColor == 'blue'
          ? const Color.fromARGB(255, 85, 136, 177)
          : eggColor == 'yellow'
              ? const Color.fromARGB(255, 200, 212, 93)
              : const Color.fromARGB(255, 177, 85, 136) // Pink basket

      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Draw basket shape
    final path = Path()
      ..moveTo(0, 0) // Start at top-left
      ..lineTo(0, size.y) // Left side
      ..lineTo(size.x, size.y) // Bottom
      ..lineTo(size.x, 0) // Right side
      ..close(); // Back to top-left

    canvas.drawPath(path, paint);

    // Fill color
    paint.style = PaintingStyle.fill;
    paint.color = paint.color.withAlpha(100);
    canvas.drawPath(path, paint);
  }
}
