import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../crackdown_game.dart';
import 'play_area.dart';

class Egg extends PositionComponent
    with CollisionCallbacks, HasGameReference<CrackDown>, DragCallbacks {
  Egg({
    required this.velocity,
    required super.position,
    required this.baseRadius,
  }) : super(
          anchor: Anchor.center,
          size: Vector2.all(baseRadius * 2),
        );

  bool _isDragging = false;
  final Vector2 velocity;
  final double baseRadius;
  Vector2? _dragStartPosition;

  double _time = 0;
  final double _wobbleFrequency = 5;
  final double _wobbleAmplitude = 0.2;
  double _cumulativeRotation = 0;
  int _crackLevel = 0;
  Vector2 oldVelocity = Vector2.zero();

  void increaseCrackLevel() {
    if (_crackLevel < 4) {
      _crackLevel++;
    } else {
      game.playState = PlayState.gameOver;
    }
  }

  @override
  bool onDragStart(DragStartEvent event) {
    //TODO: make a basket to drop eggs, dont allow drag from basket
    super.onDragStart(event);
    _isDragging = true;
    _dragStartPosition = position.clone();
    oldVelocity = velocity.clone();
    velocity.setValues(0, 0);
    return true;
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    if (_isDragging) {
      position += event.localDelta;
    }
    return true;
  }

  @override
  bool onDragEnd(DragEndEvent event) {
    //TODO: handle drag to basket
    super.onDragEnd(event);
    _isDragging = false;
    velocity.setFrom(oldVelocity);

    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    final speed = velocity.length;
    final direction = velocity.normalized();
    final wobbleFactor =
        1 + sin(_time * _wobbleFrequency) * _wobbleAmplitude * (speed / 200);

    final effectiveVelocity = direction * speed * wobbleFactor;
    position += effectiveVelocity * dt;

    _cumulativeRotation += (effectiveVelocity.length * dt / (baseRadius * 2));

    final bounds = Rect.fromLTWH(
      baseRadius,
      baseRadius,
      game.width - 2 * baseRadius,
      game.height - 2 * baseRadius,
    );

    if (position.x < bounds.left || position.x > bounds.right) {
      velocity.x *= -1;
      position.x = position.x.clamp(bounds.left, bounds.right);
      increaseCrackLevel();
    }
    if (position.y < bounds.top || position.y > bounds.bottom) {
      velocity.y *= -1;
      position.y = position.y.clamp(bounds.top, bounds.bottom);
      increaseCrackLevel();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rollAngle = _cumulativeRotation;
    final moveAngle = atan2(velocity.y, velocity.x);

    final width = baseRadius * 1.8;
    final height = baseRadius * 2.2;

    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);

    canvas.rotate(moveAngle);
    canvas.rotate(rollAngle);

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: width,
      height: height,
    );

    final paintLight = Paint()
      ..color = Color.lerp(
        const Color.fromARGB(255, 207, 115, 166), // Start color
        const Color.fromARGB(255, 147, 55, 106), // Damaged color
        _crackLevel / 4,
      )!
      ..style = PaintingStyle.fill;

    canvas.drawOval(rect, paintLight);

    final clipPath = Path();
    final splitOffset = sin(rollAngle) * width * 0.8;

    clipPath
      ..moveTo(splitOffset * 0.7, -height / 2)
      ..lineTo(width * 0.8, -height / 2)
      ..cubicTo(width, -height / 3, width, height / 3, width * 0.9, height / 2)
      ..lineTo(splitOffset, height / 2)
      ..cubicTo(
          splitOffset - width * 0.2,
          height / 3,
          splitOffset - width * 0.1,
          -height / 3,
          splitOffset * 0.7,
          -height / 2);

    canvas.clipPath(clipPath);

    final paintDark = Paint()
      ..color = Color.lerp(
        const Color.fromARGB(255, 177, 85, 136), // Start color
        const Color.fromARGB(255, 117, 25, 76), // Damaged color
        _crackLevel / 4,
      )!
      ..style = PaintingStyle.fill;

    canvas.drawOval(rect, paintDark);

    canvas.restore();
  }
}
