import 'package:flutter_test/flutter_test.dart';
import 'package:cocos_flutter/models/param_config.dart';
import 'package:cocos_flutter/models/resultado.dart';
import 'package:cocos_flutter/services/classification_service.dart';
import 'package:cocos_flutter/services/pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('buildRelatorioPdf gera bytes de PDF válidos para todos os status', () async {
    // Um valor de cada faixa (ideal, abaixo, muito acima) para forçar a
    // renderização das recomendações e garantir que nenhum caractere
    // especial (travessão, meia-risca, acentos) derruba a geração do PDF.
    final params = <RelatorioParam>[
      RelatorioParam(
        key: ParamKey.ph,
        valor: 6.3,
        resultado: ClassificationService.buildResultadoUnico(ParamKey.ph, 6.3),
      ),
      RelatorioParam(
        key: ParamKey.condutividade,
        valor: 0.01,
        resultado: ClassificationService.buildResultadoUnico(ParamKey.condutividade, 0.01),
      ),
      RelatorioParam(
        key: ParamKey.textura,
        valor: 95,
        resultado: ClassificationService.buildResultadoUnico(ParamKey.textura, 95),
      ),
    ];
    final relatorio = Relatorio(
      id: 'teste-1234',
      titulo: 'Relatório de Teste — Talhão A',
      data: DateTime.now().toIso8601String(),
      cultura: 'Soja',
      local: 'Fazenda Teste',
      params: params,
      scorePct: ClassificationService.calcScore(params),
    );

    final bytes = await PdfService.buildRelatorioPdf(relatorio);

    expect(bytes.length, greaterThan(500));
    // Todo PDF válido começa com a assinatura "%PDF-".
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
