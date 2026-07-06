import 'package:flutter/material.dart';
import 'classification.dart';
import 'param_config.dart';
import 'resultado.dart';

enum HistoricoTipo { unico, serie, relatorio }

class HistoricoEntry {
  final String id;
  final String data; // ISO string
  final HistoricoTipo tipo;
  final String titulo;
  final ParamKey paramKey;
  final double? valor; // unico
  final double? media; // serie
  final ClassificationStatus status;
  final Color cor;
  final Relatorio? relatorio;

  const HistoricoEntry({
    required this.id,
    required this.data,
    required this.tipo,
    required this.titulo,
    required this.paramKey,
    this.valor,
    this.media,
    required this.status,
    required this.cor,
    this.relatorio,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'data': data,
        'tipo': tipo.name,
        'titulo': titulo,
        'paramKey': paramKey.name,
        'valor': valor,
        'media': media,
        'status': status.name,
        'cor': cor.toARGB32(),
        'relatorio': relatorio?.toJson(),
      };

  factory HistoricoEntry.fromJson(Map<String, dynamic> j) => HistoricoEntry(
        id: j['id'] as String,
        data: j['data'] as String,
        tipo: HistoricoTipo.values.byName(j['tipo'] as String),
        titulo: j['titulo'] as String,
        paramKey: ParamKey.values.byName(j['paramKey'] as String),
        valor: (j['valor'] as num?)?.toDouble(),
        media: (j['media'] as num?)?.toDouble(),
        status: ClassificationStatus.values.byName(j['status'] as String),
        cor: Color(j['cor'] as int),
        relatorio: j['relatorio'] != null
            ? Relatorio.fromJson(j['relatorio'] as Map<String, dynamic>)
            : null,
      );
}
