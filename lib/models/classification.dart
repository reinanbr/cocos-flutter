import 'package:flutter/material.dart';

enum ClassificationStatus { otimo, bom, regular, atencao, ruim, muitoRuim }

extension ClassificationStatusLabel on ClassificationStatus {
  String get label {
    switch (this) {
      case ClassificationStatus.otimo:
        return 'Ótimo';
      case ClassificationStatus.bom:
        return 'Bom';
      case ClassificationStatus.regular:
        return 'Regular';
      case ClassificationStatus.atencao:
        return 'Atenção';
      case ClassificationStatus.ruim:
        return 'Ruim';
      case ClassificationStatus.muitoRuim:
        return 'Muito ruim';
    }
  }

  int get score {
    switch (this) {
      case ClassificationStatus.otimo:
        return 100;
      case ClassificationStatus.bom:
        return 80;
      case ClassificationStatus.regular:
        return 60;
      case ClassificationStatus.atencao:
        return 40;
      case ClassificationStatus.ruim:
        return 20;
      case ClassificationStatus.muitoRuim:
        return 0;
    }
  }
}

class Classification {
  final String label;
  final ClassificationStatus status;
  final Color cor;

  const Classification({required this.label, required this.status, required this.cor});
}
