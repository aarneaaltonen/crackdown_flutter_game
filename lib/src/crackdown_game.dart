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
    if (difficultyController.difficulty.value == Difficulty.expert) {
      final basketWidth = width / 3; // Adjust the width as needed

      world.add(Basket(
        position: Vector2(1 / 2 * basketWidth, height - 50),
        width: basketWidth,
        height: basketWidth * 0.8,
        eggColor: "pink",
      ));
      world.add(Basket(
        position: Vector2(3 / 2 * basketWidth, height - 50),
        width: basketWidth,
        height: basketWidth * 0.8,
        eggColor: "yellow",
      ));
      world.add(Basket(
        position: Vector2(5 / 2 * basketWidth, height - 50),
        height: basketWidth * 0.8,
        width: basketWidth,
        eggColor: "blue",
      ));
    } else {
      world.add(Basket(
          position: Vector2(width / 4, height - 50),
          width: width / 2,
          height: width * 0.28,
          eggColor: "pink"));
      world.add(Basket(
          position: Vector2(3 * width / 4, height - 50),
          width: width / 2,
          height: width * 0.28,
          eggColor: "blue"));
    }

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
        eggRate = 0.0015;
        break;
      case Difficulty.medium:
        eggRate = 0.0015;
        break;
      case Difficulty.hard:
        eggRate = 0.0015;
        break;
      case Difficulty.expert:
        eggRate = 0.002;
        break;
    }

    //right pipe
    world.add(Pipe(x: width - 10, y: height / 2 - 200, isTop: false));
    //left pipe
    world.add(Pipe(x: -10, y: height / 2 - 200, isTop: false));

    if (difficultyController.difficulty.value == Difficulty.hard ||
        difficultyController.difficulty.value == Difficulty.medium ||
        difficultyController.difficulty.value == Difficulty.expert) {
      //top pipe
      world.add(Pipe(x: width / 2 - 100, y: -10, isTop: true));
    }

    //Heads Up - egg
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
  final double maxEggRate = 0.007;
  int counter = 0;

//TODO: make list of egg rates for each difficulty
//store somewhere else
  final eggRates = <double>[
    0.0015,
    0.002,
    0.0025,
    0.003,
    0.0035,
    0.002,
    0.004,
    0.0045,
    0.005,
    0.0055,
    0.002,
    0.006,
    0.007,
    0.002,
    0.007,
    0.002,
    0.007,
  ];

// update method, spawns eggs at increasing rate
  @override
  void update(double dt) {
    super.update(dt);

    if (playState == PlayState.playing) {
      elapsedTime += dt;

      // Check if 10 seconds have passed
      if (elapsedTime >= rateIncreaseInterval) {
        counter++;
        //endgame, keep eggrate at max, every second interval give "grace" period to help player
        if (counter >= eggRates.length) {
          eggRate = maxEggRate;
          if (counter % 2 == 0) {
            eggRate = 0.002;
          }
        } else {
          eggRate = eggRates[counter];
        }
        print("Egg rate: $eggRate");
        elapsedTime = 0;
      }

      if (rand.nextDouble() < eggRate) {
        //right side "spawner"
        world.add(
          Egg(
              baseRadius: eggRadius,
              position: Vector2(width - 50, height / 2 - 100),
              velocity: Vector2(
                  difficultyController.difficulty.value == Difficulty.hard ||
                          difficultyController.difficulty.value ==
                              Difficulty.expert
                      ? -300 + (rand.nextDouble() - 0.5) * 100
                      : -200 + (rand.nextDouble() - 0.5) * 100,
                  (rand.nextDouble() - 0.5) * 500),
              eggColor:
                  difficultyController.difficulty.value == Difficulty.expert
                      ? (rand.nextInt(3) == 0
                          ? "yellow"
                          : (rand.nextBool() ? "pink" : "blue"))
                      : (rand.nextBool() ? "pink" : "blue")),
        );
      }
      if (rand.nextDouble() < eggRate) {
        //left side "spawner"
        world.add(
          Egg(
              baseRadius: eggRadius,
              position: Vector2(50, height / 2 - 100),
              velocity: Vector2(
                  difficultyController.difficulty.value == Difficulty.hard ||
                          difficultyController.difficulty.value ==
                              Difficulty.expert
                      ? 300 + (rand.nextDouble() - 0.5) * 100
                      : 200 + (rand.nextDouble() - 0.5) * 100,
                  (rand.nextDouble() - 0.5) * 500),
              eggColor:
                  difficultyController.difficulty.value == Difficulty.expert
                      ? (rand.nextInt(3) == 0
                          ? "yellow"
                          : (rand.nextBool() ? "pink" : "blue"))
                      : (rand.nextBool() ? "pink" : "blue")),
        );
      }

      if (difficultyController.difficulty.value == Difficulty.hard ||
          difficultyController.difficulty.value == Difficulty.medium ||
          difficultyController.difficulty.value == Difficulty.expert) {
        if (rand.nextDouble() < eggRate) {
          //top side "spawner"
          world.add(
            Egg(
                baseRadius: eggRadius,
                position: Vector2(width / 2, 50),
                velocity: Vector2(
                    (rand.nextDouble() - 0.5) * 100,
                    difficultyController.difficulty.value == Difficulty.hard ||
                            difficultyController.difficulty.value ==
                                Difficulty.expert
                        ? 300 + (rand.nextDouble() - 0.5) * 200
                        : 200 + (rand.nextDouble() - 0.5) * 200),
                eggColor:
                    difficultyController.difficulty.value == Difficulty.expert
                        ? (rand.nextInt(3) == 0
                            ? "yellow"
                            : (rand.nextBool() ? "pink" : "blue"))
                        : (rand.nextBool() ? "pink" : "blue")),
          );
        }
      }
    }
  }

  @override
  Color backgroundColor() => const Color(0xfff2e8cf);
}
