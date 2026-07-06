import 'package:flutter/material.dart';
import '../constants/colors.dart';

class HintBox extends StatelessWidget {
  final String text;
  const HintBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.hintBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.hintBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡 ', style: TextStyle(fontSize: 13)),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 12, color: AppColors.textoSec, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
