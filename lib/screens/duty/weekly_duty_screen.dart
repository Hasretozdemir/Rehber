import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/duty_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/duty_card.dart';

// Premium green gradient for weekly view
const _weeklyGradient = LinearGradient(
  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class WeeklyDutyScreen extends StatelessWidget {
  const WeeklyDutyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final duty = context.watch<DutyProvider>();
    final weeklyMap = duty.weeklyDuties;
    final days = weeklyMap.keys.toList()..sort();
    final today = DateTime.now();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium green SliverAppBar
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: const Text(
                'Haftalık Nöbet',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: 0.3,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(gradient: _weeklyGradient),
                  ),
                  // Decorative circles
                  Positioned(
                    right: -30,
                    top: -20,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(15),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -20,
                    bottom: -30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(10),
                      ),
                    ),
                  ),
                  // Week range subtitle
                  Positioned(
                    left: 20,
                    bottom: 48,
                    child: _buildWeekRange(today),
                  ),
                ],
              ),
            ),
          ),

          // Week summary header
          SliverToBoxAdapter(child: _WeekSummaryHeader(weeklyMap: weeklyMap)),

          // Day sections
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final day = days[index];
              final people = weeklyMap[day] ?? [];
              final isToday =
                  day.year == today.year &&
                  day.month == today.month &&
                  day.day == today.day;
              final isWeekend =
                  day.weekday == DateTime.saturday ||
                  day.weekday == DateTime.sunday;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DayHeader(
                    day: day,
                    isToday: isToday,
                    isWeekend: isWeekend,
                    personCount: people.length,
                    onTap: () => duty.setSelectedDate(day),
                  ),
                  if (people.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                      child: Text(
                        'Bu gün için nöbet kaydı yok',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  else
                    ...people.map((p) => DutyCard(duty: p, showDate: false)),
                  const SizedBox(height: 4),
                ],
              );
            }, childCount: days.length),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildWeekRange(DateTime today) {
    final start = today.subtract(Duration(days: today.weekday - 1));
    final end = start.add(const Duration(days: 6));
    final text =
        '${DateFormat('d MMM', 'tr_TR').format(start)} – ${DateFormat('d MMM yyyy', 'tr_TR').format(end)}';
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// ── Day header ────────────────────────────────────────────────────────────────

class _DayHeader extends StatelessWidget {
  final DateTime day;
  final bool isToday;
  final bool isWeekend;
  final int personCount;
  final VoidCallback onTap;

  const _DayHeader({
    required this.day,
    required this.isToday,
    required this.isWeekend,
    required this.personCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Colors
    final Color textColor;
    final Color subtextColor;
    final List<Color> gradColors;
    BoxShadow? shadow;

    if (isToday) {
      gradColors = const [Color(0xFF1B5E20), Color(0xFF2E7D32)];
      textColor = Colors.white;
      subtextColor = Colors.white70;
      shadow = BoxShadow(
        color: const Color(0xFF2E7D32).withAlpha(80),
        blurRadius: 10,
        offset: const Offset(0, 4),
      );
    } else if (isWeekend) {
      gradColors = [
        AppColors.warning.withAlpha(25),
        AppColors.warning.withAlpha(8),
      ];
      textColor = AppColors.warning;
      subtextColor = AppColors.warning.withAlpha(180);
    } else {
      gradColors = [theme.colorScheme.surface, theme.colorScheme.surface];
      textColor = theme.textTheme.titleLarge?.color ?? AppColors.textPrimary;
      subtextColor = AppColors.textSecondary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isToday
                ? Colors.transparent
                : isWeekend
                ? AppColors.warning.withAlpha(80)
                : AppColors.lightDivider,
            width: 1.5,
          ),
          boxShadow: shadow != null ? [shadow] : null,
        ),
        child: Row(
          children: [
            // Day number
            Text(
              DateFormat('d', 'tr_TR').format(day),
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 12),
            // Day name & date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE', 'tr_TR').format(day),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMMM yyyy', 'tr_TR').format(day),
                    style: TextStyle(color: subtextColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Person count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isToday
                    ? Colors.white.withAlpha(40)
                    : isWeekend
                    ? AppColors.warning.withAlpha(20)
                    : const Color(0xFF2E7D32).withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$personCount nöbetçi',
                style: TextStyle(
                  color: isToday
                      ? Colors.white
                      : isWeekend
                      ? AppColors.warning
                      : const Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            if (isWeekend) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'HFT SONU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            if (isToday) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'BUGÜN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Week summary header ───────────────────────────────────────────────────────

class _WeekSummaryHeader extends StatelessWidget {
  final Map<DateTime, List> weeklyMap;

  const _WeekSummaryHeader({required this.weeklyMap});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final totalDuties = weeklyMap.values.fold<int>(0, (s, l) => s + l.length);
    final criticalCount = weeklyMap.values
        .expand((l) => l)
        .where((p) => p.isCriticalUnit)
        .length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withAlpha(80),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_view_week_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bu Haftanın Özeti',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${DateFormat('dd MMM', 'tr_TR').format(startOfWeek)} – ${DateFormat('dd MMM yyyy', 'tr_TR').format(endOfWeek)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _WeekStatCard(
                label: 'Toplam Nöbet',
                value: '$totalDuties',
                icon: Icons.people_rounded,
              ),
              const SizedBox(width: 10),
              _WeekStatCard(
                label: 'Günlük Ort.',
                value: (totalDuties / 7).toStringAsFixed(1),
                icon: Icons.bar_chart_rounded,
              ),
              const SizedBox(width: 10),
              _WeekStatCard(
                label: 'Kritik Birim',
                value: '$criticalCount',
                icon: Icons.priority_high_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _WeekStatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha(40)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
