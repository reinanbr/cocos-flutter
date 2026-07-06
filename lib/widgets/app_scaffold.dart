import 'package:flutter/material.dart';
import '../constants/colors.dart';

class _NavItem {
  final String route;
  final String emoji;
  final String label;
  const _NavItem(this.route, this.emoji, this.label);
}

const _navItems = [
  _NavItem('/', '🏠', 'Início'),
  _NavItem('/manual', '📖', 'Manual de Coleta'),
  _NavItem('/unico', '📍', 'Análise Única'),
  _NavItem('/serie', '📊', 'Série de Valores'),
  _NavItem('/relatorio', '📋', 'Relatório Completo'),
  _NavItem('/comparar', '⚖️', 'Comparar Parâmetros'),
  _NavItem('/dashboard', '🌡️', 'Dashboard'),
  _NavItem('/historico', '📁', 'Histórico'),
  _NavItem('/sobre', 'ℹ️', 'Sobre o COCOS'),
];

/// Scaffold compartilhado por todas as telas: AppBar na cor terra + Drawer
/// de navegação, igual em Android e Web.
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;

  const AppScaffold({super.key, required this.title, required this.body, this.actions});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.terra,
        foregroundColor: AppColors.white,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: actions,
      ),
      drawer: Drawer(
        backgroundColor: AppColors.card,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppColors.terra),
              child: Row(
                children: [
                  Text('🌱', style: TextStyle(fontSize: 34)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('COCOS',
                            style: TextStyle(
                                color: AppColors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                        SizedBox(height: 4),
                        Text('Análise de Solo a Campo',
                            style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            for (final item in _navItems)
              ListTile(
                leading: Text(item.emoji, style: const TextStyle(fontSize: 20)),
                title: Text(item.label,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: currentRoute == item.route ? AppColors.terra : AppColors.texto)),
                selected: currentRoute == item.route,
                selectedTileColor: AppColors.terraPale,
                onTap: () {
                  Navigator.of(context).pop();
                  if (currentRoute != item.route) {
                    Navigator.of(context).pushNamed(item.route);
                  }
                },
              ),
          ],
        ),
      ),
      body: SafeArea(child: body),
    );
  }
}
