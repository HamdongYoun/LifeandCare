import 'package:flutter/material.dart';
import 'package:lifeand_care_app/core/status_indicator.dart';

class AppColors {
  static const Color primary = Color(0xFF2563EB); // Royal Blue
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color secondary = Color(0xFFF5F7FB); // Soft grayish-blue background
  static const Color accent = Color(0xFF2563EB);
  static const Color textMain = Color(0xFF2563EB); // Updated: Overall Text Design
  static const Color textSub = Color(0xFF60A5FA); // Updated: Lighter blue for muted text
  static const Color success = Color(0xFF10B981);
  static const Color cardBg = Colors.white;
}

class AppStyles {
  static final BorderRadius radius24 = BorderRadius.circular(24);
  static final BorderRadius radius20 = BorderRadius.circular(20);
  static final BorderRadius radius16 = BorderRadius.circular(16);
  static final BorderRadius radius12 = BorderRadius.circular(12);

  // Recovered from components.css (.settings-card / .mock-card)
  static final Border premiumBorder = Border.all(color: Colors.black, width: 2.0);
  
  static final BoxShadow premiumShadow = BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );

  static Widget statusPulse() => const StatusPulseIndicator();

  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.secondary,
    cardTheme: const CardTheme(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: AppColors.primary),
    ),
  );
}


