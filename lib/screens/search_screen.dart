import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/audio_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/song_tile.dart';
import 'player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final audio = context.watch<AudioProvider>();
    final hasQuery = library.searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: AuraTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recherche',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: (v) => library.setSearchQuery(v),
                    style: const TextStyle(color: AuraTheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Titres, artistes, albums…',
                      hintStyle:
                          const TextStyle(color: AuraTheme.onSurfaceMuted),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AuraTheme.onSurfaceMuted),
                      suffixIcon: hasQuery
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  color: AuraTheme.onSurfaceMuted),
                              onPressed: () {
                                _controller.clear();
                                library.clearSearch();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AuraTheme.surfaceCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AuraTheme.primary, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Results ──────────────────────────────────────────────────────
            Expanded(
              child: hasQuery
                  ? library.filteredSongs.isEmpty
                      ? Center(
                          child: Text(
                            'Aucun résultat pour "${library.searchQuery}"',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : ListView.builder(
                          itemCount: library.filteredSongs.length,
                          itemBuilder: (context, i) {
                            final song = library.filteredSongs[i];
                            return SongTile(
                              song: song,
                              songId: int.tryParse(song.id) ?? 0,
                              isPlaying: audio.currentSong?.id == song.id,
                              onTap: () {
                                audio.playQueue(library.filteredSongs,
                                    startIndex: i);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const PlayerScreen()),
                                );
                              },
                            );
                          },
                        )
                  : _SearchEmptyState(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.graphic_eq_rounded,
              size: 72, color: AuraTheme.onSurfaceMuted),
          const SizedBox(height: 16),
          Text(
            'Trouvez votre musique',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Recherchez par titre, artiste ou album',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
