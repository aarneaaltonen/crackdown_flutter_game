import 'package:crackdown_flutter_game/src/controllers/difficulty_controller.dart';
import 'package:crackdown_flutter_game/src/controllers/high_score_controller.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../crackdown_game.dart';
import '../config.dart';
import 'overlay_screen.dart';
import 'score_card.dart';

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late final CrackDown game;
  final HighScoreController highScoreController =
      Get.find<HighScoreController>();
  final DifficultyController difficultyController =
      Get.find<DifficultyController>();

  @override
  void initState() {
    super.initState();
    game = CrackDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 207, 169, 229),
              Color(0xfff2e8cf),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  ScoreCard(score: game.score),
                  Expanded(
                    child: FittedBox(
                      child: SizedBox(
                        width: gameWidth,
                        height: gameHeight,
                        child: GameWidget(
                          game: game,
                          overlayBuilderMap: {
                            PlayState.welcome.name: (context, game) => Obx(() {
                                  int highScore =
                                      highScoreController.highScores[
                                              difficultyController
                                                  .difficulty.value] ??
                                          0;
                                  return OverlayScreen(
                                    title: 'TAP TO PLAY',
                                    subtitle: 'High score: $highScore\n\n',
                                  );
                                }),
                            PlayState.gameOver.name: (context, game) =>
                                OverlayScreen(
                                  title: 'G A M E   O V E R',
                                  subtitle: 'Tap to Play Again\n\n',
                                ),
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
