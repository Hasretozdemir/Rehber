import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/contacts_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/emergency_contact_card.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contacts = context.watch<ContactsProvider>();
    final emergencyList = contacts.emergencyContacts;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Gradient SliverAppBar
          SliverAppBar(
            expandedHeight: 132,
            pinned: true,
            stretch: true,
            foregroundColor: Colors.white,
            backgroundColor: AppColors.emergency,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: const Text(
                'Acil İletişim',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.emergencyGradient,
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: -30,
                      right: -20,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(12),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -30,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(8),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 48,
                      child: Text(
                        'Dokunarak arayın',
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Info banner
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.emergency.withAlpha(15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.emergency.withAlpha(50),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.emergency.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_rounded,
                      color: AppColors.emergency,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'En kritik ${emergencyList.length} birim — Dokunarak hemen ara',
                      style: const TextStyle(
                        color: AppColors.emergency,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Emergency contacts
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: EmergencyContactCard(contact: emergencyList[i]),
                ),
                childCount: emergencyList.length,
              ),
            ),
          ),

          // Section divider
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.phone_in_talk_rounded,
                      color: AppColors.warning,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Genel Acil Numaralar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),

          // General emergency numbers
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, i) {
                final item = _generalEmergencyNumbers[i];
                return _GeneralEmergencyTile(item: item);
              }, childCount: _generalEmergencyNumbers.length),
            ),
          ),
        ],
      ),
    );
  }

  static const List<Map<String, dynamic>> _generalEmergencyNumbers = [
    {
      'label': 'Ambulans',
      'number': '112',
      'icon': Icons.emergency_rounded,
      'color': AppColors.emergency,
    },
    {
      'label': 'İtfaiye',
      'number': '110',
      'icon': Icons.local_fire_department_rounded,
      'color': AppColors.warning,
    },
    {
      'label': 'Polis',
      'number': '155',
      'icon': Icons.local_police_rounded,
      'color': AppColors.info,
    },
    {
      'label': 'Zehir Danışma',
      'number': '114',
      'icon': Icons.science_rounded,
      'color': AppColors.lab,
    },
  ];
}

class _GeneralEmergencyTile extends StatelessWidget {
  final Map<String, dynamic> item;
  const _GeneralEmergencyTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = item['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: color.withAlpha(20),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
        border: isDark ? Border.all(color: AppColors.darkDivider) : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          HapticFeedback.lightImpact();
          final uri = Uri(scheme: 'tel', path: item['number'] as String);
          if (await canLaunchUrl(uri)) launchUrl(uri);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withAlpha(40), color.withAlpha(20)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item['icon'] as IconData, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['label'] as String,
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      'Hızlı arama',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textDarkSecondary
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withAlpha(200)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(80),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.phone_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item['number'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
