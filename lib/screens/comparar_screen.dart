import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/params.dart';
import '../models/param_config.dart';
import '../models/classification.dart';
import '../models/resultado.dart';
import '../services/classification_service.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/buttons.dart';
import '../widgets/gauge_bar.dart';
import '../widgets/misc.dart';
import '../widgets/param_grid.dart';
import '../widgets/rec_box.dart';
import '../widgets/status_badge.dart';

const _statusRank = [
  ClassificationStatus.otimo,
  ClassificationStatus.bom,
  ClassificationStatus.regular,
  ClassificationStatus.atencao,
  ClassificationStatus.ruim,
  ClassificationStatus.muitoRuim,
];

class CompararScreen extends StatefulWidget {
  const CompararScreen({super.key});

  @override
  State<CompararScreen> createState() => _CompararScreenState();
}

class _CompararScreenState extends State<CompararScreen> {
  ParamKey? _paramA;
  ParamKey? _paramB;
  final _ctrlA = TextEditingController();
  final _ctrlB = TextEditingController();
  ResultadoUnico? _resA;
  ResultadoUnico? _resB;
  String? _error;

  String _midpoint(ParamKey k) {
    final info = kParams[k]!;
    return ((info.idealMin + info.idealMax) / 2).toStringAsFixed(info.step < 0.1 ? 2 : 1);
  }

  void _onComparar() {
    if (_paramA == null || _paramB == null) {
      setState(() => _error = 'Selecione os dois parâmetros.');
      return;
    }
    final vA = double.tryParse(_ctrlA.text.replaceAll(',', '.'));
    final vB = double.tryParse(_ctrlB.text.replaceAll(',', '.'));
    if (vA == null || vB == null) {
      setState(() => _error = 'Insira valores válidos.');
      return;
    }
    setState(() {
      _resA = ClassificationService.buildResultadoUnico(_paramA!, vA);
      _resB = ClassificationService.buildResultadoUnico(_paramB!, vB);
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '⚖️ Comparar Parâmetros',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Compare dois parâmetros lado a lado para ver como cada um está em relação ao ideal',
              style: TextStyle(fontSize: 13, color: AppColors.textoSec, height: 1.4),
            ),
          ),
          AppCard(
            title: '🔵 Parâmetro A',
            borderColor: AppColors.agua.withValues(alpha: 0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ParamGrid(
                  selected: _paramA,
                  onSelect: (k) => setState(() {
                    _paramA = k;
                    _ctrlA.text = _midpoint(k);
                  }),
                ),
                if (_paramA != null) _sideInput(kParams[_paramA!]!, _ctrlA, AppColors.agua),
              ],
            ),
          ),
          AppCard(
            title: '🟠 Parâmetro B',
            borderColor: AppColors.sol.withValues(alpha: 0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ParamGrid(
                  selected: _paramB,
                  onSelect: (k) => setState(() {
                    _paramB = k;
                    _ctrlB.text = _midpoint(k);
                  }),
                ),
                if (_paramB != null) _sideInput(kParams[_paramB!]!, _ctrlB, AppColors.sol),
              ],
            ),
          ),
          PrimaryButton(label: '⚖️ Comparar', onPressed: _onComparar),
          if (_error != null) ErrorBox(text: _error!),
          if (_resA != null && _resB != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _compCard(_resA!, 'A', AppColors.agua)),
                const SizedBox(width: 10),
                Expanded(child: _compCard(_resB!, 'B', AppColors.sol)),
              ],
            ),
            const SizedBox(height: 12),
            AppCard(
              title: '📊 Análise Comparativa',
              child: Column(
                children: [
                  _compLine('Parâmetro A', '${_resA!.valor} ${_resA!.unidade}', _resA!.cor, _resA!.label),
                  _compLine('Parâmetro B', '${_resB!.valor} ${_resB!.unidade}', _resB!.cor, _resB!.label),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration:
                        BoxDecoration(color: AppColors.folhaPale, borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      _resA!.status == _resB!.status
                          ? '🤝 Ambos em situação semelhante'
                          : '🏆 Parâmetro ${_statusRank.indexOf(_resA!.status) <= _statusRank.indexOf(_resB!.status) ? "A" : "B"} está em melhor condição',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.folha),
                    ),
                  ),
                  RecBox(text: _resA!.rec, status: _resA!.status),
                  RecBox(text: _resB!.rec, status: _resB!.status),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sideInput(ParamConfig info, TextEditingController ctrl, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.texto),
            decoration: InputDecoration(
              hintText: '${info.idealMin} – ${info.idealMax} ${info.unidade}',
              contentPadding: const EdgeInsets.all(13),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: accent, width: 2)),
            ),
            onChanged: (_) => setState(() {}),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('Ideal: ${info.idealMin}–${info.idealMax} ${info.unidade}',
                style: const TextStyle(fontSize: 11, color: AppColors.textoSec)),
          ),
        ],
      ),
    );
  }

  Widget _compCard(ResultadoUnico r, String letter, Color accent) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            color: accent.withValues(alpha: 0.1),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                  child: Text(letter,
                      style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
                const SizedBox(width: 8),
                Text(r.emoji, style: const TextStyle(fontSize: 24)),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: AppColors.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.nome, maxLines: 2, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.texto)),
                Text('${r.valor}', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: r.cor, height: 1.25)),
                Text(r.unidade, style: const TextStyle(fontSize: 11, color: AppColors.textoSec)),
                StatusBadge(label: r.label, cor: r.cor),
                GaugeBar(val: r.valor, min: r.min, max: r.max, ideal: r.ideal, cor: r.cor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _compLine(String label, String val, Color cor, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borda))),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textoSec))),
          Expanded(
              flex: 2,
              child: Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.texto))),
          Expanded(
              child: Text(status,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cor))),
        ],
      ),
    );
  }
}
