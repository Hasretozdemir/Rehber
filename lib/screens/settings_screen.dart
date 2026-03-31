import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import 'admin/admin_panel_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium SliverAppBar
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primaryDeep,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: const Text(
                'Ayarlar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.primaryDeep, const Color(0xFF0D1B3E)]
                            : [
                                AppColors.primaryDeep,
                                AppColors.primary,
                                AppColors.primaryLight,
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -30,
                    top: -20,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              // User profile card
              if (user != null) _ProfileCard(user: user, isDark: isDark),

              // Görünüm section
              _SectionTitle(title: 'Görünüm'),
              _SettingsTile(
                icon: isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                iconColor: AppColors.info,
                title: 'Karanlık Mod',
                subtitle: themeProvider.isDarkMode ? 'Açık' : 'Kapalı',
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.primary,
                ),
              ),

              // Admin section
              if (user?.isAdmin ?? false) ...[
                _SectionTitle(title: 'Yönetim'),
                _SettingsTile(
                  icon: Icons.admin_panel_settings_rounded,
                  iconColor: AppColors.emergency,
                  title: 'Admin Paneli',
                  subtitle: 'Kişi, nöbet ve bölüm yönetimi',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
                  ),
                ),
              ],

              // Uygulama section
              _SectionTitle(title: 'Uygulama'),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.accent,
                title: 'Hakkında',
                subtitle: 'Versiyon 1.0.0',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Hastane Rehberi',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(
                    Icons.local_hospital_rounded,
                    color: AppColors.primary,
                    size: 48,
                  ),
                  children: const [
                    SizedBox(height: 12),
                    Text(
                      'Nöbetçi Personel ve İletişim Rehberi\n\n'
                      'Hastane içi iletişimi kolaylaştırmak ve nöbet bilgilerine hızlı ulaşmak için geliştirilmiştir.',
                    ),
                  ],
                ),
              ),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                iconColor: AppColors.warning,
                title: 'Bildirimler',
                subtitle: 'Yeni nöbet atamaları için bildirim al',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bildirim ayarları yakında eklenecek.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                ),
              ),

              // Hesap section
              _SectionTitle(title: 'Hesap'),
              _LogoutTile(auth: auth, context: context),

              const SizedBox(height: 30),
              Center(
                child: Text(
                  'Hastane Rehberi v1.0.0',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Profile card ──────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final dynamic user;
  final bool isDark;

  const _ProfileCard({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkCard, AppColors.darkSurface]
              : [AppColors.primaryDeep, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(isDark ? 30 : 60),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withAlpha(60), width: 1.5),
            ),
            child: Center(
              child: Text(
                user.initials,
                style: TextStyle(
                  color: isDark ? AppColors.primaryLight : Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: TextStyle(
                    color: isDark ? AppColors.textDarkPrimary : Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textDarkSecondary
                        : Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: user.isAdmin
                          ? [AppColors.emergency, const Color(0xFFB71C1C)]
                          : [
                              Colors.white.withAlpha(50),
                              Colors.white.withAlpha(30),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    user.isAdmin ? '🔐 Admin' : '👤 Kullanıcı',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 16, 6),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              fontSize: 11,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings tile ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [iconColor.withAlpha(40), iconColor.withAlpha(15)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: iconColor.withAlpha(50)),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing:
            trailing ??
            (onTap != null
                ? Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  )
                : null),
        onTap: onTap,
      ),
    );
  }
}

// ── Logout tile ───────────────────────────────────────────────────────────────

class _LogoutTile extends StatelessWidget {
  final AuthProvider auth;
  final BuildContext context;

  const _LogoutTile({required this.auth, required this.context});

  @override
  Widget build(BuildContext ctx) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.emergency.withAlpha(20),
            AppColors.emergency.withAlpha(8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.emergency.withAlpha(60)),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.emergency, Color(0xFFB71C1C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.emergency.withAlpha(80),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.logout_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        title: const Text(
          'Çıkış Yap',
          style: TextStyle(
            color: AppColors.emergency,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          'Oturumu kapat',
          style: TextStyle(
            color: AppColors.emergency.withAlpha(160),
            fontSize: 12,
          ),
        ),
        onTap: () => showDialog(
          context: ctx,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Çıkış Yap'),
            content: const Text('Oturumu kapatmak istediğinize emin misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await auth.logout();
                  if (ctx.mounted) {
                    Navigator.of(ctx).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                child: const Text(
                  'Çıkış Yap',
                  style: TextStyle(color: AppColors.emergency),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
