import 'dart:async';
import 'dart:math';

import 'package:epellemoi/core/services/persistence_service.dart';
import 'package:flutter/foundation.dart';

import '../models/candidate.dart';
import '../models/phase.dart';
import '../models/word.dart';
import 'csv_service.dart';

class CompetitionService extends ChangeNotifier {
  Phase _phaseActuelle = Phase.demiFinale;
  List<Candidate> _candidats = [];
  List<Word> _mots = [];
  Candidate? _candidatActuel;
  Word? _motActuel;
  String _epellationSaisie = '';
  bool _motRevele = false;
  int _chronoRestant = 120;
  Timer? _inactivityTimer;
  bool _chronoEnMarche = false;
  static const Duration _inactivityDelay = Duration(seconds: 3);
  Timer? _chronoTimer;
  bool _tousMotsUtilisesSignale = false;
  bool _candidatesLoaded = false;
  final CsvService _csvService = CsvService();
  Timer? _csvSaveTimer;
  // Getters
  Phase get phaseActuelle => _phaseActuelle;
  List<Candidate> get candidats {
    if (_candidats.isEmpty && !_candidatesLoaded) {
      _candidatesLoaded = true;
      loadPersistedData();
    }
    return _candidats;
  }

  bool get tousMotsUtilises => motsNonUtilises.isEmpty && _mots.isNotEmpty;
  List<Word> get mots => _mots;
  Candidate? get candidatActuel => _candidatActuel;
  Word? get motActuel => _motActuel;
  String get epellationSaisie => _epellationSaisie;
  bool get motRevele => _motRevele;
  int get chronoRestant => _chronoRestant;
  List<Word> get motsUtilises => _mots.where((m) => m.estUtilise).toList();
  // Vérifie si l'épellation est complète et correcte
  bool get epellationEstComplete {
    if (_motActuel == null) return false;
    return _epellationSaisie.length >= _motActuel!.orthographeOfficielle.length;
  }

  bool get signalerTousMotsUtilises => _tousMotsUtilisesSignale;
  List<Word> get motsNonUtilises => _mots.where((m) => !m.estUtilise).toList();
  // Vérifie si l'épellation actuelle est correcte
  bool get epellationEstCorrecte {
    if (_motActuel == null) return false;
    return _epellationSaisie.toUpperCase() ==
        _motActuel!.orthographeOfficielle.toUpperCase();
  }

  void _scheduleCsvUpdate() {
    _csvSaveTimer?.cancel();
    _csvSaveTimer = Timer(const Duration(seconds: 2), () async {
      await _csvService.saveWordsToLastFile(_mots);
      _csvSaveTimer = null;
    });
  }

  Map<String, dynamic> getStatistiquesMots() {
    final total = _mots.length;
    final utilises = motsUtilises.length;
    final nonUtilises = motsNonUtilises.length;

    return {
      'total': total,
      'utilises': utilises,
      'nonUtilises': nonUtilises,
      'pourcentageUtilises': total > 0 ? (utilises / total * 100).round() : 0,
    };
  }

  // Obtient l'état de chaque lettre (pour colorier)
  List<bool> get etatLettres {
    if (_motActuel == null) return [];

    final List<bool> etats = [];
    final mot = _motActuel!.orthographeOfficielle.toUpperCase();
    final saisie = _epellationSaisie.toUpperCase();

    for (int i = 0; i < saisie.length; i++) {
      if (i < mot.length) {
        etats.add(saisie[i] == mot[i]);
      } else {
        etats.add(false); // Lettre en trop = incorrecte
      }
    }
    return etats;
  }

  // Initialisation
  Future<void> initialiserAvecCsv(String csvContent) async {
    final csvService = CsvService();
    _mots = await csvService.loadWordsFromCsv(csvContent);
    notifyListeners();
  }

  // Gestion des candidats
  void ajouterCandidat(String nom) {
    _candidats.add(Candidate(nom: nom));
    PersistenceService.saveCandidates(_candidats);
    notifyListeners();
  }

  void supprimerCandidat(String id) {
    _candidats.removeWhere((c) => c.id == id);
    PersistenceService.saveCandidates(_candidats);
    notifyListeners();
  }

  void reinitialiserCandidats() {
    _candidats.clear();
    _candidatActuel = null;
    _candidatesLoaded = true;
    PersistenceService.saveCandidates(_candidats);
    notifyListeners();
  }

  void selectionnerCandidat(String id) {
    try {
      _candidatActuel = _candidats.firstWhere((c) => c.id == id);
    } catch (e) {
      // Si le candidat n'existe pas, sélectionner le premier
      if (_candidats.isNotEmpty) {
        _candidatActuel = _candidats.first;
      } else {
        _candidatActuel = null;
      }
    }
    notifyListeners();
  }

