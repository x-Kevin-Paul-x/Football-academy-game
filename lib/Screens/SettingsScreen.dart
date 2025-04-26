import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state_manager.dart';
import '../models/difficulty.dart'; // Import Difficulty enum
import '../main.dart'; // Import main.dart to access MyHomePage

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the GameStateManager
    final gameState = Provider.of<GameStateManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // --- Difficulty Setting ---
            ListTile(
              title: const Text('Game Difficulty'),
              trailing: DropdownButton<Difficulty>(
                value: gameState.difficulty,
                items: Difficulty.values.map((Difficulty difficulty) {
                  return DropdownMenuItem<Difficulty>(
                    value: difficulty,
                    child: Text(difficulty.toString().split('.').last), // Display enum name nicely
                  );
                }).toList(),
                onChanged: (Difficulty? newValue) {
                  if (newValue != null) {
                    // Call the method in GameStateManager to update the difficulty
                    Provider.of<GameStateManager>(context, listen: false).setDifficulty(newValue);
                  }
                },
              ),
            ),
            const Divider(), // Separator

            // --- Theme Setting ---
            ListTile(
              title: const Text('Theme'),
              trailing: DropdownButton<ThemeMode>(
                value: gameState.themeMode,
                items: ThemeMode.values.map((ThemeMode themeMode) {
                  String themeName;
                  switch (themeMode) {
                    case ThemeMode.system: themeName = 'System Default'; break;
                    case ThemeMode.light: themeName = 'Light'; break;
                    case ThemeMode.dark: themeName = 'Dark'; break;
                  }
                  return DropdownMenuItem<ThemeMode>(
                    value: themeMode,
                    child: Text(themeName),
                  );
                }).toList(),
                onChanged: (ThemeMode? newValue) {
                  if (newValue != null) {
                    // Call the method in GameStateManager to update the theme mode
                    Provider.of<GameStateManager>(context, listen: false).setThemeMode(newValue);
                  }
                },
              ),
            ),
            const Divider(), // Separator

            // --- Reset Game Button ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, // Warning color
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () async { // Make async for dialog
                  // Show confirmation dialog
                  final bool? confirmReset = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Reset'),
                        content: const Text('Are you sure you want to reset all game progress? This action cannot be undone.'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop(false); // Return false
                            },
                          ),
                          TextButton(
                            child: const Text('Reset', style: TextStyle(color: Colors.redAccent)),
                            onPressed: () {
                              Navigator.of(context).pop(true); // Return true
                            },
                          ),
                        ],
                      );
                    },
                  );

                  // If confirmed, reset the game and navigate back to main menu
                  if (confirmReset == true) {
                    Provider.of<GameStateManager>(context, listen: false).resetGame();
                    // Navigate back to the initial screen (MyHomePage)
                    // Use pushAndRemoveUntil to clear the navigation stack
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Football Youth Academy')), // Assuming MyHomePage is your initial screen
                      (Route<dynamic> route) => false, // Remove all previous routes
                    );
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Game Reset Successfully!')),
                     );
                  }
                },
                child: const Text('Reset Game Data', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
