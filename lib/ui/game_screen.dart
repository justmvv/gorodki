import 'dart:math' as math;

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
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              game.jumpToLevel(4);
            },
            child: Text('🌕  ${L10n.t.level4Name}'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              game.jumpToLevel(5);
            },
            child: Text('🏖️  ${L10n.t.level5Name}'),
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
              if (game.levelTitleT > 0) _buildLevelTitle(),
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

  /// Soft, blinking level-name title shown for the first 10s of each
  /// level — a light, understated text overlay, no box or background.
  Widget _buildLevelTitle() {
    final t = game.levelTitleT;
    final names = [
      L10n.t.level1Name,
      L10n.t.level2Name,
      L10n.t.level3Name,
      L10n.t.level4Name,
      L10n.t.level5Name,
    ];
    final name = names[(game.level - 1).clamp(0, names.length - 1)];
    // Gentle continuous blink, fading out over the last 1.5s.
    final blink = 0.45 + 0.45 * math.sin(game.time * 3.2);
    final fadeOut = t < 1.5 ? (t / 1.5).clamp(0.0, 1.0) : 1.0;
    return Positioned(
      top: 90,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: Opacity(
            opacity: blink * fadeOut,
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFF5F3E8),
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
                shadows: [
                  Shadow(blurRadius: 12, color: Colors.black87),
                  Shadow(blurRadius: 3, color: Colors.black54),
                ],
              ),
            ),
          ),
        ),
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
              _buildStatsTable(),
              const SizedBox(height: 4),
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

  /// Per-level throw breakdown, shown once all 5 levels are cleared.
  Widget _buildStatsTable() {
    const flags = ['☀️', '🌇', '❄️', '🌕', '🏖️'];
    final names = [
      L10n.t.level1Name,
      L10n.t.level2Name,
      L10n.t.level3Name,
      L10n.t.level4Name,
      L10n.t.level5Name,
    ];
    final counts = game.levelThrowCounts;
    final total = counts.fold<int>(0, (a, b) => a + b);
    const labelStyle = TextStyle(fontSize: 12, color: Color(0xFF4A3418));
    const boldStyle = TextStyle(
        fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF4A3418));

    TableRow row(String label, String value, {bool bold = false}) {
      return TableRow(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text(label,
              style: bold ? boldStyle : labelStyle,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text(value,
              textAlign: TextAlign.right, style: bold ? boldStyle : labelStyle),
        ),
      ]);
    }

    return Container(
      width: 260,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF8A6D3B), width: 1),
      ),
      child: Column(
        children: [
          Text(L10n.t.statsTitle,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3418))),
          const SizedBox(height: 6),
          Table(
            columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(1)},
            children: [
              for (int i = 0; i < 5; i++)
                row('${flags[i]} ${names[i]}', '${counts[i]}'),
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 2),
                  child: Divider(
                      color: const Color(0xFF8A6D3B).withValues(alpha: 0.6),
                      height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 2),
                  child: Divider(
                      color: const Color(0xFF8A6D3B).withValues(alpha: 0.6),
                      height: 1),
                ),
              ]),
              row(L10n.t.throwsLabel, '$total', bold: true),
            ],
          ),
        ],
      ),
    );
  }
}
