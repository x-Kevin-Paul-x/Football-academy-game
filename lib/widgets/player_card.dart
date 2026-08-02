import 'package:flutter/material.dart';
import '../models/player.dart';
import '../utils/app_theme.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  final bool showPotential;
  final List<Widget> actions;
  final VoidCallback? onTap;

  const PlayerCard({
    Key? key,
    required this.player,
    this.showPotential = false,
    this.actions = const [],
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      decoration: AppTheme.capsuleCardDecoration(context),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      player.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: _getPositionColor(player.naturalPosition).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: _getPositionColor(player.naturalPosition).withOpacity(0.4)),
                    ),
                    child: Text(
                      player.positionString,
                      style: TextStyle(
                        color: _getPositionColor(player.naturalPosition),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  _buildInfoChip(context, Icons.cake_outlined, '${player.age} yrs'),
                  _buildInfoChip(context, Icons.attach_money_outlined, '\$${player.weeklyWage}/wk'),
                  _buildInfoChip(context, Icons.star_border, 'Rep ${player.reputation}'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSkillIndicator(
                    context,
                    label: 'Current',
                    value: player.currentSkill,
                    color: isDark ? AppTheme.darkAccentPill : AppTheme.lightPillActive,
                  ),
                  if (showPotential)
                    _buildSkillIndicator(
                      context,
                      label: 'Potential',
                      value: player.potentialSkill,
                      color: AppTheme.accentGreen,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkPillInactive : AppTheme.lightPillInactive,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.battery_charging_full,
                          size: 16,
                          color: player.fatigue > 50 ? AppTheme.accentRed : AppTheme.accentGreen,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${player.fatigue.toStringAsFixed(0)}% Fatigue',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'M:${player.matchesPlayed} G:${player.goalsScored} A:${player.assists}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (actions.isNotEmpty) const SizedBox(height: 14),
              if (actions.isNotEmpty)
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8.0,
                  children: actions,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkPillInactive : AppTheme.lightPillInactive,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillIndicator(BuildContext context, {required String label, required int value, required Color color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: CircularProgressIndicator(
                value: value / 100.0,
                strokeWidth: 5,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getPositionColor(PlayerPosition position) {
    switch (position) {
      case PlayerPosition.Goalkeeper:
        return AppTheme.accentGold;
      case PlayerPosition.Defender:
        return AppTheme.accentBlue;
      case PlayerPosition.Midfielder:
        return AppTheme.accentGreen;
      case PlayerPosition.Forward:
        return AppTheme.accentRed;
    }
  }
}
