import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../constants/colors.dart';
import '../constants/params.dart';
import '../models/classification.dart';
import '../models/historico_entry.dart';
import '../models/param_config.dart';
import '../models/resultado.dart';
import '../services/classification_service.dart';
import '../services/pdf_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/buttons.dart';
import '../widgets/gauge_bar.dart';
import '../widgets/misc.dart';
import '../widgets/score_ring.dart';
import '../widgets/status_badge.dart';
import '../widgets/rec_box.dart';

enum _Etapa { meta, params, resultado }

class RelatorioScreen extends StatefulWidget {
  const RelatorioScreen({super.key});

  @override
  State<RelatorioScreen> createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends State<RelatorioScreen> {
  final _tituloCtrl = TextEditingController();
  final _localCtrl = TextEditingController();
  String _cultura = '';
  final Map<ParamKey, TextEditingController> _valores = {
    for (final k in kParamKeys) k: TextEditingController(),
  };
  _Etapa _etapa = _Etapa.meta;
  Relatorio? _relatorio;
  String? _error;

  List<ParamKey> get _preenchidos => kParamKeys
      .where((k) => double.tryParse(_valores[k]!.text.replaceAll(',', '.')) != null)
      .toList();

  Future<void> _onAnalisar() async {
    final preenchidos = _preenchidos;
    if (preenchidos.length < 3) {
      setState(() => _error = 'Preencha pelo menos 3 parâmetros.');
      return;
    }
    final params = preenchidos.map((k) {
      final v = double.parse(_valores[k]!.text.replaceAll(',', '.'));
      return RelatorioParam(key: k, valor: v, resultado: ClassificationService.buildResultadoUnico(k, v));
    }).toList();

    final scorePct = ClassificationService.calcScore(params);
    final relatorio = Relatorio(
      id: StorageService.genId(),
      titulo: _tituloCtrl.text.isNotEmpty ? _tituloCtrl.text : 'Relatório',
      data: DateTime.now().toIso8601String(),
      cultura: _cultura,
      local: _localCtrl.text,
      params: params,
      scorePct: scorePct,
    );

    await StorageService.saveRelatorio(relatorio);
    await StorageService.saveHistoricoEntry(HistoricoEntry(
      id: StorageService.genId(),
      data: DateTime.now().toIso8601String(),
      tipo: HistoricoTipo.relatorio,
      titulo: '📋 ${relatorio.titulo} — score ${relatorio.scorePct}%',
      paramKey: ParamKey.ph,
      status: scorePct >= 80
          ? ClassificationStatus.otimo
          : (scorePct >= 60 ? ClassificationStatus.regular : ClassificationStatus.ruim),
      cor: ClassificationService.scoreLabel(scorePct).cor,
      relatorio: relatorio,
    ));

    setState(() {
      _relatorio = relatorio;
      _error = null;
      _etapa = _Etapa.resultado;
    });
  }

  void _onNovo() {
    setState(() {
      _relatorio = null;
      _etapa = _Etapa.meta;
      _error = null;
      _tituloCtrl.clear();
      _localCtrl.clear();
      _cultura = '';
      for (final c in _valores.values) {
        c.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_etapa == _Etapa.resultado && _relatorio != null) {
      return AppScaffold(
        title: '📋 Relatório',
        body: _RelatorioResultado(r: _relatorio!, onNovo: _onNovo),
      );
    }

    return AppScaffold(
      title: '📋 Relatório Completo',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_etapa == _Etapa.meta) ...[
            AppCard(
              title: '📋 Novo Relatório',
              desc: 'Preencha as informações antes de inserir os valores',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Título'),
                  _textInput(_tituloCtrl, 'Ex: Talhão Norte — Safra 2025'),
                  _fieldLabel('Local / Talhão'),
                  _textInput(_localCtrl, 'Ex: Fazenda São João, Talhão 3'),
                  _fieldLabel('Cultura'),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final c in kCulturas)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(c),
                              selected: _cultura == c,
                              onSelected: (_) => setState(() => _cultura = c),
                              selectedColor: AppColors.terraPale,
                              labelStyle: TextStyle(
                                  color: _cultura == c ? AppColors.terra : AppColors.textoSec,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13),
                              side: BorderSide(
                                  color: _cultura == c ? AppColors.terra : AppColors.borda, width: 1.5),
                              backgroundColor: AppColors.bg,
                            ),
                          ),
                      ],
                    ),
                  ),
                  PrimaryButton(
                      label: 'Próximo: Inserir Valores →',
                      onPressed: () => setState(() => _etapa = _Etapa.params)),
                ],
              ),
            ),
          ],
          if (_etapa == _Etapa.params) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📋 ${_tituloCtrl.text.isNotEmpty ? _tituloCtrl.text : "Relatório"}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.texto)),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                        '${_cultura.isNotEmpty ? _cultura : "—"} · ${_localCtrl.text.isNotEmpty ? _localCtrl.text : "—"} · ${_preenchidos.length} parâmetro(s) preenchido(s)',
                        style: const TextStyle(fontSize: 13, color: AppColors.textoSec)),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _etapa = _Etapa.meta),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                    child: const Text('← Editar informações',
                        style: TextStyle(fontSize: 13, color: AppColors.terra, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            for (final catEntry in kCategorias.entries)
              Builder(builder: (context) {
                final keys = kParamKeys.where((k) => kParams[k]!.categoria == catEntry.key).toList();
                if (keys.isEmpty) return const SizedBox.shrink();
                return AppCard(
                  borderColor: catEntry.value.cor.withValues(alpha: 0.33),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(color: catEntry.value.cor, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text('${catEntry.value.emoji} ${catEntry.value.label}',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: catEntry.value.cor,
                                  letterSpacing: 0.5)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      for (final k in keys) _paramInputRow(k, catEntry.value.cor),
                    ],
                  ),
                );
              }),
            PrimaryButton(
                label: '📋 Gerar Relatório (${_preenchidos.length} parâmetros)', onPressed: _onAnalisar),
            if (_error != null) ErrorBox(text: _error!),
          ],
        ],
      ),
    );
  }

  Widget _fieldLabel(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 14),
        child: Text(t,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textoSec,
                letterSpacing: 0.5)),
      );

  Widget _textInput(TextEditingController ctrl, String hint) => TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.bg,
          contentPadding: const EdgeInsets.all(13),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borda, width: 1.5)),
        ),
        onChanged: (_) => setState(() {}),
      );

  Widget _paramInputRow(ParamKey k, Color catCor) {
    final info = kParams[k]!;
    final ctrl = _valores[k]!;
    final hasVal = double.tryParse(ctrl.text.replaceAll(',', '.')) != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borda, width: 1))),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(info.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(info.nome,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.texto)),
                      Text('Ideal: ${_fmt(info.idealMin)}–${_fmt(info.idealMax)} ${info.unidade}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textoSec)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 72,
            child: TextField(
              controller: ctrl,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.texto),
              decoration: InputDecoration(
                hintText: '—',
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: hasVal ? catCor : AppColors.borda, width: 1.5),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(info.unidade,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: AppColors.textoSec)),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}

