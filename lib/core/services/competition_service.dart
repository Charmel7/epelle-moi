import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/candidate.dart';
import '../models/phase.dart';
import '../models/word.dart';
import 'csv_service.dart';

class CompetitionService extends ChangeNotifier {
  Phase _phaseActuelle = Phase.qualifications;
  List<Candidate> _candidats = [];
  List<Word> _mots = [];
  Candidate? _candidatActuel;
  Word? _motActuel;
  String _epellationSaisie = '';
  bool _motRevele = false;
  int _chronoRestant = 60;

  Timer? _chronoTimer;
  bool _tousMotsUtilisesSignale = false;

  // Getters
  Phase get phaseActuelle => _phaseActuelle;
  List<Candidate> get candidats => _candidats;
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
    notifyListeners();
  }

  void supprimerCandidat(String id) {
    _candidats.removeWhere((c) => c.id == id);
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
    }

    _epellationSaisie = '';
    _motRevele = false;
    _chronoRestant = 60;

    notifyListeners();
    demarrerChrono();
  }

  // Saisie d'épellation
  void ajouterLettre(String lettre) {
    if (lettre.length == 1 && lettre.isNotEmpty) {
      _epellationSaisie += lettre.toUpperCase();
      notifyListeners();
    }
  }

  void supprimerLettre() {
    if (_epellationSaisie.isNotEmpty) {
      _epellationSaisie = _epellationSaisie.substring(
        0,
        _epellationSaisie.length - 1,
      );
      notifyListeners();
    }
  }

  void effacerEpellation() {
    _epellationSaisie = '';
    notifyListeners();
  }

  // Révélation
  void revelerMot() {
    _motRevele = true;
    notifyListeners();
  }

  // Verdict
  void marquerCorrect() {
    if (_candidatActuel != null) {
      _candidatActuel!.score++;
      notifyListeners();
    }
  }

  void marquerIncorrect() {
    if (_candidatActuel != null) {
      // Logique supplémentaire si nécessaire
      notifyListeners();
    }
  }

  // Chronomètre
  void demarrerChrono() {
    _chronoTimer?.cancel();
    _chronoRestant = 10;

    _chronoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_chronoRestant > 0) {
        _chronoRestant--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  void reinitialiserChrono() {
    _chronoTimer?.cancel(); // Arrêter le timer existant
    _chronoRestant = 10; // Remettre à 60 secondes

    // Lancer immédiatement un nouveau chronomètre
    _chronoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_chronoRestant > 0) {
        _chronoRestant--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });

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

  void reinitialiserSignalement() {
    _tousMotsUtilisesSignale = false;
    notifyListeners();
  }

  // Phase
  void changerPhase(Phase nouvellePhase) {
    _phaseActuelle = nouvellePhase;
    notifyListeners();
  }

  // Nettoyage
  @override
  void dispose() {
    _chronoTimer?.cancel();
    super.dispose();
  }
}
