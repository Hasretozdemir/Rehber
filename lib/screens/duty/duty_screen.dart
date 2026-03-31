import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/department.dart';
import '../../providers/duty_provider.dart';
import '../../providers/contacts_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/duty_card.dart';

class DutyScreen extends StatelessWidget {
  const DutyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final duty = context.watch<DutyProvider>();
    final contacts = context.watch<ContactsProvider>();
    final isToday = _isSameDay(duty.selectedDate, DateTime.now());

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, inner) => [
          SliverAppBar(
            expandedHeight: 132,
            pinned: true,
            stretch: true,
            foregroundColor: Colors.white,
            backgroundColor: AppColors.accent,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.today_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  tooltip: 'Bugüne git',
                  onPressed: () => duty.setSelectedDate(DateTime.now()),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: const Text(
                'Nöbet Listesi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF006064),
                      Color(0xFF00838F),
                      Color(0xFF00ACC1),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -25,
                      right: -15,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(12),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 48,
                      child: Text(
                        isToday ? 'Bugünün nöbetçileri' : 'Seçili tarih',
                        style: TextStyle(
                          color: Colors.white.withAlpha(190),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            // Date selector
            _DateSelector(
              selectedDate: duty.selectedDate,
              onDateChanged: duty.setSelectedDate,
            ),
            // Department filter chips
            _DeptFilterBar(duty: duty, contacts: contacts),
            const SizedBox(height: 4),
            // Content
            Expanded(
              child: duty.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _DutyContent(duty: duty, isToday: isToday),
            ),
          ],
        ),
      ),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final void Function(DateTime) onDateChanged;

  const _DateSelector({
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final isToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 8)]
            : [
                BoxShadow(
                  color: AppColors.accent.withAlpha(20),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: Row(
        children: [
          // Previous day
          _NavArrow(
            icon: Icons.chevron_left_rounded,
            onTap: () =>
                onDateChanged(selectedDate.subtract(const Duration(days: 1))),
          ),
          // Date display
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 90)),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (picked != null) onDateChanged(picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(isDark ? 30 : 15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 15,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        isToday
                            ? 'Bugün — ${DateFormat('dd MMMM', 'tr_TR').format(selectedDate)}'
                            : DateFormat(
                                'dd MMMM yyyy, EEEE',
                                'tr_TR',
                              ).format(selectedDate),
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Next day
          _NavArrow(
            icon: Icons.chevron_right_rounded,
            onTap: () =>
                onDateChanged(selectedDate.add(const Duration(days: 1))),
          ),
        ],
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.accent.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.accent, size: 22),
      ),
    );
  }
}

class _DeptFilterBar extends StatelessWidget {
  final DutyProvider duty;
  final ContactsProvider contacts;

  const _DeptFilterBar({required this.duty, required this.contacts});

  @override
  Widget build(BuildContext context) {
    final depts = duty.dutiesByDepartment.keys.toList();
    if (depts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 10),
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _Chip(
            label: 'Tümü',
            selected: duty.selectedDepartmentId == null,
            onTap: () => duty.setDepartmentFilter(null),
          ),
          ...depts.map((name) {
            final dept = contacts.departments
                .where((d) => d.name == name)
                .firstOrNull;
            return _Chip(
              label: name,
              selected: dept != null && duty.selectedDepartmentId == dept.id,
              color: dept?.category.color ?? AppColors.accent,
              onTap: () => duty.setDepartmentFilter(
                duty.selectedDepartmentId == dept?.id ? null : dept?.id,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(colors: [color, color.withAlpha(200)])
              : null,
          color: selected ? null : color.withAlpha(15),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? Colors.transparent : color.withAlpha(70),
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withAlpha(60),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _DutyContent extends StatelessWidget {
  final DutyProvider duty;
  final bool isToday;

  const _DutyContent({required this.duty, required this.isToday});

  @override
  Widget build(BuildContext context) {
    final dutyMap = duty.dutiesByDepartment;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (dutyMap.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withAlpha(isDark ? 30 : 15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 40,
                color: AppColors.textSecondary.withAlpha(120),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bu tarihte nöbet kaydı yok',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Farklı bir tarih seçmeyi deneyin',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        // Summary row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              _SummaryBadge(
                label: 'Nöbetçi',
                count: duty.filteredDuties.length,
                color: AppColors.accent,
              ),
              const SizedBox(width: 8),
              _SummaryBadge(
                label: 'Kritik',
                count: duty.criticalDuties.length,
                color: AppColors.emergency,
              ),
              const SizedBox(width: 8),
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.success.withAlpha(70),
                      width: 1.5,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 13,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Bugün',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        // Department-grouped list
        ...dutyMap.entries.map((entry) {
          final deptName = entry.key;
          final people = entry.value;
          final isCritical = people.any((p) => p.isCriticalUnit);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DeptSectionHeader(
                name: deptName,
                count: people.length,
                isCritical: isCritical,
              ),
              ...people.map((p) => DutyCard(duty: p)),
            ],
          );
        }),
      ],
    );
  }
}

class _DeptSectionHeader extends StatelessWidget {
  final String name;
  final int count;
  final bool isCritical;
  const _DeptSectionHeader({
    required this.name,
    required this.count,
    required this.isCritical,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isCritical ? AppColors.emergency : AppColors.accent;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 25 : 12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withAlpha(isDark ? 50 : 30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCritical ? Icons.emergency_rounded : Icons.business_rounded,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withAlpha(isDark ? 50 : 25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count kişi',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
