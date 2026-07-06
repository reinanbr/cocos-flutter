import 'package:flutter/material.dart';
import '../constants/colors.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textoSec,
              letterSpacing: 0.5)),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;

  const EmptyState({super.key, required this.emoji, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 14),
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.texto)),
          const SizedBox(height: 6),
          Text(desc,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textoSec, height: 1.5)),
        ],
      ),
    );
  }
}

class ErrorBox extends StatelessWidget {
  final String text;
  const ErrorBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration:
          BoxDecoration(color: AppColors.alertaPale, borderRadius: BorderRadius.circular(10)),
      child: Text('⚠️ $text',
          style: const TextStyle(
              color: AppColors.alerta, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}
