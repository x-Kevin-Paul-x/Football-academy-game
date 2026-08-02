import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../game_state_manager.dart';
import '../models/player.dart';
import '../utils/app_theme.dart';
import '../widgets/player_card.dart';
import '../widgets/player_radar_chart.dart';

class TransferHubScreen extends StatefulWidget {
  const TransferHubScreen({super.key});

  @override
  State<TransferHubScreen> createState() => _TransferHubScreenState();
}

class _TransferHubScreenState extends State<TransferHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NumberFormat _currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateManager>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Hub'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isDark ? AppTheme.darkAccentPill : AppTheme.lightPillActive,
          tabs: const [
            Tab(icon: Icon(Icons.outbox_rounded), text: 'Incoming Offers'),
            Tab(icon: Icon(Icons.people_outline_rounded), text: 'My Academy Roster'),
            Tab(icon: Icon(Icons.travel_explore_rounded), text: 'Market Targets'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildIncomingOffersTab(gameState, isDark),
          _buildMyRosterTab(gameState, isDark),
          _buildMarketTargetsTab(gameState, isDark),
        ],
      ),
    );
  }

  Widget _buildIncomingOffersTab(GameStateManager gameState, bool isDark) {
    final offers = gameState.transferOffers;

    if (offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 64, color: isDark ? Colors.white30 : Colors.black26),
            const SizedBox(height: 16),
            const Text(
              'No incoming transfer offers at this time.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Advance weeks or improve academy reputation to receive offers.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        final player = gameState.academyPlayers.firstWhere(
          (p) => p.id == offer['playerId'],
          orElse: () => Player(
            id: '',
            name: 'Unknown Player',
            age: 18,
            naturalPosition: PlayerPosition.Midfielder,
            potentialSkill: 50,
            weeklyWage: 100,
            preferredPositions: const [PlayerPosition.Midfielder],
          ),
        );
        final offerAmount = (offer['offerAmount'] as num).toDouble();
        final clubName = offer['buyingClubName'] as String? ?? 'Rival Club';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isDark ? AppTheme.darkAccentPill : AppTheme.lightPillActive,
                      child: Text(
                        player.position,
                        style: TextStyle(
                          color: isDark ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'Interested Club: $clubName',
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _currencyFormatter.format(offerAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PlayerRadarChart(player: player, size: 140),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        gameState.rejectTransferOffer(offer);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Rejected offer from $clubName for ${player.fullName}')),
                        );
                      },
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
                      child: const Text('Reject Offer'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        gameState.acceptTransferOffer(offer);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Accepted offer! Sold ${player.fullName} for ${_currencyFormatter.format(offerAmount)}')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppTheme.darkAccentPill : AppTheme.lightPillActive,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                      ),
                      child: const Text('Accept Deal'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyRosterTab(GameStateManager gameState, bool isDark) {
    final players = gameState.academyPlayers;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final val = player.overallRating * 1500.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(player.overallRating.toString()),
            ),
            title: Text(player.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${player.position} | Age: ${player.age} | Value: ${_currencyFormatter.format(val)}'),
            trailing: IconButton(
              icon: const Icon(Icons.sell_outlined),
              tooltip: 'List on Transfer Market',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${player.fullName} listed on transfer market!')),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMarketTargetsTab(GameStateManager gameState, bool isDark) {
    final scouted = gameState.scoutedPlayers;

    if (scouted.isEmpty) {
      return const Center(
        child: Text('No external targets scouted yet. Upgrade scouting facilities to find prospects.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: scouted.length,
      itemBuilder: (context, index) {
        final player = scouted[index];
        final cost = player.overallRating * 2000.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(child: Text(player.overallRating.toString())),
            title: Text(player.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Scouted Prospect | Cost: ${_currencyFormatter.format(cost)}'),
            trailing: ElevatedButton(
              onPressed: () {
                if (gameState.balance >= cost) {
                  gameState.signPlayer(player);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Signed ${player.fullName} to your academy!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Insufficient funds to sign this player.')),
                  );
                }
              },
              child: const Text('Sign Player'),
            ),
          ),
        );
      },
    );
  }
}
