import 'package:crackdown_flutter_game/src/crackdown_game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'src/widgets/game_app.dart';

void main() {
  Get.put(CrackDown());
  runApp(const GameApp());
}
