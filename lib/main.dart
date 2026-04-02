import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/player_provider.dart';
import 'screens/home_screen.dart';
import 'services/audio_handler.dart';
import 'theme/app_theme.dart';

late AuraAudioHandler _audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _audioHandler = await AudioService.init(
    builder: () => AuraAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.chris.auramusic.audio',
      androidNotificationChannelName: 'Aura Music Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => PlayerProvider(_audioHandler),
      child: const AuraMusicApp(),
    ),
  );
}

class AuraMusicApp extends StatelessWidget {
  const AuraMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura Music',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
