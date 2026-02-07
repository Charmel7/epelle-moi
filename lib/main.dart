// main.dart - VERSION FINALE CORRIGÉE
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

import 'core/constants/app_colors.dart';
import 'core/services/competition_service.dart';
import 'core/services/window_service.dart';
import 'ui/layout/dual_screen_layout.dart';
import 'ui/screens/admin/config_screen.dart';
import 'ui/screens/admin/control_screen.dart';
import 'ui/screens/projection/projection_screen.dart';

void main() async {
  // Initialiser window_manager avant runApp
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // DÉSACTIVEZ CES LIGNES POUR LE DÉBOGAGE
  // debugPaintSizeEnabled = true;
  // debugPaintBaselinesEnabled = true;
  await WindowService.initialize();
  runApp(const EpelleMoiApp());
}

class EpelleMoiApp extends StatelessWidget {
  const EpelleMoiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CompetitionService(),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        title: 'Épelle-Moi',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          colorScheme: ColorScheme.dark(
            primary: AppColors.or,
            secondary: AppColors.bleuMarine,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WindowListener {
  bool _estConfigure = false;
  bool _isProductionMode = true;
  List<Display> _screens = [];
  bool _isLoadingScreens = true;

  @override
  void initState() {
    super.initState();
    _initWindowManager();
    _detectScreens();
  }

  Future<void> _initWindowManager() async {
    windowManager.addListener(this);

    // Configuration initiale de la fenêtre
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setMinimumSize(const Size(1920, 1080));

    // Appliquer le mode actuel
    await _applyDisplayMode(_isProductionMode);
  }

  Future<void> _detectScreens() async {
    setState(() {
      _isLoadingScreens = true;
    });

    try {
      _screens = await screenRetriever.getAllDisplays();
      print('${_screens.length} écran(s) détecté(s)');
    } catch (e) {
      print('Erreur détection écrans: $e');
    }

    setState(() {
      _isLoadingScreens = false;
    });
  }

  Future<void> _applyDisplayMode(bool productionMode) async {
    try {
      if (!productionMode || _screens.length < 2) {
        // Mode développement
        await windowManager.setSize(const Size(1920, 1080));
        await windowManager.center();
        await windowManager.setFullScreen(false);
        print('Mode développement activé (1920x1080)');
      } else {
        // MODE PRODUCTION - NOUVELLE VERSION
        final screen1 = _screens[0];
        final screen2 = _screens[1];

        // LOGS POUR DEBUG
        print('''
=== CONFIGURATION DUAL SCREEN ===
Écran 1 (PC):
  Position: (${screen1.visiblePosition!.dx}, ${screen1.visiblePosition!.dy})
  Taille: ${screen1.size.width}x${screen1.size.height}
Écran 2 (Projecteur):
  Position: (${screen2.visiblePosition!.dx}, ${screen2.visiblePosition!.dy})
  Taille: ${screen2.size.width}x${screen2.size.height}
''');

        // OPTION 1: Utiliser la méthode "étendre" de WindowManager
        // Définir la fenêtre pour couvrir les deux écrans
        await windowManager.setPosition(
          Offset(screen1.visiblePosition!.dx, screen1.visiblePosition!.dy),
        );

        await windowManager.setSize(
          Size(
            screen1.size.width + screen2.size.width,
            max(screen1.size.height, screen2.size.height) + 500,
          ),
        );

        // OPTION 2: Forcer le plein écran étendu
        await windowManager.setFullScreen(true);
        await Future.delayed(const Duration(milliseconds: 500));
        await windowManager.setFullScreen(false);

        print('''
                === FENÊTRE CONFIGURÉE ===
                Largeur totale: ${screen1.size.width + screen2.size.width}px
                Hauteur: ${max(screen1.size.height, screen2.size.height)}px
                Écran PC: ${screen1.size.width}px
                Projecteur: ${screen2.size.width}px
                ''');

        // Vérifier que la fenêtre est bien positionnée
        final bounds = await windowManager.getBounds();
        print(
          'Fenêtre actuelle: ${bounds.width}x${bounds.height} @ (${bounds.left}, ${bounds.top})',
        );
      }
    } catch (e) {
      print('Erreur application mode: $e');
      await windowManager.setSize(const Size(1920, 1080));
      await windowManager.center();
    }
  }

  void _toggleProductionMode(bool value) async {
    setState(() {
      _isProductionMode = value;
    });

    await _applyDisplayMode(value);
    //await _verifierEtAjusterAffichage();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Mode PRODUCTION activé (étendu sur ${_screens.length} écran(s))'
              : 'Mode DÉVELOPPEMENT activé',
        ),
        backgroundColor: value ? Colors.green : Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Ajouter cette méthode dans _HomeScreenState
  Future<void> _verifierConfigurationEcrans() async {
    try {
      final bounds = await windowManager.getBounds();
      final screens = await screenRetriever.getAllDisplays();

      print('''
        === VÉRIFICATION CONFIGURATION ===
        Fenêtre actuelle:
          Position: (${bounds.left}, ${bounds.top})
          Taille: ${bounds.width}x${bounds.height}
        
        Écrans détectés:''');

      for (int i = 0; i < screens.length; i++) {
        final screen = screens[i];
        print(
          '  Écran $i: ${screen.size.width}x${screen.size.height} @ (${screen.visiblePosition!.dx}, ${screen.visiblePosition!.dy})',
        );
      }

      if (screens.length >= 2) {
        final screen1 = screens[0];
        final screen2 = screens[1];

        // Vérifier le chevauchement
        final fenetreDroite = bounds.left + bounds.width;
        final ecran2Droite = screen2.visiblePosition!.dx + screen2.size.width;

        print('''
=== CHEVAUCHEMENT ===
Fenêtre droite: ${fenetreDroite}px
Écran 2 droite: ${ecran2Droite}px
Différence: ${ecran2Droite - fenetreDroite}px
      ''');

        if (fenetreDroite < ecran2Droite - 50) {
          print('⚠️ ATTENTION: La fenêtre ne couvre pas tout le projecteur!');
          print('   Il manque ${(ecran2Droite - fenetreDroite).toInt()}px');
        }
      }
    } catch (e) {
      print('Erreur vérification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final competitionService = Provider.of<CompetitionService>(context);

    return Scaffold(
      // SUPPRIMEZ le Stack inutile, utilisez directement DualScreenLayout
      body: DualScreenLayout(
        isProductionMode: _isProductionMode,
        adminPanel: _estConfigure
            ? ControlScreen(
                onReinitialiser: () {
                  setState(() {
                    _estConfigure = false;
                  });
                },
                isProductionMode: _isProductionMode,
              )
            : ConfigScreen(
                // SUPPRIMEZ ScaledWidget ici !
                onConfigurationComplete: () {
                  if (competitionService.mots.isNotEmpty &&
                      competitionService.candidats.isNotEmpty) {
                    setState(() {
                      _estConfigure = true;
                    });
                  }
                },
              ),
        projectionPanel: const ProjectionScreen(),
      ),
    );
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    super.onWindowClose();
  }

  @override
  void onWindowResize() {
    print('Fenêtre redimensionnée');
  }

  @override
  void onWindowMove() {
    print('Fenêtre déplacée');
  }
}
