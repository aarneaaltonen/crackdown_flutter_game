import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'difficulty_controller.dart';

class HighScoreController extends GetxController {
  final storage = Hive.box('storage');

  RxMap<Difficulty, int> highScores = {
    Difficulty.easy: 0,
    Difficulty.medium: 0,
    Difficulty.hard: 0,
  }.obs;

  HighScoreController() {
    if (storage.get("highScores") == null) {
      storage.put("highScores", {
        Difficulty.easy.toString(): 0,
        Difficulty.medium.toString(): 0,
        Difficulty.hard.toString(): 0,
      });
    }
    final scores = storage.get("highScores") as Map;
    highScores[Difficulty.easy] = scores[Difficulty.easy.toString()];
    highScores[Difficulty.medium] = scores[Difficulty.medium.toString()];
    highScores[Difficulty.hard] = scores[Difficulty.hard.toString()];
  }

  void updateHighScore(Difficulty difficulty, int score) {
    if (score > highScores[difficulty]!) {
      highScores[difficulty] = score;
      _save();
    }
  }

  void _save() {
    storage.put('highScores', {
      Difficulty.easy.toString(): highScores[Difficulty.easy],
      Difficulty.medium.toString(): highScores[Difficulty.medium],
      Difficulty.hard.toString(): highScores[Difficulty.hard],
    });
  }

  int getHighScore(Difficulty difficulty) {
    return highScores[difficulty]!;
  }
}
