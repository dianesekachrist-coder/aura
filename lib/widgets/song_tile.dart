// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../core/models.dart';
import '../core/theme.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final int songId;
  final bool isPlaying;
  final VoidCallback onTap;

  const SongTile({
    super.key,
    required this.song,
    required this.songId,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isPlaying
              ? AuraTheme.primary.withOpacity(0.07)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Album art
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AuraTheme.surfaceCard,
              ),
              clipBehavior: Clip.antiAlias,
              child: QueryArtworkWidget(
                id: songId,
                type: ArtworkType.AUDIO,
                artworkBorder: BorderRadius.circular(12),
                artworkWidth: 50,
                artworkHeight: 50,
                nullArtworkWidget: Container(
                  color: AuraTheme.surfaceCard,
                  child: Center(
                    child: Icon(
                      Icons.music_note_rounded,
                      color: isPlaying
                          ? AuraTheme.primary
                          : AuraTheme.onSurfaceMuted,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.displayTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isPlaying
                              ? AuraTheme.primary
                              : AuraTheme.onSurface,
                          fontSize: 14,
                          fontWeight:
                              isPlaying ? FontWeight.w600 : FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.displayArtist,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Duration
            Text(
              _fmt(song.duration),
              style: Theme.of(context).textTheme.labelSmall,
            ),

            // Playing indicator
            if (isPlaying) ...[
              const SizedBox(width: 10),
              const _PulsingDot(),
            ],
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: AuraTheme.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
