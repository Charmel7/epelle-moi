// projection_screen.dart
import 'package:epellemoi/core/models/phase.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/competition_service.dart';
import '../../widgets/header/competition_title.dart';

class ProjectionScreen extends StatelessWidget {
  const ProjectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final competition = Provider.of<CompetitionService>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            color: Colors.black,
            child: Stack(
              children: [
                // Effet de fond minimaliste
                Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.03),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                Column(
                  children: [
                    const SizedBox(height: 40),
                    // En-tête
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black, Colors.black.withOpacity(0.8)],
                        ),
                      ),
                      child: Center(
                        child: CompetitionTitle(
                          isDarkMode: true,
                          showSubtitle: false,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Phase et candidat
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          // Phase
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white30),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              competition.phaseActuelle.nom.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Nom du candidat
                          Text(
                            competition.candidatActuel?.nom.toUpperCase() ??
                                'EN ATTENTE',
                            style: const TextStyle(
                              fontSize: 36,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1.5,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Zone d'épellation - AVEC CONTRAINTES
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 40, right: 70),
                            child: competition.motRevele
                                ? _buildRevealedWord(competition)
                                : _buildLiveSpelling(competition),
                          ),
                        ),
                      ),
                    ),

                    // Chronomètre et score
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 40,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTimer(competition),
                          const SizedBox(width: 60),
                          _buildScore(competition),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimer(CompetitionService competition) {
    final seconds = competition.chronoRestant;
    Color getTimerColor() {
      if (seconds > 30) return Colors.green;
      if (seconds > 10) return Colors.amber;
      return Colors.red;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'TEMPS RESTANT',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.5),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(seconds ~/ 60).toString().padLeft(2, '0')}:'
          '${(seconds % 60).toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 36,
            color: getTimerColor(),
            fontWeight: FontWeight.w300,
            fontFamily: 'Courier',
          ),
        ),
      ],
    );
  }

  Widget _buildScore(CompetitionService competition) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'SCORE',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.5),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${competition.candidatActuel?.score ?? 0}',
          style: const TextStyle(
            fontSize: 48,
            color: Colors.white,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildRevealedWord(CompetitionService competition) {
    final mot = competition.motActuel?.orthographeOfficielle ?? '';
    final estCorrect = competition.epellationEstCorrecte;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          estCorrect ? Icons.check : Icons.close,
          size: 64,
          color: estCorrect ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 32),
        Text(
          mot.toUpperCase(),
          style: TextStyle(
            fontSize: 64,
            color: estCorrect ? Colors.green : Colors.red,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 16),
        Text(
          estCorrect ? 'CORRECT' : 'INCORRECT',
          style: TextStyle(
            fontSize: 24,
            color: estCorrect ? Colors.green : Colors.red,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveSpelling(CompetitionService competition) {
    final saisie = competition.epellationSaisie;
    final motOfficiel = competition.motActuel?.orthographeOfficielle ?? '';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (saisie.isNotEmpty)
          // Utiliser un Container avec contraintes pour éviter l'overflow
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 800, // Largeur maximale pour les lettres
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: List.generate(saisie.length, (index) {
                bool estCorrecte = false;
                if (index < motOfficiel.length) {
                  estCorrecte =
                      saisie[index].toUpperCase() ==
                      motOfficiel[index].toUpperCase();
                }

                return Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(
                      color: estCorrecte
                          ? Colors.green.withOpacity(0.5)
                          : Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      saisie[index] == ' ' ? '␣' : saisie[index],
                      style: TextStyle(
                        fontSize: 36,
                        color: estCorrecte ? Colors.green : Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }),
            ),
          )
        else
          Column(
            children: [
              Text(
                '...',
                style: TextStyle(
                  fontSize: 72,
                  color: Colors.white.withOpacity(0.1),
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'EN ATTENTE DE LA PREMIÈRE LETTRE',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.3),
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        const SizedBox(height: 40),
        if (motOfficiel.isNotEmpty && saisie.isNotEmpty)
          Text(
            '${saisie.length}  lettres',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
      ],
    );
  }
}
