import 'package:flutter/material.dart';
import 'classification.dart';
import 'param_config.dart';

class ResultadoUnico {
  final ParamKey key;
  final double valor;
  final String nome;
  final String emoji;
  final String unidade;
  final List<double> ideal;
  final double min;
  final double max;
  final Color cor;
  final String label;
  final ClassificationStatus status;
  final String rec;
  final String? dica;

  const ResultadoUnico({
    required this.key,
    required this.valor,
    required this.nome,
    required this.emoji,
    required this.unidade,
    required this.ideal,
    required this.min,
    required this.max,
    required this.cor,
    required this.label,
    required this.status,
    required this.rec,
    this.dica,
  });

  Map<String, dynamic> toJson() => {
        'key': key.name,
        'valor': valor,
        'nome': nome,
        'emoji': emoji,
        'unidade': unidade,
        'ideal': ideal,
        'min': min,
        'max': max,
        'cor': cor.toARGB32(),
        'label': label,
        'status': status.name,
        'rec': rec,
        'dica': dica,
      };

  factory ResultadoUnico.fromJson(Map<String, dynamic> j) => ResultadoUnico(
        key: ParamKey.values.byName(j['key'] as String),
        valor: (j['valor'] as num).toDouble(),
        nome: j['nome'] as String,
        emoji: j['emoji'] as String,
        unidade: j['unidade'] as String,
        ideal: (j['ideal'] as List).map((e) => (e as num).toDouble()).toList(),
        min: (j['min'] as num).toDouble(),
        max: (j['max'] as num).toDouble(),
        cor: Color(j['cor'] as int),
        label: j['label'] as String,
        status: ClassificationStatus.values.byName(j['status'] as String),
        rec: j['rec'] as String,
        dica: j['dica'] as String?,
      );
}

class ResultadoSerie {
  final ParamKey key;
  final String nome;
  final String emoji;
  final String unidade;
  final double min;
  final double max;
  final List<double> ideal;
  final int n;
  final double mean;
  final double std;
  final double median;
  final double minV;
  final double maxV;
  final double cv;
  final String trend; // Subindo | Caindo | Estável
  final Color cor;
  final String label;
  final ClassificationStatus status;
  final List<double> valores;
  final bool altaVar;
  final String rec;

  const ResultadoSerie({
    required this.key,
    required this.nome,
    required this.emoji,
    required this.unidade,
    required this.min,
    required this.max,
    required this.ideal,
    required this.n,
    required this.mean,
    required this.std,
    required this.median,
    required this.minV,
    required this.maxV,
    required this.cv,
    required this.trend,
    required this.cor,
    required this.label,
    required this.status,
    required this.valores,
    required this.altaVar,
    required this.rec,
  });
}

class RelatorioParam {
  final ParamKey key;
  final double valor;
  final ResultadoUnico resultado;

  const RelatorioParam({required this.key, required this.valor, required this.resultado});

  Map<String, dynamic> toJson() => {
        'key': key.name,
        'valor': valor,
        'resultado': resultado.toJson(),
      };

  factory RelatorioParam.fromJson(Map<String, dynamic> j) => RelatorioParam(
        key: ParamKey.values.byName(j['key'] as String),
        valor: (j['valor'] as num).toDouble(),
        resultado: ResultadoUnico.fromJson(j['resultado'] as Map<String, dynamic>),
      );
}

class Relatorio {
  final String id;
  final String titulo;
  final String data; // ISO string
  final String cultura;
  final String local;
  final List<RelatorioParam> params;
  final int scorePct;

  const Relatorio({
    required this.id,
    required this.titulo,
    required this.data,
    required this.cultura,
    required this.local,
    required this.params,
    required this.scorePct,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'data': data,
        'cultura': cultura,
        'local': local,
        'params': params.map((p) => p.toJson()).toList(),
        'scorePct': scorePct,
      };

  factory Relatorio.fromJson(Map<String, dynamic> j) => Relatorio(
        id: j['id'] as String,
        titulo: j['titulo'] as String,
        data: j['data'] as String,
        cultura: j['cultura'] as String,
        local: j['local'] as String,
        params: (j['params'] as List)
            .map((p) => RelatorioParam.fromJson(p as Map<String, dynamic>))
            .toList(),
        scorePct: j['scorePct'] as int,
      );
}
