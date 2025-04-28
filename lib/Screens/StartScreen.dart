import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state_manager.dart';
import 'Dashboard.dart'; // To navigate to the main game screen

class StartScreen extends StatelessWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameStateManager = Provider.of<GameStateManager>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context); // Capture context

    return Scaffold(
      appBar: AppBar(
        title: const Text('Football Academy Manager'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('New Game'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                // Reset game state for a new game
                gameStateManager.resetGame();
                // Navigate to the main dashboard
                Navigator.pushReplacement( // Use pushReplacement so user can't go back to start screen
                  context,
                  MaterialPageRoute(builder: (context) => const Dashboard()),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.folder_open),
              label: const Text('Load Game'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () async { // Make onPressed async
                bool success = await gameStateManager.loadGame();
                if (success) {
                  // Navigate to the main dashboard on successful load
                  Navigator.pushReplacement( // Use pushReplacement
                    context,
                    MaterialPageRoute(builder: (context) => const Dashboard()),
                  );
                  // Optional: Show brief success message *after* navigation if desired,
                  // but might be better handled on the dashboard itself upon load.
                } else {
                  // Show error message if load failed
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Failed to load game. No save file found or error occurred.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),
            // Add Settings button later if needed here, or keep it within the main game UI
          ],
        ),
      ),
    );
  }
}
