import 'package:flutter/material.dart';

class AppColors {


  static const Color primary = Color(0xFF6B8E7B);
  static const Color primaryDark = Color(0xFF2D4A3E);
  static const Color primaryLight = Color(0xFFE6EFEA);

  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1A1D1E);
  static const Color textSecondary = Color(0xFF7D8582);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFE2E8E5);
  static const Color inactiveTrack = Color(0xFFD5DDD9);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF6B8E7B), Color(0xFFB3C7BC)],
  );
}
