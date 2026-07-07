import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/params.dart';
import '../models/classification.dart';
import '../models/param_config.dart';
import '../models/resultado.dart';

/// Motor de classificação e estatísticas do COCOS. Roda 100% no dispositivo,
/// sem depender de servidor, para uso a campo mesmo sem internet.
class ClassificationService {
  ClassificationService._();

  static Classification classify(double val, List<double> ideal) {
    final lo = ideal[0];
    final hi = ideal[1];
    if (val >= lo && val <= hi) {
      return const Classification(
          label: 'Bom / Ideal', status: ClassificationStatus.otimo, cor: AppColors.otimo);
    }
    if (val < lo * 0.5) {
      return const Classification(
          label: 'Muito baixo', status: ClassificationStatus.muitoRuim, cor: AppColors.muitoRuim);
    }
    if (val < lo * 0.75) {
      return const Classification(
          label: 'Baixo', status: ClassificationStatus.ruim, cor: AppColors.ruim);
    }
    if (val < lo) {
      return const Classification(
          label: 'Abaixo', status: ClassificationStatus.atencao, cor: AppColors.regular);
    }
    if (val > hi * 2.0) {
      return const Classification(
          label: 'Muito alto', status: ClassificationStatus.muitoRuim, cor: AppColors.muitoRuim);
    }
    if (val > hi * 1.5) {
      return const Classification(
          label: 'Alto', status: ClassificationStatus.ruim, cor: AppColors.ruim);
    }
    return const Classification(
        label: 'Acima', status: ClassificationStatus.atencao, cor: AppColors.regular);
  }

  static String _recomendacao(ParamConfig cfg, double valor, ClassificationStatus status) {
    final lo = cfg.idealMin;
    final hi = cfg.idealMax;
    final inIdeal = valor >= lo && valor <= hi;
    if (inIdeal) {
      return '✅ ${cfg.nome} na faixa ideal para a maioria das culturas. Continue com o manejo atual.';
    }
    if (valor < lo) {
      return '⬇️ Valor abaixo do ideal. ${cfg.recomendacoes['muito_baixo'] ?? cfg.recomendacoes['baixo'] ?? ''}';
    }
    return '⬆️ Valor acima do ideal. ${cfg.recomendacoes['muito_alto'] ?? cfg.recomendacoes['alto'] ?? ''}';
  }

  static ResultadoUnico buildResultadoUnico(ParamKey key, double v) {
    final cfg = kParams[key]!;
    final clf = classify(v, cfg.ideal);
    return ResultadoUnico(
      key: key,
      valor: v,
      nome: cfg.nome,
      emoji: cfg.emoji,
      unidade: cfg.unidade,
      ideal: cfg.ideal,
      min: cfg.min,
      max: cfg.max,
      cor: clf.cor,
      label: clf.label,
      status: clf.status,
      rec: _recomendacao(cfg, v, clf.status),
      dica: cfg.hint,
    );
  }

  static ResultadoSerie calcSerie(ParamKey key, List<double> nums) {
    final cfg = kParams[key]!;
    final n = nums.length;
    final mean = nums.reduce((a, b) => a + b) / n;
    final variancia =
        nums.map((v) => math.pow(v - mean, 2)).reduce((a, b) => a + b) / math.max(n - 1, 1);
    final std = math.sqrt(variancia);
    final sorted = [...nums]..sort();
    final median = sorted[n ~/ 2];
    final cv = mean != 0 ? (std / mean) * 100 : 0.0;
    final trend = nums.last > nums.first
        ? 'Subindo'
        : nums.last < nums.first
            ? 'Caindo'
            : 'Estável';
    final clf = classify(mean, cfg.ideal);
    final isOk =
        clf.status == ClassificationStatus.otimo || clf.status == ClassificationStatus.bom;

    return ResultadoSerie(
      key: key,
      nome: cfg.nome,
      emoji: cfg.emoji,
      unidade: cfg.unidade,
      min: cfg.min,
      max: cfg.max,
      ideal: cfg.ideal,
      n: n,
      mean: double.parse(mean.toStringAsFixed(3)),
      std: double.parse(std.toStringAsFixed(3)),
      median: double.parse(median.toStringAsFixed(2)),
      minV: nums.reduce(math.min),
      maxV: nums.reduce(math.max),
      cv: double.parse(cv.toStringAsFixed(1)),
      trend: trend,
      cor: clf.cor,
      label: clf.label,
      status: clf.status,
      valores: nums,
      altaVar: cv > 30,
      rec: isOk
          ? '✅ Média na faixa ideal! Continue com o manejo atual.'
          : '⚠️ Média fora do ideal. Verifique o manejo e consulte recomendações técnicas.',
    );
  }

  static int calcScore(List<RelatorioParam> params) {
    if (params.isEmpty) return 0;
    final total = params.fold<int>(0, (acc, p) => acc + p.resultado.status.score);
    return (total / params.length).round();
  }

  static ({String label, Color cor}) scoreLabel(int pct) {
    if (pct >= 80) return (label: 'Solo Saudável', cor: AppColors.otimo);
    if (pct >= 60) return (label: 'Solo Razoável', cor: AppColors.regular);
    if (pct >= 40) return (label: 'Necessita Atenção', cor: AppColors.atencao);
    return (label: 'Solo Degradado', cor: AppColors.muitoRuim);
  }

  /// Agrupa os parâmetros de um relatório por severidade e gera o texto-resumo
  /// (sem emoji, quem exibe decide se prefixa um ícone ou não).
  static ({
    String resumo,
    List<RelatorioParam> criticos,
    List<RelatorioParam> atencao,
    List<RelatorioParam> otimos,
  }) summarizeRelatorio(Relatorio r) {
    final criticos = r.params
        .where((p) =>
            p.resultado.status == ClassificationStatus.muitoRuim ||
            p.resultado.status == ClassificationStatus.ruim)
        .toList();
    final atencao =
        r.params.where((p) => p.resultado.status == ClassificationStatus.atencao).toList();
    final otimos = r.params
        .where((p) =>
            p.resultado.status == ClassificationStatus.otimo ||
            p.resultado.status == ClassificationStatus.bom)
        .toList();

    final String resumo;
    if (r.scorePct >= 80) {
      resumo = 'Solo em excelente condição. ${otimos.length} parâmetro(s) na faixa ideal.';
    } else if (r.scorePct >= 60) {
      resumo =
          'Solo em condição razoável. ${criticos.length + atencao.length} parâmetro(s) precisam de atenção.';
    } else if (r.scorePct >= 40) {
      resumo = 'Solo necessita correção. ${criticos.length} parâmetro(s) crítico(s) detectado(s).';
    } else {
      resumo =
          'Solo degradado. Corrija urgente: ${criticos.take(3).map((p) => p.resultado.nome).join(", ")}.';
    }

    return (resumo: resumo, criticos: criticos, atencao: atencao, otimos: otimos);
  }
}
