import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'providers/audio_provider.dart';
import 'providers/library_provider.dart';
import 'screens/main_scaffold.dart';
import 'core/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize just_audio_background for media notification & background playback
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.aura_music.channel.audio',
    androidNotificationChannelName: 'Aura Music Playback',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
  );

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar for immersive UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
  ));

  runApp(const AuraMusicApp());
}

class AuraMusicApp extends StatelessWidget {
  const AuraMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
      ],
      child: MaterialApp(
        title: 'Aura Music',
        debugShowCheckedModeBanner: false,
        theme: AuraTheme.darkTheme,
        home: const MainScaffold(),
      ),
    );
  }
}
