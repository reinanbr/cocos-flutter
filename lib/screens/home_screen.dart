import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/storage_service.dart';
import '../widgets/app_scaffold.dart';

class _CardInfo {
  final String route;
  final String emoji;
  final String title;
  final String desc;
  final Color color;
  const _CardInfo(this.route, this.emoji, this.title, this.desc, this.color);
}

const _cards = [
  _CardInfo('/manual', '📖', 'Manual de Coleta',
      'Passo a passo de como medir cada parâmetro direto na roça.', AppColors.folha),
  _CardInfo('/unico', '📍', 'Análise Única',
      'Analise um parâmetro e veja se está na faixa ideal.', AppColors.terra),
  _CardInfo('/serie', '📊', 'Série de Valores',
      'Compare múltiplas medições com estatísticas completas.', AppColors.agua),
  _CardInfo('/relatorio', '📋', 'Relatório Completo',
      'Analise todos os parâmetros de uma vez e obtenha um score.', AppColors.sol),
  _CardInfo('/comparar', '⚖️', 'Comparar Parâmetros',
      'Compare dois parâmetros lado a lado.', AppColors.roxo),
  _CardInfo('/dashboard', '🌡️', 'Dashboard',
      'Resumo visual de todos os seus últimos relatórios.', AppColors.terraLight),
  _CardInfo('/historico', '📁', 'Histórico',
      'Todas as suas análises salvas localmente.', AppColors.folhaLight),
  _CardInfo('/sobre', 'ℹ️', 'Sobre o COCOS',
      'Origem do projeto, criador e referências científicas.', AppColors.textoSec),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _total = 0;

  @override
  void initState() {
    super.initState();
    StorageService.loadHistorico().then((h) {
      if (mounted) setState(() => _total = h.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '🌱 COCOS',
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 14),
            decoration:
                BoxDecoration(color: AppColors.terra, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const Text('🌱', style: TextStyle(fontSize: 40)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bem-vindo ao COCOS',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.white)),
                      const SizedBox(height: 3),
                      Text('Análise de solo a campo, sem depender de laboratório',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.white.withValues(alpha: 0.8), height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(bg: AppColors.terraPale, dotColor: null, text: '📁 $_total análises salvas'),
            ],
          ),
          const SizedBox(height: 20),
          const Text('O que deseja fazer?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.texto)),
          const SizedBox(height: 12),
          for (final c in _cards)
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.of(context).pushNamed(c.route),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: c.color.withValues(alpha: 0.27), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 1)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration:
                          BoxDecoration(color: c.color, borderRadius: BorderRadius.circular(13)),
                      child: Text(c.emoji, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.title,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700, color: c.color)),
                          const SizedBox(height: 3),
                          Text(c.desc,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textoSec, height: 1.3)),
                        ],
                      ),
                    ),
                    Text('›', style: TextStyle(fontSize: 26, color: c.color, fontWeight: FontWeight.w300)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          const Center(
            child: Text('🌾 6 parâmetros de campo',
                style: TextStyle(fontSize: 12, color: AppColors.textoSec)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final Color bg;
  final Color? dotColor;
  final String text;
  const _Pill({required this.bg, required this.dotColor, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
                width: 7, height: 7, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            const SizedBox(width: 6),
          ],
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textoSec)),
        ],
      ),
    );
  }
}
