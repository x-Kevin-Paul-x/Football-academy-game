import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../game_state_manager.dart';
import '../utils/app_theme.dart';
import '../widgets/capsule_sidebar.dart';
import '../widgets/header_pill_bar.dart';
import '../widgets/stat_ring_widget.dart';
import '../widgets/mini_trend_chart.dart';

// Screens
import 'FinanceScreen.dart';
import 'PlayerManagementScreen.dart';
import 'StaffManagementScreen.dart';
import 'FacilitiesScreen.dart';
import 'TournamentsScreen.dart';
import 'SettingsScreen.dart';
import 'ScoutingScreen.dart';
import 'TransferOffersScreen.dart';
import 'NewsScreen.dart';

// Models
import '../models/player.dart';
import '../models/staff.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  bool _isAdvancing = false;
  final DateFormat _dateFormatter = DateFormat('MMMM d, yyyy');

  Future<void> _handleAdvanceWeek() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Advance Week?'),
        content: const Text(
          'This will simulate matches, training, and academy finances for the week.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Advance'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isAdvancing = true;
      });

      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;
      Provider.of<GameStateManager>(context, listen: false).advanceWeek();

      if (mounted) {
        setState(() {
          _isAdvancing = false;
        });
      }
    }
  }

  void _signPlayer(Player playerToSign) {
    Provider.of<GameStateManager>(context, listen: false).signPlayer(playerToSign);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signed ${playerToSign.name}')),
    );
  }

  void _rejectPlayer(Player playerToReject) {
    Provider.of<GameStateManager>(context, listen: false).rejectPlayer(playerToReject);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rejected ${playerToReject.name}')),
    );
  }

  Widget _buildDashboardHome(GameStateManager gameState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final numberFormatter = NumberFormat("#,##0", "en_US");

    final double reputationPercent = (gameState.academyReputation / 100.0).clamp(0.0, 1.0);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Metrics Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;

              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Financial Trend Chart Card
                  Expanded(
                    flex: isWide ? 4 : 0,
                    child: MiniTrendChart(
                      title: 'Financial Vault',
                      value: currencyFormatter.format(gameState.balance),
                      percentageChange: '+12.4%',
                      dataPoints: const [12, 14, 18, 16, 22, 28, 35, 42],
                      lineColor: gameState.balance >= 0 ? AppTheme.accentGreen : AppTheme.accentRed,
                    ),
                  ),
                  SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),

                  // Academy Reputation Ring Card
                  Expanded(
                    flex: isWide ? 3 : 0,
                    child: StatRingWidget(
                      percentage: reputationPercent,
                      title: 'Academy Reputation',
                      centerValue: '${gameState.academyReputation}',
                      subtitle: 'Tier Rating',
                      ringColor: isDark ? AppTheme.darkAccentPill : AppTheme.accentGold,
                    ),
                  ),
                  SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),

                  // Quick Stats Card
                  Expanded(
                    flex: isWide ? 3 : 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: AppTheme.capsuleCardDecoration(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Squad & Fan Base',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStatRow(
                            context,
                            icon: Icons.groups,
                            label: 'Active Players',
                            value: '${gameState.academyPlayers.length}',
                            color: AppTheme.accentBlue,
                          ),
                          const SizedBox(height: 12),
                          _buildStatRow(
                            context,
                            icon: Icons.favorite,
                            label: 'Total Fans',
                            value: numberFormatter.format(gameState.fans),
                            color: AppTheme.accentRed,
                          ),
                          const SizedBox(height: 12),
                          _buildStatRow(
                            context,
                            icon: Icons.payments,
                            label: 'Weekly Wages',
                            value: '\$${numberFormatter.format(gameState.totalWeeklyWages)}',
                            color: AppTheme.accentGold,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Main Lower Row: Team Overview Dark Showcase + Latest News Feed Card
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;

              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Team Dark Showcase Card (Reference Image 1 & 2 Aesthetic)
                  Expanded(
                    flex: isWide ? 6 : 0,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.capsuleCardDecoration(context, isDarkCard: true),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Academy Roster & Development',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Youth Development & Talent Pipeline',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Season 2026',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppTheme.darkAccentPill : Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              _buildPillStatBadge(
                                title: 'Squad Size',
                                value: '${gameState.academyPlayers.length} Players',
                                icon: Icons.sports_soccer,
                              ),
                              const SizedBox(width: 12),
                              _buildPillStatBadge(
                                title: 'Staff Roster',
                                value: '${gameState.hiredStaff.length} Staff',
                                icon: Icons.badge,
                              ),
                              const SizedBox(width: 12),
                              _buildPillStatBadge(
                                title: 'Training Facility',
                                value: 'Level ${gameState.trainingFacilityLevel}',
                                icon: Icons.business,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Progress Bar
                          Text(
                            'Squad Readiness & Morale',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: 0.78,
                              minHeight: 8,
                              backgroundColor: Colors.white12,
                              color: isDark ? AppTheme.darkAccentPill : AppTheme.accentGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),

                  // Latest News Card
                  Expanded(
                    flex: isWide ? 4 : 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: AppTheme.capsuleCardDecoration(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent News Feed',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const NewsScreen()),
                                  ).then((_) {
                                    if (context.mounted) {
                                      gameState.markAllNewsAsRead();
                                    }
                                  });
                                },
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (gameState.newsItems.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  'No recent news items.',
                                  style: TextStyle(
                                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                  ),
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: gameState.newsItems.length.clamp(0, 3),
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final news = gameState.newsItems[index];
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppTheme.darkPillInactive : AppTheme.lightPillInactive,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isDark ? AppTheme.darkCard : Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.article, size: 16),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              news.title,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              news.description,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPillStatBadge({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white70),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 10, color: Colors.white54),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<NavigationItemData> _buildNavigationItems(GameStateManager gameState) {
    final allOffers = gameState.transferOffers;
    final relevantOffersCount = allOffers.where((offer) {
      return offer['sellingClubId'] == GameStateManager.playerAcademyId;
    }).length;
    final int unreadNewsCount = gameState.newsItems.where((item) => !item.isRead).length;

    return [
      NavigationItemData(title: 'Home', icon: Icons.grid_view_rounded, badgeCount: unreadNewsCount),
      NavigationItemData(title: 'Finance', icon: Icons.account_balance_wallet_rounded),
      NavigationItemData(title: 'Players', icon: Icons.sports_soccer_rounded),
      NavigationItemData(title: 'Scouting', icon: Icons.search_rounded),
      NavigationItemData(title: 'Staff', icon: Icons.people_alt_rounded),
      NavigationItemData(title: 'Facilities', icon: Icons.business_center_rounded),
      NavigationItemData(title: 'Transfers', icon: Icons.swap_horizontal_circle_rounded, badgeCount: relevantOffersCount),
      NavigationItemData(title: 'Tournaments', icon: Icons.emoji_events_rounded),
      NavigationItemData(title: 'Settings', icon: Icons.settings_rounded),
    ];
  }

  List<Widget> _buildScreensList() {
    return [
      const SizedBox(), // Home is built directly
      const FinanceScreen(),
      const PlayerManagementScreen(),
      ScoutingScreen(
        signPlayerCallback: _signPlayer,
        rejectPlayerCallback: _rejectPlayer,
      ),
      const StaffManagementScreen(),
      const FacilitiesScreen(),
      const TransferOffersScreen(),
      const TournamentsScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateManager>(
      builder: (context, gameState, child) {
        final navItems = _buildNavigationItems(gameState);
        final screens = _buildScreensList();
        final currentTitle = navItems[_selectedIndex].title;
        final formattedDate = _dateFormatter.format(gameState.currentDate);

        return Scaffold(
          body: Row(
            children: [
              // Capsule Navigation Sidebar
              CapsuleSidebar(
                selectedIndex: _selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                items: navItems,
              ),

              // Main Content Area
              Expanded(
                child: Column(
                  children: [
                    // Top Header Pill Bar
                    HeaderPillBar(
                      title: currentTitle,
                      formattedDate: formattedDate,
                      isAdvancing: _isAdvancing,
                      onAdvanceWeek: _handleAdvanceWeek,
                    ),

                    // Page Body
                    Expanded(
                      child: _selectedIndex == 0
                          ? _buildDashboardHome(gameState)
                          : Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 24, 24),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: screens[_selectedIndex],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
