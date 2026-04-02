import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';

import '../core/models.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  List<Song> _queue = [];
  int _currentIndex = -1;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  AuraRepeatMode _repeatMode = AuraRepeatMode.off;
  AuraShuffleMode _shuffleMode = AuraShuffleMode.off;
  double _volume = 1.0;

  // ── Getters ─────────────────────────────────────────────────────────────────
  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  AuraRepeatMode get repeatMode => _repeatMode;
  AuraShuffleMode get shuffleMode => _shuffleMode;
  double get volume => _volume;
  bool get hasSong => _currentIndex >= 0 && _queue.isNotEmpty;

  Song? get currentSong => hasSong ? _queue[_currentIndex] : null;

  bool get canSkipNext =>
      _currentIndex < _queue.length - 1 || _repeatMode == AuraRepeatMode.all;
  bool get canSkipPrev =>
      _currentIndex > 0 || _repeatMode == AuraRepeatMode.all;

  // ── Init ────────────────────────────────────────────────────────────────────
  AudioProvider() {
    _initAudioSession();
    _listenToPlayerEvents();
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        if (_isPlaying) pause();
      } else {
        if (event.type == AudioInterruptionType.pause && !_isPlaying) {
          play();
        }
      }
    });
  }

  void _listenToPlayerEvents() {
    _player.playingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });

    _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _player.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });

    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _handleTrackComplete();
      }
    });
  }

  // ── Playback Controls ────────────────────────────────────────────────────────
  Future<void> playQueue(List<Song> songs, {int startIndex = 0}) async {
    _queue = List.from(songs);
    _currentIndex = startIndex.clamp(0, songs.length - 1);
    await _loadAndPlay();
  }

  Future<void> playSong(Song song) async {
    if (_queue.isEmpty) {
      _queue = [song];
      _currentIndex = 0;
    } else {
      final idx = _queue.indexWhere((s) => s.id == song.id);
      if (idx >= 0) {
        _currentIndex = idx;
      } else {
        _queue.insert(_currentIndex + 1, song);
        _currentIndex = _currentIndex + 1;
      }
    }
    await _loadAndPlay();
  }

  Future<void> _loadAndPlay() async {
    if (!hasSong) return;
    final song = currentSong!;

    try {
      final audioSource = AudioSource.uri(
        Uri.parse(song.uri),
        tag: MediaItem(
          id: song.id,
          title: song.displayTitle,
          artist: song.displayArtist,
          album: song.displayAlbum,
          artUri:
              song.albumArtUri != null ? Uri.parse(song.albumArtUri!) : null,
          duration: song.duration,
        ),
      );
      await _player.setAudioSource(audioSource);
      await _player.play();
      notifyListeners();
    } catch (e) {
      debugPrint('AudioProvider: Error loading ${song.uri} → $e');
    }
  }

  Future<void> play() async => await _player.play();
  Future<void> pause() async => await _player.pause();

  Future<void> togglePlayPause() async {
    _isPlaying ? await pause() : await play();
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  Future<void> seekToRelative(double ratio) async {
    final target =
        Duration(milliseconds: (_duration.inMilliseconds * ratio).round());
    await seekTo(target);
  }

  Future<void> skipNext() async {
    if (_queue.isEmpty) return;
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
    } else if (_repeatMode == AuraRepeatMode.all) {
      _currentIndex = 0;
    } else {
      return;
    }
    await _loadAndPlay();
  }

  Future<void> skipPrev() async {
    if (_queue.isEmpty) return;
    if (_position.inSeconds > 3) {
      await seekTo(Duration.zero);
      return;
    }
    if (_currentIndex > 0) {
      _currentIndex--;
    } else if (_repeatMode == AuraRepeatMode.all) {
      _currentIndex = _queue.length - 1;
    } else {
      await seekTo(Duration.zero);
      return;
    }
    await _loadAndPlay();
  }

  void toggleRepeat() {
    switch (_repeatMode) {
      case AuraRepeatMode.off:
        _repeatMode = AuraRepeatMode.all;
        break;
      case AuraRepeatMode.all:
        _repeatMode = AuraRepeatMode.one;
        break;
      case AuraRepeatMode.one:
        _repeatMode = AuraRepeatMode.off;
        break;
    }
    notifyListeners();
  }

  void toggleShuffle() {
    _shuffleMode = _shuffleMode == AuraShuffleMode.off
        ? AuraShuffleMode.on
        : AuraShuffleMode.off;
    if (_shuffleMode == AuraShuffleMode.on) {
      _shuffleQueue();
    }
    notifyListeners();
  }

  void _shuffleQueue() {
    if (_queue.length <= 1) return;
    final current = currentSong;
    _queue.shuffle();
    if (current != null) {
      _queue.remove(current);
      _queue.insert(0, current);
      _currentIndex = 0;
    }
  }

  Future<void> setVolume(double v) async {
    _volume = v.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
    notifyListeners();
  }

  void addToQueue(Song song) {
    _queue.add(song);
    notifyListeners();
  }

  void addNext(Song song) {
    final insertAt = (_currentIndex + 1).clamp(0, _queue.length);
    _queue.insert(insertAt, song);
    notifyListeners();
  }

  void _handleTrackComplete() {
    switch (_repeatMode) {
      case AuraRepeatMode.one:
        _loadAndPlay();
        break;
      case AuraRepeatMode.all:
        skipNext();
        break;
      case AuraRepeatMode.off:
        if (_currentIndex < _queue.length - 1) {
          skipNext();
        } else {
          _isPlaying = false;
          notifyListeners();
        }
        break;
    }
  }

  // ── Formatting ───────────────────────────────────────────────────────────────
  static String formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
