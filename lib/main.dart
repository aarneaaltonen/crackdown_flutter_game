import 'package:crackdown_flutter_game/src/controllers/difficulty_controller.dart';
import 'package:crackdown_flutter_game/src/controllers/high_score_controller.dart';
import 'package:crackdown_flutter_game/src/crackdown_game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'src/widgets/game_app.dart';

Future<void> main() async {
  await Hive.initFlutter();
  await Hive.openBox('storage');
  Get.put<DifficultyController>(DifficultyController());
  Get.put(CrackDown());
  Get.put<HighScoreController>(HighScoreController());
  runApp(const GameApp());
}
