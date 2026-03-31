import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/contact.dart';
import '../../models/department.dart';
import '../../providers/contacts_provider.dart';
import '../../theme/app_colors.dart';

class ContactDetailScreen extends StatelessWidget {
  final Contact contact;
  final Department? department;

  const ContactDetailScreen({
    super.key,
    required this.contact,
    this.department,
  });

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$text kopyalandı'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = department?.category.color ?? AppColors.primary;
    final isFav = context.watch<ContactsProvider>().isFavorite(contact.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header SliverAppBar
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: color,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isFav ? AppColors.warningLight : Colors.white,
                ),
                onPressed: () =>
                    context.read<ContactsProvider>().toggleFavorite(contact.id),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withAlpha(180)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withAlpha(100),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          contact.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      contact.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (contact.role != null)
                      Text(
                        contact.role!,
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Department badge
                  if (department != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: color.withAlpha(isDark ? 40 : 20),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: color.withAlpha(60)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            department!.category.icon,
                            color: color,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            contact.departmentName,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          if (department!.isEmergency) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.emergency,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'ACİL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    'İletişim Bilgileri',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  // Internal number
                  _ContactInfoTile(
                    icon: Icons.dialpad_rounded,
                    label: 'Dahili Numara',
                    value: contact.internalNumber,
                    color: color,
                    onCall: () => _call(contact.internalNumber),
                    onCopy: () => _copy(context, contact.internalNumber),
                  ),
                  if (contact.mobileNumber != null) ...[
                    const SizedBox(height: 10),
                    _ContactInfoTile(
                      icon: Icons.smartphone_rounded,
                      label: 'Cep Telefonu',
                      value: contact.mobileNumber!,
                      color: AppColors.success,
                      onCall: () => _call(contact.mobileNumber!),
                      onCopy: () => _copy(context, contact.mobileNumber!),
                    ),
                  ],
                  if (contact.email != null) ...[
                    const SizedBox(height: 10),
                    _ContactInfoTile(
                      icon: Icons.email_outlined,
                      label: 'E-posta',
                      value: contact.email!,
                      color: AppColors.info,
                      onCopy: () => _copy(context, contact.email!),
                    ),
                  ],
                  const SizedBox(height: 30),
                  // Quick action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _call(contact.internalNumber),
                          icon: const Icon(Icons.phone_rounded),
                          label: Text('Dahili: ${contact.internalNumber}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      if (contact.mobileNumber != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _call(contact.mobileNumber!),
                            icon: const Icon(Icons.smartphone_rounded),
                            label: const Text('Cep'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onCall;
  final VoidCallback onCopy;

  const _ContactInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onCopy,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withAlpha(isDark ? 40 : 20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 18),
            onPressed: onCopy,
            color: AppColors.textSecondary,
          ),
          if (onCall != null)
            GestureDetector(
              onTap: onCall,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.phone_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
