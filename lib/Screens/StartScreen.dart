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
                  : () {
                      final TextEditingController nameController =
                          TextEditingController(text: 'My Academy');
                      final GlobalKey<FormState> formKey =
                          GlobalKey<FormState>();

                      showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Start New Game'),
                            content: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Enter your academy name:'),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: nameController,
                                    autofocus: true,
                                    textInputAction: TextInputAction.done,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: const InputDecoration(
                                      labelText: 'Academy Name',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.school),
                                      hintText: 'e.g. Future Stars',
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      if (value.trim().length < 3) {
                                        return 'Min 3 chars';
                                      }
                                      if (value.trim().length > 25) {
                                        return 'Max 25 chars';
                                      }
                                      return null;
                                    },
                                    onFieldSubmitted: (_) {
                                      if (formKey.currentState!.validate()) {
                                        Navigator.of(context).pop(true);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    Navigator.of(context).pop(true);
                                  }
                                },
                                child: const Text('Start Game'),
                              ),
                            ],
                          );
                        },
                      ).then((result) {
                        if (!mounted) {
                          nameController.dispose();
                          return;
                        }
                        if (result == true) {
                          gameStateManager.resetGame(
                              academyName: nameController.text.trim());
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Dashboard()),
                          );
                        }
                        nameController.dispose();
                      });
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
}
