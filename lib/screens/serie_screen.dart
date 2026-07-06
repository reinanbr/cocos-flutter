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
import '../widgets/misc.dart';
import '../widgets/param_grid.dart';
import '../widgets/rec_box.dart';
import '../widgets/status_badge.dart';

class _SeriesItem {
  final int id;
  final TextEditingController controller = TextEditingController();
  _SeriesItem(this.id);
}

class SerieScreen extends StatefulWidget {
  const SerieScreen({super.key});

  @override
  State<SerieScreen> createState() => _SerieScreenState();
}

class _SerieScreenState extends State<SerieScreen> {
  ParamKey? _param;
  List<_SeriesItem> _items = [];
  int _nextId = 4;
  ResultadoSerie? _resultado;
  String? _error;

  void _resetItems() {
    _items = [_SeriesItem(1), _SeriesItem(2), _SeriesItem(3)];
    _nextId = 4;
  }

  void _onSelectParam(ParamKey key) {
    setState(() {
      _param = key;
      _resetItems();
      _resultado = null;
      _error = null;
    });
  }

  void _addItem() => setState(() => _items.add(_SeriesItem(_nextId++)));
  void _removeItem(int id) => setState(() => _items.removeWhere((i) => i.id == id));

  Future<void> _onAnalisar() async {
    if (_param == null) {
      setState(() => _error = 'Selecione um parâmetro.');
      return;
    }
    final nums = _items
        .map((i) => double.tryParse(i.controller.text.replaceAll(',', '.')))
        .whereType<double>()
        .toList();
    if (nums.length < 2) {
      setState(() => _error = 'Insira pelo menos 2 valores.');
      return;
    }
    final resultado = ClassificationService.calcSerie(_param!, nums);
    setState(() {
      _resultado = resultado;
      _error = null;
    });
    await StorageService.saveHistoricoEntry(HistoricoEntry(
      id: StorageService.genId(),
      data: DateTime.now().toIso8601String(),
      tipo: HistoricoTipo.serie,
      titulo: '${resultado.emoji} ${resultado.nome} — ${resultado.n} medições (média ${resultado.mean})',
      paramKey: _param!,
      media: resultado.mean,
      status: resultado.status,
      cor: resultado.cor,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final info = _param != null ? kParams[_param!] : null;

    return AppScaffold(
      title: '📊 Série de Valores',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            title: '📊 Análise de Série',
            desc: 'Insira medições de diferentes pontos ou datas do terreno',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ParamGrid(selected: _param, onSelect: _onSelectParam),
                if (info != null) ...[
                  const SizedBox(height: 14),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: info.nome,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.terra)),
                    TextSpan(
                        text: ' — ${info.unidade}',
                        style: const TextStyle(fontSize: 14, color: AppColors.textoSec)),
                  ])),
                  const SizedBox(height: 10),
                  for (int i = 0; i < _items.length; i++)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        border: Border.all(color: AppColors.borda, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration:
                                const BoxDecoration(color: AppColors.terra, shape: BoxShape.circle),
                            child: Text('${i + 1}',
                                style: const TextStyle(
                                    color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _items[i].controller,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.texto),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: ((info.idealMin + info.idealMax) / 2).toStringAsFixed(1),
                              ),
                            ),
                          ),
                          if (_items.length > 2)
                            InkWell(
                              onTap: () => _removeItem(_items[i].id),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                    color: AppColors.alertaPale, shape: BoxShape.circle),
                                child: const Text('✕',
                                    style: TextStyle(
                                        color: AppColors.alerta,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  InkWell(
                    onTap: _addItem,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borda, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('+ Adicionar valor',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.terraLight)),
                      ),
                    ),
                  ),
                  PrimaryButton(label: '📊 Analisar Série', onPressed: _onAnalisar),
                ],
              ],
            ),
          ),
          if (_error != null) ErrorBox(text: _error!),
          if (_resultado != null) _SerieResultCard(r: _resultado!),
        ],
      ),
    );
  }
}

class _SerieResultCard extends StatelessWidget {
  final ResultadoSerie r;
  const _SerieResultCard({required this.r});

  @override
  Widget build(BuildContext context) {
    final trendEmoji = r.trend == 'Subindo' ? '📈' : (r.trend == 'Caindo' ? '📉' : '➡️');
    final maxV = r.valores.reduce((a, b) => a > b ? a : b);
    final stats = <(String, String, Color?)>[
      ('Mín', _fmt(r.minV), null),
      ('Média', _fmt(r.mean), r.cor),
      ('Máx', _fmt(r.maxV), null),
      ('Mediana', _fmt(r.median), null),
      ('CV', '${r.cv}%', r.cv > 30 ? AppColors.atencao : null),
      ('N', '${r.n}', null),
    ];

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
                      Text('${r.nome} · ${r.n} medições',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.texto)),
                      Text.rich(TextSpan(text: '${r.mean} ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: r.cor), children: [
                        TextSpan(text: r.unidade, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                      ])),
                      StatusBadge(label: 'Média: ${r.label}', cor: r.cor),
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in stats)
                      Container(
                        width: (MediaQuery.of(context).size.width - 32 - 36 - 16) / 3,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borda, width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Text(s.$1,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textoSec,
                                    letterSpacing: 0.4)),
                            const SizedBox(height: 3),
                            Text(s.$2,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700, color: s.$3 ?? AppColors.terra)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const SectionLabel(text: 'VALORES'),
                SizedBox(
                  height: 96,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (int i = 0; i < r.valores.length; i++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: (8 + (r.valores[i] / maxV) * 72).clamp(8, 80).toDouble(),
                                  decoration: BoxDecoration(
                                    color: _barColor(r.valores[i], r.ideal),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text('${i + 1}',
                                    style: const TextStyle(fontSize: 9, color: AppColors.textoSec)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text('🟢 ideal  🔶 atenção  🔴 fora',
                    style: TextStyle(fontSize: 11, color: AppColors.textoSec)),
                const SizedBox(height: 8),
                const SectionLabel(text: 'POSIÇÃO DA MÉDIA'),
                GaugeBar(val: r.mean, min: r.min, max: r.max, ideal: r.ideal, cor: r.cor),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.terraPale, borderRadius: BorderRadius.circular(12)),
                  child: Text('$trendEmoji Tendência: ${r.trend}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.terra)),
                ),
                if (r.altaVar)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppColors.hintBg,
                        border: Border.all(color: AppColors.hintBorder),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text('⚠️ Alta variação! Verifique as condições de coleta.',
                        style: TextStyle(fontSize: 12, color: AppColors.textoSec, height: 1.4)),
                  ),
                RecBox(text: r.rec, status: r.status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _barColor(double v, List<double> ideal) {
    if (v >= ideal[0] && v <= ideal[1]) return AppColors.folha;
    if (v < ideal[0] * 0.5 || v > ideal[1] * 1.5) return AppColors.alerta;
    return AppColors.atencao;
  }

  String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}
