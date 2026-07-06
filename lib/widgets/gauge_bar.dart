import 'package:flutter/material.dart';
import '../constants/colors.dart';

class GaugeBar extends StatelessWidget {
  final double val;
  final double min;
  final double max;
  final List<double> ideal;
  final Color cor;

  const GaugeBar({
    super.key,
    required this.val,
    required this.min,
    required this.max,
    required this.ideal,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    final range = (max - min) == 0 ? 1 : (max - min);
    final fillPct = ((val - min) / range * 100).clamp(2, 100).toDouble();
    final idealLeft = ((ideal[0] - min) / range * 100).clamp(0, 100).toDouble();
    final idealWidth = ((ideal[1] - ideal[0]) / range * 100).clamp(0, 100).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          LayoutBuilder(builder: (context, constraints) {
            final w = constraints.maxWidth;
            return Container(
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.gaugeTrack,
                borderRadius: BorderRadius.circular(7),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned(
                    left: w * idealLeft / 100,
                    width: w * idealWidth / 100,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.folha.withValues(alpha: 0.2),
                        border: const Border.symmetric(
                            vertical: BorderSide(color: AppColors.folha, width: 2)),
                      ),
                    ),
                  ),
                  Container(
                    width: w * fillPct / 100,
                    decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(7)),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(min), style: const TextStyle(fontSize: 10, color: AppColors.textoSec)),
              Text('✓ ${_fmt(ideal[0])} – ${_fmt(ideal[1])}',
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.folha, fontWeight: FontWeight.w700)),
              Text(_fmt(max), style: const TextStyle(fontSize: 10, color: AppColors.textoSec)),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}
