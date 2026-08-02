import 'package:flutter/material.dart';
import '../models/staff.dart';
import '../utils/app_theme.dart';

class StaffCard extends StatelessWidget {
  final Staff staff;
  final List<Widget> actions;

  const StaffCard({
    Key? key,
    required this.staff,
    this.actions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      decoration: AppTheme.capsuleCardDecoration(context),
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
                    staff.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: _getRoleColor(staff.role).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: _getRoleColor(staff.role).withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getRoleIcon(staff.role), color: _getRoleColor(staff.role), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        staff.role.name,
                        style: TextStyle(
                          color: _getRoleColor(staff.role),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildInfoChip(context, Icons.military_tech, 'Skill ${staff.skill}'),
                _buildInfoChip(context, Icons.attach_money, '\$${staff.weeklyWage}/wk'),
              ],
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

  Color _getRoleColor(StaffRole role) {
    switch (role) {
      case StaffRole.Coach:
        return AppTheme.accentBlue;
      case StaffRole.Scout:
        return Colors.purpleAccent;
      case StaffRole.Physio:
        return AppTheme.accentGreen;
      case StaffRole.Manager:
        return AppTheme.accentGold;
      case StaffRole.MerchandiseManager:
        return Colors.orangeAccent;
    }
  }

  IconData _getRoleIcon(StaffRole role) {
    switch (role) {
      case StaffRole.Manager:
        return Icons.manage_accounts;
      case StaffRole.Coach:
        return Icons.sports_soccer;
      case StaffRole.Scout:
        return Icons.search;
      case StaffRole.Physio:
        return Icons.medical_services;
      case StaffRole.MerchandiseManager:
        return Icons.store;
    }
  }
}
