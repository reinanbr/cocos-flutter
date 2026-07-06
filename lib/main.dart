import 'package:flutter/material.dart';

import 'constants/colors.dart';
import 'screens/comparar_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/historico_screen.dart';
import 'screens/home_screen.dart';
import 'screens/manual_screen.dart';
import 'screens/relatorio_screen.dart';
import 'screens/serie_screen.dart';
import 'screens/sobre_screen.dart';
import 'screens/unico_screen.dart';

void main() {
  runApp(const CocosApp());
}

class CocosApp extends StatelessWidget {
  const CocosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COCOS — Análise de Solo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.terra,
          primary: AppColors.terra,
          secondary: AppColors.folha,
        ),
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/manual': (context) => const ManualScreen(),
        '/unico': (context) => const UnicoScreen(),
        '/serie': (context) => const SerieScreen(),
        '/relatorio': (context) => const RelatorioScreen(),
        '/comparar': (context) => const CompararScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/historico': (context) => const HistoricoScreen(),
        '/sobre': (context) => const SobreScreen(),
      },
    );
  }
}
