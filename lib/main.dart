import 'package:flutter/material.dart';

import 'package:quran_app/core/routes/app_routes.dart';
import 'package:quran_app/features/home/presentation/view/get_telawa_screen.dart';
import 'package:quran_app/features/suwar/presentation/view/get_suwar_screen.dart';

void main() {
  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quran App',
      theme: ThemeData(primarySwatch: Colors.blue),

      initialRoute: AppRoutes.getTelawa,
      routes: {
        AppRoutes.getTelawa: (context) => const GetTelawaScreen(),
        AppRoutes.getSuwar: (context) => const GetSuwarScreen(),
      },
    );
  }
}
