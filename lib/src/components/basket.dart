import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../crackdown_game.dart';
import 'egg.dart';

class Basket extends RectangleComponent
    with CollisionCallbacks, HasGameRef<CrackDown> {
  Basket({
    required super.position,
    required double width,
    required this.eggColor,
  }) : super(
          size: Vector2(width, width * 0.6),
          anchor: Anchor.bottomCenter,
          children: [RectangleHitbox()],
        );

  final String eggColor;

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = eggColor == 'blue'
          ? const Color.fromARGB(255, 85, 136, 177)
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
