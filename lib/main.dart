import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemNavigator
import 'package:provider/provider.dart'; // Import provider
// import 'Screens/Dashboard.dart'; // No longer needed directly here
import 'game_state_manager.dart'; // Import the GameStateManager
// import 'models/difficulty.dart'; // No longer needed directly here
// import 'Screens/SettingsScreen.dart'; // No longer needed directly here
import 'Screens/StartScreen.dart'; // Import the new StartScreen

void main() {
  // Ensure Flutter bindings are initialized before using plugins
  WidgetsFlutterBinding.ensureInitialized(); // <-- ADD THIS LINE

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
          title: 'Football Academy Manager', // Updated title
          theme: ThemeData( // Light Theme
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
          home: const StartScreen(), // Set StartScreen as the home
        );
      },
    );
  }
}

// Removed the old MyHomePage StatefulWidget and _MyHomePageState
// as StartScreen is now the entry point.
