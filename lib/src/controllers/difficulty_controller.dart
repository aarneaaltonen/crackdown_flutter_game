import 'package:get/get.dart';

enum Difficulty { easy, medium, hard }

class DifficultyController extends GetxController {
  Rx<Difficulty> difficulty = Difficulty.easy.obs;

  void changeDifficulty(Difficulty value) {
    difficulty.value = value;
  }
}
