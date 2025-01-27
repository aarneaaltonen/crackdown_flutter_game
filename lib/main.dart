import 'package:crackdown_flutter_game/src/controllers/difficulty_controller.dart';
import 'package:crackdown_flutter_game/src/controllers/high_score_controller.dart';
import 'package:crackdown_flutter_game/src/crackdown_game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'src/widgets/game_app.dart';
import 'src/widgets/home_screen.dart';
import 'src/widgets/level_selection_screen.dart';

Future<void> main() async {
  await Hive.initFlutter();
  await Hive.openBox('storage');
  Get.put<DifficultyController>(DifficultyController());
  Get.put(CrackDown());
  Get.put<HighScoreController>(HighScoreController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Crackdown',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.pressStart2pTextTheme().apply(
          bodyColor: const Color(0xff184e77),
          displayColor: const Color(0xff184e77),
        ),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => HomeScreen()),
        GetPage(name: '/game', page: () => GameApp()),
        GetPage(
            name: '/LevelSelectionScreen', page: () => LevelSelectionScreen()),
      ],
    );
  }
}
