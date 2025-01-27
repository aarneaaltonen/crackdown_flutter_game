import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../controllers/difficulty_controller.dart';

import 'home_screen.dart';
import 'level_selection_screen.dart';

class OverlayScreen extends StatelessWidget {
  const OverlayScreen({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final difficultyController = Get.find<DifficultyController>();

    return Stack(
      children: [
        // Main content centered
        Align(
          alignment: const Alignment(0, -0.15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineLarge,
              ).animate().slideY(duration: 750.ms, begin: -3, end: 0),
              const SizedBox(height: 16),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.headlineSmall,
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fadeIn(duration: NumDurationExtensions(1).seconds)
                  .then()
                  .fadeOut(duration: NumDurationExtensions(1).seconds),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: Theme.of(context).textTheme.headlineSmall,
                ),
                onPressed: () => Get.offAll(() => HomeScreen()),
                child: const Text("Home"),
              ).animate().fadeIn(delay: NumDurationExtensions(1).seconds),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: Theme.of(context).textTheme.headlineSmall,
                ),
                onPressed: () => Get.to(() => const LevelSelectionScreen()),
                child: const Text("Select Difficulty"),
              ).animate().fadeIn(delay: NumDurationExtensions(1).seconds),
            ],
          ),
        ),
        // Difficulty indicator
        Positioned(
          top: 20,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Obx(() => Text(
                  'Difficulty: ${difficultyController.difficulty.value.name}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                )),
          ).animate().fadeIn(duration: 500.ms),
        ),
      ],
    );
  }
}
