// lib/ui/widgets/header/competition_title.dart
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class CompetitionTitle extends StatelessWidget {
  final bool isDarkMode;
  final bool compact;
  final bool showSubtitle;
  final String? customSubtitle;

  const CompetitionTitle({
    super.key,
    this.isDarkMode = false,
    this.compact = false,
    this.showSubtitle = true,
    this.customSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = isDarkMode ? Colors.white : Colors.black;
    final Color secondaryColor = isDarkMode
        ? Colors.white70
        : Colors.grey[800]!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // "CONCOURS" en haut
        Text(
          'CONCOURS',
          style: TextStyle(
            fontSize: compact ? 12 : 20,
            letterSpacing: 4,
            fontWeight: FontWeight.w300,
            color: secondaryColor,
            height: 1,
          ),
        ),
        const SizedBox(height: 30),

        // "ÉPELLE" en gras
        Text(
          'ÉPELLE',
          style: TextStyle(
            fontSize: compact ? 20 : 40,
            fontWeight: FontWeight.w900,
            color: primaryColor,
            height: 0.9,
            letterSpacing: 1,
          ),
        ),

        // "MOI" en très gros
        Text(
          'MOI',
          style: TextStyle(
            fontSize: compact ? 35 : 60,
            fontWeight: FontWeight.w900,
            color: primaryColor,
            height: 0.85,
            letterSpacing: 1,
          ),
        ),

        // Sous-titre optionnel
        if (showSubtitle) ...[
          const SizedBox(height: 4),
          Text(
            customSubtitle ?? 'CONSOLE DE CONTRÔLE',
            style: TextStyle(
              fontSize: compact ? 5 : 12,
              letterSpacing: 2,
              fontWeight: FontWeight.w300,
              color: secondaryColor,
            ),
          ),
        ],
      ],
    );
  }
}

// Variante avec fond coloré
class CompetitionTitleCard extends StatelessWidget {
  final bool isAdminScreen;
  final String? subtitle;

  const CompetitionTitleCard({
    super.key,
    this.isAdminScreen = true,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = !isAdminScreen;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: isAdminScreen ? AppColors.bleuMarineFonce : Colors.black,
        border: Border(
          bottom: BorderSide(
            color: AppColors.or.withOpacity(isAdminScreen ? 0.1 : 0.3),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: CompetitionTitle(
          isDarkMode: isDarkMode,
          showSubtitle: true,
          customSubtitle: subtitle,
        ),
      ),
    );
  }
}
