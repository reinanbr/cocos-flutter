import 'package:flutter/material.dart';
import '../models/param_config.dart';
import 'colors.dart';

/// Os 6 parâmetros de solo que dá para medir na roça, sem laboratório:
/// pH (medidor de bolso), condutividade e salinidade (condutivímetro),
/// umidade e temperatura (sonda de solo) e textura (teste manual do tato).
final Map<ParamKey, ParamConfig> kParams = {
  ParamKey.ph: const ParamConfig(
    key: ParamKey.ph,
    nome: 'pH do Solo',
    emoji: '🧪',
    unidade: 'pH',
    min: 0,
    max: 14,
    ideal: [6.0, 6.5],
    step: 0.1,
    categoria: Categoria.quimico,
    hint: 'pH 7 = neutro. Abaixo de 7 = ácido. Acima de 7 = alcalino. '
        'Meça com um medidor de pH de bolso ou fitas indicadoras direto no solo úmido.',
    recomendacoes: {
      'muito_baixo':
          'Solo fortemente ácido. Aplique calcário dolomítico (2 a 4 t/ha, a depender da CTC e do teor de alumínio trocável) '
          'de 60 a 90 dias antes do plantio, incorporando nos primeiros 20 cm do solo. O excesso de acidez libera alumínio '
          'tóxico às raízes e bloqueia a absorção de fósforo, cálcio e magnésio — reavalie o pH após a calagem e, se possível, '
          'confirme a dose exata com uma análise de solo em laboratório (índice SMP ou saturação por bases).',
      'baixo':
          'Solo levemente ácido. Faça calagem de manutenção com calcário calcítico ou dolomítico (1 a 2 t/ha), preferindo '
          'dolomítico se a análise indicar Mg baixo. Aplique com 60 dias de antecedência ao plantio para dar tempo de reação '
          'no solo e monitore a evolução do pH a cada safra.',
      'ideal':
          'pH na faixa ideal (6,0–6,5), ponto de maior disponibilidade simultânea de N, P, K, Ca, Mg e micronutrientes para a '
          'maioria das culturas. Mantenha o manejo atual e repita a calagem de manutenção apenas quando a próxima medição '
          'indicar queda do pH.',
      'alto':
          'Solo alcalino. Isso reduz a disponibilidade de ferro, manganês, zinco e boro. Aplique enxofre elementar ou gesso '
          'agrícola em doses fracionadas e reavalie em 3 a 6 meses, já que a acidificação é um processo gradual. Evite nova '
          'calagem até o pH voltar a cair.',
      'muito_alto':
          'pH muito alto (solo fortemente alcalino/sódico). Risco elevado de deficiência de ferro, manganês e zinco, com '
          'clorose visível nas folhas novas. Priorize enxofre elementar ou sulfato de alumínio para correção gradual e '
          'busque orientação de um agrônomo — solos sódicos podem exigir gessagem associada à lixiviação.',
    },
  ),
  ParamKey.condutividade: const ParamConfig(
    key: ParamKey.condutividade,
    nome: 'Condutividade Elétrica',
    emoji: '⚡',
    unidade: 'dS/m',
    min: 0,
    max: 8,
    ideal: [0.1, 1.5],
    step: 0.05,
    categoria: Categoria.quimico,
    hint: 'Indica sais solúveis no solo. Meça com um condutivímetro de bolso '
        'encostando a sonda no solo úmido. Alta CE causa estresse hídrico.',
    recomendacoes: {
      'muito_baixo':
          'CE muito baixa. Costuma indicar solo com pouquíssimos sais dissolvidos e baixa reserva de nutrientes '
          'minerais disponíveis. Reforce a adubação (orgânica e mineral) de forma parcelada e reavalie a CE cerca de '
          '30 dias depois para acompanhar a resposta.',
      'baixo':
          'CE abaixo do ideal — solo com baixa concentração de sais solúveis, o que geralmente acompanha baixa '
          'fertilidade. Aumente gradualmente a adubação de manutenção e evite depender só de fontes de baixa '
          'solubilidade.',
      'ideal':
          'Condutividade elétrica dentro da faixa segura (0,1–1,5 dS/m): há sais suficientes disponíveis às plantas '
          'sem risco de estresse osmótico. Mantenha o parcelamento atual da adubação.',
      'alto':
          'CE elevada — sinal de acúmulo de sais no perfil, muitas vezes por excesso de adubação química ou água de '
          'irrigação salina. Reduza fontes de fertilizante muito solúveis (como cloreto de potássio em excesso), '
          'melhore a drenagem da área e, se possível, faça uma lâmina de lixiviação com água de boa qualidade.',
      'muito_alto':
          'Solo salino (CE muito alta). Risco real de queima de raízes e dificuldade das plantas em absorver água '
          'mesmo com o solo úmido (estresse osmótico). Aplique gesso agrícola para deslocar sódio e sais do perfil, '
          'aumente a lâmina de irrigação para lixiviação e garanta um sistema de drenagem eficiente antes de plantar '
          'novamente.',
    },
  ),
  ParamKey.salinidade: const ParamConfig(
    key: ParamKey.salinidade,
    nome: 'Salinidade',
    emoji: '🧂',
    unidade: 'g/L',
    min: 0,
    max: 10,
    ideal: [0.0, 0.5],
    step: 0.05,
    categoria: Categoria.quimico,
    hint: 'Concentração de sais. Pode ser estimada com o mesmo condutivímetro '
        'de bolso (função TDS/salinidade). Valores altos prejudicam absorção de água.',
    recomendacoes: {
      'muito_baixo': 'Salinidade muito baixa — solo adequado, sem risco de sais para as plantas. Nenhuma correção necessária.',
      'baixo': 'Salinidade baixa — solo adequado. Mantenha o monitoramento de rotina, sobretudo se a irrigação usar água '
          'de poço ou reservatório com potencial salino.',
      'ideal': 'Salinidade dentro da faixa segura (até 0,5 g/L) para a maioria das culturas, inclusive as mais sensíveis '
          'a sais. Continue o manejo atual de adubação e irrigação.',
      'alto':
          'Salinidade elevada. Reduza fertilizantes de alto índice salino (como cloreto de potássio e ureia em excesso), '
          'prefira parcelar as aplicações em doses menores e mais frequentes, e melhore a drenagem para evitar acúmulo '
          'de sais na zona radicular.',
      'muito_alto':
          'Solo hipersalino — risco severo de plasmólise (perda de água) nas raízes mesmo com umidade aparente no solo. '
          'Segundo a FAO/UNESCO (1988), esse nível compromete a maioria das culturas agrícolas. Faça lixiviação urgente '
          'com lâmina de água de boa qualidade, associe gesso agrícola para deslocar sódio e evite novas aplicações de '
          'fertilizantes salinos até a próxima medição confirmar a queda da salinidade.',
    },
  ),
  ParamKey.umidade: const ParamConfig(
    key: ParamKey.umidade,
    nome: 'Umidade',
    emoji: '💧',
    unidade: '%',
    min: 0,
    max: 100,
    ideal: [40, 60],
    step: 1,
    categoria: Categoria.fisico,
    hint: 'Porcentagem de água no solo. Meça com um higrômetro/sonda de '
        'umidade de solo, cravada a 10–15 cm de profundidade.',
    recomendacoes: {
      'muito_baixo': 'Solo muito seco. Irrigação urgente necessária — plantas já podem estar sob estresse hídrico visível '
          '(murcha, folhas enroladas). Irrigue em lâmina adequada à cultura e, se possível, aplique cobertura morta '
          '(palhada) para reduzir a evaporação e manter a umidade por mais tempo.',
      'baixo': 'Umidade abaixo do ideal. Aumente a frequência ou o volume de irrigação, preferindo horários de menor '
          'evapotranspiração (início da manhã ou fim da tarde) para melhor aproveitamento da água aplicada.',
      'ideal': 'Umidade ideal (40–60%): boa disponibilidade de água para absorção de nutrientes e atividade microbiana '
          'sem excesso. Mantenha o manejo de irrigação atual.',
      'alto': 'Umidade elevada. Verifique se a drenagem da área está funcionando e reduza o volume/frequência de '
          'irrigação — excesso de água por período prolongado favorece compactação e perda de nutrientes por '
          'lixiviação.',
      'muito_alto':
          'Solo encharcado. Risco de hipóxia radicular (falta de oxigênio nas raízes) e proliferação de doenças '
          'fúngicas e bacterianas. Suspenda a irrigação imediatamente, avalie a necessidade de drenos ou valetas de '
          'escoamento e evite tráfego de máquinas na área até o solo secar, para não compactar ainda mais.',
    },
  ),
  ParamKey.temperatura: const ParamConfig(
    key: ParamKey.temperatura,
    nome: 'Temperatura',
    emoji: '🌡️',
    unidade: '°C',
    min: 0,
    max: 50,
    ideal: [18, 28],
    step: 0.5,
    categoria: Categoria.fisico,
    hint: 'Temperatura do solo a 5–10 cm de profundidade. Use um termômetro '
        'de solo (espeto) inserido na terra, à sombra da própria planta.',
    recomendacoes: {
      'muito_baixo':
          'Solo muito frio. A atividade microbiana e a mineralização de nutrientes ficam praticamente paralisadas '
          'nessa faixa. Evite semear ou transplantar agora — aguarde o aquecimento natural do solo ou, se possível, '
          'use cobertura plástica (mulching) para acelerar o ganho de temperatura.',
      'baixo': 'Solo frio. Germinação e crescimento radicular tendem a ficar mais lentos, prolongando o ciclo da '
          'cultura. Se a semeadura for urgente, prefira cultivares mais tolerantes a baixas temperaturas de solo.',
      'ideal':
          'Temperatura ideal (18–28 °C): atividade microbiana, mineralização de nutrientes e crescimento radicular '
          'ocorrem de forma otimizada. Mantenha a cobertura vegetal/palhada atual, que ajuda a estabilizar essa faixa.',
      'alto': 'Solo quente. Aumente a irrigação (o efeito evaporativo ajuda a resfriar) e aplique cobertura morta para '
          'reduzir a incidência direta de sol sobre o solo, especialmente em horários de pico de calor.',
      'muito_alto':
          'Solo muito quente — risco real de dano a raízes finas e redução da atividade microbiana benéfica. '
          'Irrigue e cubra o solo com palhada urgentemente, e avalie sombreamento temporário em mudas ou plantas '
          'jovens mais sensíveis ao calor excessivo do solo.',
    },
  ),
  ParamKey.textura: const ParamConfig(
    key: ParamKey.textura,
    nome: 'Argila (Textura)',
    emoji: '🪨',
    unidade: '%',
    min: 0,
    max: 100,
    ideal: [20, 45],
    step: 1,
    categoria: Categoria.fisico,
    hint: 'Percentual estimado de argila no solo. Estime pelo teste manual do '
        'tato (bolinha/fita de solo úmido) — veja o passo a passo no Manual de Coleta.',
    recomendacoes: {
      'muito_baixo':
          'Solo muito arenoso (textura arenosa). Baixa capacidade de retenção de água e nutrientes — a adubação e a '
          'irrigação tendem a se perder rápido por percolação. Incorpore matéria orgânica (composto, esterco curtido, '
          'palhada) regularmente para aumentar a CTC e a retenção hídrica, e prefira irrigações mais frequentes e com '
          'menor lâmina de cada vez.',
      'baixo': 'Solo arenoso/franco-arenoso. Aumente o aporte de matéria orgânica para melhorar a estrutura e a '
          'capacidade de troca catiônica (CTC), e parcele mais a adubação para reduzir perdas por lixiviação.',
      'ideal': 'Textura equilibrada (solo de textura média): boa retenção de água e nutrientes combinada com aeração '
          'adequada. Mantenha o manejo atual de matéria orgânica e rotação de culturas.',
      'alto': 'Solo argiloso. Boa retenção de água e nutrientes, mas atenção ao risco de compactação, especialmente '
          'sob tráfego de máquinas com solo úmido. Monitore a aeração, evite trabalhar o solo encharcado e considere '
          'plantas de cobertura com raízes profundas para melhorar a estrutura.',
      'muito_alto':
          'Solo muito argiloso. Alto risco de compactação e encharcamento, com drenagem lenta. A gessagem agrícola '
          'pode ajudar a melhorar a estrutura em profundidade (efeito na floculação de argilas), associada ao uso de '
          'plantas de cobertura e à redução do tráfego de máquinas pesadas sobre a área, principalmente após chuvas.',
    },
  ),
};

final List<ParamKey> kParamKeys = kParams.keys.toList(growable: false);

class CategoriaInfo {
  final String label;
  final Color cor;
  final String emoji;
  const CategoriaInfo(this.label, this.cor, this.emoji);
}

final Map<Categoria, CategoriaInfo> kCategorias = {
  Categoria.quimico: const CategoriaInfo('Químico', AppColors.agua, '🧪'),
  Categoria.fisico: const CategoriaInfo('Físico', AppColors.terra, '🌍'),
};

const List<String> kCulturas = [
  'Soja', 'Milho', 'Cana-de-açúcar', 'Café', 'Algodão',
  'Arroz', 'Feijão', 'Trigo', 'Tomate', 'Mandioca',
  'Citros', 'Manga', 'Banana', 'Abacate', 'Maracujá',
  'Eucalipto', 'Pastagem', 'Hortaliças', 'Outra',
];
