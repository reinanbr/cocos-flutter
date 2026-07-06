import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color cor;

  const StatusBadge({super.key, required this.label, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(color: cor, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}
