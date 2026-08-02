import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../game_state_manager.dart';
import '../models/difficulty.dart';
import '../utils/app_theme.dart';
import 'dashboard_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool _isLoading = false;
  bool _isNewGameSetup = false;

  final TextEditingController _academyNameController =
      TextEditingController(text: 'Apex Academy');
  Difficulty _selectedDifficulty = Difficulty.Normal;

  final List<String> _presetNames = [
    'Apex Academy',
    'Valiant Youth FC',
    'Nova Stars Academy',
    'Titan Football Club',
    'Vanguard Academy',
    'Starlight Youth',
  ];

  void _generateRandomName() {
    final random = Random();
    final name = _presetNames[random.nextInt(_presetNames.length)];
    _academyNameController.text = name;
  }

  @override
  void dispose() {
    _academyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gameStateManager = Provider.of<GameStateManager>(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient & Radial Glow
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, -0.2),
                radius: 1.2,
                colors: isDark
                    ? [
                        const Color(0xFF1E2130),
                        const Color(0xFF0D0E12),
                      ]
                    : [
                        const Color(0xFFFFFFFF),
                        const Color(0xFFECEEF2),
                      ],
              ),
            ),
          ),

          // Ambient Decorative Elements
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? AppTheme.darkAccentPill : AppTheme.accentBlue)
                    .withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -120,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? AppTheme.accentGold : AppTheme.lightPillActive)
                    .withValues(alpha: 0.06),
              ),
            ),
          ),

          // Main Screen Content
          SafeArea(
            child: Column(
              children: [
                // Top Header Pill Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // App Version Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.accentGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'v2.5 CAPSULE EDITION',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Theme Quick Switch
                      InkWell(
                        onTap: () {
                          final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
                          gameStateManager.setThemeMode(newMode);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isDark ? Icons.wb_sunny : Icons.nightlight_round,
                                size: 16,
                                color: isDark ? AppTheme.accentGold : AppTheme.lightPillActive,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isDark ? 'Light Mode' : 'Dark Mode',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppTheme.darkTextPrimary
                                      : AppTheme.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Center Hero Card & Flanking Layout
                Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 960;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Left Teaser Card (Wide screens only)
                              if (isWide) ...[
                                Expanded(
                                  child: _buildSideTeaserCard(
                                    context,
                                    title: 'MANAGEMENT VAULT',
                                    subtitle: 'Key Features',
                                    items: const [
                                      Tuple('Youth Scouting', Icons.search_rounded),
                                      Tuple('Pro Leagues & Cups', Icons.emoji_events_rounded),
                                      Tuple('Financial Budgeting', Icons.account_balance_wallet_rounded),
                                      Tuple('Facility Upgrades', Icons.business_center_rounded),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                              ],

                              // Main Hero Card
                              Container(
                                width: 480,
                                padding: const EdgeInsets.all(36),
                                decoration: AppTheme.capsuleCardDecoration(context),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: _isNewGameSetup
                                      ? _buildNewGameSetupView(context, gameStateManager)
                                      : _buildMainMenuView(context, gameStateManager, scaffoldMessenger),
                                ),
                              ),

                              // Right Teaser Card (Wide screens only)
                              if (isWide) ...[
                                const SizedBox(width: 24),
                                Expanded(
                                  child: _buildSideTeaserCard(
                                    context,
                                    title: 'CAREER STATUS',
                                    subtitle: 'Manager Profile',
                                    items: const [
                                      Tuple('Dynamic AI Transfers', Icons.swap_horiz_rounded),
                                      Tuple('Staff Skill Bonuses', Icons.badge_rounded),
                                      Tuple('Match Event Simulation', Icons.sports_soccer_rounded),
                                      Tuple('Custom Tactics', Icons.tune_rounded),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Footer Text
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Built with Flutter • Football Academy Simulation Engine',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Main Menu View ---
  Widget _buildMainMenuView(
    BuildContext context,
    GameStateManager gameStateManager,
    ScaffoldMessengerState scaffoldMessenger,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      key: const ValueKey('MainMenuView'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glowing Soccer Logo Badge
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkAccentPill : AppTheme.lightPillActive,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isDark ? AppTheme.darkAccentPill : AppTheme.lightPillActive)
                    .withValues(alpha: 0.35),
                blurRadius: 28,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Icon(
            Icons.sports_soccer,
            size: 46,
            color: isDark ? Colors.black : Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'FOOTBALL ACADEMY',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Next-Gen Management Suite',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 36),

        // Start New Career Button
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
            onPressed: () {
              setState(() {
                _isNewGameSetup = true;
              });
            },
          ),
        ),
        const SizedBox(height: 14),

        // Load Saved Career Button
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
    );
  }

  // --- New Game Setup View ---
  Widget _buildNewGameSetupView(
    BuildContext context,
    GameStateManager gameStateManager,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      key: const ValueKey('NewGameSetupView'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
              onPressed: () {
                setState(() {
                  _isNewGameSetup = false;
                });
              },
            ),
            const SizedBox(width: 8),
            Text(
              'Career Setup',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Academy Name Input
        Text(
          'Academy Name',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkPillInactive : AppTheme.lightPillInactive,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                  ),
                ),
                child: TextField(
                  controller: _academyNameController,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter academy name...',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Randomize Name',
              child: InkWell(
                onTap: _generateRandomName,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkPillInactive : AppTheme.lightPillInactive,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                    ),
                  ),
                  child: Icon(
                    Icons.casino_rounded,
                    size: 20,
                    color: isDark ? AppTheme.darkAccentPill : AppTheme.lightPillActive,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Difficulty Selector
        Text(
          'Select Difficulty',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Difficulty.values.map((diff) {
            final isSelected = diff == _selectedDifficulty;
            final activeBg = isDark ? AppTheme.darkAccentPill : AppTheme.lightPillActive;
            final activeText = isDark ? Colors.black : Colors.white;

            return ChoiceChip(
              label: Text(diff.name),
              selected: isSelected,
              selectedColor: activeBg,
              backgroundColor: isDark ? AppTheme.darkPillInactive : AppTheme.lightPillInactive,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? activeText
                    : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide.none,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedDifficulty = diff;
                  });
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 28),

        // Launch Career Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.rocket_launch_rounded, size: 20),
            label: const Text('Launch Academy Career'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppTheme.darkAccentPill : AppTheme.lightPillActive,
              foregroundColor: isDark ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              gameStateManager.resetGame();
              gameStateManager.setDifficulty(_selectedDifficulty);
              gameStateManager.setAcademyName(_academyNameController.text);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Dashboard()),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Side Teaser Card Widget ---
  Widget _buildSideTeaserCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<Tuple<String, IconData>> items,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: AppTheme.capsuleCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: isDark ? AppTheme.darkAccentPill : AppTheme.accentBlue,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkPillInactive : AppTheme.lightPillInactive,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.item2,
                        size: 16,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.item1,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class Tuple<T1, T2> {
  final T1 item1;
  final T2 item2;
  const Tuple(this.item1, this.item2);
}
