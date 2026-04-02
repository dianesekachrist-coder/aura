// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/models.dart';

enum LibraryStatus { idle, loading, ready, permissionDenied, error }

class LibraryProvider extends ChangeNotifier {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  LibraryStatus _status = LibraryStatus.idle;
  List<Song> _songs = [];
  List<Song> _filteredSongs = [];
  String _searchQuery = '';
  String? _errorMessage;

  LibraryStatus get status => _status;
  List<Song> get songs => _songs;
  List<Song> get filteredSongs => _filteredSongs;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == LibraryStatus.loading;
  bool get hasPermission => _status != LibraryStatus.permissionDenied;

  // ── Public API ────────────────────────────────────────────────────────────────
  Future<void> init() async {
    if (_status == LibraryStatus.ready) return;
    await requestPermissionAndLoad();
  }

  Future<void> requestPermissionAndLoad() async {
    _setStatus(LibraryStatus.loading);

    final granted = await _requestStoragePermission();
    if (!granted) {
      _setStatus(LibraryStatus.permissionDenied);
      return;
    }

    await _loadSongs();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    _applyFilter();
    notifyListeners();
  }

  void clearSearch() => setSearchQuery('');

  Future<void> refresh() async {
    _songs = [];
    _filteredSongs = [];
    await requestPermissionAndLoad();
  }

  // ── Private Helpers ───────────────────────────────────────────────────────────
  Future<bool> _requestStoragePermission() async {
    // Android 13+ uses READ_MEDIA_AUDIO
    Permission p = Permission.audio;
    var status = await p.status;
    if (status.isDenied) {
      status = await p.request();
    }
    // Fallback for older Android
    if (status.isPermanentlyDenied) {
      // Also try READ_EXTERNAL_STORAGE for Android <= 12
      var legacyStatus = await Permission.storage.status;
      if (legacyStatus.isDenied)
        legacyStatus = await Permission.storage.request();
      return legacyStatus.isGranted;
    }
    return status.isGranted;
  }

  Future<void> _loadSongs() async {
    try {
      final rawSongs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      // Filter: skip very short tracks (ringtones etc.) and tracks without URI
      _songs = rawSongs
          .where((s) =>
              s.duration != null &&
              s.duration! > 30000 && // > 30 seconds
              s.uri != null)
          .map(_mapToSong)
          .toList();

      _applyFilter();
      _setStatus(LibraryStatus.ready);
    } catch (e) {
      _errorMessage = e.toString();
      _setStatus(LibraryStatus.error);
      debugPrint('LibraryProvider error: $e');
    }
  }

  Song _mapToSong(SongModel s) {
    return Song(
      id: s.id.toString(),
      title: s.title,
      artist: s.artist ?? 'Unknown Artist',
      album: s.album ?? 'Unknown Album',
      albumArtUri: s.uri, // on_audio_query provides this for artwork lookup
      uri: s.uri!,
      duration: Duration(milliseconds: s.duration ?? 0),
      trackNumber: s.track ?? 0,
    );
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredSongs = List.from(_songs);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredSongs = _songs.where((s) {
        return s.title.toLowerCase().contains(q) ||
            s.artist.toLowerCase().contains(q) ||
            s.album.toLowerCase().contains(q);
      }).toList();
    }
  }

  void _setStatus(LibraryStatus s) {
    _status = s;
    notifyListeners();
  }
}
