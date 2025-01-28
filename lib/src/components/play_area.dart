import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../crackdown_game.dart';

class PlayArea extends RectangleComponent with HasGameReference<CrackDown> {
  PlayArea()
      : super(
          children: [RectangleHitbox()],
        );

  final Paint gridPaint = Paint()
    ..color = Colors.black.withOpacity(0.1)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    size = Vector2(game.width, game.height);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Apply gradient background
    final Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Color.fromARGB(255, 253, 205, 255),
          Color.fromARGB(255, 252, 248, 195),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRect(rect, paint);

    // Draw grid lines
    const double gridSize = 50.0;
    for (double x = 0; x < size.x; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), gridPaint);
    }
    for (double y = 0; y < size.y; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), gridPaint);
    }
  }
}
