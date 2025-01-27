import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/egg.dart';
import 'components/play_area.dart';
import 'config.dart';

enum PlayState { welcome, playing, gameOver, won }

class CrackDown extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  CrackDown()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: gameWidth,
            height: gameHeight,
          ),
        );

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
      case PlayState.won:
        overlays.add(playState.name);
      case PlayState.playing:
        overlays.remove(PlayState.welcome.name);
        overlays.remove(PlayState.gameOver.name);
        overlays.remove(PlayState.won.name);
      //add these later
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
    world.removeAll(world.children.query<Egg>());
    playState = PlayState.playing;

    world.add(
      Egg(
        baseRadius: eggRadius,
        position: size / 2,
        velocity: Vector2((rand.nextDouble() - 0.5) * width, 200),
      ),
    );
    world.add(
      Egg(
        baseRadius: eggRadius,
        position: size / 2,
        velocity: Vector2((rand.nextDouble() - 0.5) * width, 200),
      ),
    );
  }

  @override
  void onTap() {
    super.onTap();
    startGame();
  }

//TODO: create two pipes, that produce two types of eggs, at a increasing pace.

  @override
  void update(double dt) {
    super.update(dt);
    if (playState == PlayState.playing) {
      if (rand.nextDouble() < 0.001) {
        world.add(
          Egg(
            baseRadius: eggRadius,
            position: Vector2(rand.nextDouble() * width, 0),
            velocity: Vector2((rand.nextDouble() - 0.5) * width, 200),
          ),
        );
      }
    }
  }

  @override
  Color backgroundColor() => const Color(0xfff2e8cf);
}
