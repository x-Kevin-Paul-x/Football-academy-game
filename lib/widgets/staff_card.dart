import 'package:flutter/material.dart';
import '../models/staff.dart';

class StaffCard extends StatelessWidget {
  final Staff staff;
  final List<Widget> actions; // Buttons like Hire, Fire, etc.

  const StaffCard({
    Key? key,
    required this.staff,
    this.actions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    staff.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text(staff.role.name),
                  backgroundColor: _getRoleColor(staff.role).withOpacity(0.2),
                  labelStyle: TextStyle(color: _getRoleColor(staff.role), fontWeight: FontWeight.bold),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                _buildInfoChip(Icons.star_border_outlined, 'Skill: ${staff.skill}'),
                _buildInfoChip(Icons.attach_money_outlined, 'Wage: \$${staff.weeklyWage}/wk'),
              ],
            ),
            if (actions.isNotEmpty)
              const Divider(height: 20, thickness: 1),
            if (actions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8.0,
                  children: actions,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.grey[700]),
      label: Text(text),
      backgroundColor: Colors.grey[800], // Darker chip background for dark theme
      labelStyle: TextStyle(color: Colors.grey[300]),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
    );
  }

  Color _getRoleColor(StaffRole role) {
    switch (role) {
      case StaffRole.Coach: return Colors.blueAccent;
      case StaffRole.Scout: return Colors.purpleAccent;
      case StaffRole.Physio: return Colors.tealAccent;
      case StaffRole.Manager: return Colors.amberAccent;
    }
  }
}
