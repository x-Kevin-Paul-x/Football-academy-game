import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class NavigationItemData {
  final String title;
  final IconData icon;
  final int badgeCount;

  NavigationItemData({
    required this.title,
    required this.icon,
    this.badgeCount = 0,
  });
}

class CapsuleSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<NavigationItemData> items;
  final String managerName;
  final String academyName;

  const CapsuleSidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
    this.managerName = 'Head Manager',
    this.academyName = 'Academy FC',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBgColor = isDark ? AppTheme.darkAccentPill : AppTheme.lightPillActive;
    final activeIconColor = isDark ? Colors.black : Colors.white;
    final inactiveIconColor = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x60000000) : const Color(0x0F000000),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Brand/Club Logo Pill
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkPillActive : AppTheme.lightPillActive,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.sports_soccer,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(indent: 16, endIndent: 16, height: 1),
          const SizedBox(height: 16),

          // Navigation Items List
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = index == selectedIndex;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                  child: Tooltip(
                    message: item.title,
                    preferBelow: false,
                    child: InkWell(
                      onTap: () => onItemSelected(index),
                      borderRadius: BorderRadius.circular(24),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? activeBgColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item.icon,
                                  color: isSelected ? activeIconColor : inactiveIconColor,
                                  size: 22,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? activeIconColor : inactiveIconColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            if (item.badgeCount > 0)
                              Positioned(
                                top: -2,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.accentRed,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '${item.badgeCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(indent: 16, endIndent: 16, height: 1),
          const SizedBox(height: 16),

          // User Profile Capsule Avatar
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Tooltip(
              message: '$managerName ($academyName)',
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF3A3D4D), const Color(0xFF1F2029)]
                        : [const Color(0xFF141519), const Color(0xFF3A3D4D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppTheme.darkAccentPill : Colors.white,
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
