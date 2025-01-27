import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/egg.dart';
import 'components/play_area.dart';
import 'config.dart';

enum PlayState { welcome, playing, gameOver }

enum Difficulty { easy, medium, hard }

class CrackDown extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  CrackDown()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: gameWidth,
            height: gameHeight,
          ),
        );

  final difficultyNotifier = ValueNotifier<Difficulty>(Difficulty.easy);
  Difficulty get difficulty => difficultyNotifier.value;
  set difficulty(Difficulty value) => difficultyNotifier.value = value;
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

    playState = PlayState.welcome;
  }

  void startGame() {
    if (playState == PlayState.playing) return;
    print("game started");
    eggRate = 0.001;
    world.removeAll(world.children.query<Egg>());
    playState = PlayState.playing;
  }

  @override
  void onTap() {
    super.onTap();
    startGame();
  }

//TODO: create two pipes, that produce two types of eggs, at a increasing pace.
  double eggRate = 0.001;
  double elapsedTime = 0;
  final double rateIncreaseInterval = 10.0; // seconds
  final double maxEggRate = 0.1;

  @override
  void update(double dt) {
    super.update(dt);

    if (playState == PlayState.playing) {
      elapsedTime += dt;

      // Check if 10 seconds have passed
      if (elapsedTime >= rateIncreaseInterval) {
        eggRate *= 2; // Double the rate
        eggRate = eggRate.clamp(0.001, maxEggRate); // Cap the rate
        elapsedTime = 0; // Reset timer
      }

      if (rand.nextDouble() < eggRate) {
        world.add(
          Egg(
              baseRadius: eggRadius,
              position: Vector2(width - 50, height / 2),
              velocity: Vector2(-200 + (rand.nextDouble() - 0.5) * 100,
                  (rand.nextDouble() - 0.5) * 100),
              eggColor: rand.nextBool() ? "pink" : "blue"),
        );
      }
    }
  }

  @override
  Color backgroundColor() => const Color(0xfff2e8cf);
}
