// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart'
    as oaq; // ✅ préfixe pour éviter le conflit RepeatMode

import '../core/theme.dart';
import '../core/models.dart'; // RepeatMode, ShuffleMode, Song
import '../providers/audio_provider.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    final song = audio.currentSong;

    if (song == null) {
      return const Scaffold(
          body: Center(child: Text('Aucune lecture en cours')));
    }

    return Scaffold(
      backgroundColor: AuraTheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AuraTheme.primaryDark.withOpacity(0.4),
              AuraTheme.surface,
              AuraTheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──────────────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'En lecture',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  letterSpacing: 1.5,
                                  color: AuraTheme.onSurfaceMuted,
                                ),
                          ),
                          Text(
                            song.displayAlbum,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert_rounded),
                      onPressed: () => _showOptionsSheet(context, audio, song),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // ── Album Art with Hero animation ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Hero(
                  tag: 'album_art_${song.id}',
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: audio.isPlaying ? 300 : 260,
                    height: audio.isPlaying ? 300 : 260,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AuraTheme.primary.withOpacity(0.3),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: oaq.QueryArtworkWidget(
                      id: int.tryParse(song.id) ?? 0,
                      type: oaq.ArtworkType.AUDIO,
                      artworkBorder: BorderRadius.circular(28),
                      artworkWidth: 300,
                      artworkHeight: 300,
                      nullArtworkWidget: Container(
                        color: AuraTheme.surfaceElevated,
                        child: const Center(
                          child: Icon(Icons.music_note_rounded,
                              size: 80, color: AuraTheme.primary),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // ── Song Info ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.displayTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song.displayArtist,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontSize: 15,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_border_rounded),
                      color: AuraTheme.primary,
                      onPressed: () {}, // TODO: favorites feature
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Progress Slider ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context),
                      child: Slider(
                        value: audio.duration.inMilliseconds > 0
                            ? (audio.position.inMilliseconds /
                                    audio.duration.inMilliseconds)
                                .clamp(0.0, 1.0)
                            : 0.0,
                        onChanged: (v) => audio.seekToRelative(v),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AudioProvider.formatDuration(audio.position),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            AudioProvider.formatDuration(audio.duration),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Controls ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Shuffle
                    _ControlIcon(
                      icon: Icons.shuffle_rounded,
                      size: 22,
                      color: audio.shuffleMode == AuraShuffleMode.on
                          ? AuraTheme.primary
                          : AuraTheme.onSurfaceMuted,
                      onTap: () => audio.toggleShuffle(),
                    ),

                    // Prev
                    _ControlIcon(
                      icon: Icons.skip_previous_rounded,
                      size: 36,
                      onTap: () => audio.skipPrev(),
                    ),

                    // Play / Pause
                    GestureDetector(
                      onTap: () => audio.togglePlayPause(),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AuraTheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AuraTheme.primary.withOpacity(0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          audio.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),

                    // Next
                    _ControlIcon(
                      icon: Icons.skip_next_rounded,
                      size: 36,
                      onTap: () => audio.skipNext(),
                    ),

                    // Repeat
                    _ControlIcon(
                      icon: audio.repeatMode == AuraRepeatMode.one
                          ? Icons.repeat_one_rounded
                          : Icons.repeat_rounded,
                      size: 22,
                      color: audio.repeatMode == AuraRepeatMode.off
                          ? AuraTheme.onSurfaceMuted
                          : AuraTheme.primary,
                      onTap: () => audio.toggleRepeat(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Volume ───────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  children: [
                    const Icon(Icons.volume_down_rounded,
                        size: 18, color: AuraTheme.onSurfaceMuted),
                    Expanded(
                      child: Slider(
                        value: audio.volume,
                        onChanged: (v) => audio.setVolume(v),
                      ),
                    ),
                    const Icon(Icons.volume_up_rounded,
                        size: 18, color: AuraTheme.onSurfaceMuted),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsSheet(BuildContext context, AudioProvider audio, Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AuraTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AuraTheme.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading:
                const Icon(Icons.queue_music_rounded, color: AuraTheme.primary),
            title: const Text('Ajouter à la file'),
            onTap: () {
              audio.addToQueue(song);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ajouté à la file d\'attente')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.play_circle_outline_rounded,
                color: AuraTheme.primary),
            title: const Text('Lire ensuite'),
            onTap: () {
              audio.addNext(song);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ControlIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final VoidCallback onTap;

  const _ControlIcon({
    required this.icon,
    required this.onTap,
    this.size = 28,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: size, color: color ?? AuraTheme.onSurface),
      ),
    );
  }
}
