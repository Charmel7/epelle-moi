import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/candidate.dart';

class PersistenceService {
  static const String _keyLastCsvPath = 'last_csv_path';
  static const String _keyCandidates = 'candidates';

  // ---- Chemin CSV ----
  static Future<void> saveLastCsvPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastCsvPath, path);
  }

  static Future<String?> getLastCsvPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastCsvPath);
  }

  // ---- Candidats ----
  static Future<void> saveCandidates(List<Candidate> candidates) async {
    final prefs = await SharedPreferences.getInstance();
    // Convertir chaque candidat en Map, puis la liste en String JSON
    final List<Map<String, dynamic>> candidatesMap = candidates
        .map((c) => c.toJson())
        .toList();
    final String encoded = jsonEncode(candidatesMap);
    await prefs.setString(_keyCandidates, encoded);
  }

  static Future<List<Candidate>> loadCandidates() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_keyCandidates);
    if (data == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.map((item) => Candidate.fromJson(item)).toList();
    } catch (e) {
      print('Erreur de chargement des candidats: $e');
      return [];
    }
  }

  // ---- Effacer toutes les données persistées ----
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
