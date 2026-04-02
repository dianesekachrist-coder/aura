// lib/providers/player_provider.dart
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import '../models/song.dart';
import '../services/audio_handler.dart';

class PlayerProvider extends ChangeNotifier {
  final AuraAudioHandler _handler;

  PlayerProvider(this._handler) {
    // Forward stream events to UI.
    _handler.playbackState.listen((_) => notifyListeners());
    _handler.mediaItem.listen((_) => notifyListeners());
    _handler.player.positionStream.listen((_) => notifyListeners());
    _handler.player.durationStream.listen((_) => notifyListeners());
  }

  // ── State ─────────────────────────────────────────────────────────────────

  Song? _currentSong;
  Song? get currentSong => _currentSong;

  List<Song> _queue = [];

  bool get isPlaying => _handler.playbackState.value.playing;

  Duration get position => _handler.player.position;

  Duration get duration =>
      _handler.player.duration ?? const Duration(seconds: 1);

  double get progress {
    final d = duration.inMilliseconds;
    if (d == 0) return 0;
    return (position.inMilliseconds / d).clamp(0.0, 1.0);
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> playSong(Song song, {List<Song>? queue}) async {
    _currentSong = song;
    _queue = queue ?? mockSongs;
    notifyListeners();

    final mediaItems = _queue.map(_toMediaItem).toList();
    final item = _toMediaItem(song);
    await _handler.loadAndPlay(item, mediaItems);
  }

  Future<void> togglePlayPause() async {
    isPlaying ? await _handler.pause() : await _handler.play();
  }

  Future<void> next() => _handler.skipToNext();
  Future<void> previous() => _handler.skipToPrevious();

  Future<void> seekTo(double value) {
    final ms = (value * duration.inMilliseconds).round();
    return _handler.seek(Duration(milliseconds: ms));
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  MediaItem _toMediaItem(Song s) => MediaItem(
        id: s.id,
        title: s.title,
        artist: s.artist,
        album: s.album,
        duration: s.duration,
        extras: {'url': s.audioUrl},
      );

  Song? nextSong() {
    if (_currentSong == null) return null;
    final idx = _queue.indexWhere((s) => s.id == _currentSong!.id);
    if (idx < _queue.length - 1) return _queue[idx + 1];
    return null;
  }

  Song? previousSong() {
    if (_currentSong == null) return null;
    final idx = _queue.indexWhere((s) => s.id == _currentSong!.id);
    if (idx > 0) return _queue[idx - 1];
    return null;
  }
}
