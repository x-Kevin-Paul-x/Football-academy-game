import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemNavigator
import 'package:provider/provider.dart'; // Import provider
import 'Screens/Dashboard.dart';
import 'game_state_manager.dart'; // Import the GameStateManager
import 'models/difficulty.dart'; // Import Difficulty enum
import 'Screens/SettingsScreen.dart'; // Import SettingsScreen

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameStateManager(), // Create an instance
      child: const MyApp(), // Wrap MyApp
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Consume the GameStateManager to get the theme mode
    return Consumer<GameStateManager>(
      builder: (context, gameState, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Youth Academy',
          theme: ThemeData( // Light Theme (Define if needed, or keep it simple)
            brightness: Brightness.light,
            primarySwatch: Colors.deepPurple,
            useMaterial3: true,
            // Add other light theme specific properties
          ),
          darkTheme: ThemeData( // Dark Theme
            brightness: Brightness.dark,
            primarySwatch: Colors.deepPurple,
            scaffoldBackgroundColor: Colors.grey[900],
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[850],
              foregroundColor: Colors.white,
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.grey[850],
              selectedItemColor: Colors.deepPurpleAccent,
              unselectedItemColor: Colors.grey[400],
              type: BottomNavigationBarType.fixed,
            ),
            useMaterial3: true,
            // Add other dark theme specific properties
          ),
          themeMode: gameState.themeMode, // Use themeMode from GameStateManager
          home: const MyHomePage(title: 'Football Youth Academy'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title ;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use the theme's scaffold background color
    return Scaffold(
      body: Center(
        child: Padding( // Add padding around the column
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, // Make buttons stretch
            children: [
              Text( // Use widget.title for consistency
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32, // Slightly larger title
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface, // Use theme color
                ),
              ),
              const SizedBox(height: 40), // Increased spacing

              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Dashboard()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15), // Adjusted padding
                  textStyle: const TextStyle(
                    fontSize: 18, // Adjusted font size
                    fontWeight: FontWeight.bold,
                  ),
                  // Use theme colors for button
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text("New Game"),
              ),

              const SizedBox(height: 15), // Spacing between buttons

              ElevatedButton(
                onPressed: () {
                  // Load Game Functionality (Placeholder)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Load Game functionality is not yet implemented.')),
                  );
                  // In a full implementation, this would trigger loading state from storage
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.secondary, // Use secondary color
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                ),
                child: const Text("Load Game"),
              ),

              const SizedBox(height: 15), // Spacing between buttons

              ElevatedButton( // Settings Button
                onPressed: () {
                  Navigator.push( // Use push, not pushReplacement
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: Colors.blueGrey[600], // Different color for Settings
                  foregroundColor: Colors.white,
                ),
                child: const Text("Settings"),
              ),

              const SizedBox(height: 15), // Spacing between buttons

              ElevatedButton( // Quit Button
                onPressed: () {
                  // Quit Game Functionality
                  SystemNavigator.pop(); // Closes the application
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                   backgroundColor: Colors.grey[700], // Different color for Quit
                   foregroundColor: Colors.white,
                ),
                child: const Text("Quit Game"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
