import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
