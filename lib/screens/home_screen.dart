// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../core/theme.dart';
import '../providers/audio_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/song_tile.dart';
import 'player_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final audio = context.watch<AudioProvider>();

    return Scaffold(
      backgroundColor: AuraTheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour 👋',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aura Music',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ],
                ),
              ),
            ),

            // ── Now Playing Banner ───────────────────────────────────────────
            if (audio.hasSong)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: _NowPlayingBanner(audio: audio),
                ),
              ),

            // ── Recently Added ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                child: Text(
                  'Récemment ajoutés',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),

            // ── Song List ────────────────────────────────────────────────────
            if (library.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (library.status == LibraryStatus.permissionDenied)
              SliverFillRemaining(
                child: _PermissionPlaceholder(
                  onRetry: () => library.requestPermissionAndLoad(),
                ),
              )
            else if (library.songs.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text('Aucune musique trouvée sur l\'appareil.'),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final song = library.songs[i];
                    return SongTile(
                      song: song,
                      songId: int.tryParse(song.id) ?? 0,
                      isPlaying: audio.currentSong?.id == song.id,
                      onTap: () {
                        audio.playQueue(library.songs, startIndex: i);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PlayerScreen(),
                          ),
                        );
                      },
                    );
                  },
                  childCount: library.songs.length,
                ),
              ),

            // Bottom padding for mini-player
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}

// ── Now Playing Banner ──────────────────────────────────────────────────────────
class _NowPlayingBanner extends StatelessWidget {
  final AudioProvider audio;
  const _NowPlayingBanner({required this.audio});

  @override
  Widget build(BuildContext context) {
    final song = audio.currentSong!;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PlayerScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AuraTheme.primaryDark.withOpacity(0.7),
              AuraTheme.surfaceCard,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: AuraTheme.primary.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AuraTheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: QueryArtworkWidget(
                id: int.tryParse(song.id) ?? 0,
                type: ArtworkType.AUDIO,
                nullArtworkWidget: const Icon(
                  Icons.music_note_rounded,
                  color: AuraTheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.displayTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    song.displayArtist,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(
              audio.isPlaying
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_filled_rounded,
              color: AuraTheme.primary,
              size: 36,
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionPlaceholder extends StatelessWidget {
  final VoidCallback onRetry;
  const _PermissionPlaceholder({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline_rounded,
                size: 64, color: AuraTheme.onSurfaceMuted),
            const SizedBox(height: 16),
            Text(
              'Accès au stockage requis',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Aura Music a besoin d\'accéder à vos fichiers audio pour lire votre musique.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Autoriser l\'accès'),
            ),
          ],
        ),
      ),
    );
  }
}
