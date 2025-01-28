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
      Difficulty.expert:
          "Three egg colors, fast, wobbly eggs, three spawn points",
    };

    // Calculate the combined high score for Easy, Medium, and Hard
    final combinedHighScore =
        highScoreController.getHighScore(Difficulty.easy) +
            highScoreController.getHighScore(Difficulty.medium) +
            highScoreController.getHighScore(Difficulty.hard);

    // Check if Expert difficulty should be locked
    final isExpertLocked = combinedHighScore < 2;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Select Difficulty'),
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Get.toNamed('/'),
          ),
        ),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isSmallScreen
                ? SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: Difficulty.values.map((difficulty) {
                        final isDisabled =
                            difficulty == Difficulty.expert && isExpertLocked;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Tooltip(
                            preferBelow: true,
                            message: isDisabled
                                ? "Unlock Expert mode by achieving a combined high score of 250 in Easy, Medium, and Hard modes."
                                : difficultyInfo[difficulty]!,
                            verticalOffset: 80,
                            child: SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isDisabled
                                    ? null
                                    : () {
                                        difficultyController
                                            .changeDifficulty(difficulty);
                                        Get.offAllNamed('/game');
                                      },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.zero,
                                  backgroundColor:
                                      isDisabled ? Colors.grey[300] : null,
                                ),
                                child: Stack(
                                  children: [
                                    // Main content of the button
                                    Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            difficulty.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                  color: isDisabled
                                                      ? Colors.grey[600]
                                                      : null,
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                          Obx(() => Text(
                                                'High Score: ${highScoreController.getHighScore(difficulty)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: isDisabled
                                                          ? Colors.grey[600]
                                                          : null,
                                                    ),
                                              )),
                                        ],
                                      ),
                                    ),
                                    // Grey overlay for locked difficulty
                                    if (isDisabled)
                                      Positioned(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            color:
                                                Colors.black.withOpacity(0.5),
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.lock,
                                                  size: 40,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  '$combinedHighScore / 250',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Unlock Expert Mode',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Colors.white,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ).animate().fadeIn(
                                  delay: (50 *
                                          Difficulty.values.indexOf(difficulty))
                                      .ms),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: Difficulty.values.length,
                    itemBuilder: (context, index) {
                      final difficulty = Difficulty.values[index];
                      final isDisabled =
                          difficulty == Difficulty.expert && isExpertLocked;
                      return Tooltip(
                        preferBelow: true,
                        message: isDisabled
                            ? "Unlock Expert mode by achieving a combined high score of 250 in Easy, Medium, and Hard modes."
                            : difficultyInfo[difficulty]!,
                        verticalOffset: 80,
                        child: ElevatedButton(
                          onPressed: isDisabled
                              ? null
                              : () {
                                  difficultyController
                                      .changeDifficulty(difficulty);
                                  Get.offAllNamed('/game');
                                },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.zero,
                            backgroundColor:
                                isDisabled ? Colors.grey[300] : null,
                          ),
                          child: Stack(
                            children: [
                              // Main content of the button
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      difficulty.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: isDisabled
                                                ? Colors.grey[600]
                                                : null,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Obx(() => Text(
                                          'High Score: ${highScoreController.getHighScore(difficulty)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: isDisabled
                                                    ? Colors.grey[600]
                                                    : null,
                                              ),
                                        )),
                                  ],
                                ),
                              ),
                              // Grey overlay for locked difficulty
                              if (isDisabled)
                                Positioned(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.lock,
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '$combinedHighScore / 250',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Unlock Expert Mode',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Colors.white,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ).animate().fadeIn(delay: (50 * index).ms),
                      );
                    },
                  ),
          ),
        ));
  }
}
