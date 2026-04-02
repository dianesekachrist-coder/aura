import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/audio_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/mini_player.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  static const _pages = [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Kick off library scan after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // Page content — IndexedStack keeps pages alive (music won't cut off)
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),

          // Mini player sits above nav bar
          if (audio.hasSong)
            Positioned(
              left: 0,
              right: 0,
              bottom: kBottomNavigationBarHeight +
                  MediaQuery.of(context).padding.bottom,
              child: const MiniPlayer(),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Recherche',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_music_outlined),
            selectedIcon: Icon(Icons.library_music_rounded),
            label: 'Bibliothèque',
          ),
        ],
      ),
    );
  }
}
