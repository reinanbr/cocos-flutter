/// Parâmetros de solo que o COCOS analisa, todos mensuráveis a campo,
/// na roça, com instrumentos simples (medidor de pH, sonda de umidade/
/// temperatura, condutivímetro de bolso ou o teste de textura pelo tato).
enum ParamKey { ph, condutividade, salinidade, umidade, temperatura, textura }

enum Categoria { quimico, fisico }

class ParamConfig {
  final ParamKey key;
  final String nome;
  final String emoji;
  final String unidade;
  final double min;
  final double max;
  final List<double> ideal; // [lo, hi]
  final double step;
  final String hint;
  final Categoria categoria;

  /// Recomendação de manejo por faixa de classificação.
  final Map<String, String> recomendacoes;

  const ParamConfig({
    required this.key,
    required this.nome,
    required this.emoji,
    required this.unidade,
    required this.min,
    required this.max,
    required this.ideal,
    required this.step,
    required this.hint,
    required this.categoria,
    required this.recomendacoes,
  });

  double get idealMin => ideal[0];
  double get idealMax => ideal[1];
}
