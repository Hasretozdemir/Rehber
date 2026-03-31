import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors — deep sapphire blue
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryDeep = Color(0xFF0A2E6E);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryGlow = Color(0xFF64B5F6);

  // Accent — electric cyan/teal
  static const Color accent = Color(0xFF00ACC1);
  static const Color accentLight = Color(0xFF4DD0E1);

  // Emergency / Critical
  static const Color emergency = Color(0xFFC62828);
  static const Color emergencyLight = Color(0xFFEF5350);
  static const Color emergencyGlow = Color(0xFFFF8A80);
  static const Color warning = Color(0xFFF57F17);
  static const Color warningLight = Color(0xFFFFCA28);

  // Status colors
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFF66BB6A);
  static const Color info = Color(0xFF0277BD);

  // Department tag colors
  static const Color acil = Color(0xFFC62828);
  static const Color lab = Color(0xFF6A1B9A);
  static const Color yogunBakim = Color(0xFFBF360C);
  static const Color ameliyathane = Color(0xFF1565C0);
  static const Color klinik = Color(0xFF2E7D32);
  static const Color idari = Color(0xFF01579B);
  static const Color radyoloji = Color(0xFF4527A0);

  // Light theme
  static const Color lightBackground = Color(0xFFEFF4FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFDDE3F0);

  // Dark theme
  static const Color darkBackground = Color(0xFF070E1A);
  static const Color darkSurface = Color(0xFF0F1A2E);
  static const Color darkCard = Color(0xFF162235);
  static const Color darkElevated = Color(0xFF1A2840);
  static const Color darkDivider = Color(0xFF1E2D45);

  // Text
  static const Color textPrimary = Color(0xFF0D1F3C);
  static const Color textSecondary = Color(0xFF5A6A8A);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textDarkPrimary = Color(0xFFE8EEFF);
  static const Color textDarkSecondary = Color(0xFF8BA3C7);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A2463), Color(0xFF1565C0), Color(0xFF00838F)],
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7F0000), Color(0xFFC62828), Color(0xFFE53935)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2)],
  );
}
