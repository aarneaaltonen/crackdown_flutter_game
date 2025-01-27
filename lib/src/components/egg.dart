import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/difficulty_controller.dart';
import '../controllers/high_score_controller.dart';
import '../crackdown_game.dart';
import 'basket.dart';

class Egg extends PositionComponent
    with CollisionCallbacks, HasGameReference<CrackDown>, DragCallbacks {
  Egg({
    required this.velocity,
    required super.position,
    required this.baseRadius,
    required this.eggColor,
  }) : super(
          anchor: Anchor.center,
          size: Vector2.all(baseRadius * 2),
        );

  bool _isDragging = false;
  final Vector2 velocity;
  final double baseRadius;
  final String eggColor;

  double _time = 0;
  final double _wobbleFrequency = 5;
  final double _wobbleAmplitude =
      Get.find<DifficultyController>().difficulty.value == Difficulty.hard
          ? 0.5
          : 0.2;
  double _cumulativeRotation = 0;
  int _crackLevel = 0;
  Vector2 oldVelocity = Vector2.zero();

  void increaseCrackLevel() {
    if (_crackLevel < 4) {
      if (!_isDragging) {
        _crackLevel++;
      }
    } else {
      game.playState = PlayState.gameOver;
      final highScoreController = Get.find<HighScoreController>();
      final difficultyController = Get.find<DifficultyController>();
      final currentDifficulty = difficultyController.difficulty.value;
      final currentScore = game.score.value;
      highScoreController.updateHighScore(currentDifficulty, currentScore);
    }
  }

  @override
  bool onDragStart(DragStartEvent event) {
    if (game.playState != PlayState.playing) return false;
    super.onDragStart(event);
    _isDragging = true;

    oldVelocity = velocity.clone();
    velocity.setValues(0, 0);
    return true;
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    if (game.playState != PlayState.playing) return false;
    if (_isDragging) {
      position += event.localDelta;
    }
    return true;
  }

  @override
  bool onDragEnd(DragEndEvent event) {
    if (!_isDragging) return false;
    super.onDragEnd(event);
    _isDragging = false;
    final baskets = game.children.query<World>().first.children.query<Basket>();

    for (final basket in baskets) {
      if (basket.containsPoint(position)) {
        if (basket.eggColor == eggColor) {
          // Correct basket - remove egg
          game.score.value++;
          removeFromParent();
//+1effect
          final scoreText = CustomTextComponent(
            text: '+1',
            position: position.clone(),
            anchor: Anchor.center,
            textRenderer: TextPaint(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
          );

          scoreText
            ..add(
              MoveByEffect(
                Vector2(0, -50),
                EffectController(
                  duration: 0.5,
                  curve: Curves.easeOut,
                ),
              ),
            )
            ..add(
              OpacityEffect.fadeOut(
                EffectController(
                  duration: 0.5,
                ),
              )..onComplete = () {
                  scoreText.removeFromParent();
                },
            );

          game.world.add(scoreText);

          return true;
        } else {
          // Wrong basket - increase crack level
          game.playState = PlayState.gameOver;
          velocity.setValues(0, 0);

          // Update high score if necessary
          final highScoreController = Get.find<HighScoreController>();
          final difficultyController = Get.find<DifficultyController>();
          final currentDifficulty = difficultyController.difficulty.value;
          final currentScore = game.score.value;
          highScoreController.updateHighScore(currentDifficulty, currentScore);

          return true;
        }
      }
    }

    // Not dropped in basket - resume movement
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
      game.height * 0.8 - 2 * baseRadius,
    );

    if (position.x < bounds.left || position.x > bounds.right) {
      velocity.x *= -1;
      position.x = position.x.clamp(bounds.left, bounds.right);
      increaseCrackLevel();
    }
    if (position.y < bounds.top || position.y > bounds.bottom) {
      if (!_isDragging) {
        velocity.y *= -1;
        position.y = position.y.clamp(bounds.top, bounds.bottom);
        increaseCrackLevel();
      }
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

//lighter side of egg
    final paintLight = Paint()
      ..color = Color.lerp(
        // Base colors
        eggColor == 'blue'
            ? const Color.fromARGB(255, 115, 166, 207) // Blue light
            : const Color.fromARGB(255, 207, 115, 166), // Pink light
        // Heavily damaged colors (darker)
        eggColor == 'blue'
            ? const Color.fromARGB(255, 35, 76, 107) // Blue very damaged
            : const Color.fromARGB(255, 107, 35, 76), // Pink very damaged
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
        // Base colors
        eggColor == 'blue'
            ? const Color.fromARGB(255, 85, 136, 177) // Blue dark
            : const Color.fromARGB(255, 177, 85, 136), // Pink dark
        // Heavily damaged colors (darker)
        eggColor == 'blue'
            ? const Color.fromARGB(255, 15, 46, 77) // Blue very damaged dark
            : const Color.fromARGB(255, 77, 15, 46), // Pink very damaged dark
        _crackLevel / 4,
      )!
      ..style = PaintingStyle.fill;

    canvas.drawOval(rect, paintDark);

    canvas.restore();
  }
}

//Helper functions for the fadeout +1 score effect
mixin HasOpacityProvider on Component implements OpacityProvider {
  final Paint _paint = BasicPalette.white.paint();
  final Paint _srcOverPaint = Paint()..blendMode = BlendMode.srcOver;

  @override
  double get opacity => _paint.color.opacity;

  @override
  set opacity(double newOpacity) {
    _paint
      ..color = _paint.color.withOpacity(newOpacity)
      ..blendMode = BlendMode.modulate;
  }

  @override
  void renderTree(Canvas canvas) {
    canvas.saveLayer(null, _srcOverPaint);
    super.renderTree(canvas);
    canvas.drawPaint(_paint);
    canvas.restore();
  }
}

class CustomTextComponent extends TextComponent with HasOpacityProvider {
  CustomTextComponent({
    super.text,
    super.position,
    super.anchor,
    super.textRenderer,
    super.children,
  });
}
