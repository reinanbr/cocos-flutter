import 'dart:typed_data';

import 'package:flutter/material.dart' show Color;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../constants/params.dart';
import '../models/resultado.dart';
import 'classification_service.dart';

const _terra = PdfColor.fromInt(0xFF6B4226);
const _textoSec = PdfColor.fromInt(0xFF6B5344);
const _borda = PdfColor.fromInt(0xFFE8D9CE);
const _trackBg = PdfColor.fromInt(0xFFE8D9CE);

PdfColor _pdfColor(Color c) => PdfColor.fromInt(c.toARGB32());

/// Monta o PDF completo de um relatório de solo do COCOS: cabeçalho, score,
/// resumo, tabela de parâmetros com barra de posição na escala e as
/// recomendações de correção — o mesmo conteúdo mostrado na tela, pronto
/// para salvar, imprimir ou compartilhar.
class PdfService {
  PdfService._();

  /// Fontes com cobertura Unicode completa (acentos, travessão, meia-risca) —
  /// as fontes padrão de PDF (Helvetica) não têm glifo para vários desses
  /// caracteres e derrubam a renderização quando encontram um.
  static Future<pw.ThemeData> _loadTheme() async {
    final regularBytes = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final boldBytes = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    return pw.ThemeData.withFont(
      base: pw.Font.ttf(regularBytes),
      bold: pw.Font.ttf(boldBytes),
    );
  }

