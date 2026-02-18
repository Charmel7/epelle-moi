import 'dart:convert' show utf8;
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:epellemoi/core/services/persistence_service.dart'
    show PersistenceService;
import 'package:file_picker/file_picker.dart';

import '../models/word.dart';

class CsvService {
  Future<List<Word>> loadWordsFromCsv(String csvContent) async {
    try {
      final converter = const CsvToListConverter();
      final rows = converter.convert(csvContent, eol: '\n');

      if (rows.isEmpty) return [];

      final headers = List<String>.from(rows[0]);

      final words = <Word>[];

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        final Map<String, dynamic> mappedRow = {};

        for (int j = 0; j < headers.length; j++) {
          if (j < row.length) {
            mappedRow[headers[j]] = row[j]?.toString() ?? '';
          }
        }

        // Vérifier que le mot n'est pas vide
        if (mappedRow['Mot']?.toString().trim().isNotEmpty == true) {
          words.add(Word.fromCsv(mappedRow));
        }
      }

      return words;
    } catch (e) {
      print('Erreur lors du chargement CSV: $e');
      return [];
    }
  }

  String exportWordsToCsv(List<Word> words) {
    final List<List<dynamic>> rows = [];

    // En-têtes
    rows.add([
      'Mot',
      'Orthographe Officielle',
      'Définition(s)',
      'Exemple de Phrase',
      'Nature Grammaticale',
      'Étymologie',
      'Catégorie',
      'Niveau de Difficulté',
      'Statut',
      'Utilisé',
    ]);

    // Données
    for (final word in words) {
      rows.add([
        word.mot,
        word.orthographeOfficielle,
        word.definition,
        word.exemple,
        word.natureGrammaticale,
        word.etymologie,
        word.categorie,
        word.niveauDifficulte,
        word.estValide ? '✓' : '',
        word.estUtilise ? 'Oui' : 'Non',
      ]);
    }

    final converter = const ListToCsvConverter();
    return converter.convert(rows);
  }

  Future<void> saveWordsToLastFile(List<Word> words) async {
    try {
      final path = await PersistenceService.getLastCsvPath();
      if (path == null || path.isEmpty) {
        print(
          'Aucun chemin de fichier CSV sauvegardé. Impossible de mettre à jour.',
        );
        return;
      }

      final file = File(path);
      if (!await file.exists()) {
        print('Le fichier CSV d\'origine n\'existe plus au chemin: $path');
        return;
      }

      final csvContent = exportWordsToCsv(words);
      await file.writeAsString(csvContent, flush: true);
      print('Fichier CSV mis à jour avec le nouveau statut des mots.');
    } catch (e) {
      print('Erreur lors de la mise à jour du fichier CSV: $e');
    }
  }

  Future<List<Word>> loadWordsFromFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
        allowMultiple: false,
        dialogTitle: 'Sélectionnez le fichier CSV des mots',
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.extension?.toLowerCase() != 'csv') {
          throw Exception('Veuillez sélectionner un fichier CSV');
        }

        String csvContent;

        // Si le fichier est déjà chargé en mémoire
        if (file.bytes != null) {
          csvContent = utf8.decode(file.bytes!);
        }
        // Sinon, lire depuis le chemin
        else if (file.path != null) {
          final fileContent = File(file.path!);
          csvContent = await fileContent.readAsString();
          await PersistenceService.saveLastCsvPath(file.path!);
        } else {
          throw Exception('Impossible de lire le fichier');
        }

        return await loadWordsFromCsv(csvContent);
      }

      return [];
    } catch (e) {
      print('Erreur lors du chargement du fichier: $e');
      rethrow;
    }
  }

  // Méthode pour charger depuis un chemin spécifique (pour tests)
  Future<List<Word>> loadWordsFromPath(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Le fichier n\'existe pas: $filePath');
      }

      final csvContent = await file.readAsString();
      return await loadWordsFromCsv(csvContent);
    } catch (e) {
      print('Erreur lors du chargement depuis le chemin: $e');
      rethrow;
    }
  }
}
