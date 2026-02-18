import 'package:flutter/material.dart';
import 'package:screen_retriever/screen_retriever.dart';

import '../../core/constants/app_colors.dart';

class DualScreenLayout extends StatefulWidget {
  final Widget adminPanel;
  final Widget projectionPanel;
  final bool isProductionMode;

  const DualScreenLayout({
    super.key,
    required this.adminPanel,
    required this.projectionPanel,
    this.isProductionMode = false,
  });

  @override
  State<DualScreenLayout> createState() => _DualScreenLayoutState();
}

class _DualScreenLayoutState extends State<DualScreenLayout> {
  late List<Display> _screens;
  bool _isInitialized = false;
  double _screen1Width = 1920; // Valeur par défaut
  double _screen2Width = 1920; // Valeur par défaut
  double _screen1Height = 1080; // Valeur par défaut
  double _screen2Height = 1080; // Valeur par défaut

  @override
  void initState() {
    super.initState();
    _initializeScreens();
  }

  Future<void> _initializeScreens() async {
    try {
      _screens = await screenRetriever.getAllDisplays();

      if (_screens.length >= 2) {
        // Trier par position X (de gauche à droite)
        _screens.sort(
          (a, b) => a.visiblePosition!.dx.compareTo(b.visiblePosition!.dx),
        );

        _screen1Width = _screens[0].size.width;
        _screen2Width = _screens[1].size.width;
        _screen1Height = _screens[0].size.height;
        _screen2Height = _screens[1].size.height;

        print('''
=== DUAL SCREEN LAYOUT ===
Écran 1 (PC): ${_screen1Width}px
Écran 2 (Projecteur): ${_screen2Width}px
Ratio: ${(_screen1Width / _screen2Width).toStringAsFixed(2)}
        ''');
      }
    } catch (e) {
      print('Erreur détection écrans: $e');
      _screens = [];
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!widget.isProductionMode || _screens.length < 2) {
      return _buildDevelopmentLayout();
    }

    return _buildProductionLayout();
  }

  Widget _buildDevelopmentLayout() {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Row(
          children: [
            // Panneau Admin (50%)
            Expanded(
              flex: 1,
              child: Container(
                color: AppColors.bleuMarine,
                child: widget.adminPanel,
              ),
            ),

            // Séparateur
            Container(width: 4, color: AppColors.or),

            // Panneau Projection (50%)
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.black,
                child: widget.projectionPanel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductionLayout() {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Écran PC (Admin) - positionné à gauche
            Positioned(
              left: 0,
              top: 0,
              width: _screen1Width,
              height: _screen1Height,
              child: Container(
                color: AppColors.bleuMarine,
                child: widget.adminPanel,
              ),
            ),

            // Écran Projecteur (Projection) - positionné à droite
            Positioned(
              left: _screen1Width - 5, // Commence après l'écran 1
              top: 0,
              width: _screen2Width * 0.8,
              height: _screen2Height,
              child: Container(
                color: Colors.black,
                child: widget.projectionPanel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
