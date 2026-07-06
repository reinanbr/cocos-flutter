# 🌱 COCOS — Análise de Solo

Aplicativo Flutter para análise de solo direto na roça, usando apenas
instrumentos simples e baratos (medidor de pH de bolso, condutivímetro,
sonda de umidade/temperatura e o teste manual de textura) — sem depender de
laboratório ou de conexão com a internet.

## O que o app faz

O COCOS trabalha com 6 parâmetros de solo mensuráveis em campo:

| Parâmetro | Unidade | Faixa ideal |
|---|---|---|
| 🧪 pH do Solo | pH | 6,0 – 6,5 |
| ⚡ Condutividade Elétrica | dS/m | 0,1 – 1,5 |
| 🧂 Salinidade | g/L | 0,0 – 0,5 |
| 💧 Umidade | % | 40 – 60 |
| 🌡️ Temperatura | °C | 18 – 28 |
| 🪨 Argila (Textura) | % | 20 – 45 |

Para cada parâmetro, o app classifica o valor medido (ótimo, bom, regular,
atenção, ruim, muito ruim) e gera recomendações agronômicas específicas
(calagem, adubação, irrigação, drenagem etc.).

### Funcionalidades

- **📖 Manual de Coleta** — passo a passo de como medir cada parâmetro na roça.
- **📍 Análise Única** — avalia um parâmetro isolado e mostra se está na faixa ideal.
- **📊 Série de Valores** — compara múltiplas medições com estatísticas (média,
  desvio padrão, mediana, coeficiente de variação, tendência).
- **📋 Relatório Completo** — analisa todos os parâmetros de uma vez, associados
  a uma cultura e local, e gera um score geral de saúde do solo.
- **⚖️ Comparar Parâmetros** — compara dois parâmetros lado a lado.
- **🌡️ Dashboard** — resumo visual dos últimos relatórios salvos.
- **📁 Histórico** — todas as análises salvas localmente no dispositivo.
- **📄 Exportar PDF** — gera relatórios em PDF para compartilhar ou imprimir.
- **ℹ️ Sobre** — informações e referências técnicas usadas nas classificações.

## Como funciona

- Todo o processamento (classificação, estatísticas, score) roda **100% no
  dispositivo**, sem servidor — pensado para uso a campo mesmo sem internet.
- Os dados (histórico e relatórios) são persistidos localmente com
  `shared_preferences`.
- Relatórios podem ser exportados em PDF com os pacotes `pdf` e `printing`.

## Stack técnica

- [Flutter](https://flutter.dev/) / Dart
- `shared_preferences` — persistência local
- `pdf` + `printing` — geração e exportação de relatórios em PDF
- `uuid`, `intl` — utilitários
- `flutter_native_splash`, `flutter_launcher_icons` — splash screen e ícone do app

## Estrutura do projeto

```
lib/
├── constants/     # parâmetros de solo, cores, culturas, referências técnicas
├── models/        # modelos de dados (resultado, classificação, histórico)
├── services/      # classificação, persistência (storage) e geração de PDF
├── screens/       # telas do app (home, manual, único, série, relatório, ...)
├── widgets/       # componentes de UI reutilizáveis
└── main.dart      # ponto de entrada e rotas
```

## Rodando o projeto

```bash
flutter pub get
flutter run
```

## Getting Started (Flutter)

Este projeto foi criado com Flutter. Para mais informações sobre o framework:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)
