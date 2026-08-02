import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state_manager.dart';
import '../utils/app_theme.dart';
import '../Screens/NewsScreen.dart';

class HeaderPillBar extends StatelessWidget {
  final String title;
  final String formattedDate;
  final bool isAdvancing;
  final VoidCallback onAdvanceWeek;

  const HeaderPillBar({
    Key? key,
    required this.title,
    required this.formattedDate,
    required this.isAdvancing,
    required this.onAdvanceWeek,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gameState = Provider.of<GameStateManager>(context);
    final unreadNewsCount = gameState.newsItems.where((item) => !item.isRead).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 24, 12),
      child: Row(
        children: [
          // Section Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Football Academy Management System',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Search Bar Pill
          Container(
            width: 200,
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  size: 18,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Search academy...',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Date Indicator Pill
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppTheme.accentGold),
                const SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // News Feed Pill Button
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewsScreen()),
              ).then((_) {
                if (context.mounted) {
                  Provider.of<GameStateManager>(context, listen: false).markAllNewsAsRead();
                }
              });
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                ),
              ),
              child: Row(
                children: [
                  Badge(
                    label: Text(unreadNewsCount.toString()),
                    isLabelVisible: unreadNewsCount > 0,
                    backgroundColor: AppTheme.accentRed,
                    child: Icon(
                      Icons.newspaper,
                      size: 18,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'News',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Theme Quick Toggle Switch Pill
          InkWell(
            onTap: () {
              final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
              gameState.setThemeMode(newMode);
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isDark ? Icons.wb_sunny : Icons.nightlight_round,
                    size: 18,
                    color: isDark ? AppTheme.accentGold : AppTheme.lightPillActive,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isDark ? 'Light' : 'Dark',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Advance 1 Week Action Pill Button
          ElevatedButton.icon(
            onPressed: isAdvancing ? null : onAdvanceWeek,
            icon: isAdvancing
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  )
                : const Icon(Icons.fast_forward_rounded, size: 18),
            label: const Text('Advance Week'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppTheme.darkAccentPill : AppTheme.lightPillActive,
              foregroundColor: isDark ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
