import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quran_app/core/constants/app_assets.dart';
import 'package:quran_app/core/routes/app_routes.dart';
import 'package:quran_app/core/themes/app_color.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.getTelawa);
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAssets.quranImage,
              width: 170,
              height: 170,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 14),
            const Text(
              'Quran App',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
