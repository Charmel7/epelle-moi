// core/services/display_service.dart - Version corrigée
import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

class DisplayService {
  static Future<void> setupDualScreen(bool isProductionMode) async {
    try {
      await windowManager.ensureInitialized();

      if (!isProductionMode) {
        // MODE DÉVELOPPEMENT : Une seule fenêtre 1920x1080
        await windowManager.setMinimumSize(const Size(1920, 1200));
        await windowManager.setSize(const Size(1920, 1200));
        await windowManager.center();
        await windowManager.setFullScreen(false);
        return;
      }

      // MODE PRODUCTION : Étendre sur 2 écrans
      final screens = await screenRetriever.getAllDisplays();

      if (screens.length < 2) {
        print(
          'ATTENTION: Moins de 2 écrans détectés, passage en mode développement',
        );
        await windowManager.setSize(const Size(1920, 1080));
        await windowManager.center();
        return;
      }

      // Trier les écrans par position X
      screens.sort(
        (a, b) => a.visiblePosition!.dx.compareTo(b.visiblePosition!.dx),
      );

      final leftScreen = screens[0]; // Écran le plus à gauche (PC)
      final rightScreen = screens[1]; // Écran le plus à droite (Projecteur)

      // Calculer la fenêtre qui couvre les 2 écrans
      final left = leftScreen.visiblePosition!.dx;
      final top = math.min(
        leftScreen.visiblePosition!.dy,
        rightScreen.visiblePosition!.dy,
      );
      final right = rightScreen.visiblePosition!.dx + rightScreen.size.width;
      final bottom = math.max(
        leftScreen.visiblePosition!.dy + leftScreen.size.height,
        rightScreen.visiblePosition!.dy + rightScreen.size.height,
      );

      final width = right - left;
      final height = bottom - top;

      print('''Configuration Production:
        Écran 1 (PC): ${leftScreen.size.width}x${leftScreen.size.height} @ (${leftScreen.visiblePosition!.dx}, ${leftScreen.visiblePosition!.dy})
        Écran 2 (Projecteur): ${rightScreen.size.width}x${rightScreen.size.height} @ (${rightScreen.visiblePosition!.dx}, ${rightScreen.visiblePosition!.dy})
        Fenêtre totale: ${width}x${height} @ ($left, $top)
      ''');

      // Définir la fenêtre pour couvrir exactement les 2 écrans
      await windowManager.setBounds(Rect.fromLTWH(left, top, width, height));
      await windowManager.setFullScreen(false);
      await windowManager.setMinimumSize(Size(width, height));

      // Masquer la barre de titre pour un look plus professionnel
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    } catch (e) {
      print('Erreur configuration dual screen: $e');
      // En cas d'erreur, revenir au mode développement
      await windowManager.setSize(const Size(1920, 1080));
      await windowManager.center();
    }
  }
}