  // Gestion des mots
  void tirerMotAleatoire() {
    // Arrêter le timer existant

    _chronoTimer?.cancel();
    _chronoTimer = null;
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    _chronoEnMarche = false;

    if (_mots.isEmpty) {
      print("Aucun mot disponible dans la liste");
      _tousMotsUtilisesSignale = false;
      return;
    }

    final motsNonUtilises = _mots.where((m) => !m.estUtilise).toList();

    // Vérifier si tous les mots ont été utilisés
    if (motsNonUtilises.isEmpty) {
      print("TOUS LES MOTS ONT ÉTÉ UTILISÉS !");
      _tousMotsUtilisesSignale = true; // Activer le signalement

      // Réinitialiser tous les mots automatiquement pour continuer
      for (var mot in _mots) {
        mot.estUtilise = false;
      }

      // Maintenant, tirer un mot parmi les réinitialisés
      if (_mots.isNotEmpty) {
        final random = Random();
        final randomIndex = random.nextInt(_mots.length);
        _motActuel = _mots[randomIndex];
        _motActuel?.estUtilise = true;
        _scheduleCsvUpdate();

        // Afficher un message dans les logs pour le développeur
        print("Tous les mots ont été utilisés - Réinitialisation automatique");
        print("Nouveau mot tiré après réinitialisation: ${_motActuel!.mot}");
      }
    } else {
      _tousMotsUtilisesSignale = false; // Désactiver le signalement
      final random = Random();
      final randomIndex = random.nextInt(motsNonUtilises.length);
      _motActuel = motsNonUtilises[randomIndex];
      _motActuel?.estUtilise = true;
      _scheduleCsvUpdate();
    }

    _epellationSaisie = '';
    _motRevele = false;
    //_chronoRestant = 120;

    notifyListeners();
  }

  // Saisie d'épellation

  void ajouterLettre(String lettre) {
    if (lettre.length == 1 && lettre.isNotEmpty) {
      _epellationSaisie += lettre.toUpperCase();
      notifyListeners();
      _onUserActivity();
    }
  }

  void supprimerLettre() {
    if (_epellationSaisie.isNotEmpty) {
      _epellationSaisie = _epellationSaisie.substring(
        0,
        _epellationSaisie.length - 1,
      );
      notifyListeners();
      _onUserActivity();
    }
  }

  void effacerEpellation() {
    _epellationSaisie = '';
    notifyListeners();
    _onUserActivity(); // <-- AJOUT
  }

  // Révélation
  void revelerMot() {
    _motRevele = true;
    _arreterChrono();
    _inactivityTimer?.cancel();
    notifyListeners();
  }

  // Verdict
  void marquerCorrect() {
    if (_candidatActuel != null) {
      _candidatActuel!.score++;
      PersistenceService.saveCandidates(_candidats);
      notifyListeners();
    }
  }

  void marquerIncorrect() {
    if (_candidatActuel != null) {
      PersistenceService.saveCandidates(_candidats);
      notifyListeners();
    }
  }

  // Chronomètre
  void _demarrerChrono() {
    if (_chronoTimer != null || _chronoRestant <= 0 || _motRevele) return;
    _chronoEnMarche = true;
    _chronoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_chronoRestant > 0) {
        _chronoRestant--;
        notifyListeners();
        if (_chronoRestant == 0) {
          timer.cancel();
          _chronoTimer = null;
          _chronoEnMarche = false;
        }
      } else {
        timer.cancel();
        _chronoTimer = null;
        _chronoEnMarche = false;
      }
    });
  }

  void _arreterChrono() {
    _chronoTimer?.cancel();
    _chronoTimer = null;
    _chronoEnMarche = false;
  }

  void _onUserActivity() {
    // Ne pas démarrer si le mot est révélé
    if (_motRevele) return;

    // Annuler le timer d'inactivité précédent
    _inactivityTimer?.cancel();

    // Démarrer le chrono s'il n'est pas en marche
    if (!_chronoEnMarche && _chronoRestant > 0) {
      _demarrerChrono();
    }

    // Planifier un nouveau timer d'inactivité
    _inactivityTimer = Timer(_inactivityDelay, () {
      _arreterChrono();
      _inactivityTimer = null;
    });
  }

  void reinitialiserChrono() {
    _chronoTimer?.cancel(); //
    _chronoRestant = 120;
    notifyListeners();
  }

  void mettreEnPauseChrono() {
    _chronoTimer?.cancel();
    notifyListeners();
  }

  Future<bool> chargerMotsDepuisFichier() async {
    try {
      final csvService = CsvService();
      final motsCharges = await csvService.loadWordsFromFile();

      _tousMotsUtilisesSignale = false;
      _mots = motsCharges;
      notifyListeners();

      return motsCharges.isNotEmpty;
    } catch (e) {
      print('Erreur lors du chargement du fichier: $e');
      rethrow;
    }
  }

  Future<void> loadPersistedData() async {
    // Restaurer les candidats
    final savedCandidates = await PersistenceService.loadCandidates();
    if (savedCandidates.isNotEmpty) {
      _candidats = savedCandidates;
      _candidatesLoaded = true;
      // Optionnel : restaurer le candidat sélectionné (si vous l'avez aussi sauvegardé)
    }
    print(
      'Chargement des candidats persistés: ${savedCandidates.length} trouvés',
    );
    notifyListeners();
  }

  void reinitialiserSignalement() {
    _tousMotsUtilisesSignale = false;
    notifyListeners();
  }

  // Phase
  void changerPhase(Phase nouvellePhase) {
    _phaseActuelle = nouvellePhase;
    notifyListeners();
  }

  @override
  void dispose() {
    _chronoTimer?.cancel();
    _inactivityTimer?.cancel();
    super.dispose();
  }
}
