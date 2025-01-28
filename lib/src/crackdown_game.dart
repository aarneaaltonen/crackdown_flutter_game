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

  double eggRate = 0.0015;
  double elapsedTime = 0;
  final double rateIncreaseInterval = 10.0;
  final double maxEggRate = 0.007;
  int counter = 0;

//TODO: implement different egg rates for different difficulties
  final eggRates = <double>[
    0.0015,
    0.002,
    0.0025,
    0.003,
    0.0035,
    0.002,
    0.004,
    0.002,
    0.005,
    0.002,
    0.006,
    0.002,
    0.007,
    0.002,
    0.007,
    0.002,
    0.007,
  ];

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;

    world.add(PlayArea());
    _addBaskets();
    playState = PlayState.welcome;
  }

  void _addBaskets() {
    final basketWidth =
        difficultyController.difficulty.value == Difficulty.expert
            ? width / 3
            : width / 2;

    final baskets = [
      if (difficultyController.difficulty.value == Difficulty.expert)
        ...List.generate(
            3,
            (index) => Basket(
                  position:
                      Vector2((2 * index + 1) / 2 * basketWidth, height - 50),
                  width: basketWidth,
                  height: basketWidth * 0.8,
                  eggColor: ["pink", "yellow", "blue"][index],
                ))
      else
        ...List.generate(
            2,
            (index) => Basket(
                  position: Vector2((2 * index + 1) * width / 4, height - 50),
                  width: basketWidth,
                  height: width * 0.28,
                  eggColor: ["pink", "blue"][index],
                ))
    ];

    world.addAll(baskets);
  }

  void startGame() {
    if (playState == PlayState.playing) return;

    eggRate = 0.001;
    world.removeAll(world.children.query<Egg>());
    score.value = 0;
    playState = PlayState.playing;

    _setEggRateBasedOnDifficulty();
    _addPipes();
    //heads up! - egg
    _addInitialEgg();
  }

  void _setEggRateBasedOnDifficulty() {
    switch (difficultyController.difficulty.value) {
      case Difficulty.easy:
      case Difficulty.medium:
      case Difficulty.hard:
        eggRate = 0.0015;
        break;
      case Difficulty.expert:
        eggRate = 0.002;
        break;
    }
  }

  void _addPipes() {
    world.add(Pipe(x: width - 10, y: height / 2 - 200, isTop: false));
    world.add(Pipe(x: -10, y: height / 2 - 200, isTop: false));

    if (difficultyController.difficulty.value == Difficulty.hard ||
        difficultyController.difficulty.value == Difficulty.medium ||
        difficultyController.difficulty.value == Difficulty.expert) {
      world.add(Pipe(x: width / 2 - 100, y: -10, isTop: true));
    }
  }

  void _addInitialEgg() {
    world.add(Egg(
      baseRadius: eggRadius,
      position: Vector2(width - 50, height / 2 - 100),
      velocity: Vector2(-200 + (rand.nextDouble() - 0.5) * 100,
          (rand.nextDouble() - 0.5) * 100),
      eggColor: rand.nextBool() ? "pink" : "blue",
    ));
  }

  @override
  void onTap() {
    super.onTap();
    startGame();
  }

//main game loop, randomly spawn egg at an increasing rate
  @override
  void update(double dt) {
    super.update(dt);

    if (playState == PlayState.playing) {
      elapsedTime += dt;

      if (elapsedTime >= rateIncreaseInterval) {
        counter++;
        if (counter >= eggRates.length) {
          eggRate = maxEggRate;
          if (counter % 2 == 0) {
            eggRate = 0.002;
          }
        } else {
          eggRate = eggRates[counter];
        }
        elapsedTime = 0;
      }

      _spawnEggs();
    }
  }

  void _spawnEggs() {
    if (rand.nextDouble() < eggRate) {
      _spawnEgg(Vector2(width - 50, height / 2 - 100), "right");
    }
    if (rand.nextDouble() < eggRate) {
      _spawnEgg(Vector2(50, height / 2 - 100), "left");
    }
    if (difficultyController.difficulty.value == Difficulty.hard ||
        difficultyController.difficulty.value == Difficulty.medium ||
        difficultyController.difficulty.value == Difficulty.expert) {
      if (rand.nextDouble() < eggRate) {
        _spawnEgg(Vector2(width / 2, 50), "top");
      }
    }
  }

  void _spawnEgg(Vector2 position, String spawnSide) {
    final isHardOrExpert =
        difficultyController.difficulty.value == Difficulty.hard ||
            difficultyController.difficulty.value == Difficulty.expert;
    final velocity = Vector2(
      spawnSide == "right"
          ? isHardOrExpert
              ? -300 + (rand.nextDouble() - 0.5) * 100
              : -200 + (rand.nextDouble() - 0.5) * 100
          : spawnSide == "left"
              ? isHardOrExpert
                  ? 300 + (rand.nextDouble() - 0.5) * 100
                  : 200 + (rand.nextDouble() - 0.5) * 100
              : (rand.nextDouble() - 0.5) * 100,
      spawnSide == "top"
          ? isHardOrExpert
              ? 300 + (rand.nextDouble() - 0.5) * 200
              : 200 + (rand.nextDouble() - 0.5) * 200
          : (rand.nextDouble() - 0.5) * 500,
    );

    world.add(Egg(
      baseRadius: eggRadius,
      position: position,
      velocity: velocity,
      eggColor: _getRandomEggColor(),
    ));
  }

  String _getRandomEggColor() {
    if (difficultyController.difficulty.value == Difficulty.expert) {
      return ["yellow", "pink", "blue"][rand.nextInt(3)];
    } else {
      return rand.nextBool() ? "pink" : "blue";
    }
  }

  @override
  Color backgroundColor() => const Color(0xfff2e8cf);
}
