import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/background_egg.dart';
import '../config.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MediaQuery.of(context).size.width >= BreakPoints.small
          ? AppBar(
              title: Center(child: const Text('Crackdown')),
            )
          : null,
      bottomNavigationBar: MediaQuery.of(context).size.width < BreakPoints.small
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () {
                      Get.toNamed('/game');
                    },
                    tooltip: 'Play',
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Get.toNamed('/LevelSelectionScreen');
                    },
                    tooltip: 'Select Difficulty',
                  ),
                ],
              ),
            )
          : null,
      body: Stack(
        children: [
          GameContainer(),
          Column(
            children: [
              IgnorePointer(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                        ),
                        Container(
                          margin: const EdgeInsets.all(16.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(183, 255, 255, 255),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Text(
                            'How to Play:\n\n'
                            'Drag the eggs into the matching colored baskets.\n\n'
                            'Be careful! If an egg hits a wall, it will crack.\n\n'
                            'Four cracks, and the egg breaks.\n\n'
                            'If an egg breaks or is sorted into the wrong basket, the GAME is OVER.\n\n'
                            'Earn points by correctly sorting eggs\n\n'
                            'Watch out! As time goes on, the eggs will come faster—stay sharp and act quickly!\n\n',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (MediaQuery.of(context).size.width >= BreakPoints.small) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 16.0),
                  ),
                  onPressed: () {
                    Get.toNamed('/game');
                  },
                  child: const Text('Play'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 16.0),
                  ),
                  onPressed: () {
                    Get.toNamed('/LevelSelectionScreen');
                  },
                  child: const Text('Select Difficulty'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
