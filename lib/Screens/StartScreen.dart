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

  void _showNewGameDialog(
      BuildContext context, GameStateManager gameStateManager) {
    final TextEditingController _nameController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Name Your Academy'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Academy Name',
              hintText: 'e.g. Rising Stars FC',
              border: OutlineInputBorder(),
              helperText: '3-25 characters (letters & numbers)',
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.trim().length < 3) {
                return 'Name must be at least 3 characters.';
              }
              if (value.length > 25) {
                return 'Name must be at most 25 characters.';
              }
              final validCharacters = RegExp(r'^[a-zA-Z0-9 ]+$');
              if (!validCharacters.hasMatch(value)) {
                return 'Alphanumeric characters only.';
              }
              return null;
            },
            onFieldSubmitted: (_) => _submitNewGame(dialogContext, context,
                gameStateManager, _nameController, _formKey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _submitNewGame(
                dialogContext, context, gameStateManager, _nameController, _formKey),
            child: const Text('Start Game'),
          ),
        ],
      ),
    ).then((_) => _nameController.dispose());
  }

  void _submitNewGame(
      BuildContext dialogContext,
      BuildContext parentContext,
      GameStateManager gameStateManager,
      TextEditingController controller,
      GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      final name = controller.text.trim();
      gameStateManager.resetGame(academyName: name);
      Navigator.pop(dialogContext); // Close dialog
      Navigator.pushReplacement(
        parentContext,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    }
  }
}
