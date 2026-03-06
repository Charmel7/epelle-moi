class Word {
  final String mot;
  final String orthographeOfficielle;
  final String definition;
  final String exemple;
  final String natureGrammaticale;
  final String etymologie;
  final String categorie;
  final int niveauDifficulte;
  final bool estValide;
  final String prononciation;
  bool estUtilise;

  Word({
    required this.mot,
    required this.orthographeOfficielle,
    required this.definition,
    required this.exemple,
    required this.natureGrammaticale,
    required this.etymologie,
    required this.categorie,
    required this.niveauDifficulte,
    required this.estValide,
    required this.prononciation,
    this.estUtilise = false,
  });

  factory Word.fromCsv(Map<String, dynamic> csvRow) {
    print('Clés disponibles : ${csvRow.keys}');
    print('Valeur de Prononciation : "${csvRow['Prononciation']}"');
    print('--- CSV HEADER ---');
    csvRow.forEach((key, value) {
      print('$key => "$value"');
    });
    return Word(
      mot: csvRow['Mot']?.toString().trim() ?? '',
      orthographeOfficielle:
          csvRow['Orthographe Officielle']?.toString().trim() ?? '',
      prononciation:
          csvRow['Prononciation']?.toString().trim() ??
          'Prononciation non trouvée',
      definition: csvRow['Définition(s)']?.toString().trim() ?? '',
      exemple: csvRow['Exemple de Phrase']?.toString().trim() ?? '',
      natureGrammaticale:
          csvRow['Nature Grammaticale']?.toString().trim() ?? '',
      etymologie: csvRow['Étymologie']?.toString().trim() ?? '',
      categorie: csvRow['Catégorie']?.toString().trim() ?? '',
      niveauDifficulte:
          int.tryParse(csvRow['Niveau de Difficulté']?.toString() ?? '3') ?? 3,
      estValide: (csvRow['Statut']?.toString() ?? '') == '✓',
      estUtilise: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Mot': mot,
      'Orthographe Officielle': orthographeOfficielle,
      'Définition(s)': definition,
      'Exemple de Phrase': exemple,
      'Nature Grammaticale': natureGrammaticale,
      'Étymologie': etymologie,
      'Catégorie': categorie,
      'Niveau de Difficulté': niveauDifficulte.toString(),
      'Statut': estValide ? '✓' : '',
      'Prononciation': prononciation,
      'Utilisé': estUtilise ? 'Oui' : 'Non',
    };
  }
}
