import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

//lots of reused code from the egg component, tried to use inheritance but having two different game references was causing issues
class BackgroundEgg extends PositionComponent
    with HasGameReference<FlameGame>, DragCallbacks {
  BackgroundEgg({
    required this.velocity,
    required super.position,
    required this.baseRadius,
    required this.eggColor,
  }) : super(
          anchor: Anchor.center,
          size: Vector2.all(baseRadius * 2),
        );

  bool disableWobble = false;

  final Vector2 velocity;
  final double baseRadius;
  final String eggColor;

  double _time = 0;
  final double _wobbleFrequency = 5;
  final double _wobbleAmplitude = 0.2;
  double _cumulativeRotation = 0;

  bool _isDragging = false;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    // Wobble effect for movement
    //remove wobble from eggs that were flung by user
    final speed = velocity.length;
    final direction = velocity.normalized();
    final wobbleFactor =
        1 + sin(_time * _wobbleFrequency) * _wobbleAmplitude * (speed / 200);

    final effectiveVelocity =
        disableWobble ? direction * speed : direction * speed * wobbleFactor;
    position += effectiveVelocity * dt;

    _cumulativeRotation += (effectiveVelocity.length * dt / (baseRadius * 2));

    // Widen the respawn area with padding
    final respawnPadding = 50;
    if (position.x < -respawnPadding ||
        position.x > game.size.x + respawnPadding ||
        position.y < -respawnPadding ||
        position.y > game.size.y + respawnPadding) {
      resetPosition();
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _isDragging = true;

    velocity.setZero();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (_isDragging) {
      position += event.localDelta;
    }
  }

//get mouse speed and give it to the egg
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _isDragging = false;
    //fling with mouse
    Vector2 velocity = event.velocity.clone();
    velocity *= 0.5;
    disableWobble = true;
    this.velocity.setFrom(velocity.clone());
  }

//resets the position of the egg when it goes off screen
  void resetPosition() {
    final random = Random();

    final side = random.nextInt(4);

    switch (side) {
      case 0:
        position = Vector2(
          random.nextDouble() * game.size.x,
          -baseRadius,
        );
        break;
      case 1:
        position = Vector2(
          game.size.x + baseRadius,
          random.nextDouble() * game.size.y,
        );
        break;
      case 2:
        position = Vector2(
          random.nextDouble() * game.size.x,
          game.size.y + baseRadius,
        );
        break;
      case 3:
        position = Vector2(
          -baseRadius,
          random.nextDouble() * game.size.y,
        );
        break;
    }

    // Set a random velocity towards the center of the screen
    final center = Vector2(game.size.x / 2, game.size.y / 2);
    final directionToCenter = (center - position).normalized();

    final maxAngleOffset = 0.5;
    final angleOffset = (random.nextDouble() * 2 - 1) * maxAngleOffset;

    final direction = Vector2(
      directionToCenter.x * cos(angleOffset) -
          directionToCenter.y * sin(angleOffset),
      directionToCenter.x * sin(angleOffset) +
          directionToCenter.y * cos(angleOffset),
    );

    // Set the velocity with the new direction and random speed
    final speed = (random.nextDouble() * 100) + 50;
    velocity.setFrom(direction * speed);
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

    final paintLight = _getPaintLight();
    canvas.drawOval(rect, paintLight);

    final clipPath = _getClipPath(rollAngle, width, height);
    canvas.clipPath(clipPath);

    final paintDark = _getPaintDark();
    canvas.drawOval(rect, paintDark);

    canvas.restore();
  }

  Paint _getPaintLight() {
    return Paint()
      ..color = _getBaseColorLight()
      ..style = PaintingStyle.fill;
  }

  Paint _getPaintDark() {
    return Paint()
      ..color = _getBaseColorDark()
      ..style = PaintingStyle.fill;
  }

  Color _getBaseColorLight() {
    switch (eggColor) {
      case 'blue':
        return const Color.fromARGB(255, 115, 166, 207);
      case 'pink':
        return const Color.fromARGB(255, 207, 115, 166);
      case 'yellow':
        return const Color.fromARGB(255, 219, 219, 135);
      case 'green':
        return const Color.fromARGB(255, 115, 207, 115);
      case 'purple':
        return const Color.fromARGB(255, 166, 115, 207);
      case 'orange':
        return const Color.fromARGB(255, 207, 166, 115);
      case 'red':
        return const Color.fromARGB(255, 207, 115, 115);
      case 'teal':
        return const Color.fromARGB(255, 115, 207, 207);
      default:
        return const Color.fromARGB(255, 219, 219, 135);
    }
  }

  Color _getBaseColorDark() {
    switch (eggColor) {
      case 'blue':
        return const Color.fromARGB(255, 85, 136, 177);
      case 'pink':
        return const Color.fromARGB(255, 177, 85, 136);
      case 'yellow':
        return const Color.fromARGB(255, 255, 255, 102);
      case 'green':
        return const Color.fromARGB(255, 85, 177, 85);
      case 'purple':
        return const Color.fromARGB(255, 136, 85, 177);
      case 'orange':
        return const Color.fromARGB(255, 177, 136, 85);
      case 'red':
        return const Color.fromARGB(255, 177, 85, 85);
      case 'teal':
        return const Color.fromARGB(255, 85, 177, 177);
      default:
        return const Color.fromARGB(255, 255, 255, 102);
    }
  }

  Path _getClipPath(double rollAngle, double width, double height) {
    final splitOffset = sin(rollAngle) * width * 0.8;

    return Path()
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
        -height / 2,
      );
  }
}

class BackgroundGame extends FlameGame {
  final int numberOfEggs = 25;
  final Random random = Random();
  int eggsSpawned = 0;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    spawnEggsOverTime();
  }

  void spawnEggsOverTime() {
    if (eggsSpawned >= numberOfEggs) return;

    // Spawn an egg
    final egg = BackgroundEgg(
      velocity: Vector2(
        (random.nextDouble() * 200) - 100,
        (random.nextDouble() * 200) - 100,
      ),
      position: Vector2(
        random.nextBool() ? -20.0 : size.x + 20.0,
        random.nextBool() ? -20.0 : size.y + 20.0,
      ),
      baseRadius: 20 + random.nextDouble() * 5,
      eggColor: [
        'blue',
        'pink',
        'yellow',
        'green',
        'purple',
        'orange',
        'red',
        'teal'
      ][random.nextInt(8)], // Randomly select from 8 colors
    );
    add(egg);
    eggsSpawned++;

    // Spawn starting eggs with some delay
    final spawnDelay = random.nextDouble() * 1.5;
    Future.delayed(Duration(seconds: spawnDelay.toInt()), spawnEggsOverTime);
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromARGB(255, 207, 169, 229),
          Color(0xfff2e8cf),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);

    super.render(canvas);
  }
}

//extra container so eggs dont respawn in onLoad method when resizing screen
class GameContainer extends StatefulWidget {
  const GameContainer({super.key});

  @override
  _GameContainerState createState() => _GameContainerState();
}

class _GameContainerState extends State<GameContainer> {
  late final FlameGame _game;

  @override
  void initState() {
    super.initState();
    _game = BackgroundGame();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: GameWidget(game: _game),
    );
  }
}
