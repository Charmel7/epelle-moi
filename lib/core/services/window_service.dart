import 'dart:math';

import 'package:flutter/material.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

class WindowService {
  static Future<void> initialize() async {
    await windowManager.ensureInitialized();

    final WindowOptions windowOptions = WindowOptions(
      size: const Size(3840, 1080),
      minimumSize: const Size(2560, 900),
      center: false,
      backgroundColor: Colors.black,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();

      // Étirer sur deux écrans si disponibles
      await _setupDualScreen();
    });
  }

  static Future<void> _setupDualScreen() async {
    try {
      final displays = await screenRetriever.getAllDisplays();

      if (displays.length >= 2) {
        final primary = displays[0];
        final secondary = displays[1];

        final primaryBounds = primary.visiblePosition!;
        final primarySize = primary.size;

        final secondaryBounds = secondary.visiblePosition!;
        final secondarySize = secondary.size;

        // Calculer les coordonnées pour couvrir les deux écrans
        final left = primaryBounds.dx;
        final top = primaryBounds.dy;
        final right = secondaryBounds.dx + secondarySize.width;
        final bottom = max(
          primaryBounds.dy + primarySize.height,
          secondaryBounds.dy + secondarySize.height,
        );

        await windowManager.setBounds(Rect.fromLTRB(left, top, right, bottom));
        await windowManager.setFullScreen(true);
      }
    } catch (e) {
      print('Erreur configuration dual screen: $e');
    }
  }
}
