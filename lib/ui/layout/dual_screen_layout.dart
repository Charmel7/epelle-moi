// dual_screen_layout.dart
import 'dart:math' as math;
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

  @override
  void initState() {
    super.initState();
    _initializeScreens();
  }

  Future<void> _initializeScreens() async {
    try {
      _screens = await screenRetriever.getAllDisplays();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Erreur détection écrans: $e');
      _screens = [];
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!widget.isProductionMode || _screens.length < 2) {
      // MODE DÉVELOPPEMENT ou un seul écran
      return _buildDevelopmentLayout();
    }

    // MODE PRODUCTION avec 2+ écrans
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
            Container(
              width: 4,
              color: AppColors.or,
            ),

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
    // En mode production, utilisez également Expanded au lieu de SizedBox
    // Car la fenêtre est déjà dimensionnée pour couvrir les 2 écrans
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Row(
          children: [
            // ÉCRAN PC (Admin) - Utilise Expanded au lieu de SizedBox fixe
            Expanded(
              flex: 1,
              child: Container(
                color: AppColors.bleuMarine,
                child: widget.adminPanel,
              ),
            ),

            // ÉCRAN PROJECTEUR (Projection) - Utilise Expanded au lieu de SizedBox fixe
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
}
