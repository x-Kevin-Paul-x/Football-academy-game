import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state_manager.dart';
import '../utils/app_theme.dart';
import 'Dashboard.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gameStateManager = Provider.of<GameStateManager>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0D0E12), const Color(0xFF191A23)]
                : [const Color(0xFFECEEF2), const Color(0xFFDDE1EA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(40),
            decoration: AppTheme.capsuleCardDecoration(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Hero Icon Badge
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkAccentPill : AppTheme.lightPillActive,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? AppTheme.darkAccentPill.withOpacity(0.3) : const Color(0x33000000),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.sports_soccer,
                    size: 44,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'FOOTBALL ACADEMY',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                  ),
                ),
                Text(
                  'Next-Gen Management Suite',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 36),

                // New Game Pill Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow_rounded, size: 22),
                    label: const Text('Start New Career'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppTheme.darkAccentPill : AppTheme.lightPillActive,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () {
                            gameStateManager.resetGame();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const Dashboard()),
                            );
                          },
                  ),
                ),
                const SizedBox(height: 16),

                // Load Game Pill Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            ),
                          )
                        : const Icon(Icons.folder_open_rounded, size: 22),
                    label: const Text('Load Saved Career'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: BorderSide(
                        color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });

                            bool success = await gameStateManager.loadGame();

                            if (!mounted) return;

                            if (success) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const Dashboard()),
                              );
                            } else {
                              setState(() {
                                _isLoading = false;
                              });
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to load game. No save file found.'),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
