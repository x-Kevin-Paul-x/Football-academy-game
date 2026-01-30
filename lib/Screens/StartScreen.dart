import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state_manager.dart';
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
                  : () => _showNewGameDialog(context, gameStateManager),
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

  void _showNewGameDialog(BuildContext context, GameStateManager gameStateManager) {
    // Controller and Key for the dialog form
    final TextEditingController nameController =
        TextEditingController(text: "My Academy");
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Start New Game'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter your academy name:'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: nameController,
                  maxLength: 25,
                  decoration: const InputDecoration(
                    labelText: 'Academy Name',
                    border: OutlineInputBorder(),
                    hintText: 'e.g. My Academy',
                    helperText: '3-25 chars, alphanumeric only',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    // Client-side validation mirroring the backend security rules
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name.';
                    }
                    if (value.trim().length < 3) {
                      return 'Name must be at least 3 characters.';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value.trim())) {
                      return 'Only letters, numbers, and spaces.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Start Game'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  try {
                    // Pass the sanitized input to the secure resetGame method
                    gameStateManager.resetGame(
                        academyName: nameController.text);
                    Navigator.of(dialogContext).pop(); // Close dialog

                    // Navigate to dashboard
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Dashboard()),
                    );
                  } catch (e) {
                    // Catch any backend validation errors (defense in depth)
                    String errorMessage = e.toString();
                    if (e is ArgumentError) {
                      errorMessage = e.message.toString();
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $errorMessage')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    ).then((_) => nameController.dispose()); // Clean up resources
  }
}
