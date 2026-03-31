import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const String _adminEmail = 'admin@hastane.gov.tr';
  static const String _userEmail = 'kullanici@hastane.gov.tr';
  static const String _demoPass = '1234';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
    if (ok && mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, anim, __) => const HomeScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  void _fillDemo(String email) {
    _emailCtrl.text = email;
    _passCtrl.text = _demoPass;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF070E1A),
                    Color(0xFF0F1A2E),
                    Color(0xFF0D2040),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0A2463),
                    Color(0xFF1565C0),
                    Color(0xFF1976D2),
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
        ),
        child: Stack(
          children: [
            // Decorative background blobs
            Positioned(
              top: -size.width * 0.25,
              left: -size.width * 0.2,
              child: Container(
                width: size.width * 0.7,
                height: size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(isDark ? 8 : 15),
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.08,
              right: -size.width * 0.15,
              child: Container(
                width: size.width * 0.55,
                height: size.width * 0.55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentLight.withAlpha(isDark ? 20 : 30),
                ),
              ),
            ),
            // Main scroll
            SafeArea(
              child: Column(
                children: [
                  // Top header area
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo container with glow
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withAlpha(isDark ? 18 : 30),
                                border: Border.all(
                                  color: Colors.white.withAlpha(
                                    isDark ? 30 : 60,
                                  ),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentLight.withAlpha(60),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.local_hospital_rounded,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Hastane Rehberi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Hesabınıza giriş yapın',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(210),
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
                  // Bottom card
                  Expanded(
                    flex: 6,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                : Colors.white,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(36),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(40),
                                blurRadius: 30,
                                offset: const Offset(0, -6),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Handle bar
                                  Center(
                                    child: Container(
                                      width: 40,
                                      height: 4,
                                      margin: const EdgeInsets.only(bottom: 28),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.darkDivider
                                            : AppColors.lightDivider,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Giriş Yap',
                                        style: theme.textTheme.headlineMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 28),
                                  // Error banner
                                  if (auth.errorMessage != null)
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(bottom: 20),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: AppColors.emergency.withAlpha(
                                          15,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: AppColors.emergency.withAlpha(
                                            70,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppColors.emergency
                                                  .withAlpha(20),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.error_outline_rounded,
                                              color: AppColors.emergency,
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              auth.errorMessage!,
                                              style: const TextStyle(
                                                color: AppColors.emergency,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  // E-posta field
                                  _FieldLabel(
                                    label: 'E-posta Adresi',
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _emailCtrl,
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: (_) => auth.clearError(),
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.alternate_email_rounded,
                                      ),
                                      hintText: 'ornek@hastane.gov.tr',
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'E-posta gerekli';
                                      if (!v.contains('@'))
                                        return 'Geçerli e-posta girin';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  // Şifre field
                                  _FieldLabel(label: 'Şifre', isDark: isDark),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _passCtrl,
                                    obscureText: _obscurePass,
                                    onChanged: (_) => auth.clearError(),
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                      ),
                                      hintText: '••••••••',
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePass
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscurePass = !_obscurePass,
                                        ),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Şifre gerekli';
                                      if (v.length < 4)
                                        return 'En az 4 karakter';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 32),
                                  // Login button with gradient
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: auth.isLoading
                                            ? null
                                            : const LinearGradient(
                                                colors: [
                                                  Color(0xFF1565C0),
                                                  Color(0xFF0D47A1),
                                                ],
                                              ),
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: auth.isLoading
                                            ? []
                                            : [
                                                BoxShadow(
                                                  color: AppColors.primary
                                                      .withAlpha(80),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: auth.isLoading
                                            ? null
                                            : _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        child: auth.isLoading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.5,
                                                    ),
                                              )
                                            : const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.login_rounded,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    'Giriş Yap',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      letterSpacing: 0.3,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  // Demo accounts section
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: isDark
                                              ? AppColors.darkDivider
                                              : AppColors.lightDivider,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Text(
                                          'Demo Hesaplar',
                                          style: TextStyle(
                                            color: isDark
                                                ? AppColors.textDarkSecondary
                                                : AppColors.textSecondary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: isDark
                                              ? AppColors.darkDivider
                                              : AppColors.lightDivider,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _DemoAccountButton(
                                          label: 'Kullanıcı',
                                          icon: Icons.person_rounded,
                                          email: _userEmail,
                                          color: AppColors.primary,
                                          onTap: () => _fillDemo(_userEmail),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _DemoAccountButton(
                                          label: 'Admin',
                                          icon: Icons
                                              .admin_panel_settings_rounded,
                                          email: _adminEmail,
                                          color: AppColors.emergency,
                                          onTap: () => _fillDemo(_adminEmail),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Center(
                                    child: Text(
                                      'Şifre: $_demoPass',
                                      style: TextStyle(
                                        color: isDark
                                            ? AppColors.textDarkSecondary
                                            : AppColors.textSecondary,
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _FieldLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    ),
  );
}

class _DemoAccountButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String email;
  final Color color;
  final VoidCallback onTap;

  const _DemoAccountButton({
    required this.label,
    required this.icon,
    required this.email,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(isDark ? 25 : 15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(70), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withAlpha(isDark ? 40 : 25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    email.split('@').first,
                    style: TextStyle(color: color.withAlpha(160), fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
