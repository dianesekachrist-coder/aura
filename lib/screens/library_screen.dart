import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/models.dart'; // ✅ Requis pour le type Song
import '../core/theme.dart';
import '../providers/audio_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/song_tile.dart';
import 'player_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final audio = context.watch<AudioProvider>();

    return Scaffold(
      backgroundColor: AuraTheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Bibliothèque',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: () => library.refresh(),
                      color: AuraTheme.onSurfaceMuted,
                    ),
                  ],
                ),
              ),
            ),

            // Stats row
            if (library.songs.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: _StatsRow(count: library.songs.length),
                ),
              ),

            // Play all button
            if (library.songs.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.play_arrow_rounded,
                          label: 'Tout lire',
                          onTap: () {
                            audio.playQueue(library.songs, startIndex: 0);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const PlayerScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.shuffle_rounded,
                          label: 'Aléatoire',
                          secondary: true,
                          onTap: () {
                            final shuffled = List<Song>.from(library.songs)
                              ..shuffle();
                            audio.playQueue(shuffled, startIndex: 0);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const PlayerScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Song list
            if (library.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
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
                              builder: (_) => const PlayerScreen()),
                        );
                      },
                    );
                  },
                  childCount: library.songs.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int count;
  const _StatsRow({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AuraTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.library_music_rounded,
              color: AuraTheme.primary, size: 20),
          const SizedBox(width: 10),
          Text(
            '$count titres',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool secondary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: secondary ? AuraTheme.surfaceCard : AuraTheme.primary,
          borderRadius: BorderRadius.circular(14),
          border: secondary ? Border.all(color: AuraTheme.divider) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: secondary ? AuraTheme.onSurface : Colors.white,
                size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: secondary ? AuraTheme.onSurface : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
