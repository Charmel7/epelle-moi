import 'package:flutter/material.dart';

import '../../../core/constants/app_text_styles.dart';

class ChronometerWidget extends StatelessWidget {
  final int seconds;

  const ChronometerWidget({super.key, required this.seconds});

  @override
  Widget build(BuildContext context) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    Color getColor() {
      if (seconds > 30) return Colors.green;
      if (seconds > 10) return Colors.orange;
      return Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: getColor(), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: getColor(), size: 24),
          const SizedBox(width: 10),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}',
            style: AppTextStyles.sansSerifGrand.copyWith(
              fontSize: 36,
              color: getColor(),
            ),
          ),
        ],
      ),
    );
  }
}
