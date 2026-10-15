import 'package:flutter/material.dart';
import '../utils/colors.dart';

class RiskIndicator extends StatelessWidget {
  final String level;

  const RiskIndicator({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (level) {
      case 'red':
        color = AppColors.red;
        label = 'HIGH';
        break;
      case 'yellow':
        color = AppColors.yellow;
        label = 'CAUTION';
        break;
      case 'green':
      default:
        color = AppColors.green;
        label = 'SAFE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class RiskBadge extends StatelessWidget {
  final String level;
  final double score;
  final bool showScore;

  const RiskBadge({
    super.key,
    required this.level,
    required this.score,
    this.showScore = true,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (level) {
      case 'red':
        color = AppColors.red;
        icon = Icons.error_outline;
        break;
      case 'yellow':
        color = AppColors.yellow;
        icon = Icons.warning_amber;
        break;
      case 'green':
      default:
        color = AppColors.green;
        icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          if (showScore)
            Text(
              '${score.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          if (!showScore)
            Text(
              level.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
        ],
      ),
    );
  }
}
