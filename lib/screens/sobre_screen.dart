import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/referencias.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ℹ️ Sobre o COCOS',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(color: AppColors.terra, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const Text('🌱', style: TextStyle(fontSize: 40)),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('COCOS',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.white)),
                      SizedBox(height: 3),
                      Text('Código de Otimização das Características Orgânicas do Solo',
                          style: TextStyle(fontSize: 12, color: Color(0xCCFFFFFF), height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppCard(
            title: '🌾 O que é o COCOS',
            child: const Text(
              'O COCOS é um aplicativo de apoio à análise de solo voltado a quem trabalha direto na roça: '
              'o produtor mede parâmetros do solo com instrumentos simples de campo, insere os valores no '
              'app e recebe, na hora, a classificação de cada parâmetro (ideal, atenção ou crítico), uma '
              'pontuação geral do solo e recomendações práticas de manejo — sem depender de enviar amostra '
              'para um laboratório para ter uma primeira leitura da situação do talhão.',
              style: TextStyle(fontSize: 13.5, color: AppColors.texto, height: 1.55),
            ),
          ),
          AppCard(
            title: '🌴 De onde vem o nome',
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"COCOS" é a sigla de Código de Otimização das Características Orgânicas do Solo — o '
                  'nome resume exatamente a proposta do projeto: um código (um programa) que ajuda a '
                  'otimizar o manejo a partir das características orgânicas, químicas e físicas do solo.',
                  style: TextStyle(fontSize: 13.5, color: AppColors.texto, height: 1.55),
                ),
              ],
            ),
          ),
          AppCard(
            title: '💡 A origem do projeto',
            child: const Text(
              'A ideia nasceu em 2023, durante o desenvolvimento de projetos para uma disciplina de '
              'Ciência de Dados. Surgiu a proposta de criar um código capaz de gerar um PDF com gráficos '
              'sobre a condição do solo — um relatório completo, visual e fácil de entender, que reunisse '
              'em um só documento a leitura de vários parâmetros e desse uma visão geral da saúde do '
              'terreno. Esse experimento acadêmico deu origem ao motor de classificação que hoje está por '
              'trás do COCOS, incluindo a própria função de gerar relatório completo em PDF disponível no '
              'app.',
              style: TextStyle(fontSize: 13.5, color: AppColors.texto, height: 1.55),
            ),
          ),
          AppCard(
            title: '👤 Criador',
            child: const Text(
              'O COCOS foi idealizado e desenvolvido por Reinan Bezerra.',
              style: TextStyle(fontSize: 13.5, color: AppColors.texto, height: 1.55, fontWeight: FontWeight.w600),
            ),
          ),
          AppCard(
            title: '🛠️ Como o app foi construído em Flutter',
            child: const Text(
              'A versão atual do COCOS foi reescrita em Flutter/Dart, o que permite manter uma única base '
              'de código para Android e Web a partir dos mesmos arquivos-fonte. O motor de classificação — '
              'que decide se um valor está ideal, em atenção ou crítico, calcula estatísticas de séries de '
              'medições e o score geral do relatório — roda em Dart puro, direto no aparelho. O histórico e '
              'os relatórios salvos ficam gravados localmente no dispositivo do usuário, e a geração do PDF '
              'do relatório completo usa as bibliotecas pdf e printing do ecossistema Flutter para montar o '
              'documento e abrir a tela de impressão/salvamento nativa do sistema.',
              style: TextStyle(fontSize: 13.5, color: AppColors.texto, height: 1.55),
            ),
          ),
          AppCard(
            title: '📚 Referências',
            child: SelectionArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < kReferencias.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        '[${i + 1}] ${kReferencias[i]}',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textoSec, height: 1.5),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
