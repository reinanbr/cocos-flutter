import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/classification.dart';

class RecBox extends StatelessWidget {
  final String text;
  final ClassificationStatus status;

  const RecBox({super.key, required this.text, required this.status});

  @override
  Widget build(BuildContext context) {
    final bool bad = status == ClassificationStatus.ruim ||
        status == ClassificationStatus.muitoRuim;
    final bool warn = status == ClassificationStatus.atencao;
    final Color bg = bad ? AppColors.alertaPale : (warn ? AppColors.atencaoPale : AppColors.folhaPale);
    final Color fg = bad ? AppColors.alerta : (warn ? AppColors.atencao : AppColors.folha);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: TextStyle(fontSize: 13, color: fg, height: 1.5, fontWeight: FontWeight.w500)),
    );
  }
}
