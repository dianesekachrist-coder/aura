// lib/services/audio_handler.dart
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// Bridges audio_service ↔ just_audio.
/// Handles lock-screen controls and notification.
class AuraAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();

  AuraAudioHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  // ── Playback controls ────────────────────────────────────────────────────

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    final current = playbackState.value.queueIndex ?? 0;
    if (queue.value.isNotEmpty && current < queue.value.length - 1) {
      await skipToQueueItem(current + 1);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    final current = playbackState.value.queueIndex ?? 0;
    if (current > 0) {
      await skipToQueueItem(current - 1);
    } else {
      await seek(Duration.zero);
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    final item = queue.value[index];
    mediaItem.add(item);
    await _player.setUrl(item.extras!['url'] as String);
    await _player.play();
  }

  // ── Public helper called by the provider ─────────────────────────────────

  Future<void> loadAndPlay(MediaItem item, List<MediaItem> fullQueue) async {
    queue.add(fullQueue);
    final index = fullQueue.indexOf(item);
    await skipToQueueItem(index);
  }

  AudioPlayer get player => _player;

  // ── Internal ─────────────────────────────────────────────────────────────

  PlaybackState _transformEvent(PlaybackEvent event) {
    final processing = {
      ProcessingState.idle: AudioProcessingState.idle,
      ProcessingState.loading: AudioProcessingState.loading,
      ProcessingState.buffering: AudioProcessingState.buffering,
      ProcessingState.ready: AudioProcessingState.ready,
      ProcessingState.completed: AudioProcessingState.completed,
    }[_player.processingState]!;

    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        _player.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: processing,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
