import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import 'emergency_screen.dart';
import 'directory/directory_screen.dart';
import 'duty/duty_screen.dart';
import 'duty/weekly_duty_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _pages = const [
    EmergencyScreen(),
    DirectoryScreen(),
    DutyScreen(),
    WeeklyDutyScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withAlpha(100)
                  : AppColors.primary.withAlpha(18),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                _NavItem(
                  index: 0,
                  current: _currentIndex,
                  icon: Icons.emergency_outlined,
                  activeIcon: Icons.emergency_rounded,
                  label: 'Acil',
                  color: AppColors.emergency,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  index: 1,
                  current: _currentIndex,
                  icon: Icons.contacts_outlined,
                  activeIcon: Icons.contacts_rounded,
                  label: 'Rehber',
                  color: AppColors.primary,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  index: 2,
                  current: _currentIndex,
                  icon: Icons.today_outlined,
                  activeIcon: Icons.today_rounded,
                  label: 'Nöbet',
                  color: AppColors.accent,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  index: 3,
                  current: _currentIndex,
                  icon: Icons.calendar_view_week_outlined,
                  activeIcon: Icons.calendar_view_week_rounded,
                  label: 'Haftalık',
                  color: AppColors.success,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
                _NavItem(
                  index: 4,
                  current: _currentIndex,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: 'Ayarlar',
                  color: AppColors.warning,
                  badge: auth.isAdmin,
                  onTap: () => setState(() => _currentIndex = 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int current;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;
  final bool badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.current,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
    this.badge = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == current;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withAlpha(isDark ? 35 : 20)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      key: ValueKey(isSelected),
                      size: 24,
                      color: isSelected
                          ? color
                          : (isDark
                                ? AppColors.textDarkSecondary
                                : AppColors.textSecondary),
                    ),
                  ),
                  if (badge)
                    Positioned(
                      top: -3,
                      right: -3,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.emergency,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? color
                      : (isDark
                            ? AppColors.textDarkSecondary
                            : AppColors.textSecondary),
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
