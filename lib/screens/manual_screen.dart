import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/manual_data.dart';
import '../constants/params.dart';
import '../models/param_config.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';

class ManualScreen extends StatelessWidget {
  const ManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '📖 Manual de Coleta',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            borderColor: AppColors.folha.withValues(alpha: 0.4),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🌾 Como coletar os dados do solo na roça',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.texto)),
                SizedBox(height: 8),
                Text(
                  'O COCOS trabalha apenas com parâmetros que você mesmo consegue medir no campo, '
                  'com instrumentos simples e baratos — sem precisar mandar amostra para laboratório. '
                  'Abaixo está o passo a passo de coleta de cada um.',
                  style: TextStyle(fontSize: 13, color: AppColors.textoSec, height: 1.5),
                ),
                SizedBox(height: 10),
                Text(
                  '💡 Dica geral: colete sempre em vários pontos do talhão (5 a 10), andando em '
                  'zigue-zague, e evite dias de chuva forte ou logo após adubação/calagem recente.',
                  style: TextStyle(
                      fontSize: 12.5, color: AppColors.folha, fontWeight: FontWeight.w600, height: 1.5),
                ),
              ],
            ),
          ),
          for (final m in kManual) _ManualCard(manual: m),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _ManualCard extends StatelessWidget {
  final ManualParam manual;
  const _ManualCard({required this.manual});

  @override
  Widget build(BuildContext context) {
    final info = kParams[manual.key]!;
    final catCor = kCategorias[info.categoria]!.cor;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: catCor.withValues(alpha: 0.35), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: manual.key == ParamKey.ph,
          leading: Text(info.emoji, style: const TextStyle(fontSize: 26)),
          title: Text(info.nome,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: catCor)),
          subtitle: Text('Ideal: ${_fmt(info.idealMin)}–${_fmt(info.idealMax)} ${info.unidade}',
              style: const TextStyle(fontSize: 12, color: AppColors.textoSec)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🧰 O QUE VOCÊ VAI PRECISAR',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textoSec,
                    letterSpacing: 0.4)),
            const SizedBox(height: 6),
            for (final item in manual.materiais)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: AppColors.textoSec)),
                    Expanded(
                        child: Text(item,
                            style: const TextStyle(fontSize: 13, color: AppColors.texto, height: 1.4))),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            const Text('👣 PASSO A PASSO',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textoSec,
                    letterSpacing: 0.4)),
            const SizedBox(height: 8),
            for (int i = 0; i < manual.passos.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(color: catCor, shape: BoxShape.circle),
                      child: Text('${i + 1}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.white, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(manual.passos[i],
                          style: const TextStyle(fontSize: 13.5, color: AppColors.texto, height: 1.45)),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration:
                  BoxDecoration(color: AppColors.hintBg, borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.hintBorder)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡 ', style: TextStyle(fontSize: 13)),
                  Expanded(
                    child: Text(manual.dica,
                        style: const TextStyle(fontSize: 12, color: AppColors.textoSec, height: 1.4)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}
