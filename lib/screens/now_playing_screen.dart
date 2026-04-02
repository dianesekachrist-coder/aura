// lib/screens/now_playing_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/album_art.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = player.currentSong;
    if (song == null) return const Scaffold();

    final accent = Color(song.colors[0]);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              accent.withOpacity(0.25),
              AppTheme.background,
              AppTheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 12),
                _TopBar(accent: accent),
                const SizedBox(height: 40),
                _BigAlbumArt(song: song),
                const SizedBox(height: 36),
                _SongInfo(
                    title: song.title, artist: song.artist, accent: accent),
                const SizedBox(height: 28),
                _SeekBar(player: player, accent: accent, fmt: _fmt),
                const SizedBox(height: 20),
                _Controls(player: player, accent: accent),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final Color accent;
  const _TopBar({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
          color: AppTheme.textSub,
        ),
        Text('Now Playing',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(letterSpacing: 1.2, fontSize: 12)),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_horiz_rounded, size: 24),
          color: AppTheme.textSub,
        ),
      ],
    );
  }
}

class _BigAlbumArt extends StatelessWidget {
  final dynamic song;
  const _BigAlbumArt({required this.song});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AlbumArt(
        song: song,
        size: MediaQuery.of(context).size.width * 0.72,
        borderRadius: 28,
      ),
    );
  }
}

class _SongInfo extends StatelessWidget {
  final String title;
  final String artist;
  final Color accent;
  const _SongInfo(
      {required this.title, required this.artist, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context).textTheme.displaySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(artist,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Icon(Icons.favorite_border_rounded, color: accent, size: 26),
      ],
    );
  }
}

class _SeekBar extends StatelessWidget {
  final PlayerProvider player;
  final Color accent;
  final String Function(Duration) fmt;
  const _SeekBar(
      {required this.player, required this.accent, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: accent,
            thumbColor: accent,
            overlayColor: accent.withOpacity(0.15),
          ),
          child: Slider(
            value: player.progress,
            onChanged: player.seekTo,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fmt(player.position),
                  style: Theme.of(context).textTheme.bodySmall),
              Text(fmt(player.duration),
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  final PlayerProvider player;
  final Color accent;
  const _Controls({required this.player, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ControlBtn(
          icon: Icons.shuffle_rounded,
          color: AppTheme.textSub,
          size: 22,
          onTap: () {},
        ),
        _ControlBtn(
          icon: Icons.skip_previous_rounded,
          color: AppTheme.textPrimary,
          size: 36,
          onTap: player.previous,
        ),
        _PlayPauseBtn(player: player, accent: accent),
        _ControlBtn(
          icon: Icons.skip_next_rounded,
          color: AppTheme.textPrimary,
          size: 36,
          onTap: player.next,
        ),
        _ControlBtn(
          icon: Icons.repeat_rounded,
          color: AppTheme.textSub,
          size: 22,
          onTap: () {},
        ),
      ],
    );
  }
}

class _PlayPauseBtn extends StatelessWidget {
  final PlayerProvider player;
  final Color accent;
  const _PlayPauseBtn({required this.player, required this.accent});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: player.togglePlayPause,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [accent, accent.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.45),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 38,
        ),
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;
  const _ControlBtn(
      {required this.icon,
      required this.color,
      required this.size,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: color, size: size),
    );
  }
}
