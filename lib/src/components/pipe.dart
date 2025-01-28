import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Pipe extends RectangleComponent {
  final bool isTop;
  final double borderRadius;

  Pipe({
    required double x,
    required double y,
    required this.isTop,
    this.borderRadius = 10.0,
  }) : super(
          size: isTop ? Vector2(200, 20) : Vector2(20, 200),
          position: Vector2(x, y),
          paint: Paint()..color = Colors.brown,
        );

  @override
  void render(Canvas canvas) {
    final roundedRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(roundedRect, paint);
  }
}
