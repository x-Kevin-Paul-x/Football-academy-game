import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemNavigator
import 'package:provider/provider.dart'; // Import provider
// import 'Screens/Dashboard.dart'; // No longer needed directly here
import 'utils/app_theme.dart';
import 'game_state_manager.dart'; // Import the GameStateManager
// import 'models/difficulty.dart'; // No longer needed directly here
// import 'Screens/SettingsScreen.dart'; // No longer needed directly here
import 'screens/start_screen.dart'; // Import the new start_screen

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
          title: 'Football Academy Manager',
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: gameState.themeMode, // Use themeMode from GameStateManager
          home: const StartScreen(), // Set StartScreen as the home
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return AppTheme.lightTheme;
  }

  ThemeData _buildDarkTheme() {
    return AppTheme.darkTheme;
  }
}

// Removed the old MyHomePage StatefulWidget and _MyHomePageState
// as StartScreen is now the entry point.
