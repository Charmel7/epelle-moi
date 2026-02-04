// core/widgets/common/responsive_text.dart - Version corrigée
import 'package:flutter/material.dart';

import '../../../core/utils/responsive_utils.dart';

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? fontSize; // Ajout du paramètre

  const ResponsiveText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.fontSize, // Ajout dans le constructeur
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: style.copyWith(
        fontSize: ResponsiveUtils.responsiveFontSize(
          context,
          fontSize ?? style.fontSize ?? 14, // Utilise fontSize si fourni
        ),
      ),
    );
  }
}
