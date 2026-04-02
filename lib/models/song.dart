class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;

  /// URL or asset path. Use a royalty-free stream for demo purposes.
  final String audioUrl;

  /// Gradient color pair for the album art placeholder
  final List<int> colors;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.audioUrl,
    required this.colors,
  });
}

/// Mock catalogue – swap audioUrl with real URLs or on-device paths later.
final List<Song> mockSongs = [
  Song(
    id: '1',
    title: 'Neon Drift',
    artist: 'Synthwave Collective',
    album: 'Electric Horizons',
    duration: const Duration(minutes: 3, seconds: 42),
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    colors: [0xFF00BCD4, 0xFF006064],
  ),
  Song(
    id: '2',
    title: 'Midnight Circuit',
    artist: 'Codebreaker',
    album: 'Binary Dreams',
    duration: const Duration(minutes: 4, seconds: 15),
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    colors: [0xFF7C4DFF, 0xFF311B92],
  ),
  Song(
    id: '3',
    title: 'Solar Winds',
    artist: 'Aurora Project',
    album: 'Cosmic Layers',
    duration: const Duration(minutes: 3, seconds: 58),
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    colors: [0xFFFF6D00, 0xFFE65100],
  ),
  Song(
    id: '4',
    title: 'Glass City',
    artist: 'Velvet Static',
    album: 'Transparent World',
    duration: const Duration(minutes: 5, seconds: 3),
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
    colors: [0xFF26A69A, 0xFF004D40],
  ),
  Song(
    id: '5',
    title: 'Pulse Protocol',
    artist: 'Freq Division',
    album: 'Signal / Noise',
    duration: const Duration(minutes: 3, seconds: 29),
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
    colors: [0xFFEC407A, 0xFF880E4F],
  ),
  Song(
    id: '6',
    title: 'Afterglow',
    artist: 'Liminal Space',
    album: 'Between Worlds',
    duration: const Duration(minutes: 4, seconds: 44),
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
    colors: [0xFF42A5F5, 0xFF0D47A1],
  ),
];
