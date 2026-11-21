import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/core/routes/app_routes.dart';
import 'package:quran_app/features/home/presentation/view/get_telawa_screen.dart';
import 'package:quran_app/features/home/presentation/view_model/get_telawa_cubit.dart';
import 'package:quran_app/features/suwar/presentation/view/get_suwar_screen.dart';
import 'package:quran_app/features/suwar/presentation/view_model/get_suwar_cubit.dart';

void main() {
  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GetTelawaCubit>(
          create: (_) => GetTelawaCubit()..getTelawa(),
        ),
        BlocProvider<GetSuwarCubit>(create: (_) => GetSuwarCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Quran App',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: AppRoutes.getTelawa,
        routes: {
          AppRoutes.getTelawa: (context) => const GetTelawaScreen(),
          AppRoutes.getSuwar: (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            return GetSuwarScreen(selectedMoshaf: args);
          },
        },
      ),
    );
  }
}
