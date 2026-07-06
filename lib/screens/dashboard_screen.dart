import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../constants/colors.dart';
import '../constants/params.dart';
import '../models/param_config.dart';
import '../models/resultado.dart';
import '../services/classification_service.dart';
import '../services/pdf_service.dart';
import '../services/storage_service.dart';
import '../utils/format.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/misc.dart';
import '../widgets/score_ring.dart';

class _ParamStat {
  final ParamKey key;
  final double mean;
  final bool inIdeal;
  final Color cor;
  final int n;
  const _ParamStat(this.key, this.mean, this.inIdeal, this.cor, this.n);
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Relatorio> _relatorios = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _baixarPdf(Relatorio r) async {
    try {
      final bytes = await PdfService.buildRelatorioPdf(r);
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'relatorio-cocos-${r.id.substring(0, 8)}.pdf',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível gerar o PDF. Tente novamente.')),
        );
      }
    }
  }

  Future<void> _load() async {
    final data = await StorageService.loadRelatorios();
    if (mounted) setState(() { _relatorios = data; _loading = false; });
  }

  List<_ParamStat> get _paramStats {
    final out = <_ParamStat>[];
    for (final key in kParamKeys) {
      final vals = _relatorios.expand((r) => r.params.where((p) => p.key == key).map((p) => p.valor)).toList();
      if (vals.isEmpty) continue;
      final mean = vals.reduce((a, b) => a + b) / vals.length;
      final info = kParams[key]!;
      final inIdeal = mean >= info.idealMin && mean <= info.idealMax;
      final cor = inIdeal ? AppColors.folha : (mean < info.idealMin ? AppColors.atencao : AppColors.alerta);
      out.add(_ParamStat(key, double.parse(mean.toStringAsFixed(2)), inIdeal, cor, vals.length));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(title: '🌡️ Dashboard', body: Center(child: CircularProgressIndicator(color: AppColors.folha)));
    }
    if (_relatorios.isEmpty) {
      return AppScaffold(
        title: '🌡️ Dashboard',
        body: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            children: const [
              EmptyState(
                emoji: '🌡️',
                title: 'Dashboard vazio',
                desc: 'Gere pelo menos um Relatório Completo para ver o resumo do seu solo aqui.',
              ),
            ],
          ),
        ),
      );
    }

    final paramStats = _paramStats;
    final avgScore = (_relatorios.fold<int>(0, (a, r) => a + r.scorePct) / _relatorios.length).round();
    final critCount = paramStats.where((p) => !p.inIdeal).length;
    final okCount = paramStats.where((p) => p.inIdeal).length;
    final globalInfo = ClassificationService.scoreLabel(avgScore);
    // _relatorios já vem do mais novo para o mais antigo; para o gráfico de
    // evolução mostramos os 8 mais recentes em ordem cronológica (esquerda→direita).
    final evolucao = _relatorios.take(8).toList().reversed.toList();

    return AppScaffold(
      title: '🌡️ Dashboard',
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: globalInfo.cor.withValues(alpha: 0.1),
                border: Border.all(color: globalInfo.cor.withValues(alpha: 0.27), width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  ScoreRing(pct: avgScore, cor: globalInfo.cor, size: 90),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Score Médio do Solo',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.texto)),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(globalInfo.label,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: globalInfo.cor)),
                        ),
                        Text('${_relatorios.length} relatório${_relatorios.length != 1 ? "s" : ""} · ${paramStats.length} parâmetros',
                            style: const TextStyle(fontSize: 11, color: AppColors.textoSec)),
                        const SizedBox(height: 8),
                        Wrap(spacing: 8, children: [
                          _pill('✅ $okCount ideal${okCount != 1 ? "is" : ""}', AppColors.folhaPale, AppColors.folha),
                          if (critCount > 0) _pill('⚠️ $critCount fora', AppColors.alertaPale, AppColors.alerta),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppCard(
              title: '📈 Evolução do Score',
              child: SizedBox(
                height: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final r in evolucao)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('${r.scorePct}',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: ClassificationService.scoreLabel(r.scorePct).cor)),
                              const SizedBox(height: 3),
                              Container(
                                height: (16 + (r.scorePct / 100) * 64).toDouble(),
                                decoration: BoxDecoration(
                                  color: ClassificationService.scoreLabel(r.scorePct).cor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(formatDate(r.data).substring(0, 5),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 9, color: AppColors.textoSec)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            for (final catEntry in kCategorias.entries)
              Builder(builder: (context) {
                final catParams = paramStats.where((p) => kParams[p.key]!.categoria == catEntry.key).toList();
                if (catParams.isEmpty) return const SizedBox.shrink();
                return AppCard(
                  borderColor: catEntry.value.cor.withValues(alpha: 0.33),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: catEntry.value.cor, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text('${catEntry.value.emoji} ${catEntry.value.label}',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: catEntry.value.cor, letterSpacing: 0.5)),
                      ]),
                      const SizedBox(height: 14),
                      for (final p in catParams) _paramRow(p),
                    ],
                  ),
                );
              }),
            AppCard(
              title: '📋 Últimos Relatórios',
              child: Column(
                children: [
                  for (final r in _relatorios.take(6))
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borda))),
                      child: Row(
                        children: [
                          ScoreRing(pct: r.scorePct, cor: ClassificationService.scoreLabel(r.scorePct).cor, size: 52),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.titulo, maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.texto)),
                                if (r.cultura.isNotEmpty)
                                  Text('🌾 ${r.cultura}', style: const TextStyle(fontSize: 11, color: AppColors.textoSec)),
                                if (r.local.isNotEmpty)
                                  Text('📍 ${r.local}', style: const TextStyle(fontSize: 11, color: AppColors.textoSec)),
                                Text('🗓 ${formatDate(r.data)} · ${r.params.length} parâmetros',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textoSec)),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Baixar em PDF',
                            icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.terra),
                            onPressed: () => _baixarPdf(r),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paramRow(_ParamStat p) {
    final info = kParams[p.key]!;
    final range = (info.max - info.min) == 0 ? 1 : (info.max - info.min);
    final fillPct = ((p.mean - info.min) / range * 100).clamp(2, 100).toDouble();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 2), child: Text(info.emoji, style: const TextStyle(fontSize: 22))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(info.nome, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.texto))),
                    Text.rich(TextSpan(text: '${p.mean} ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: p.cor), children: [
                      TextSpan(text: info.unidade, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400)),
                    ])),
                  ],
                ),
                const SizedBox(height: 4),
                LayoutBuilder(builder: (context, constraints) {
                  return Container(
                    height: 8,
                    decoration: BoxDecoration(color: AppColors.borda, borderRadius: BorderRadius.circular(4)),
                    clipBehavior: Clip.antiAlias,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: constraints.maxWidth * fillPct / 100,
                        decoration: BoxDecoration(color: p.cor, borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 4),
                Text('${p.inIdeal ? "✅ Na faixa ideal" : "⚠️ Fora da faixa"} · ${p.n} medição${p.n != 1 ? "ões" : ""}',
                    style: TextStyle(fontSize: 11, color: p.cor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
      );
}
