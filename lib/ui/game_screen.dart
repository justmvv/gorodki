import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../game/audio_manager.dart';
import '../game/game_controller.dart';
import '../game/figures.dart';
import '../game/strings.dart';
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
  final FocusNode _cheatFocus = FocusNode();
  bool _cheatK = false; // K pressed, waiting for U

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
    _cheatFocus.dispose();
    super.dispose();
  }

  // Cheat code: K, then U — opens the level select menu.
  void _onKey(KeyEvent e) {
    if (e is! KeyDownEvent) return;
    if (e.logicalKey == LogicalKeyboardKey.keyK) {
      _cheatK = true;
    } else if (_cheatK && e.logicalKey == LogicalKeyboardKey.keyU) {
      _cheatK = false;
      _showLevelMenu();
    } else {
      _cheatK = false;
    }
  }

  void _showLevelMenu() {
    showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(L10n.t.levelMenuTitle),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              game.jumpToLevel(1);
            },
            child: Text('☀️  ${L10n.t.level1Name}'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              game.jumpToLevel(2);
            },
            child: Text('🌇  ${L10n.t.level2Name}'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              game.jumpToLevel(3);
            },
            child: Text('❄️  ${L10n.t.level3Name}'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87B5D6),
      body: KeyboardListener(
        focusNode: _cheatFocus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: AnimatedBuilder(
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
      ),
    );
  }

  Widget _buildHud() {
    final f = game.figure;
    final t = L10n.t;
    final line = (f.isLetter || game.fromKon) ? t.lineKon : t.lineHalf;
    return Positioned(
      top: 8,
      left: 12,
      right: 12,
      child: Row(
        children: [
          _hudChip(
            '${game.figureIndex + 1}/${kFigures.length}  '
            '${t.figureNames[game.figureIndex]}',
            sub: f.russianName,
          ),
          const Spacer(),
          _hudChip('${t.throwsLabel}: ${game.throwsTotal}', sub: line),
          const SizedBox(width: 8),
          _audioButton(
            icon: audio.sfxOn ? Icons.volume_up : Icons.volume_off,
            tooltip: t.sfxTooltip,
            active: audio.sfxOn,
            onTap: () => setState(audio.toggleSfx),
          ),
          const SizedBox(width: 6),
          _audioButton(
            icon: audio.musicOn ? Icons.music_note : Icons.music_off,
            tooltip: t.musicTooltip,
            active: audio.musicOn,
            onTap: () async {
              await audio.toggleMusic();
              if (mounted) setState(() {});
            },
          ),
          const SizedBox(width: 6),
          _languageButton(),
        ],
      ),
    );
  }

  Widget _languageButton() {
    return PopupMenuButton<GameStrings>(
      tooltip: L10n.t.langName,
      onSelected: (lang) => setState(() => L10n.t = lang),
      itemBuilder: (context) => [
        for (final lang in kLanguages)
          PopupMenuItem(
            value: lang,
            child: Row(
              children: [
                Text(lang.flag, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Text(lang.langName,
                    style: TextStyle(
                        fontWeight: lang == L10n.t
                            ? FontWeight.bold
                            : FontWeight.normal)),
                if (lang == L10n.t) ...[
                  const Spacer(),
                  const Icon(Icons.check, size: 16),
                ],
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
        ),
        child: Text(L10n.t.flag, style: const TextStyle(fontSize: 18)),
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
              Text(L10n.t.goTitle,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A3418))),
              const SizedBox(height: 6),
              Text('${L10n.t.goTotal} ${game.throwsTotal}',
                  style:
                      const TextStyle(fontSize: 17, color: Color(0xFF4A3418))),
              const SizedBox(height: 4),
              Text(L10n.t.goCoo,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF8A6D3B))),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: game.newGame,
                child: Text(L10n.t.playAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
