import 'package:get/get.dart';

enum Difficulty { easy, medium, hard, expert }

class DifficultyController extends GetxController {
  Rx<Difficulty> difficulty = Difficulty.easy.obs;

  void changeDifficulty(Difficulty value) {
    difficulty.value = value;
  }
}
