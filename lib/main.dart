import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/strings.dart';
import 'ui/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Pick the best UI language from the device locale (en/de/es/nl,
  // falls back to English). Works fully offline.
  L10n.detect();
  // The courtyard looks best in landscape.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const GorodkiApp());
}

class GorodkiApp extends StatelessWidget {
  const GorodkiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gorodki: Courtyard Edition',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6D4C2F)),
        fontFamily: 'monospace',
      ),
      home: const GameScreen(),
    );
  }
}
