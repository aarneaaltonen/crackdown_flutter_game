import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'level_selection_screen.dart';
import '../config.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MediaQuery.of(context).size.width >= BreakPoints.small
          ? AppBar(
              title: const Text('Crackdown'),
            )
          : null, // Hide AppBar for small screens
      bottomNavigationBar: MediaQuery.of(context).size.width < BreakPoints.small
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () {
                      // Navigate to the game screen
                      Get.toNamed('/game');
                    },
                    tooltip: 'Play',
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      // Navigate to the difficulty selection screen
                      Get.to(() => LevelSelectionScreen());
                    },
                    tooltip: 'Difficulty Selection',
                  ),
                ],
              ),
            )
          : null, // Hide BottomAppBar for larger screens
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
        child: Center(
          child: SingleChildScrollView(
            // Ensure no overflow on small screens
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Section for game instructions
                Container(
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
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
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (MediaQuery.of(context).size.width >= BreakPoints.small) ...[
                  // Show buttons for larger screens
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the game screen
                      Get.toNamed('/game');
                    },
                    child: const Text('Play'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the difficulty selection screen
                      Get.to(() => LevelSelectionScreen());
                    },
                    child: const Text('Difficulty selection'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
