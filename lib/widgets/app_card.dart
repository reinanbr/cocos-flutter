import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AppCard extends StatelessWidget {
  final String? title;
  final String? desc;
  final Widget child;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    this.title,
    this.desc,
    required this.child,
    this.borderColor,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor ?? AppColors.borda, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(title!,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.texto)),
            ),
          if (desc != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(desc!,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textoSec, height: 1.4)),
            ),
          child,
        ],
      ),
    );
  }
}
