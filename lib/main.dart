import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'Screens/Dashboard.dart';
import 'game_state_manager.dart'; // Import the GameStateManager

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Youth Academy',
      theme: ThemeData(
        brightness: Brightness.dark, // Enable dark mode
        primarySwatch: Colors.deepPurple, // Keep purple as primary
        scaffoldBackgroundColor: Colors.grey[900], // Dark background
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[850], // Slightly lighter AppBar
          foregroundColor: Colors.white, // White title text
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey[850], // Match AppBar
          selectedItemColor: Colors.deepPurpleAccent, // Brighter purple for selection
          unselectedItemColor: Colors.grey[400], // Lighter grey for unselected
          type: BottomNavigationBarType.fixed,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Football Youth Academy'),
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
                  // TODO: Implement Load Game functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Load Game not implemented yet')),
                  );
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

              ElevatedButton(
                onPressed: () {
                  // TODO: Implement Quit Game functionality (e.g., SystemNavigator.pop())
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quit Game not implemented yet')),
                  );
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
