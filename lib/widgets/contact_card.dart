import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact.dart';
import '../models/department.dart';
import '../providers/contacts_provider.dart';
import '../theme/app_colors.dart';

class ContactCard extends StatelessWidget {
  final Contact contact;
  final Department? department;
  final VoidCallback? onTap;

  const ContactCard({
    super.key,
    required this.contact,
    this.department,
    this.onTap,
  });

  Future<void> _callInternal(BuildContext context) async {
    HapticFeedback.lightImpact();
    final uri = Uri(scheme: 'tel', path: contact.internalNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = department?.category.color ?? AppColors.primary;
    final isFav = context.watch<ContactsProvider>().isFavorite(contact.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(isDark ? 20 : 30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Gradient Avatar
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withAlpha(isDark ? 160 : 200)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: color.withAlpha(80),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      contact.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              contact.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (department?.isEmergency ?? false)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.emergency,
                                    AppColors.emergency.withAlpha(180),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Text(
                                'ACİL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            department?.category.icon ?? Icons.business_rounded,
                            size: 12,
                            color: color,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              contact.departmentName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (contact.role != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          contact.role!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Right column: number + action buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Number badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withAlpha(isDark ? 60 : 30),
                            color.withAlpha(isDark ? 40 : 15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withAlpha(60)),
                      ),
                      child: Text(
                        contact.internalNumber,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Call button
                        GestureDetector(
                          onTap: () => _callInternal(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.success, Color(0xFF2E7D32)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(11),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.success.withAlpha(80),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.phone_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Favorite button
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            context.read<ContactsProvider>().toggleFavorite(
                              contact.id,
                            );
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: isFav
                                  ? LinearGradient(
                                      colors: [
                                        AppColors.warning,
                                        AppColors.warning.withAlpha(180),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: isFav
                                  ? null
                                  : (isDark
                                        ? AppColors.darkCard
                                        : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(11),
                              boxShadow: isFav
                                  ? [
                                      BoxShadow(
                                        color: AppColors.warning.withAlpha(80),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              isFav
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: isFav
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
