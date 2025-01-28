import 'dart:async';
import 'dart:math' as math;

import 'package:crackdown_flutter_game/src/components/basket.dart';
import 'package:crackdown_flutter_game/src/components/pipe.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'components/egg.dart';
import 'components/play_area.dart';
import 'config.dart';
import 'controllers/difficulty_controller.dart';

enum PlayState { welcome, playing, gameOver }

class CrackDown extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  CrackDown()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: gameWidth,
            height: gameHeight,
          ),
        );

  final DifficultyController difficultyController = Get.find();
  final ValueNotifier<int> score = ValueNotifier(0);
  final rand = math.Random();

  double get width => size.x;
  double get height => size.y;

  late PlayState _playState;
  PlayState get playState => _playState;
  set playState(PlayState playState) {
    _playState = playState;
    switch (playState) {
      case PlayState.welcome:
      case PlayState.gameOver:
        overlays.add(playState.name);
      case PlayState.playing:
        overlays.remove(PlayState.welcome.name);
        overlays.remove(PlayState.gameOver.name);
    }
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;

    world.add(PlayArea());
    world.add(Basket(
        position: Vector2(width / 4, height - 50),
        width: width / 2,
        eggColor: "pink"));
    world.add(Basket(
        position: Vector2(3 * width / 4, height - 50),
        width: width / 2,
        eggColor: "blue"));

    playState = PlayState.welcome;
  }

  void startGame() {
    if (playState == PlayState.playing) return;

    eggRate = 0.001;
    world.removeAll(world.children.query<Egg>());
    score.value = 0;
    playState = PlayState.playing;

    switch (difficultyController.difficulty.value) {
      case Difficulty.easy:
        eggRate = 0.001;
        break;
      case Difficulty.medium:
        eggRate = 0.001;
        break;
      case Difficulty.hard:
        eggRate = 0.001;
        break;
    }

    //right pipe
    world.add(Pipe(x: width - 10, y: height / 2 - 200, isTop: false));
    //left pipe
    world.add(Pipe(x: -10, y: height / 2 - 200, isTop: false));

    if (difficultyController.difficulty.value == Difficulty.hard ||
        difficultyController.difficulty.value == Difficulty.medium) {
      //top pipe
      world.add(Pipe(x: width / 2 - 100, y: -10, isTop: true));
    }

    //Heads Up! egg
    world.add(Egg(
        baseRadius: eggRadius,
        position: Vector2(width - 50, height / 2 - 100),
        velocity: Vector2(-200 + (rand.nextDouble() - 0.5) * 100,
            (rand.nextDouble() - 0.5) * 100),
        eggColor: rand.nextBool() ? "pink" : "blue"));
  }

  @override
  void onTap() {
    super.onTap();
    startGame();
  }

  double eggRate = 0.0015;
  double elapsedTime = 0;
  final double rateIncreaseInterval = 10.0;
  final double maxEggRate = 0.005;
  int counter = 0;

//in update method, increase egg spawn rate every ten seconds
  @override
  void update(double dt) {
    super.update(dt);

    if (playState == PlayState.playing) {
      elapsedTime += dt;

      // Check if 10 seconds have passed
      if (elapsedTime >= rateIncreaseInterval) {
        counter++;
        eggRate += 0.0005;
        if (eggRate > maxEggRate) eggRate = maxEggRate;
        elapsedTime = 0; // Reset timer
        if (counter > 15) {
          eggRate = 0.01;
        }
        if (counter > 10) {
          eggRate = 0.006;
        }
      }

      if (rand.nextDouble() < eggRate) {
        //right side "spawner"
        world.add(
          Egg(
              baseRadius: eggRadius,
              position: Vector2(width - 50, height / 2 - 100),
              velocity: Vector2(
                  difficultyController.difficulty.value == Difficulty.hard
                      ? -300 + (rand.nextDouble() - 0.5) * 100
                      : -200 + (rand.nextDouble() - 0.5) * 100,
                  (rand.nextDouble() - 0.5) * 500),
              eggColor: rand.nextBool() ? "pink" : "blue"),
        );
      }
      if (rand.nextDouble() < eggRate) {
        //left side "spawner"
        world.add(
          Egg(
              baseRadius: eggRadius,
              position: Vector2(50, height / 2 - 100),
              velocity: Vector2(
                  difficultyController.difficulty.value == Difficulty.hard
                      ? 300 + (rand.nextDouble() - 0.5) * 100
                      : 200 + (rand.nextDouble() - 0.5) * 100,
                  (rand.nextDouble() - 0.5) * 500),
              eggColor: rand.nextBool() ? "pink" : "blue"),
        );
      }

      if (difficultyController.difficulty.value == Difficulty.hard ||
          difficultyController.difficulty.value == Difficulty.medium) {
        if (rand.nextDouble() < eggRate) {
          //top side "spawner"
          world.add(
            Egg(
                baseRadius: eggRadius,
                position: Vector2(width / 2, 50),
                velocity: Vector2(
                    (rand.nextDouble() - 0.5) * 100,
                    difficultyController.difficulty.value == Difficulty.hard
                        ? 300 + (rand.nextDouble() - 0.5) * 200
                        : 200 + (rand.nextDouble() - 0.5) * 200),
                eggColor: rand.nextBool() ? "pink" : "blue"),
          );
        }
      }
    }
  }

  @override
  Color backgroundColor() => const Color(0xfff2e8cf);
}
