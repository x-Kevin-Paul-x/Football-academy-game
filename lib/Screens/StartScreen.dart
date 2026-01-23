import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state_manager.dart';
import '../models/difficulty.dart'; // Import Difficulty
import 'Dashboard.dart'; // To navigate to the main game screen

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final gameStateManager =
        Provider.of<GameStateManager>(context, listen: false);
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: _isLoading
                  ? null
                  : () {
                      _showNewGameDialog(context, gameStateManager);
                    },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.folder_open),
              label: const Text('Load Game'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() {
                        _isLoading = true;
                      });

                      // Small delay to let the UI update if loadGame is too fast
                      // and to ensure the user sees the feedback.
                      // await Future.delayed(const Duration(milliseconds: 500));

                      bool success = await gameStateManager.loadGame();

                      if (!mounted) return;

                      if (success) {
                        // Navigate to the main dashboard on successful load
                        Navigator.pushReplacement(
                          // Use pushReplacement
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Dashboard()),
                        );
                        // Optional: Show brief success message *after* navigation if desired,
                        // but might be better handled on the dashboard itself upon load.
                      } else {
                        setState(() {
                          _isLoading = false;
                        });
                        // Show error message if load failed
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Failed to load game. No save file found or error occurred.'),
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

  // Show dialog to input Academy Name and select Difficulty
  void _showNewGameDialog(BuildContext context, GameStateManager gameStateManager) {
    final TextEditingController nameController = TextEditingController();
    Difficulty selectedDifficulty = Difficulty.Normal;
    String? errorMessage; // Local state for error message in dialog is tricky without StatefulWidget
                          // Better to use a StatefulBuilder inside the dialog

    showDialog(
      context: context,
      barrierDismissible: false, // Force user to choose or cancel
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('New Academy'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Enter your Academy Name:'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Future Stars FC',
                        border: const OutlineInputBorder(),
                        errorText: errorMessage, // Show error if validation fails
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Select Difficulty:'),
                    DropdownButton<Difficulty>(
                      value: selectedDifficulty,
                      isExpanded: true,
                      items: Difficulty.values.map((Difficulty difficulty) {
                        return DropdownMenuItem<Difficulty>(
                          value: difficulty,
                          child: Text(difficulty.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (Difficulty? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedDifficulty = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Close dialog
                  },
                ),
                ElevatedButton(
                  child: const Text('Start Game'),
                  onPressed: () {
                    final String name = nameController.text.trim();

                    // --- SECURITY: Input Validation ---
                    if (!GameStateManager.isValidAcademyName(name)) {
                      setState(() {
                        errorMessage = "Invalid name. Use 3-25 alphanumeric chars.";
                      });
                      return; // Stop execution
                    }

                    // If valid, close dialog and start game
                    Navigator.of(dialogContext).pop();

                    // Reset game with validated name and difficulty
                    gameStateManager.resetGame(
                      academyName: name,
                      difficulty: selectedDifficulty
                    );

                    // Navigate to dashboard
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Dashboard()),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
