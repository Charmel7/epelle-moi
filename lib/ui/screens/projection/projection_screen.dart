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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.0),

            color: Colors.black,
            child: Stack(
              children: [
                // Effet de fond minimaliste
                Column(
                  children: [
                    // En-tête avec padding proportionnel
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.05, // 5% de la hauteur
                        horizontal: screenWidth * 0, // 5% de la largeur
                      ),
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

                    // Phase et candidat
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.01,
                      ),
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
                                fontSize: 18,
                                color: Colors.white,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),

                          // Nom du candidat
                          Text(
                            competition.candidatActuel?.nom.toUpperCase() ??
                                'EN ATTENTE',
                            style: TextStyle(
                              fontSize: screenHeight * 0.035,
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

                    // Zone d'épellation - avec hauteur contrôlée
                    Container(
                      height: screenHeight * 0.25, // 25% de l'écran
                      child: Center(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05,
                            ),
                            child: competition.motRevele
                                ? _buildRevealedWord(competition, screenHeight)
                                : _buildLiveSpelling(competition, screenHeight),
                          ),
                        ),
                      ),
                    ),

                    // Chronomètre et score en bas
                    Container(
                      width: double.infinity,
                      height:
                          screenHeight * 0.15, // J'ai ramener à 5% de l'écran
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.02,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.95),
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildTimer(competition, screenHeight),
                          _buildScore(competition, screenHeight),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimer(CompetitionService competition, double screenHeight) {
    final seconds = competition.chronoRestant;
    Color getTimerColor() {
      if (seconds > 30) return Colors.green;
      if (seconds > 10) return Colors.amber;
      return Colors.red;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TEMPS RESTANT',
          style: TextStyle(
            fontSize: screenHeight * 0.02, // 1.8% de la hauteur
            color: Colors.white.withOpacity(0.5),
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Text(
          '${(seconds ~/ 60).toString().padLeft(2, '0')}:'
          '${(seconds % 60).toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: screenHeight * 0.04, // 4.5% de la hauteur
            color: getTimerColor(),
            fontWeight: FontWeight.w300,
            fontFamily: 'Courier',
          ),
        ),
      ],
    );
  }

  Widget _buildScore(CompetitionService competition, double screenHeight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'SCORE',
          style: TextStyle(
            fontSize: screenHeight * 0.02, // 2% de la hauteur
            color: Colors.white.withOpacity(0.5),
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          '${competition.candidatActuel?.score ?? 0}',
          style: TextStyle(
            fontSize: screenHeight * 0.045, // 4,5% de la hauteur
            color: Colors.white,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildRevealedWord(
    CompetitionService competition,
    double screenHeight,
  ) {
    final mot = competition.motActuel?.orthographeOfficielle ?? '';
    final estCorrect = competition.epellationEstCorrecte;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          estCorrect ? Icons.check : Icons.close,
          size: screenHeight * 0.07, // 7% de la hauteur
          color: estCorrect ? Colors.green : Colors.red,
        ),
        SizedBox(height: screenHeight * 0.02),
        Text(
          mot.toUpperCase(),
          style: TextStyle(
            fontSize: screenHeight * 0.07, // 7% de la hauteur
            color: estCorrect ? Colors.green : Colors.red,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: screenHeight * 0.015),
        Text(
          estCorrect ? 'CORRECT' : 'INCORRECT',
          style: TextStyle(
            fontSize: screenHeight * 0.025, // 2.5% de la hauteur
            color: estCorrect ? Colors.green : Colors.red,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveSpelling(
    CompetitionService competition,
    double screenHeight,
  ) {
    final saisie = competition.epellationSaisie;
    final motOfficiel = competition.motActuel?.orthographeOfficielle ?? '';
    final screenWidth = 1920;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (saisie.isNotEmpty)
          // Conteneur avec hauteur maximale et scroll si nécessaire
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth * 0.8,
              maxHeight: screenHeight * 0.3,
            ),
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: screenWidth * 0.01,
                runSpacing: screenHeight * 0.01,
                children: List.generate(saisie.length, (index) {
                  bool estCorrecte = false;
                  if (index < motOfficiel.length) {
                    estCorrecte =
                        saisie[index].toUpperCase() ==
                        motOfficiel[index].toUpperCase();
                  }

                  return Container(
                    width: screenHeight * 0.06, // 6% de la hauteur
                    height: screenHeight * 0.08, // 8% de la hauteur
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
                          fontSize: screenHeight * 0.04, // 4% de la hauteur
                          color: estCorrecte ? Colors.green : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          )
        else
          Column(
            children: [
              Text(
                '...',
                style: TextStyle(
                  fontSize: screenHeight * 0.08, // 8% de la hauteur
                  color: Colors.white.withOpacity(0.1),
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'EN ATTENTE DE LA PREMIÈRE LETTRE',
                style: TextStyle(
                  fontSize: screenHeight * 0.016, // 1.6% de la hauteur
                  color: Colors.white.withOpacity(0.3),
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        SizedBox(height: screenHeight * 0.02),
        if (motOfficiel.isNotEmpty && saisie.isNotEmpty)
          Text(
            '${saisie.length} lettre${saisie.length > 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: screenHeight * 0.018,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
      ],
    );
  }
}
