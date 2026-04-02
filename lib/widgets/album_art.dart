// lib/widgets/album_art.dart
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../theme/app_theme.dart';

class AlbumArt extends StatelessWidget {
  final Song song;
  final double size;
  final double borderRadius;

  const AlbumArt({
    super.key,
    required this.song,
    this.size = 56,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final c1 = Color(song.colors[0]);
    final c2 = Color(song.colors[1]);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: [c1, c2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: c1.withOpacity(0.4),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Center(
        child: Icon(Icons.music_note_rounded,
            color: AppTheme.textPrimary.withOpacity(0.8), size: size * 0.4),
      ),
    );
  }
}
