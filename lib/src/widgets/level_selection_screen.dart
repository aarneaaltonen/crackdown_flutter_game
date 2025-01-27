import 'package:crackdown_flutter_game/src/controllers/difficulty_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config.dart';
import '../controllers/high_score_controller.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final highScoreController = Get.find<HighScoreController>();
    final DifficultyController difficultyController =
        Get.find<DifficultyController>();
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < BreakPoints.medium;

    final difficultyInfo = {
      Difficulty.easy: "Slow eggs, two spawn points",
      Difficulty.medium: "Slow eggs, three spawn points",
      Difficulty.hard: "Fast, wobbly eggs, three spawn points",
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Difficulty'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isSmallScreen
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: Difficulty.values.map((difficulty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Tooltip(
                      preferBelow: true,
                      message: difficultyInfo[difficulty]!,
                      verticalOffset: 80,
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            difficultyController.changeDifficulty(difficulty);
                            Get.offAllNamed('/game');
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                difficulty.name,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Obx(() => Text(
                                    'High Score: ${highScoreController.getHighScore(difficulty)}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  )),
                            ],
                          ),
                        ).animate().fadeIn(
                            delay: (50 * Difficulty.values.indexOf(difficulty))
                                .ms),
                      ),
                    ),
                  );
                }).toList(),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: Difficulty.values.length,
                itemBuilder: (context, index) {
                  final difficulty = Difficulty.values[index];
                  return Tooltip(
                    preferBelow: true,
                    message: difficultyInfo[difficulty]!,
                    verticalOffset: 80,
                    child: ElevatedButton(
                      onPressed: () {
                        difficultyController.changeDifficulty(difficulty);
                        Get.offAllNamed('/game');
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            difficulty.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Obx(() => Text(
                                'High Score: ${highScoreController.getHighScore(difficulty)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              )),
                        ],
                      ),
                    ).animate().fadeIn(delay: (50 * index).ms),
                  );
                },
              ),
      ),
    );
  }
}