class _RelatorioResultado extends StatefulWidget {
  final Relatorio r;
  final VoidCallback onNovo;
  const _RelatorioResultado({required this.r, required this.onNovo});

  @override
  State<_RelatorioResultado> createState() => _RelatorioResultadoState();
}

class _RelatorioResultadoState extends State<_RelatorioResultado> {
  bool _gerandoPdf = false;

  Future<void> _onBaixarPdf() async {
    setState(() => _gerandoPdf = true);
    try {
      final bytes = await PdfService.buildRelatorioPdf(widget.r);
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'relatorio-cocos-${widget.r.id.substring(0, 8)}.pdf',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível gerar o PDF. Tente novamente.')),
        );
      }
    } finally {
      if (mounted) setState(() => _gerandoPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.r;
    final onNovo = widget.onNovo;
    final scoreInfo = ClassificationService.scoreLabel(r.scorePct);
    final summary = ClassificationService.summarizeRelatorio(r);
    final criticos = summary.criticos;
    final atencao = summary.atencao;
    final otimos = summary.otimos;
    final resumoEmoji = r.scorePct >= 80
        ? '✅'
        : r.scorePct >= 60
            ? '🟡'
            : r.scorePct >= 40
                ? '⚠️'
                : '🚨';
    final resumo = '$resumoEmoji ${summary.resumo}';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: scoreInfo.cor.withValues(alpha: 0.1),
            border: Border.all(color: scoreInfo.cor.withValues(alpha: 0.27), width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              ScoreRing(pct: r.scorePct, cor: scoreInfo.cor, size: 100),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.titulo,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.texto)),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(scoreInfo.label,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: scoreInfo.cor)),
                    ),
                    if (r.cultura.isNotEmpty)
                      Text('🌾 ${r.cultura}', style: const TextStyle(fontSize: 12, color: AppColors.textoSec)),
                    if (r.local.isNotEmpty)
                      Text('📍 ${r.local}', style: const TextStyle(fontSize: 12, color: AppColors.textoSec)),
                    Text('📊 ${r.params.length} parâmetros analisados',
                        style: const TextStyle(fontSize: 12, color: AppColors.textoSec)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borda, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(resumo, style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.texto)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: [
                if (otimos.isNotEmpty)
                  _pill('✅ ${otimos.length} ideal${otimos.length != 1 ? "is" : ""}', AppColors.folhaPale, AppColors.folha),
                if (atencao.isNotEmpty)
                  _pill('⚠️ ${atencao.length} atenção', AppColors.solPale, AppColors.sol),
                if (criticos.isNotEmpty)
                  _pill('🚨 ${criticos.length} crítico${criticos.length != 1 ? "s" : ""}', AppColors.alertaPale, AppColors.alerta),
              ]),
            ],
          ),
        ),
        for (final catEntry in kCategorias.entries)
          Builder(builder: (context) {
            final catParams = r.params.where((p) => kParams[p.key]!.categoria == catEntry.key).toList();
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
                  for (final p in catParams)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.only(bottom: 14),
                      decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.borda, width: 1))),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(p.resultado.emoji, style: const TextStyle(fontSize: 28)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(p.resultado.nome,
                                        style: const TextStyle(
                                            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.texto)),
                                    Text.rich(TextSpan(text: '${p.resultado.valor} ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: p.resultado.cor), children: [
                                      TextSpan(text: p.resultado.unidade, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400)),
                                    ])),
                                  ],
                                ),
                                GaugeBar(
                                    val: p.resultado.valor,
                                    min: p.resultado.min,
                                    max: p.resultado.max,
                                    ideal: p.resultado.ideal,
                                    cor: p.resultado.cor),
                                StatusBadge(label: p.resultado.label, cor: p.resultado.cor),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }),
        if (criticos.isNotEmpty || atencao.isNotEmpty)
          AppCard(
            title: '📋 Recomendações de Correção',
            child: Column(
              children: [
                for (final p in [...criticos, ...atencao])
                  RecBox(text: '${p.resultado.emoji} ${p.resultado.nome}: ${p.resultado.rec}', status: p.resultado.status),
              ],
            ),
          ),
        PrimaryButton(
          label: _gerandoPdf ? 'Gerando PDF...' : '📄 Baixar Relatório em PDF',
          onPressed: _gerandoPdf ? null : _onBaixarPdf,
          color: AppColors.agua,
        ),
        PrimaryButton(label: '📋 Novo Relatório', onPressed: onNovo, color: AppColors.terra),
        SecondaryButton(label: '← Voltar ao Início', onPressed: onNovo),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _pill(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
      );
}
