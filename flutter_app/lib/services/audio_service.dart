import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  String? _currentUrl;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  bool get isPlaying => _player.playing;
  String? get currentUrl => _currentUrl;

  Future<void> playUrl(String url) async {
    if (url.isEmpty) return;
    try {
      if (_currentUrl != url) {
        _currentUrl = url;
        await _player.setUrl(url);
      }
      await _player.play();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pause() async => _player.pause();

  Future<void> stop() async {
    await _player.stop();
    _currentUrl = null;
  }

  Future<void> seekTo(Duration position) async => _player.seek(position);

  Future<void> togglePlayPause(String url) async {
    if (_currentUrl == url && isPlaying) {
      await pause();
    } else {
      await playUrl(url);
    }
  }

  void dispose() => _player.dispose();
}
