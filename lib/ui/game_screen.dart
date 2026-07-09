import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../game/audio_manager.dart';
import '../game/game_controller.dart';
import '../game/figures.dart';
import 'scene_painter.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final GameController game;
  late final AudioManager audio;
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  Offset? _dragStart;

  @override
  void initState() {
    super.initState();
    audio = AudioManager();
    game = GameController();
    game.onSound = audio.playSfx;
    _ticker = createTicker((elapsed) {
      final dt = (_last == Duration.zero)
          ? 0.016
          : (elapsed - _last).inMicroseconds / 1e6;
      _last = elapsed;
      game.tick(dt);
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    game.dispose();
    audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87B5D6),
      body: AnimatedBuilder(
        animation: game,
        builder: (context, _) {
          return Stack(
            children: [
              // The courtyard.
              Positioned.fill(
                child: GestureDetector(
                  onPanStart: (d) => _dragStart = d.localPosition,
                  onPanUpdate: (d) {
                    final s = _dragStart;
                    if (s == null) return;
                    final scale = ScenePainter.metersPerPixel(
                        MediaQuery.of(context).size);
                    game.updateAim(
                      (d.localPosition.dx - s.dx) * scale,
                      (d.localPosition.dy - s.dy) * scale,
                    );
                  },
                  onPanEnd: (_) {
                    _dragStart = null;
                    game.releaseThrow();
                  },
                  onPanCancel: () {
                    _dragStart = null;
                    game.cancelAim();
                  },
                  child: CustomPaint(
                    painter: ScenePainter(game),
                    isComplex: true,
                    willChange: true,
                  ),
                ),
              ),
              _buildHud(),
              ..._buildMessages(),
              if (game.phase == Phase.gameOver) _buildGameOver(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHud() {
    final f = game.figure;
    final line = (f.isLetter || game.fromKon) ? 'Kon · 13 m' : 'Half-kon · 6.5 m';
    return Positioned(
      top: 8,
      left: 12,
      right: 12,
      child: Row(
        children: [
          _hudChip(
            '${game.figureIndex + 1}/${kFigures.length}  ${f.name}',
            sub: f.russianName,
          ),
          const Spacer(),
          _hudChip('Throws: ${game.throwsTotal}', sub: line),
          const SizedBox(width: 8),
          _audioButton(
            icon: audio.sfxOn ? Icons.volume_up : Icons.volume_off,
            tooltip: 'Sound effects',
            active: audio.sfxOn,
            onTap: () => setState(audio.toggleSfx),
          ),
          const SizedBox(width: 6),
          _audioButton(
            icon: audio.musicOn ? Icons.music_note : Icons.music_off,
            tooltip: '8-bit "Akh, Samara-gorodok"',
            active: audio.musicOn,
            onTap: () async {
              await audio.toggleMusic();
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _hudChip(String text, {String? sub}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          if (sub != null)
            Text(sub,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11)),
        ],
      ),
    );
  }

  Widget _audioButton({
    required IconData icon,
    required String tooltip,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black.withValues(alpha: active ? 0.55 : 0.35),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon,
                size: 20,
                color: active ? Colors.white : Colors.white54),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMessages() {
    return [
      Positioned(
        top: 64,
        left: 0,
        right: 0,
        child: Column(
          children: [
            for (final m in game.messages)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                constraints: const BoxConstraints(maxWidth: 520),
                decoration: BoxDecoration(
                  color: const Color(0xF2FFF6DC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF8A6D3B)),
                  boxShadow: const [
                    BoxShadow(blurRadius: 6, color: Colors.black26)
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(m.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        m.text,
                        style: const TextStyle(
                            color: Color(0xFF4A3418),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ];
  }

  Widget _buildGameOver() {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6DC),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              const Text('All 15 figures cleared!',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A3418))),
              const SizedBox(height: 6),
              Text('Total throws: ${game.throwsTotal}',
                  style:
                      const TextStyle(fontSize: 17, color: Color(0xFF4A3418))),
              const SizedBox(height: 4),
              const Text('The pigeons rate your performance: "coo".',
                  style: TextStyle(fontSize: 13, color: Color(0xFF8A6D3B))),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: game.newGame,
                child: const Text('Play again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
