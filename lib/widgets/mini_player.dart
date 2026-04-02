// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../core/theme.dart';
import '../providers/audio_provider.dart';
import '../screens/player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    final song = audio.currentSong;
    if (song == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a1, a2) => const PlayerScreen(),
          transitionsBuilder: (_, a1, __, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: a1, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 380),
        ),
      ),
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AuraTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AuraTheme.divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Progress line
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _ProgressLine(audio: audio),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // Album art with Hero
                    Hero(
                      tag: 'album_art_${song.id}',
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AuraTheme.surfaceCard,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: QueryArtworkWidget(
                          id: int.tryParse(song.id) ?? 0,
                          type: ArtworkType.AUDIO,
                          artworkBorder: BorderRadius.circular(12),
                          artworkWidth: 46,
                          artworkHeight: 46,
                          nullArtworkWidget: const Icon(
                            Icons.music_note_rounded,
                            color: AuraTheme.primary,
                            size: 22,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Song info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            song.displayTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontSize: 14,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            song.displayArtist,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontSize: 12,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Prev
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded),
                      onPressed: () => audio.skipPrev(),
                      iconSize: 22,
                      color: AuraTheme.onSurface,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                    const SizedBox(width: 4),

                    // Play/Pause
                    IconButton(
                      icon: Icon(
                        audio.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      onPressed: () => audio.togglePlayPause(),
                      iconSize: 30,
                      color: AuraTheme.primary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                    const SizedBox(width: 4),

                    // Next
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded),
                      onPressed: () => audio.skipNext(),
                      iconSize: 22,
                      color: AuraTheme.onSurface,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final AudioProvider audio;
  const _ProgressLine({required this.audio});

  @override
  Widget build(BuildContext context) {
    final ratio = audio.duration.inMilliseconds > 0
        ? (audio.position.inMilliseconds / audio.duration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    return LayoutBuilder(
      builder: (_, constraints) => Container(
        height: 2,
        width: constraints.maxWidth * ratio,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AuraTheme.primary, AuraTheme.accent],
          ),
        ),
      ),
    );
  }
}
