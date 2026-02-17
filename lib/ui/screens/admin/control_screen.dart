// Nouvelle version complète de control_screen.dart
import 'package:epellemoi/core/models/phase.dart';
import 'package:epellemoi/core/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/competition_service.dart';
import '../../widgets/header/competition_title.dart';

class ControlScreen extends StatefulWidget {
  final VoidCallback onReinitialiser;

  const ControlScreen({
    super.key,
    required this.onReinitialiser,
    required bool isProductionMode,
  });
  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  // Ajoutez ces deux variables
  TextEditingController? _saisieController;
  FocusNode? _saisieFocusNode;

  @override
  void initState() {
    super.initState();
    // Initialiser le contrôleur et le focus node
    _saisieController = TextEditingController();
    _saisieFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Nettoyer
    _saisieController?.dispose();
    _saisieFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header inspiré de l'affiche
          Container(
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                CompetitionTitle(isDarkMode: true, showSubtitle: false),
                const SizedBox(height: 16),
                Consumer<CompetitionService>(
                  builder: (context, competition, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildInfoBadge(
                          icon: Icons.person,
                          text:
                              competition.candidatActuel?.nom ??
                              'Aucun candidat',
                          style: TextStyle(color: Colors.white),
                          color: AppColors.or,
                        ),
                        const SizedBox(width: 16),
                        _buildInfoBadge(
                          icon: Icons.star,
                          style: TextStyle(color: Colors.white),
                          text:
                              'Score: ${competition.candidatActuel?.score ?? 0}',
                          color: Colors.green,
                        ),
                        const SizedBox(width: 16),
                        _buildInfoBadge(
                          icon: Icons.flag,
                          style: TextStyle(color: Colors.white),
                          text: competition.phaseActuelle.nom,
                          color: Colors.blue,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 200, right: 50, top: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Panneau gauche - Fiche du mot
                  Expanded(flex: 3, child: _buildWordPanel(context)),

                  const SizedBox(width: 24),

                  // Panneau droit - Commandes
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildSpellingInput(context),
                        const SizedBox(height: 24),
                        _buildControlButtons(context),
                        const SizedBox(height: 24),
                        _buildCandidatesList(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Barre inférieure
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 130),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => _showResetDialog(context),
                  tooltip: 'Configuration',
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Mode contrôle actif • Synchronisé avec l\'écran projection',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showResetDialog(context),
                  icon: const Icon(Icons.restart_alt, size: 16),
                  label: const Text('REINITIALISER'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String text,
    required Color color,
    required TextStyle style,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Ajoutez cette méthode dans la classe ControlScreen
  void _verifierTousMotsUtilises(
    BuildContext context,
    CompetitionService competition,
  ) {
    if (competition.signalerTousMotsUtilises) {
      // Réinitialiser le signalement après l'avoir affiché
      Future.delayed(const Duration(milliseconds: 100), () {
        competition.reinitialiserSignalement();
      });

      // Afficher un message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tous les mots ont été utilisés ! Les mots ont été réinitialisés automatiquement.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.or, // Utilisez votre couleur or
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  Widget _buildWordPanel(BuildContext context) {
    return Consumer<CompetitionService>(
      builder: (context, competition, child) {
        final mot = competition.motActuel;

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête du mot
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MOT À ÉPELLER',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        letterSpacing: 1.5,
                      ),
                    ),
                    if (mot != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Niveau ${mot.niveauDifficulte}/5',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Mot principal
              Expanded(
                child: Center(
                  child: mot == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.spellcheck,
                              size: 48,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun mot sélectionné',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cliquez sur "MOT SUIVANT" pour commencer',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              mot.mot.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                letterSpacing: 2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              mot.orthographeOfficielle.toUpperCase(),
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              // Définition et informations
              if (mot != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DÉFINITION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mot.definition,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      if (mot.exemple.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'EXEMPLE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '"${mot.exemple}"',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildCategoryChip(mot.categorie),
                          _buildCategoryChip(mot.natureGrammaticale),
                          if (mot.etymologie.isNotEmpty)
                            _buildCategoryChip(mot.etymologie),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildSpellingInput(BuildContext context) {
    return Consumer<CompetitionService>(
      builder: (context, competition, child) {
        final saisie = competition.epellationSaisie;
        final motOfficiel = competition.motActuel?.orthographeOfficielle ?? '';

        // Synchroniser le contrôleur avec la saisie actuelle
        if (_saisieController!.text != saisie) {
          _saisieController!.text = saisie;
          _saisieController!.selection = TextSelection.collapsed(
            offset: saisie.length,
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SAISIE D\'ÉPELLATION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    '${saisie.length}/${motOfficiel.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ZONE DE SAISIE SIMPLIFIÉE
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _saisieController,
                  focusNode: _saisieFocusNode,
                  maxLength: motOfficiel.isEmpty ? null : motOfficiel.length,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Cliquez et tapez au clavier |',
                    hintStyle: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                      letterSpacing: 2,
                      fontFamily: 'Courier',
                    ),
                    counterText: '',
                  ),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    letterSpacing: 2,
                    fontFamily: 'Courier',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (value) {
                    // Mettre à jour le service sans tout effacer
                    if (value.length > saisie.length) {
                      // Ajouter seulement la nouvelle lettre
                      String nouvelleLettre = value.substring(saisie.length);
                      competition.ajouterLettre(nouvelleLettre);
                    } else if (value.length < saisie.length) {
                      // Supprimer une lettre
                      competition.supprimerLettre();
                    }
                  },
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        competition.supprimerLettre();
                        // Garder le focus
                        _saisieFocusNode?.requestFocus();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: const Text('RETOUR'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        competition.reinitialiserChrono();
                        // Garder le focus
                        _saisieFocusNode?.requestFocus();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Icon(Icons.refresh, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        competition.effacerEpellation();
                        // Garder le focus
                        _saisieFocusNode?.requestFocus();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red[700],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.red[100]!),
                        ),
                      ),
                      child: const Text('EFFACER'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButtons(BuildContext context) {
    return Consumer<CompetitionService>(
      builder: (context, competition, child) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'CONTRÔLES PRINCIPAUX',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        competition.marquerCorrect();
                        AudioService().playCorrect();
                        competition.tirerMotAleatoire();
                        // Vérifier après le tirage
                        _verifierTousMotsUtilises(context, competition);
                      },
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text('CORRECT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[50],
                        foregroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.green[100]!),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        competition.marquerIncorrect();
                        AudioService().playIncorrect();
                        competition.tirerMotAleatoire();
                        // Vérifier après le tirage
                        _verifierTousMotsUtilises(context, competition);
                      },
                      icon: const Icon(Icons.close, size: 20),
                      label: const Text('INCORRECT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red[700],
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.red[100]!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        competition.tirerMotAleatoire();
                        // Vérifier après le tirage
                        _verifierTousMotsUtilises(context, competition);
                      },
                      icon: const Icon(Icons.skip_next, size: 18),
                      label: const Text('MOT SUIVANT'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Dans control_screen.dart, partie du bouton RÉVÉLER
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        competition.revelerMot();
                        // Jouer le son approprié après révélation
                        if (competition.epellationEstCorrecte) {
                          competition.marquerCorrect();
                          AudioService().playCorrect();
                        } else {
                          competition.marquerIncorrect();
                          AudioService().playIncorrect();
                        }
                      },
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('RÉVÉLER'),

                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCandidatesList(BuildContext context) {
    return Consumer<CompetitionService>(
      builder: (context, competition, child) {
        final candidats = competition.candidats;
        final candidatActuel = competition.candidatActuel;

        return Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CANDIDATS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          letterSpacing: 1.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${candidats.length} participants',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: candidats.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people,
                                size: 48,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Aucun candidat',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[400],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ajoutez des candidats dans la configuration',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[300],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(4),
                          itemCount: candidats.length,
                          itemBuilder: (context, index) {
                            final candidat = candidats[index];
                            final estActif = candidatActuel?.id == candidat.id;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              child: Material(
                                color: estActif
                                    ? Colors.black
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                child: InkWell(
                                  onTap: () => competition.selectionnerCandidat(
                                    candidat.id,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: estActif
                                            ? Colors.black
                                            : Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: estActif
                                                ? Colors.white
                                                : Colors.grey[200],
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${index + 1}',
                                              style: TextStyle(
                                                color: estActif
                                                    ? Colors.black
                                                    : Colors.grey[600],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                candidat.nom,
                                                style: TextStyle(
                                                  color: estActif
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontWeight: estActif
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'Score: ${candidat.score}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: estActif
                                                      ? Colors.grey[300]
                                                      : Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (estActif)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retour à la configuration'),
        content: const Text(
          'Voulez-vous retourner à l\'écran de configuration ?\n'
          'La partie en cours ne sera pas sauvegardée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onReinitialiser();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: const Text(
              'Confirmer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildProgressIndicator(
  BuildContext context,
  CompetitionService competition,
) {
  final stats = competition.getStatistiquesMots();
  final total = stats['total'] as int;
  final utilises = stats['utilises'] as int;

  if (total == 0) return SizedBox();

  final pourcentage = stats['pourcentageUtilises'] as int;

  return Container(
    margin: EdgeInsets.only(top: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progression des mots:',
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
            Text(
              '$pourcentage% ($utilises/$total)',
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
          ],
        ),
        SizedBox(height: 4),
        Container(
          height: 6,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(3),
          ),
          child: Stack(
            children: [
              Container(
                height: 6,
                width: 200 * (pourcentage / 100),
                decoration: BoxDecoration(
                  color: pourcentage >= 100 ? AppColors.or : Colors.green,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ),
        if (pourcentage >= 100)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 12, color: AppColors.or),
                SizedBox(width: 4),
                Text(
                  'Tous les mots ont été utilisés',
                  style: TextStyle(fontSize: 11, color: AppColors.or),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
