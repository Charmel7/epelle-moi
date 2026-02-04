// core/utils/responsive_utils.dart
import 'package:flutter/widgets.dart';

class ResponsiveUtils {
  // Taille d'écran de référence (1920x1080 - Full HD)
  static const double referenceWidth = 1920;
  static const double referenceHeight = 1080;

  // Points de rupture pour le responsive
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1920;

  // Méthodes d'adaptation
  static double responsiveWidth(BuildContext context, double width) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (width / referenceWidth) * screenWidth;
  }

  static double responsiveHeight(BuildContext context, double height) {
    final screenHeight = MediaQuery.of(context).size.height;
    return (height / referenceHeight) * screenHeight;
  }

  static double responsiveFontSize(BuildContext context, double fontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / referenceWidth;
    return fontSize * scale.clamp(0.8, 1.2); // Limite le scaling
  }

  static double responsiveSpacing(BuildContext context, double spacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    return spacing * (screenWidth / referenceWidth);
  }

  // Vérification du type d'écran
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint &&
          MediaQuery.of(context).size.width < desktopBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  static bool isLargeScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= largeDesktopBreakpoint;

  // Pour les layouts spécifiques
  static double getAdminPanelWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 3840) return 960; // Très grand écran
    if (width > 1920) return width * 0.25; // Écran large
    return width * 0.4; // Mode développement
  }

  static double getProjectionPanelWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 3840) return width - 960;
    return width - getAdminPanelWidth(context);
  }
}