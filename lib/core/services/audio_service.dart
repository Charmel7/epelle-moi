import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  // Préchargement facultatif
  Future<void> preloadSounds() async {
    try {
      // On peut précharger en récupérant les sources, mais ce n'est pas obligatoire
      await _player.setAsset('assets/sounds/correct.mp3');
      await _player.setAsset('assets/sounds/incorrect.mp3');
    } catch (e) {
      // Ignorer les erreurs de préchargement
    }
  }

  Future<void> playCorrect() async {
    await _play('assets/sounds/correct.mp3');
  }

  Future<void> playIncorrect() async {
    await _play('assets/sounds/incorrect.mp3');
  }

  Future<void> _play(String assetPath) async {
    try {
      await _player.setAsset(assetPath);
      await _player.play();
    } catch (e) {
      // Silencieux en cas d'erreur (fichier manquant, etc.)
    }
  }

  void dispose() {
    _player.dispose();
  }
}
