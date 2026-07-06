import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/params.dart';
import '../models/historico_entry.dart';
import '../models/param_config.dart';
import '../models/resultado.dart';
import '../services/classification_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/buttons.dart';
import '../widgets/gauge_bar.dart';
import '../widgets/hint_box.dart';
import '../widgets/misc.dart';
import '../widgets/param_grid.dart';
import '../widgets/status_badge.dart';
import '../widgets/rec_box.dart';

class UnicoScreen extends StatefulWidget {
  const UnicoScreen({super.key});

  @override
  State<UnicoScreen> createState() => _UnicoScreenState();
}

class _UnicoScreenState extends State<UnicoScreen> {
  ParamKey? _param;
  final _controller = TextEditingController();
  ResultadoUnico? _resultado;
  String? _error;

  void _onSelectParam(ParamKey key) {
    final info = kParams[key]!;
    setState(() {
      _param = key;
      _resultado = null;
      _error = null;
      _controller.text =
          ((info.idealMin + info.idealMax) / 2).toStringAsFixed(info.step < 0.1 ? 2 : 1);
    });
  }

  void _onSlider(double v) {
    final info = kParams[_param]!;
    setState(() {
      _controller.text = v.toStringAsFixed(info.step < 0.1 ? 2 : 1);
    });
  }

  Future<void> _onAnalisar() async {
    if (_param == null) {
      setState(() => _error = 'Selecione um parâmetro.');
      return;
    }
    final v = double.tryParse(_controller.text.replaceAll(',', '.'));
    if (v == null) {
      setState(() => _error = 'Digite um valor válido.');
      return;
    }
    final resultado = ClassificationService.buildResultadoUnico(_param!, v);
    setState(() {
      _resultado = resultado;
      _error = null;
    });
    await StorageService.saveHistoricoEntry(HistoricoEntry(
      id: StorageService.genId(),
      data: DateTime.now().toIso8601String(),
      tipo: HistoricoTipo.unico,
      titulo: '${resultado.emoji} ${resultado.nome}: ${_fmtNum(v)} ${resultado.unidade}',
      paramKey: _param!,
      valor: v,
      status: resultado.status,
      cor: resultado.cor,
    ));
  }

  String _fmtNum(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  Widget build(BuildContext context) {
    final info = _param != null ? kParams[_param!] : null;
    final currentVal = double.tryParse(_controller.text.replaceAll(',', '.'));

    return AppScaffold(
      title: '📍 Análise Única',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            title: '🌍 Selecione o Parâmetro',
            desc: 'Toque no parâmetro que você mediu no terreno',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ParamGrid(selected: _param, onSelect: _onSelectParam),
                if (info != null) ...[
                  const SizedBox(height: 14),
                  Text('Valor de ${info.nome}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textoSec,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.texto),
                    decoration: InputDecoration(
                      hintText: '${_fmtNum(info.idealMin)} – ${_fmtNum(info.idealMax)}',
                      filled: true,
                      fillColor: AppColors.bg,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.borda, width: 2),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.terraPale, borderRadius: BorderRadius.circular(6)),
                    child: Text(info.unidade,
                        style: const TextStyle(fontSize: 12, color: AppColors.textoSec)),
                  ),
                  Slider(
                    min: info.min,
                    max: info.max,
                    divisions: ((info.max - info.min) / info.step).round().clamp(1, 100000),
                    value: (currentVal ?? info.idealMin).clamp(info.min, info.max),
                    activeColor: AppColors.folha,
                    inactiveColor: AppColors.borda,
                    onChanged: _onSlider,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmtNum(info.min),
                          style: const TextStyle(fontSize: 10, color: AppColors.textoSec)),
                      Text('✓ ${_fmtNum(info.idealMin)}–${_fmtNum(info.idealMax)}',
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.folha, fontWeight: FontWeight.w700)),
                      Text(_fmtNum(info.max),
                          style: const TextStyle(fontSize: 10, color: AppColors.textoSec)),
                    ],
                  ),
                  HintBox(text: info.hint),
                  PrimaryButton(label: '🔍 Analisar', onPressed: _onAnalisar),
                ],
              ],
            ),
          ),
          if (_error != null) ErrorBox(text: _error!),
          if (_resultado != null) _ResultCard(r: _resultado!),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final ResultadoUnico r;
  const _ResultCard({required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: r.cor.withValues(alpha: 0.33), width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            color: r.cor.withValues(alpha: 0.1),
            child: Row(
              children: [
                Text(r.emoji, style: const TextStyle(fontSize: 34)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.nome,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.texto)),
                      Text.rich(
                        TextSpan(
                          text: '${r.valor} ',
                          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: r.cor),
                          children: [
                            TextSpan(
                                text: r.unidade,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
                          ],
                        ),
                      ),
                      StatusBadge(label: r.label, cor: r.cor),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            color: AppColors.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel(text: 'POSIÇÃO NA ESCALA'),
                GaugeBar(val: r.valor, min: r.min, max: r.max, ideal: r.ideal, cor: r.cor),
                RecBox(text: r.rec, status: r.status),
                if (r.dica != null) HintBox(text: r.dica!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
