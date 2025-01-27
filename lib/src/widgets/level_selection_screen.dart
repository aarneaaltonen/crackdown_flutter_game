import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../crackdown_game.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CrackDown game = Get.find<CrackDown>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Difficulty'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 3,
        itemBuilder: (context, index) {
          final level = index + 1;
          return ElevatedButton(
            onPressed: () {
              game.difficulty = Difficulty.values[index];
              Get.back();
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
                  Difficulty.values[index].name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    (level / 3).ceil(),
                    (index) => const Icon(Icons.star, size: 20),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .scale(
                duration: 200.ms,
                curve: Curves.easeOut,
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
              )
              .fadeIn(duration: 200.ms, delay: (50 * index).ms);
        },
      ),
    );
  }
}
