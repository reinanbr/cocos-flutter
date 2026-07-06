import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/params.dart';
import '../models/param_config.dart';

class ParamGrid extends StatelessWidget {
  final ParamKey? selected;
  final ValueChanged<ParamKey> onSelect;

  const ParamGrid({super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kParamKeys.map((key) {
        final info = kParams[key]!;
        final isSel = selected == key;
        final catCor = kCategorias[info.categoria]!.cor;
        return InkWell(
          onTap: () => onSelect(key),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 96,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            decoration: BoxDecoration(
              color: isSel ? catCor.withValues(alpha: 0.12) : AppColors.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSel ? catCor : AppColors.borda, width: isSel ? 2 : 1.5),
            ),
            child: Column(
              children: [
                Text(info.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 6),
                Text(
                  info.nome,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSel ? catCor : AppColors.textoSec,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