  static Future<Uint8List> buildRelatorioPdf(Relatorio r) async {
    final doc = pw.Document(theme: await _loadTheme());
    final summary = ClassificationService.summarizeRelatorio(r);
    final scoreInfo = ClassificationService.scoreLabel(r.scorePct);
    final dataFmt = DateFormat('dd/MM/yyyy \'às\' HH:mm').format(DateTime.parse(r.data).toLocal());

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(32, 28, 32, 28),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('COCOS — Relatório de Análise de Solo',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _terra)),
                pw.Text('Página ${context.pageNumber}/${context.pagesCount}',
                    style: const pw.TextStyle(fontSize: 9, color: _textoSec)),
              ],
            ),
            pw.Divider(color: _borda, thickness: 1),
          ],
        ),
        footer: (context) => pw.Column(
          children: [
            pw.Divider(color: _borda, thickness: 0.5),
            pw.Text(
              'Gerado pelo app COCOS em $dataFmt · Este relatório é uma ferramenta de apoio ao manejo e não '
              'substitui a análise laboratorial completa do solo.',
              style: const pw.TextStyle(fontSize: 7.5, color: _textoSec),
            ),
          ],
        ),
        build: (context) => [
          pw.SizedBox(height: 8),
          pw.Text(r.titulo, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Wrap(spacing: 16, children: [
            if (r.cultura.isNotEmpty) pw.Text('Cultura: ${r.cultura}', style: const pw.TextStyle(fontSize: 10, color: _textoSec)),
            if (r.local.isNotEmpty) pw.Text('Local: ${r.local}', style: const pw.TextStyle(fontSize: 10, color: _textoSec)),
            pw.Text('Data: $dataFmt', style: const pw.TextStyle(fontSize: 10, color: _textoSec)),
            pw.Text('${r.params.length} parâmetros analisados', style: const pw.TextStyle(fontSize: 10, color: _textoSec)),
          ]),
          pw.SizedBox(height: 16),
          _scoreBox(r, scoreInfo.label, _pdfColor(scoreInfo.cor), summary.resumo),
          pw.SizedBox(height: 8),
          pw.Wrap(spacing: 8, runSpacing: 8, children: [
            if (summary.otimos.isNotEmpty) _pill('${summary.otimos.length} na faixa ideal', const PdfColor.fromInt(0xFFE8F4E8), const PdfColor.fromInt(0xFF2D6A2D)),
            if (summary.atencao.isNotEmpty) _pill('${summary.atencao.length} em atenção', const PdfColor.fromInt(0xFFFFF3DC), const PdfColor.fromInt(0xFFD4891A)),
            if (summary.criticos.isNotEmpty) _pill('${summary.criticos.length} crítico(s)', const PdfColor.fromInt(0xFFFFF5F5), const PdfColor.fromInt(0xFFC53030)),
          ]),
          pw.SizedBox(height: 20),
          for (final catEntry in kCategorias.entries) ...() {
            final catParams = r.params.where((p) => kParams[p.key]!.categoria == catEntry.key).toList();
            if (catParams.isEmpty) return <pw.Widget>[];
            return <pw.Widget>[
              pw.Text(catEntry.value.label.toUpperCase(),
                  style: pw.TextStyle(
                      fontSize: 11, fontWeight: pw.FontWeight.bold, color: _pdfColor(catEntry.value.cor), letterSpacing: 0.5)),
              pw.SizedBox(height: 8),
              for (final p in catParams) _paramRow(p),
              pw.SizedBox(height: 12),
            ];
          }(),
          if (summary.criticos.isNotEmpty || summary.atencao.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text('RECOMENDAÇÕES DE CORREÇÃO',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _terra, letterSpacing: 0.5)),
            pw.SizedBox(height: 8),
            for (final p in [...summary.criticos, ...summary.atencao]) _recBox(p),
          ],
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _scoreBox(Relatorio r, String label, PdfColor cor, String resumo) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: cor.withAlpha(0.08),
        border: pw.Border.all(color: cor, width: 1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(
            width: 56,
            height: 56,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, border: pw.Border.all(color: cor, width: 3)),
            child: pw.Text('${r.scorePct}%', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: cor)),
          ),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(label, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: cor)),
                pw.SizedBox(height: 3),
                pw.Text(resumo, style: const pw.TextStyle(fontSize: 9.5, color: PdfColor.fromInt(0xFF2C1A0E))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _pill(String text, PdfColor bg, PdfColor fg) => pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: pw.BoxDecoration(color: bg, borderRadius: pw.BorderRadius.circular(10)),
        child: pw.Text(text, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: fg)),
      );

  static pw.Widget _paramRow(RelatorioParam p) {
    final res = p.resultado;
    final cor = _pdfColor(res.cor);
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _borda, width: 0.75))),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(res.nome, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.Row(children: [
                pw.Text('${res.valor} ${res.unidade}   ', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: cor)),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: pw.BoxDecoration(color: cor.withAlpha(0.15), borderRadius: pw.BorderRadius.circular(8)),
                  child: pw.Text(res.label, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: cor)),
                ),
              ]),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Text('Faixa ideal: ${_fmt(res.ideal[0])}–${_fmt(res.ideal[1])} ${res.unidade}',
              style: const pw.TextStyle(fontSize: 8.5, color: _textoSec)),
          pw.SizedBox(height: 5),
          _gauge(res.valor, res.min, res.max, res.ideal, cor),
        ],
      ),
    );
  }

  static pw.Widget _gauge(double val, double min, double max, List<double> ideal, PdfColor cor) {
    const width = 460.0;
    const height = 8.0;
    final range = (max - min) == 0 ? 1 : (max - min);
    final fillW = ((val - min) / range * width).clamp(4, width).toDouble();
    final idealLeft = ((ideal[0] - min) / range * width).clamp(0, width).toDouble();
    final idealW = ((ideal[1] - ideal[0]) / range * width).clamp(0, width - idealLeft).toDouble();

    return pw.SizedBox(
      width: width,
      height: height,
      child: pw.Stack(children: [
        pw.Container(width: width, height: height, decoration: pw.BoxDecoration(color: _trackBg, borderRadius: pw.BorderRadius.circular(4))),
        pw.Positioned(
          left: idealLeft,
          child: pw.Container(width: idealW, height: height, color: PdfColor.fromInt(0x332D6A2D)),
        ),
        pw.Positioned(
          left: 0,
          child: pw.Container(width: fillW, height: height, decoration: pw.BoxDecoration(color: cor, borderRadius: pw.BorderRadius.circular(4))),
        ),
      ]),
    );
  }

  static pw.Widget _recBox(RelatorioParam p) {
    final res = p.resultado;
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(color: const PdfColor.fromInt(0xFFFAF6F1), borderRadius: pw.BorderRadius.circular(6)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(res.nome, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: _pdfColor(res.cor))),
          pw.SizedBox(height: 3),
          pw.Text(_stripLeadingIcon(res.rec), style: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF2C1A0E))),
        ],
      ),
    );
  }

  static String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  /// Remove o emoji/seta que prefixa os textos de recomendação — as fontes
  /// padrão de PDF não têm glifos coloridos de emoji.
  static String _stripLeadingIcon(String text) {
    final idx = text.indexOf(' ');
    if (idx <= 0) return text;
    final first = text.substring(0, idx);
    final isIcon = first.runes.every((r) => r > 0x2100);
    return isIcon ? text.substring(idx + 1) : text;
  }
}
