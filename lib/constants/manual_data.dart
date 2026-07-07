import '../models/param_config.dart';

class ManualParam {
  final ParamKey key;
  final List<String> materiais;
  final List<String> passos;
  final String dica;

  const ManualParam({
    required this.key,
    required this.materiais,
    required this.passos,
    required this.dica,
  });
}

/// Passo a passo de coleta a campo para cada parâmetro. Pensado para quem
/// está na roça, sem acesso a laboratório, usando instrumentos simples e baratos.
final List<ManualParam> kManual = [
  ManualParam(
    key: ParamKey.ph,
    materiais: [
      'Medidor de pH de solo digital (de bolso) ou fitas indicadoras de pH',
      'Água destilada ou de chuva (sem cloro)',
      'Pá pequena ou enxadeco',
      'Copo ou recipiente limpo',
    ],
    passos: [
      'Escolha de 5 a 10 pontos representativos do talhão, andando em zigue-zague.',
      'Retire a palha/vegetação da superfície e cave até 15–20 cm de profundidade.',
      'Recolha uma amostra de terra e retire pedras, raízes e restos vegetais.',
      'Umedeça a terra com água destilada até formar uma pasta úmida (se o medidor tiver sonda própria para solo, pode inserir direto no solo úmido, sem precisar da pasta).',
      'Insira o eletrodo do medidor na pasta ou no solo úmido e aguarde 30–60 segundos até o valor estabilizar.',
      'Anote o valor de cada ponto. Se possível, lance todos os valores na tela "Série de Valores" para ver a média e a variação do talhão.',
    ],
    dica: 'Evite medir logo após calagem ou adubação, espere de 30 a 60 dias para o solo estabilizar. '
        'O solo não deve estar nem seco (rachado) nem encharcado.',
  ),
  ManualParam(
    key: ParamKey.condutividade,
    materiais: [
      'Condutivímetro de bolso (medidor de CE/EC)',
      'Água destilada',
      'Recipiente limpo (copo ou pote)',
      'Colher ou bastão para misturar',
    ],
    passos: [
      'Colete uma amostra de solo (15–20 cm de profundidade) livre de pedras e raízes.',
      'Misture solo e água destilada na proporção 1:1 ou 1:2 (uma parte de solo para uma ou duas partes de água).',
      'Agite bem por 1 minuto e deixe decantar por 30 minutos.',
      'Mergulhe a sonda do condutivímetro na água clara que ficou por cima (sobrenadante), sem tocar o sedimento do fundo.',
      'Aguarde a leitura estabilizar e anote o valor em dS/m.',
    ],
    dica: 'Sempre use a mesma proporção solo:água em todas as medições para poder comparar valores entre coletas.',
  ),
  ManualParam(
    key: ParamKey.salinidade,
    materiais: [
      'Condutivímetro de bolso com função TDS/salinidade (o mesmo aparelho da Condutividade)',
      'Água destilada',
      'Recipiente limpo',
    ],
    passos: [
      'Repita o mesmo preparo da Condutividade Elétrica: misture solo e água destilada (1:1 ou 1:2), agite e deixe decantar 30 minutos.',
      'Troque o medidor para o modo salinidade/TDS (g/L ou ppm): a maioria dos condutivímetros de bolso tem os dois modos.',
      'Mergulhe a sonda no sobrenadante e aguarde a leitura estabilizar.',
      'Anote o valor. Se o aparelho mostrar em ppm, divida por 1000 para converter para g/L.',
    ],
    dica: 'Meça CE e salinidade na mesma amostra, uma logo após a outra, para economizar tempo e amostras.',
  ),
  ManualParam(
    key: ParamKey.umidade,
    materiais: [
      'Higrômetro / sonda de umidade de solo (medidor de bolso com haste)',
    ],
    passos: [
      'Escolha o ponto de medição longe de pedras grandes ou raízes superficiais.',
      'Insira a haste do medidor a 10–15 cm de profundidade, com uma leve pressão firme e constante.',
      'Aguarde alguns segundos até o ponteiro ou mostrador estabilizar.',
      'Anote o valor em % e repita em vários pontos do talhão.',
    ],
    dica: 'Evite medir logo após chuva ou irrigação forte, espere algumas horas para a leitura refletir a '
        'umidade real de manejo, e não um pico passageiro.',
  ),
  ManualParam(
    key: ParamKey.temperatura,
    materiais: [
      'Termômetro de solo tipo espeto',
    ],
    passos: [
      'Insira o termômetro no solo a 5–10 cm de profundidade.',
      'Faça a medição à sombra da própria planta ou cobertura, evitando sol direto na haste do aparelho.',
      'Aguarde 1–2 minutos até a leitura estabilizar.',
      'Anote o valor em °C. Sempre que possível, meça no mesmo horário do dia para poder comparar entre datas diferentes.',
    ],
    dica: 'A temperatura do solo varia bastante ao longo do dia, meça sempre por volta do mesmo horário '
        '(ex: sempre às 9h) para acompanhar a evolução real.',
  ),
  ManualParam(
    key: ParamKey.textura,
    materiais: [
      'Nenhum instrumento, apenas as mãos (teste manual do tato)',
      'Um pouco de água para umedecer o solo',
    ],
    passos: [
      'Retire uma amostra de solo do subsolo (15–20 cm), sem pedras nem raízes.',
      'Umedeça aos poucos até formar uma "massinha" moldável, que não grude excessivamente na mão.',
      'Tente formar uma bolinha com a massa. Se ela esfarelar e não formar bolinha, o solo é arenoso (baixo teor de argila, ~5–15%).',
      'Se formar bolinha, tente esticá-la entre o polegar e o indicador formando uma fita (fita de solo).',
      'Fita curta que quebra com menos de 2,5 cm → solo arenoso / franco-arenoso (~15–25% de argila).',
      'Fita de 2,5 a 5 cm antes de quebrar → solo de textura média / franco (~25–40% de argila).',
      'Fita com mais de 5 cm, brilhante e bem plástica → solo argiloso (~40–60% ou mais de argila).',
      'Anote a estimativa percentual de argila correspondente à faixa observada.',
    ],
    dica: 'É um teste de estimativa, não substitui uma análise granulométrica de laboratório, mas é '
        'suficiente para orientar decisões de manejo no dia a dia.',
  ),
];
