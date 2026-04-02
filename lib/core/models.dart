import 'package:equatable/equatable.dart';

class Song extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String? albumArtUri;
  final String uri; // local file URI
  final Duration duration;
  final int trackNumber;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.albumArtUri,
    required this.uri,
    required this.duration,
    this.trackNumber = 0,
  });

  String get displayArtist => artist.isEmpty ? 'Unknown Artist' : artist;
  String get displayAlbum => album.isEmpty ? 'Unknown Album' : album;
  String get displayTitle => title.isEmpty ? 'Unknown Track' : title;

  @override
  List<Object?> get props => [id, uri];
}

// ✅ Préfixe Aura pour éviter les conflits avec flutter/material.dart et on_audio_query
enum AuraRepeatMode { off, all, one }

enum AuraShuffleMode { off, on }
