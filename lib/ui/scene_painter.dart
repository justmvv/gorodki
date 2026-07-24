import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/figures.dart';
import '../game/game_controller.dart';
import '../game/strings.dart';
import '../game/world.dart';

/// Paints the whole courtyard: buildings, the player, the gorod square,
/// pins, the kennel with Barbos, Uncle Gena on his bench, laundry,
/// pigeons and other essential municipal infrastructure.
class ScenePainter extends CustomPainter {
  final GameController g;

  ScenePainter(this.g) : super(repaint: g);

  late double _scale;
  late double _groundY;

  static double metersPerPixel(Size size) => World.width / size.width;

  Offset _w(double x, double y) => Offset(x * _scale, _groundY - y * _scale);

  @override
  void paint(Canvas canvas, Size size) {
    _scale = size.width / World.width;
    _groundY = size.height * 0.82;

    _sky(canvas, size);
    if (!g.nightmare) _clouds(canvas, size);
    if (g.beach) {
      _seaBackdrop(canvas, size);
    } else {
      _buildingLeft(canvas, size);
      _buildingRight(canvas, size);
    }
    _ground(canvas, size);
    _chalkLines(canvas);
    if (g.evening) {
      _lamp(canvas, World.lampX, g.lampBroken);
      _lamp(canvas, World.lampX2, g.lampBroken2, scale: 0.85);
      _fireflies(canvas, size);
      _spiderWeb(canvas);
      _car(canvas);
      _manholeProp(canvas);
      _hedgehogProp(canvas);
      _trashBin(canvas);
      _fleeingCats(canvas);
      if (g.ownerChasing) _ownerRunner(canvas);
    } else if (g.winter) {
      _yolka(canvas);
      _snowmanProp(canvas);
      _skierProp(canvas);
      _snowdriftProp(canvas);
    } else {
      // Level 1, the nightmare yard, and the beach all share this hazard
      // set (laundry line, kennel, bench) — each function reskins itself
      // internally based on g.nightmare / g.beach.
      _laundry(canvas);
      _kennel(canvas);
      _bench(canvas);
    }
    _puddle(canvas);
    _pins(canvas);
    _mole(canvas);
    _crowSteal(canvas);
    if (g.skeletonsOut) _skeletons(canvas);
    _player(canvas);
    _bat(canvas);
    _pigeon(canvas);
    _fruit(canvas);
    if (g.beach) _coconut(canvas);
    if (g.nightmare) _dragonFireBreath(canvas);
    if (g.phase == Phase.spiderCocoon) _spiderDescent(canvas);
    _drone(canvas);
    _splash(canvas);
    _eveningLight(canvas, size);
    if (g.winter) _snowfall(canvas, size);
    if (g.playerBuried) _avalanche(canvas, size);
    _aim(canvas);
    _tutorial(canvas, size);
    _figurePreview(canvas, size);
  }

  // ----------------------------------------------------------------
  // Backdrop
  // ----------------------------------------------------------------

  void _sky(Canvas c, Size s) {
    final r = Offset.zero & s;
    if (g.evening) {
      // Sunset: deep violet fading into ember orange at the rooftops.
      c.drawRect(
        r,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E2148),
              Color(0xFF8A3D4C),
              Color(0xFFE58A55),
            ],
            stops: [0.0, 0.55, 1.0],
          ).createShader(r),
      );
      // The low sun, squeezing between the buildings.
      final sun = Offset(16.2 * _scale, _groundY - 90);
      final ray = Paint()
        ..color = const Color(0x2FFF5A3C)
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 6; i++) {
        final a = math.pi + i * math.pi / 5 + math.sin(g.time * 0.3) * 0.05;
        c.drawLine(sun,
            sun + Offset(math.cos(a), math.sin(a)) * (150.0 + (i % 2) * 50),
            ray);
      }
      c.drawCircle(sun, 40, Paint()..color = const Color(0x40FFB37A));
      c.drawCircle(sun, 30, Paint()..color = const Color(0xFFFF7A4D));
      c.drawCircle(sun, 22, Paint()..color = const Color(0xFFFFC08A));
    } else if (g.winter) {
      // Crisp winter blue, bright low sun, no clouds to speak of.
      c.drawRect(
        r,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3E7FC4), Color(0xFFCFE9F7)],
          ).createShader(r),
      );
      final sun = Offset(15.5 * _scale, s.height * 0.16);
      c.drawCircle(sun, 46, Paint()..color = const Color(0x33FFFFFF));
      c.drawCircle(sun, 26, Paint()..color = const Color(0xFFFFF6D8));
      c.drawCircle(sun, 20, Paint()..color = const Color(0xFFFFFDF2));
      // A mysterious, twinkling Star of Bethlehem, high overhead.
      _bethlehemStar(c, s);
    } else if (g.nightmare) {
      // A hellish, moonlit night: near-black overhead, bruised red low
      // down where the ordinary yard should be.
      c.drawRect(
        r,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0812), Color(0xFF1D0F14), Color(0xFF4A1620)],
            stops: [0.0, 0.6, 1.0],
          ).createShader(r),
      );
      // A pale, faintly unsettling moon.
      final moon = Offset(s.width * 0.78, s.height * 0.16);
      c.drawCircle(moon, 44, Paint()..color = const Color(0x22E8E4D8));
      c.drawCircle(moon, 28, Paint()..color = const Color(0xFFE8E4D8));
      final crater = Paint()..color = const Color(0xFFC9C4B4);
      c.drawCircle(moon.translate(-9, -6), 4, crater);
      c.drawCircle(moon.translate(6, 4), 5.5, crater);
      c.drawCircle(moon.translate(2, -10), 3, crater);
      // Low graveyard fog, drifting past.
      final fog = Paint()..color = Colors.white.withValues(alpha: 0.05);
      for (int i = 0; i < 3; i++) {
        final drift = (g.time * (5 + i * 2) + i * 220) % (s.width + 300);
        c.drawOval(
            Rect.fromCenter(
                center: Offset(drift - 150, _groundY - 12 - i * 10),
                width: 260,
                height: 26),
            fog);
      }
    } else {
      c.drawRect(
        r,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6FA8D0), Color(0xFFBFDCEE)],
          ).createShader(r),
      );
    }
  }

  void _seaBackdrop(Canvas c, Size s) {
    // The sea, filling in for the usual apartment blocks.
    final horizonY = s.height * 0.46;
    final sea = Rect.fromLTRB(0, horizonY, s.width, _groundY);
    c.drawRect(
        sea,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3E8FBF), Color(0xFF1E5F8A)],
          ).createShader(sea));
    // Gentle animated wave crests.
    final wave = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    for (int row = 0; row < 4; row++) {
      final y = horizonY + 14 + row * 22.0;
      final offset = (g.time * (18 + row * 4)) % 40;
      final path = Path();
      for (double x = -40 + offset; x < s.width + 20; x += 40) {
        path.moveTo(x, y);
        path.quadraticBezierTo(x + 10, y - 4, x + 20, y);
        path.quadraticBezierTo(x + 30, y + 4, x + 40, y);
      }
      c.drawPath(path, wave);
    }
    // Distant boats, drifting along the horizon at their own unhurried
    // pace — a sail, a couple of hull silhouettes, going about their day.
    for (int i = 0; i < 3; i++) {
      final speed = 3.5 + i * 2.2;
      final laneY = horizonY + 4 + i * 5.0;
      final bx = (g.time * speed + i * 220) % (s.width + 160) - 80;
      if (i == 0) {
        // A little sailboat.
        c.drawLine(Offset(bx, laneY), Offset(bx, laneY - 16),
            Paint()
              ..color = Colors.white70
              ..strokeWidth = 1.2);
        final sail = Path()
          ..moveTo(bx, laneY - 15)
          ..lineTo(bx + 10, laneY - 4)
          ..lineTo(bx, laneY - 3)
          ..close();
        c.drawPath(sail, Paint()..color = Colors.white70);
      } else {
        // A low cargo-ship silhouette.
        final hull = Path()
          ..moveTo(bx - 12, laneY)
          ..lineTo(bx + 12, laneY)
          ..lineTo(bx + 9, laneY + 3)
          ..lineTo(bx - 9, laneY + 3)
          ..close();
        c.drawPath(hull, Paint()..color = const Color(0xFF2A3038).withValues(alpha: 0.6));
        c.drawLine(Offset(bx - 3, laneY), Offset(bx - 3, laneY - 5),
            Paint()
              ..color = const Color(0xFF2A3038).withValues(alpha: 0.6)
              ..strokeWidth = 1.5);
      }
    }

    // A pleasure boat, much closer in, puttering along the shoreline
    // with a proper wake trailing behind it.
    final pbSpeed = 16.0;
    final pbX = (g.time * pbSpeed) % (s.width + 220) - 110;
    final pbY = _groundY - 44;
    final pbHull = Path()
      ..moveTo(pbX - 22, pbY)
      ..quadraticBezierTo(pbX - 25, pbY + 9, pbX - 15, pbY + 11)
      ..lineTo(pbX + 17, pbY + 11)
      ..quadraticBezierTo(pbX + 25, pbY + 9, pbX + 20, pbY)
      ..close();
    c.drawPath(pbHull, Paint()..color = const Color(0xFFF2F2EE));
    c.drawLine(Offset(pbX - 20, pbY), Offset(pbX + 18, pbY),
        Paint()
          ..color = const Color(0xFFCF6679)
          ..strokeWidth = 2);
    c.drawRect(Rect.fromLTWH(pbX - 9, pbY - 11, 18, 11),
        Paint()..color = const Color(0xFF2FA0A8));
    c.drawRect(Rect.fromLTWH(pbX - 6, pbY - 9, 12, 5),
        Paint()..color = const Color(0xFFBFE3E6));
    c.drawLine(Offset(pbX + 3, pbY - 11), Offset(pbX + 3, pbY - 18),
        Paint()
          ..color = const Color(0xFF3A3742)
          ..strokeWidth = 1.5);
    // Wake, fanning out behind (the boat travels left-to-right, so the
    // wake trails to its left).
    final wakeP = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.4;
    for (int i = 1; i <= 4; i++) {
      wakeP.color = Colors.white.withValues(alpha: (0.4 / i).clamp(0.0, 1.0));
      c.drawOval(
          Rect.fromCenter(
              center: Offset(pbX - 20 - i * 11, pbY + 11), width: 16, height: 5),
          wakeP);
    }

    // Sand dunes framing the shoreline, and a couple of palms for shade
    // nobody asked for.
    final duneP = Paint()..color = const Color(0xFFE3C88A);
    c.drawOval(
        Rect.fromCenter(
            center: Offset(s.width * 0.08, _groundY),
            width: s.width * 0.5,
            height: 40),
        duneP);
    c.drawOval(
        Rect.fromCenter(
            center: Offset(s.width * 0.95, _groundY),
            width: s.width * 0.4,
            height: 34),
        duneP);

    // The palm nearest the player stands unnaturally, suspiciously tall —
    // plenty of drop height for what's coming.
    _palm(c, _w(World.nearPalmX, 0), height: 150);
    _palm(c, _w(21.6, 0));
  }

  void _palm(Canvas c, Offset base, {double height = 92}) {
    final trunk = Paint()
      ..color = const Color(0xFF8A6B3F)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final lean = math.sin(g.time * 0.4) * 3;
    final top = Offset(base.dx + 14 + lean, base.dy - height);
    final trunkPath = Path()..moveTo(base.dx, base.dy);
    trunkPath.quadraticBezierTo(
        base.dx + 6, base.dy - height * 0.54, top.dx, top.dy);
    c.drawPath(trunkPath, trunk);
    final leaf = Paint()..color = const Color(0xFF4E8A4A);
    for (int i = 0; i < 5; i++) {
      final a = -math.pi / 2 + (i - 2) * 0.5 + math.sin(g.time * 1.5 + i) * 0.05;
      final tip = top + Offset(math.cos(a), math.sin(a)) * 34;
      final p = Path()
        ..moveTo(top.dx, top.dy)
        ..quadraticBezierTo(top.dx + math.cos(a + 0.3) * 18,
            top.dy + math.sin(a + 0.3) * 18, tip.dx, tip.dy)
        ..quadraticBezierTo(top.dx + math.cos(a - 0.3) * 18,
            top.dy + math.sin(a - 0.3) * 18, top.dx, top.dy)
        ..close();
      c.drawPath(p, leaf);
    }
    // A couple of coconuts, because why not.
    c.drawCircle(
        top.translate(-3, 6), 3, Paint()..color = const Color(0xFF6B4A2E));
    c.drawCircle(
        top.translate(4, 8), 3, Paint()..color = const Color(0xFF6B4A2E));
  }

  void _clouds(Canvas c, Size s) {
    final p = Paint()
      ..color = g.evening
          ? const Color(0xFFE8A98F).withValues(alpha: 0.7)
          : Colors.white.withValues(alpha: 0.85);
    final drift = (g.time * 4) % (s.width + 200);
    for (final (cx, cy, k) in [(0.2, 0.12, 1.0), (0.65, 0.2, 0.7)]) {
      final base = Offset(
          (s.width * cx + drift) % (s.width + 200) - 100, s.height * cy);
      c.drawOval(Rect.fromCenter(center: base, width: 90 * k, height: 30 * k), p);
      c.drawOval(
          Rect.fromCenter(
              center: base + Offset(30 * k, -10 * k),
              width: 70 * k,
              height: 28 * k),
          p);
      c.drawOval(
          Rect.fromCenter(
              center: base + Offset(-30 * k, -6 * k),
              width: 60 * k,
              height: 24 * k),
          p);
    }
  }

  void _windowsGrid(Canvas c, Rect facade,
      {int cols = 3,
      int skipBottom = 0,
      bool Function(int row, int col)? skipCell}) {
    final wall = Paint()..color = const Color(0xFF9AA7B8);
    final frame = Paint()..color = const Color(0xFF5B6B7E);
    const rows = 4;
    final wW = facade.width / (cols * 2 + 1);
    final wH = facade.height / (rows * 2.2);
    for (int r = 0; r < rows - skipBottom; r++) {
      for (int col = 0; col < cols; col++) {
        if (skipCell != null && skipCell(r, col)) continue;
        final rect = Rect.fromLTWH(
          facade.left + wW * (col * 2 + 1),
          facade.top + facade.height * 0.08 + r * wH * 2,
          wW,
          wH,
        );
        c.drawRect(rect.inflate(2), frame);
        // In the evening, some windows glow with kitchen-TV warmth; in the
        // nightmare yard, a rarer few flicker with something greener.
        final lit = g.evening && (r * 3 + col) % 3 == 0;
        final eerie = g.nightmare && (r * 3 + col) % 4 == 0;
        c.drawRect(
            rect,
            eerie
                ? (Paint()..color = const Color(0xFF5FA86A))
                : lit
                    ? (Paint()..color = const Color(0xFFF2CE7E))
                    : (g.evening || g.nightmare)
                        ? (Paint()..color = const Color(0xFF2A2830))
                        : wall);
        c.drawLine(rect.topCenter, rect.bottomCenter, frame..strokeWidth = 1.5);
      }
    }
  }

  void _buildingLeft(Canvas c, Size s) {
    final right = _w(1.6, 0).dx;
    final facade = Rect.fromLTRB(-10, s.height * 0.06, right, _groundY);
    c.drawRect(
        facade,
        Paint()
          ..color =
              g.nightmare ? const Color(0xFF2E2A30) : const Color(0xFFC9B49A));
    if (g.winter) {
      c.drawRect(Rect.fromLTWH(facade.left, facade.top, facade.width, 10),
          Paint()..color = const Color(0xFFF3F8FC));
    }
    // The two windows nearest the entrance are skipped — the door lives there.
    _windowsGrid(c, Rect.fromLTRB(0, facade.top, right, facade.bottom),
        skipCell: (r, col) => col == 2 && r >= 2);
    // Entrance door with the eternal "ДОМОФОН" vibe — properly sized
    // for an actual human being now.
    final door = Rect.fromLTWH(right - 64, _groundY - 88, 46, 88);
    // Canopy over the entrance.
    c.drawRect(
        Rect.fromLTWH(door.left - 8, door.top - 8, door.width + 16, 6),
        Paint()..color = const Color(0xFF55534E));
    c.drawRect(door.inflate(3), Paint()..color = const Color(0xFF4A3320));
    c.drawRect(door, Paint()..color = const Color(0xFF6B4A2E));
    // Door panels + a little window on top.
    final panel = Paint()
      ..color = const Color(0xFF553A22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    c.drawRect(
        Rect.fromLTWH(door.left + 6, door.top + 30, door.width - 12,
            door.height - 38),
        panel);
    c.drawRect(
        Rect.fromLTWH(door.left + 6, door.top + 6, door.width - 12, 18),
        Paint()..color = const Color(0xFF8FA0AE));
    // Handle.
    c.drawCircle(Offset(door.left + 9, door.center.dy + 8), 2.5,
        Paint()..color = const Color(0xFFC9B37E));
  }

  void _buildingRight(Canvas c, Size s) {
    final left = _w(World.buildingRX, 0).dx;
    final facade = Rect.fromLTRB(left, s.height * 0.03, s.width + 10, _groundY);
    c.drawRect(
        facade,
        Paint()
          ..color =
              g.nightmare ? const Color(0xFF35313A) : const Color(0xFFB8C0A8));
    if (g.winter) {
      c.drawRect(Rect.fromLTWH(facade.left, facade.top, facade.width, 10),
          Paint()..color = const Color(0xFFF3F8FC));
    }

    // Windows form a regular grid anchored in WORLD coordinates, so that
    // Baba Zina's window (World.windowY1..windowY2, used by the physics)
    // is simply one cell of the grid — accented, but in line with the rest.
    final frame = Paint()..color = const Color(0xFF5B6B7E);
    final glass = Paint()..color = const Color(0xFF9AA7B8);
    const colsX = [0.35, 1.75]; // column offsets from the facade, meters
    const winW = 1.0;
    const rowStep = 2.0; // floor height, meters
    for (int col = 0; col < colsX.length; col++) {
      for (int row = -1; row < 5; row++) {
        final y1 = World.windowY1 + row * rowStep;
        final y2 = World.windowY2 + row * rowStep;
        if (y1 < 0.7) continue; // no windows behind the bench
        final top = _w(0, y2).dy;
        if (top < facade.top + 8) break;
        final rect = Rect.fromLTRB(
          left + colsX[col] * _scale,
          top,
          left + (colsX[col] + winW) * _scale,
          _w(0, y1).dy,
        );
        final isZina = col == 0 && row == 0;
        c.drawRect(
            rect.inflate(isZina ? 4 : 2),
            isZina
                ? (Paint()..color = const Color(0xFF8A5A33))
                : frame);
        final lit = g.evening && !isZina && (col * 5 + row) % 3 == 0;
        final eerie = g.nightmare && !isZina && (col * 5 + row) % 4 == 0;
        c.drawRect(
            rect,
            isZina
                ? (Paint()
                  ..color = g.nightmare
                      ? Color.lerp(const Color(0xFF7A2410),
                          const Color(0xFFFF9A3E), 0.4 + 0.3 * math.sin(g.time * 4))!
                      : const Color(0xFFDDEBF2))
                : eerie
                    ? (Paint()..color = const Color(0xFF5FA86A))
                    : lit
                        ? (Paint()..color = const Color(0xFFF2CE7E))
                        : (g.evening || g.nightmare)
                            ? (Paint()..color = const Color(0xFF2A2830))
                            : glass);
        c.drawLine(
            rect.topCenter, rect.bottomCenter, frame..strokeWidth = 1.5);
        if (isZina) _zinaWindow(c, rect);
        // Same column as Baba Zina (closer to the middle of the facade,
        // clearly on-screen) but two floors up, so the windows don't
        // overlap.
        if (col == 0 && row == 2 && g.ownerWindowT > 0) {
          _ownerInWindow(c, rect);
        }
      }
    }
  }

  /// The famous accented window: curtains, geraniums, and (after the
  /// unfortunate incident) cracks and Baba Zina herself.
  void _zinaWindow(Canvas c, Rect win) {
    if (g.nightmare) {
      _dragonWindow(c, win);
      return;
    }
    // Cozy curtains.
    final curtain = Paint()..color = const Color(0xFFEED9A4);
    c.drawRect(
        Rect.fromLTWH(win.left, win.top, win.width * 0.16, win.height),
        curtain);
    c.drawRect(
        Rect.fromLTWH(win.right - win.width * 0.16, win.top, win.width * 0.16,
            win.height),
        curtain);
    // Geranium pot on the sill.
    final potW = win.width * 0.3;
    final pot =
        Rect.fromLTWH(win.left + win.width * 0.35, win.bottom - 10, potW, 10);
    c.drawRect(pot, Paint()..color = const Color(0xFFA9552E));
    c.drawCircle(pot.topCenter.translate(0, -5), 6,
        Paint()..color = const Color(0xFFD8484D));

    if (g.windowBroken) {
      final crack = Paint()
        ..color = const Color(0xFF4E4636)
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke;
      final ctr = win.center;
      for (int i = 0; i < 7; i++) {
        final a = i * math.pi * 2 / 7 + 0.4;
        c.drawLine(
            ctr,
            ctr +
                Offset(math.cos(a), math.sin(a)) *
                    (win.shortestSide * 0.55),
            crack);
      }
      // Baba Zina, displeased.
      c.drawCircle(ctr.translate(0, -4), 9,
          Paint()..color = const Color(0xFFE8C39E));
      final scarf = Paint()..color = const Color(0xFFC94F7C);
      c.drawArc(Rect.fromCircle(center: ctr.translate(0, -4), radius: 10),
          math.pi, math.pi, true, scarf);
      final eye = Paint()..color = Colors.black87;
      c.drawCircle(ctr.translate(-3, -5), 1.2, eye);
      c.drawCircle(ctr.translate(3, -5), 1.2, eye);
      c.drawLine(ctr.translate(-3, 1), ctr.translate(3, 1),
          eye..strokeWidth = 1.4);
    }
  }

  /// Nightmare reskin of Baba Zina's window: a dragon lives there now.
  /// It stays a pair of eyes in the dark until you break the glass, at
  /// which point it leans out — see [_dragonFireBreath] for the actual
  /// flame reaching across the yard.
  void _dragonWindow(Canvas c, Rect win) {
    // Whatever's on fire in there is doing most of the lighting — this
    // yard doesn't do "calm." An ambient glow wash plus a few flame
    // licks near the floor, visible right through the glass regardless
    // of whether the dragon itself is currently showing off.
    final flicker = 0.6 + 0.4 * math.sin(g.time * 9);
    c.drawRect(
        win,
        Paint()
          ..color = Color.fromRGBO(255, 90, 20, 0.18 + 0.09 * flicker));
    for (int i = 0; i < 3; i++) {
      final fx = win.left + win.width * (0.26 + i * 0.24);
      final baseY = win.bottom - 3;
      final h = (13 + 5 * math.sin(g.time * 8 + i * 2.3)) * (0.7 + 0.3 * flicker);
      final outer = Path()
        ..moveTo(fx - 4, baseY)
        ..quadraticBezierTo(fx - 6, baseY - h * 0.55, fx, baseY - h)
        ..quadraticBezierTo(fx + 6, baseY - h * 0.55, fx + 4, baseY)
        ..close();
      c.drawPath(
          outer, Paint()..color = const Color(0xFFFF7A2E).withValues(alpha: 0.8));
      final innerH = h * 0.55;
      final inner = Path()
        ..moveTo(fx - 2, baseY)
        ..quadraticBezierTo(fx - 3, baseY - innerH * 0.6, fx, baseY - innerH)
        ..quadraticBezierTo(fx + 3, baseY - innerH * 0.6, fx + 2, baseY)
        ..close();
      c.drawPath(inner,
          Paint()..color = const Color(0xFFFFE082).withValues(alpha: 0.85));
    }

    // Scorched, tattered curtains — drawn over the fire, so it reads as
    // glowing behind them rather than sitting flat on the glass.
    final curtain = Paint()..color = const Color(0xFF2A2026);
    c.drawRect(
        Rect.fromLTWH(win.left, win.top, win.width * 0.16, win.height),
        curtain);
    c.drawRect(
        Rect.fromLTWH(win.right - win.width * 0.16, win.top, win.width * 0.16,
            win.height),
        curtain);
    // A wilted, faintly smoking plant, where geraniums used to be.
    final potW = win.width * 0.3;
    final pot =
        Rect.fromLTWH(win.left + win.width * 0.35, win.bottom - 10, potW, 10);
    c.drawRect(pot, Paint()..color = const Color(0xFF3A2E22));
    c.drawCircle(pot.topCenter.translate(0, -5), 6,
        Paint()..color = const Color(0xFF4A3A2E));

    if (!g.windowBroken) {
      // Just a pair of watching eyes in the dark, for now.
      final glow = 0.5 + 0.3 * math.sin(g.time * 2);
      final ctr = win.center;
      for (final dx in [-4.0, 4.0]) {
        c.drawCircle(ctr.translate(dx, -2), 2.2,
            Paint()..color = Color.fromRGBO(255, 200, 40, 0.5 + glow * 0.4));
      }
      return;
    }

    final crack = Paint()
      ..color = const Color(0xFF1B1214)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    final ctr = win.center;
    for (int i = 0; i < 7; i++) {
      final a = i * math.pi * 2 / 7 + 0.4;
      c.drawLine(ctr,
          ctr + Offset(math.cos(a), math.sin(a)) * (win.shortestSide * 0.55),
          crack);
    }

    if (!g.dragonBreathing) {
      // The attack is over — it retreats back into the shadows rather
      // than staying permanently draped out of a broken window. Only
      // the watching eyes remain, now glowing angrier through the cracks.
      final glow = 0.5 + 0.3 * math.sin(g.time * 2.4);
      for (final dx in [-4.0, 4.0]) {
        c.drawCircle(ctr.translate(dx, -2), 2.4,
            Paint()..color = Color.fromRGBO(255, 80, 30, 0.6 + glow * 0.4));
      }
      return;
    }

    // The dragon: anchored just past the window FRAME's own outer edge
    // (not the glass), with enough lean to clear the head's own half
    // -width — otherwise the resting pose visually overlaps the frame
    // and reads as "stuck in the window" instead of leaning out of it.
    // Only leans out while actually breathing (see above).
    final sill = Offset(win.right + 4, win.bottom - win.height * 0.22);
    final head = sill.translate(30.0, -4);
    final scale = Paint()..color = const Color(0xFF3E6B4A);
    c.drawOval(
        Rect.fromCenter(center: head, width: 22, height: 15), scale);
    c.drawOval(
        Rect.fromCenter(center: head.translate(10, 3), width: 14, height: 8),
        scale);
    final horn = Paint()..color = const Color(0xFF8B3A22);
    c.drawPath(
        Path()
          ..moveTo(head.dx - 6, head.dy - 7)
          ..lineTo(head.dx - 10, head.dy - 17)
          ..lineTo(head.dx - 3, head.dy - 8)
          ..close(),
        horn);
    c.drawPath(
        Path()
          ..moveTo(head.dx + 2, head.dy - 8)
          ..lineTo(head.dx + 2, head.dy - 18)
          ..lineTo(head.dx + 7, head.dy - 9)
          ..close(),
        horn);
    c.drawCircle(head.translate(4, -2), 2, Paint()..color = const Color(0xFFFFD040));
    c.drawCircle(head.translate(4, -2), 0.9, Paint()..color = Colors.black);
  }

  void _ground(Canvas c, Size s) {
    // Asphalt with a hint of heroic Soviet patching.
    final r = Rect.fromLTRB(0, _groundY, s.width, s.height);
    if (g.winter) {
      c.drawRect(r, Paint()..color = const Color(0xFFF3F8FC));
      final shadow = Paint()..color = const Color(0xFFD3E3EE);
      for (final (px, pw) in [(3.0, 1.4), (10.6, 2.0), (17.4, 1.2)]) {
        c.drawOval(
            Rect.fromLTWH(_w(px, 0).dx, _groundY + 8, pw * _scale, 14),
            shadow);
      }
      return;
    }
    if (g.beach) {
      c.drawRect(r, Paint()..color = const Color(0xFFE8CE96));
      final ripple = Paint()..color = const Color(0xFFD8BA7E);
      for (final (px, pw) in [(3.0, 1.4), (10.6, 2.0), (17.4, 1.2)]) {
        c.drawOval(
            Rect.fromLTWH(_w(px, 0).dx, _groundY + 8, pw * _scale, 14),
            ripple);
      }
      return;
    }
    if (g.nightmare) {
      c.drawRect(r, Paint()..color = const Color(0xFF241E22));
      // Glowing cracks, because regular asphalt patching wasn't ominous
      // enough.
      final crack = Paint()
        ..color = const Color(0xFFB3402A).withValues(
            alpha: 0.5 + 0.2 * math.sin(g.time * 2))
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      for (final px in [3.0, 8.5, 13.0, 17.0, 20.5]) {
        final o = _w(px, 0);
        final path = Path()..moveTo(o.dx - 14, _groundY + 4);
        path.lineTo(o.dx, _groundY + 12);
        path.lineTo(o.dx + 16, _groundY + 8);
        path.lineTo(o.dx + 6, _groundY + 20);
        c.drawPath(path, crack);
      }
      return;
    }
    c.drawRect(r,
        Paint()..color = Color(g.evening ? 0xFF6E655E : 0xFF8D8D85));
    final patch = Paint()..color = Color(g.evening ? 0xFF5E564F : 0xFF7C7C74);
    for (final (px, pw) in [(3.0, 1.4), (10.6, 2.0), (17.4, 1.2)]) {
      c.drawOval(
          Rect.fromLTWH(_w(px, 0).dx, _groundY + 8, pw * _scale, 14), patch);
    }
  }

  void _chalkLines(Canvas c) {
    // On snow, white chalk vanishes — switch to a dark navy line instead.
    // In the nightmare yard, chalk gives way to a dull embery red; on the
    // beach, someone's clearly drawn the lines with a stick in the sand.
    final lineColor = g.winter
        ? const Color(0xFF2E4A66)
        : g.nightmare
            ? const Color(0xFF8A3A2E)
            : g.beach
                ? const Color(0xFF6B4A2E)
                : Colors.white;
    final chalk = Paint()
      ..color = lineColor.withValues(alpha: 0.9)
      ..strokeWidth = 3;

    void line(double x, String label) {
      c.drawLine(_w(x, 0), Offset(_w(x, 0).dx, _groundY + 26), chalk);
      final tp = TextPainter(
        text: TextSpan(
            text: label,
            style: TextStyle(
                color: lineColor.withValues(alpha: 0.9),
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(c, Offset(_w(x, 0).dx - tp.width / 2, _groundY + 28));
    }

    line(World.konX, 'KON · 13 m');
    line(World.polukonX, 'HALF-KON · 6.5 m');

    // The gorod square (as a chalk rectangle on the ground, in side view
    // it shows as a stripe).
    final gorod = Rect.fromLTRB(
        _w(World.gorodFront, 0).dx, _groundY + 2, _w(World.gorodBack, 0).dx,
        _groundY + 22);
    c.drawRect(
        gorod,
        Paint()
          ..color = lineColor.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
    final tp = TextPainter(
      text: TextSpan(
          text: 'GOROD',
          style: TextStyle(
              color: lineColor.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset(gorod.center.dx - tp.width / 2, gorod.center.dy - 6));
  }

  // ----------------------------------------------------------------
  // Props
  // ----------------------------------------------------------------

  /// Beach reskin of the laundry line: a taut volleyball net.
  void _volleyballNet(Canvas c) {
    // Planted at a forward rake, top leaning toward the sea, so the net
    // reads as standing up perpendicular to the shoreline instead of
    // looking like a flat band lying parallel to the waves behind it.
    const rake = 0.32; // meters the top leans, relative to the base
    final poleP = Paint()
      ..color = const Color(0xFFE9E3CE)
      ..strokeWidth = 4;
    final poleTop1 = _w(World.ropeX1 - 0.15 + rake, World.ropeY + 0.55);
    final poleTop2 = _w(World.ropeX2 + 0.15 + rake, World.ropeY + 0.55);
    final base1 = _w(World.ropeX1 - 0.15, 0);
    final base2 = _w(World.ropeX2 + 0.15, 0);
    c.drawLine(base1, poleTop1, poleP);
    c.drawLine(base2, poleTop2, poleP);

    // ...but the net itself is only strung at regulation net height (a
    // band around eye level), not floor-to-pole-top. It sways gently —
    // it's meant to spring, not snag. The rake carries through the mesh
    // too, so the whole panel reads as one tilted plane, not a flat
    // rectangle facing the viewer head-on.
    final sway = math.sin(g.time * 3) * 1.5;
    final top1 = _w(World.ropeX1 - 0.15 + rake, World.ropeY + 0.3);
    final top2 = _w(World.ropeX2 + 0.15 + rake, World.ropeY + 0.3);
    final bot1 = _w(World.ropeX1 - 0.15 + rake * 0.35, World.ropeY - 0.3)
        .translate(0, sway);
    final bot2 = _w(World.ropeX2 + 0.15 + rake * 0.35, World.ropeY - 0.3)
        .translate(0, sway);

    final mesh = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    const cols = 8, rows = 3;
    for (int i = 0; i <= cols; i++) {
      final t = i / cols;
      c.drawLine(Offset.lerp(top1, top2, t)!, Offset.lerp(bot1, bot2, t)!, mesh);
    }
    for (int j = 0; j <= rows; j++) {
      final t = j / rows;
      c.drawLine(Offset.lerp(top1, bot1, t)!, Offset.lerp(top2, bot2, t)!, mesh);
    }
    // Taped top and bottom bands.
    c.drawLine(top1, top2, Paint()
      ..color = const Color(0xFFCF6679)
      ..strokeWidth = 5);
    c.drawLine(bot1, bot2, Paint()
      ..color = const Color(0xFFCF6679)
      ..strokeWidth = 4);
  }

  /// Nightmare reskin of the laundry line: rusty chains, swaying, with a
  /// small lantern (of unclear provenance) hanging from the middle one.
  void _hangingChains(Canvas c) {
    final poleP = Paint()
      ..color = const Color(0xFF2A2830)
      ..strokeWidth = 4;
    final p1 = _w(World.ropeX1 - 0.15, 0);
    final p2 = _w(World.ropeX2 + 0.15, 0);
    final top1 = _w(World.ropeX1 - 0.15, World.ropeY + 0.35);
    final top2 = _w(World.ropeX2 + 0.15, World.ropeY + 0.35);
    c.drawLine(p1, top1, poleP);
    c.drawLine(p2, top2, poleP);

    final chain = Paint()
      ..color = const Color(0xFF5A5460)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (final fx in [World.ropeX1 + 0.5, (World.ropeX1 + World.ropeX2) / 2, World.ropeX2 - 0.5]) {
      final top = _w(fx, World.ropeY + 0.3);
      final sway = math.sin(g.time * 1.4 + fx) * 6;
      var y = top.dy;
      var x = top.dx;
      for (int i = 0; i < 6; i++) {
        final nx = top.dx + sway * (i / 6);
        final ny = y + 8;
        c.drawOval(Rect.fromCenter(center: Offset((x + nx) / 2, (y + ny) / 2), width: 6, height: 8), chain);
        x = nx;
        y = ny;
      }
      if (fx == (World.ropeX1 + World.ropeX2) / 2) {
        // A little lantern, guttering.
        final flick = 0.6 + 0.3 * math.sin(g.time * 9);
        c.drawRect(Rect.fromCenter(center: Offset(x, y + 8), width: 10, height: 12),
            Paint()..color = const Color(0xFF3A342E));
        c.drawCircle(Offset(x, y + 8), 4,
            Paint()..color = Color.fromRGBO(255, 140, 60, flick));
      }
    }
  }

  void _laundry(Canvas c) {
    if (g.beach) {
      _volleyballNet(c);
      return;
    }
    if (g.nightmare) {
      _hangingChains(c);
      return;
    }
    final poleP = Paint()
      ..color = const Color(0xFF5E5E58)
      ..strokeWidth = 4;
    final p1 = _w(World.ropeX1 - 0.15, 0);
    final p2 = _w(World.ropeX2 + 0.15, 0);
    final top1 = _w(World.ropeX1 - 0.15, World.ropeY + 0.35);
    final top2 = _w(World.ropeX2 + 0.15, World.ropeY + 0.35);
    c.drawLine(p1, top1, poleP);
    c.drawLine(p2, top2, poleP);

    final rope = Path()
      ..moveTo(top1.dx, top1.dy + 6)
      ..quadraticBezierTo(
          (top1.dx + top2.dx) / 2,
          _w(0, World.ropeY).dy + 10,
          top2.dx,
          top2.dy + 6);
    c.drawPath(
        rope,
        Paint()
          ..color = const Color(0xFF4A4A44)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);

    // The laundry itself: a shirt, a towel and the legendary underpants.
    void garment(double x, Color color, {bool pants = false}) {
      final o = _w(x, World.ropeY);
      final sway = math.sin(g.time * 2 + x) * 2;
      final paint = Paint()..color = color;
      if (pants) {
        final path = Path()
          ..moveTo(o.dx - 10 + sway, o.dy + 4)
          ..lineTo(o.dx + 10 + sway, o.dy + 4)
          ..lineTo(o.dx + 12 + sway, o.dy + 22)
          ..lineTo(o.dx + 4 + sway, o.dy + 22)
          ..lineTo(o.dx + sway, o.dy + 12)
          ..lineTo(o.dx - 4 + sway, o.dy + 22)
          ..lineTo(o.dx - 12 + sway, o.dy + 22)
          ..close();
        c.drawPath(path, paint);
        // Polka dots, obviously.
        final dot = Paint()..color = Colors.white70;
        c.drawCircle(Offset(o.dx - 5 + sway, o.dy + 12), 2, dot);
        c.drawCircle(Offset(o.dx + 6 + sway, o.dy + 15), 2, dot);
      } else {
        c.drawRect(
            Rect.fromLTWH(o.dx - 9 + sway, o.dy + 4, 18, 20), paint);
      }
    }

    garment(World.ropeX1 + 0.35, const Color(0xFF7FA3C7));
    garment(World.ropeX1 + 0.95, const Color(0xFFCF6679), pants: true);
    garment(World.ropeX1 + 1.55, const Color(0xFFE9E3CE));
  }

  void _puddle(Canvas c) {
    final r = Rect.fromLTWH(
      _w(World.puddleX1, 0).dx,
      _groundY + 4,
      (World.puddleX2 - World.puddleX1) * _scale,
      10,
    );
    if (g.nightmare) {
      final glow = 0.6 + 0.2 * math.sin(g.time * 3);
      c.drawOval(r, Paint()..color = const Color(0xFF2A100C));
      c.drawOval(r.deflate(3), Paint()..color = Color.fromRGBO(200, 60, 20, glow));
      return;
    }
    c.drawOval(r, Paint()..color = const Color(0xFF5F7E96));
    c.drawOval(r.deflate(3), Paint()..color = const Color(0xFF7FA0B8));
  }

  void _kennel(Canvas c) {
    if (g.beach) {
      _sandcastle(c);
      return;
    }
    if (g.nightmare) {
      _gravePortal(c);
      return;
    }
    final base = _w(World.kennelX, 0);
    final w = World.kennelW * _scale;
    final h = World.kennelH * _scale;

    // Box.
    final body = Rect.fromLTWH(base.dx, base.dy - h * 0.72, w, h * 0.72);
    c.drawRect(body, Paint()..color = const Color(0xFF8A5A33));
    // Roof.
    final roof = Path()
      ..moveTo(base.dx - w * 0.08, base.dy - h * 0.72)
      ..lineTo(base.dx + w / 2, base.dy - h)
      ..lineTo(base.dx + w * 1.08, base.dy - h * 0.72)
      ..close();
    c.drawPath(roof, Paint()..color = const Color(0xFF5E3A1E));
    // Door hole.
    c.drawOval(
        Rect.fromCenter(
            center: body.center.translate(0, h * 0.08),
            width: w * 0.36,
            height: h * 0.42),
        Paint()..color = const Color(0xFF2B1B0E));
    // Nameplate: BARBOS.
    final tp = TextPainter(
      text: const TextSpan(
          text: 'BARBOS',
          style: TextStyle(
              color: Color(0xFFF2E3C6),
              fontSize: 8,
              fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset(body.center.dx - tp.width / 2, body.top + 3));

    // Barbos himself.
    if (g.dogOut) {
      _dog(c, g.dogX, running: true, facingRight: g.dogFacingRight);
    } else {
      // Muzzle peeking from the doorway, tracking the bat with disapproval.
      final peek = body.center.translate(0, h * 0.05);
      c.drawCircle(peek, w * 0.13, Paint()..color = const Color(0xFFC98A4B));
      c.drawCircle(peek.translate(-w * 0.04, -w * 0.03), 1.8,
          Paint()..color = Colors.black);
      c.drawCircle(peek.translate(w * 0.04, -w * 0.03), 1.8,
          Paint()..color = Colors.black);
      c.drawCircle(peek.translate(0, w * 0.04), 2.2,
          Paint()..color = Colors.black87);
    }
  }

  /// Beach reskin of the kennel: a sandcastle guarded by a territorial crab.
  void _sandcastle(Canvas c) {
    final base = _w(World.kennelX, 0);
    final w = World.kennelW * _scale;
    final h = World.kennelH * _scale;
    final sand = Paint()..color = const Color(0xFFE3C88A);
    final sandDark = Paint()..color = const Color(0xFFC9A968);

    final body = Rect.fromLTWH(base.dx, base.dy - h * 0.6, w, h * 0.6);
    c.drawRect(body, sand);
    for (final tx in [body.left + 4, body.right - 16]) {
      c.drawRect(Rect.fromLTWH(tx, body.top - 14, 14, 14), sand);
      for (int i = 0; i < 3; i++) {
        c.drawRect(Rect.fromLTWH(tx + i * 5.0 - 1, body.top - 16, 3, 4), sandDark);
      }
    }
    c.drawArc(Rect.fromLTWH(body.center.dx - 8, body.bottom - 16, 16, 16),
        math.pi, math.pi, true, sandDark);
    final flagX = body.center.dx;
    c.drawLine(Offset(flagX, body.top - 14), Offset(flagX, body.top - 30),
        Paint()
          ..color = const Color(0xFF6B4A2E)
          ..strokeWidth = 2);
    final flag = Path()
      ..moveTo(flagX, body.top - 30)
      ..lineTo(flagX + 12, body.top - 26)
      ..lineTo(flagX, body.top - 22)
      ..close();
    c.drawPath(flag, Paint()..color = const Color(0xFFCF6679));
    final tp = TextPainter(
      text: const TextSpan(
          text: 'CRABBY',
          style: TextStyle(
              color: Color(0xFF6B4A2E),
              fontSize: 8,
              fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset(body.center.dx - tp.width / 2, body.top + 3));

    if (g.dogOut) {
      _crab(c, g.dogX, running: true, facingRight: g.dogFacingRight);
    } else {
      final peek = body.center.translate(0, h * 0.05);
      c.drawCircle(peek, w * 0.1, Paint()..color = const Color(0xFFD8543C));
    }
  }

  void _crab(Canvas c, double x, {bool running = false, bool facingRight = false}) {
    final o = _w(x, 0);
    final k = _scale;
    final body = Paint()..color = const Color(0xFFD8543C);
    final bounce = running ? math.sin(g.time * 20) * 3 : 0.0;
    final center = Offset(o.dx, o.dy - 0.16 * k + bounce);

    c.save();
    if (facingRight) {
      c.translate(o.dx * 2, 0);
      c.scale(-1, 1);
    }
    c.drawOval(
        Rect.fromCenter(center: center, width: 0.4 * k, height: 0.24 * k),
        body);
    for (final side in [-1.0, 1.0]) {
      final stalk = center.translate(side * 0.1 * k, -0.12 * k);
      c.drawLine(center.translate(side * 0.08 * k, -0.02 * k), stalk,
          Paint()
            ..color = body.color
            ..strokeWidth = 2);
      c.drawCircle(stalk, 2.2, Paint()..color = Colors.black);
    }
    final clawPhase =
        running ? math.sin(g.time * 20) * 6 : math.sin(g.time * 3) * 3;
    for (final side in [-1.0, 1.0]) {
      final claw = center.translate(side * 0.22 * k, 0.02 * k + clawPhase * side);
      c.drawCircle(claw, 5, body);
      c.drawCircle(claw.translate(side * 3, -2), 3, body);
    }
    final leg = Paint()
      ..color = body.color
      ..strokeWidth = 3;
    for (int i = 0; i < 3; i++) {
      final legPhase = running ? math.sin(g.time * 20 + i) * 5 : 0.0;
      for (final side in [-1.0, 1.0]) {
        final lx = center.dx + side * (0.05 * k + i * 0.05 * k);
        c.drawLine(Offset(lx, center.dy + 0.08 * k),
            Offset(lx + legPhase, center.dy + 0.16 * k), leg);
      }
    }
    c.restore();

    if (running && !facingRight) {
      final tp = TextPainter(
        text: const TextSpan(
            text: 'CLICK CLICK',
            style: TextStyle(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(c, center.translate(-32, -32));
    }
  }

  /// Nightmare reskin of the kennel: a crooked grave doubling as a portal,
  /// guarded by a rather more literal hellhound.
  void _gravePortal(Canvas c) {
    final base = _w(World.kennelX, 0);
    final w = World.kennelW * _scale;
    final h = World.kennelH * _scale;
    final stone = Paint()..color = const Color(0xFF3A3640);
    final body = Rect.fromLTWH(base.dx, base.dy - h * 0.72, w, h * 0.72);
    c.drawRRect(
        RRect.fromRectAndCorners(body,
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18)),
        stone);
    final glow = 0.5 + 0.3 * math.sin(g.time * 3);
    final holeCenter = body.center.translate(0, h * 0.08);
    c.drawOval(
        Rect.fromCenter(center: holeCenter, width: w * 0.4, height: h * 0.46),
        Paint()..color = Color.fromRGBO(120, 20, 20, 0.5 + glow * 0.3));
    c.drawOval(
        Rect.fromCenter(center: holeCenter, width: w * 0.28, height: h * 0.32),
        Paint()..color = const Color(0xFFE65A28).withValues(alpha: 0.6));
    final tp = TextPainter(
      text: const TextSpan(
          text: 'R.I.P. ROVER',
          style: TextStyle(
              color: Color(0xFFAFA8B8),
              fontSize: 8,
              fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset(body.center.dx - tp.width / 2, body.top + 3));

    if (g.dogOut) {
      _dog(c, g.dogX, running: true, facingRight: g.dogFacingRight, hellish: true);
    } else {
      c.drawCircle(holeCenter.translate(-w * 0.05, -h * 0.02), 2,
          Paint()..color = const Color(0xFFFF3B30));
      c.drawCircle(holeCenter.translate(w * 0.05, -h * 0.02), 2,
          Paint()..color = const Color(0xFFFF3B30));
    }
  }

  void _dog(Canvas c, double x,
      {bool running = false, bool facingRight = false, bool hellish = false}) {
    final o = _w(x, 0);
    final k = _scale; // pixels per meter
    final body = Paint()
      ..color = hellish ? const Color(0xFF241E22) : const Color(0xFFC98A4B);
    final bounce = running ? math.sin(g.time * 18) * 3 : 0.0;

    c.save();
    if (facingRight) {
      // Mirror the sprite around the dog's position: head-first both ways.
      c.translate(o.dx * 2, 0);
      c.scale(-1, 1);
    }

    // Body (~0.55 m long).
    c.drawOval(
        Rect.fromCenter(
            center: Offset(o.dx, o.dy - 0.28 * k + bounce),
            width: 0.55 * k,
            height: 0.3 * k),
        body);
    // Head.
    final head = Offset(o.dx - 0.3 * k, o.dy - 0.42 * k + bounce);
    c.drawCircle(head, 0.14 * k, body);
    // Ear.
    c.drawOval(
        Rect.fromCenter(
            center: head.translate(0.05 * k, -0.12 * k),
            width: 0.09 * k,
            height: 0.16 * k),
        Paint()..color = const Color(0xFF9A6432));
    // Eye + nose.
    c.drawCircle(head.translate(-0.05 * k, -0.03 * k), 1.8,
        Paint()..color = hellish ? const Color(0xFFFF3B30) : Colors.black);
    c.drawCircle(head.translate(-0.13 * k, 0.02 * k), 2.5,
        Paint()..color = Colors.black87);
    if (hellish) {
      // Two extra heads, because one Barbos was never going to be enough.
      for (final side in [-1.0, 1.0]) {
        final extra = head.translate(side * 0.12 * k, 0.06 * k);
        c.drawCircle(extra, 0.09 * k, body);
        c.drawCircle(extra.translate(-0.03 * k, -0.02 * k), 1.4,
            Paint()..color = const Color(0xFFFF3B30));
      }
    }
    // Legs (blurred windmill while running).
    final leg = Paint()
      ..color = const Color(0xFF9A6432)
      ..strokeWidth = 4;
    for (int i = 0; i < 4; i++) {
      final phase = running ? math.sin(g.time * 18 + i * 1.6) * 6 : 0.0;
      final lx = o.dx - 0.18 * k + i * 0.12 * k;
      c.drawLine(Offset(lx, o.dy - 0.16 * k + bounce),
          Offset(lx + phase, o.dy), leg);
    }
    // Tail.
    c.drawLine(
        Offset(o.dx + 0.25 * k, o.dy - 0.33 * k + bounce),
        Offset(o.dx + 0.36 * k,
            o.dy - 0.44 * k + bounce + math.sin(g.time * 12) * 3),
        leg..strokeWidth = 3);
    c.restore();

    // Comic-strip "WOOF!!" — only while actually chasing (drawn outside
    // the mirrored canvas so the text never flips).
    if (running && !facingRight) {
      final tp = TextPainter(
        text: TextSpan(
            text: hellish ? 'GRRR×3!!' : 'WOOF!!',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(c, head.translate(-20, -34));
    }
  }

  /// Beach reskin of the bench: Uncle Gena, towel, bottle, unbothered.
  void _towelScene(Canvas c) {
    final o = _w(World.benchX, 0);
    final w = World.benchW * _scale;
    final seatY = o.dy - 3;

    final stripes = [const Color(0xFFCF6679), const Color(0xFFE9E3CE)];
    final towel = Rect.fromLTWH(o.dx - 6, seatY, w + 20, 12);
    for (int i = 0; i < 5; i++) {
      c.drawRect(
          Rect.fromLTWH(towel.left + i * (towel.width / 5), towel.top,
              towel.width / 5, towel.height),
          Paint()..color = stripes[i % 2]);
    }

    if (g.drunkardChasing) {
      _genaWithBroom(c);
    } else {
      final cx = o.dx + w * 0.3;
      final skin = Paint()..color = const Color(0xFFE0B48C);
      final trunks = Paint()..color = const Color(0xFF3E9A5B);
      c.drawOval(
          Rect.fromCenter(center: Offset(cx, seatY - 6), width: 46, height: 16),
          skin);
      c.drawOval(
          Rect.fromCenter(
              center: Offset(cx + 10, seatY - 6), width: 20, height: 14),
          trunks);
      final head = Offset(cx - 26, seatY - 10);
      c.drawCircle(head, 9, skin);
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(head.dx - 8, head.dy - 2, 16, 5),
              const Radius.circular(2)),
          Paint()..color = const Color(0xFF2A2830));
      final arm = Paint()
        ..color = skin.color
        ..strokeWidth = 6;
      c.drawLine(Offset(cx - 14, seatY - 6), Offset(cx - 20, seatY + 2), arm);
      if (g.drunkardAngry) {
        final shake = math.sin(g.time * 22) * 3;
        c.drawLine(Offset(cx + 14, seatY - 8),
            Offset(cx + 28 + shake, seatY - 26), arm);
        c.drawCircle(Offset(cx + 30 + shake, seatY - 28), 5, skin);
        final tp = TextPainter(
          text: const TextSpan(
              text: '#@*!',
              style: TextStyle(
                  color: Color(0xFFB33A3A),
                  fontSize: 13,
                  fontWeight: FontWeight.w900)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(c, Offset(cx + 18, seatY - 50));
      }
    }

    // Not a bottle anymore — Uncle Gena has upgraded to a proper martini,
    // and it topples exactly the same way a bottle would.
    if (g.bottleFlying) {
      final bo = _w(g.bottleFx, g.bottleFy);
      c.save();
      c.translate(bo.dx, bo.dy);
      c.rotate(g.time * 10);
      _martiniGlass(c);
      c.restore();
    } else {
      final bo = _w(World.bottleX, 0);
      c.save();
      c.translate(bo.dx, bo.dy - World.bottleH * _scale * 0.55);
      _martiniGlass(c);
      c.restore();
    }

    // A parasol — even Uncle Gena has standards.
    final poleX = o.dx + w + 6;
    c.drawLine(Offset(poleX, o.dy), Offset(poleX, o.dy - 60),
        Paint()
          ..color = const Color(0xFF8B5E34)
          ..strokeWidth = 3);
    final canopy = Path()
      ..moveTo(poleX - 26, o.dy - 56)
      ..quadraticBezierTo(poleX, o.dy - 72, poleX + 26, o.dy - 56)
      ..close();
    c.drawPath(canopy, Paint()..color = const Color(0xFFCF6679));
  }

  void _bench(Canvas c) {
    if (g.beach) {
      _towelScene(c);
      return;
    }
    final o = _w(World.benchX, 0);
    final w = World.benchW * _scale;
    final seatY = o.dy - 0.45 * _scale;
    // The nightmare yard's Uncle Gena has fully committed to the bit: red
    // skin, dark coat, small horns. No longer subtle about it.
    final skinColor = g.nightmare ? const Color(0xFFB33A2E) : const Color(0xFFE0B48C);
    final coatColor = g.nightmare ? const Color(0xFF3A1418) : const Color(0xFF6E7B65);

    // Bench.
    final wood = Paint()
      ..color = g.nightmare ? const Color(0xFF2A2228) : const Color(0xFF7A5230);
    c.drawRect(Rect.fromLTWH(o.dx, seatY, w, 6), wood);
    c.drawRect(Rect.fromLTWH(o.dx, seatY - 0.45 * _scale, w, 5), wood); // back
    c.drawRect(Rect.fromLTWH(o.dx + 4, seatY, 5, o.dy - seatY), wood);
    c.drawRect(Rect.fromLTWH(o.dx + w - 9, seatY, 5, o.dy - seatY), wood);

    if (g.drunkardChasing) {
      _genaWithBroom(c);
    } else {
      // Uncle Gena, seated.
      final cx = o.dx + w * 0.45;
      final skin = Paint()..color = skinColor;
      final coat = Paint()..color = coatColor;
      // Torso (slouched at a physically improbable but spiritually accurate
      // angle).
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(cx - 11, seatY - 34, 24, 34),
              const Radius.circular(7)),
          coat);
      // Head + ushanka (horns poke straight through it in the nightmare
      // yard — the hat was simply not consulted).
      final head = Offset(cx + 1, seatY - 42);
      c.drawCircle(head, 9, skin);
      c.drawArc(Rect.fromCircle(center: head, radius: 10.5), math.pi * 0.95,
          math.pi, true, Paint()..color = const Color(0xFF5A4632));
      if (g.nightmare) {
        // A dark rust-brown reads clearly against both the night sky
        // and the ushanka — near-black horns were invisible against the
        // nightmare backdrop.
        final horn = Paint()..color = const Color(0xFF8B3A22);
        for (final side in [-1.0, 1.0]) {
          final base = head.translate(side * 6, -8);
          final tip = head.translate(side * 11, -19);
          c.drawPath(
              Path()
                ..moveTo(base.dx - 2, base.dy)
                ..lineTo(tip.dx, tip.dy)
                ..lineTo(base.dx + 2, base.dy)
                ..close(),
              horn);
        }
      }
      // Majestic nose.
      c.drawCircle(
          head.translate(7, 2), 3, Paint()..color = const Color(0xFFD08B6E));
      // Legs.
      final leg = Paint()
        ..color = const Color(0xFF4C4C46)
        ..strokeWidth = 6;
      c.drawLine(Offset(cx - 4, seatY), Offset(cx - 8, o.dy), leg);
      c.drawLine(Offset(cx + 8, seatY), Offset(cx + 12, o.dy), leg);

      // Arm: relaxed, or shaking a fist at fate (i.e., you).
      final arm = Paint()
        ..color = coat.color
        ..strokeWidth = 6;
      if (g.drunkardAngry) {
        final shake = math.sin(g.time * 22) * 3;
        c.drawLine(Offset(cx - 6, seatY - 26),
            Offset(cx - 22 + shake, seatY - 48), arm);
        c.drawCircle(Offset(cx - 24 + shake, seatY - 50), 5, skin);
        final tp = TextPainter(
          text: const TextSpan(
              text: '#@*!',
              style: TextStyle(
                  color: Color(0xFFB33A3A),
                  fontSize: 13,
                  fontWeight: FontWeight.w900)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(c, Offset(cx - 34, seatY - 74));
      } else {
        c.drawLine(
            Offset(cx - 6, seatY - 26), Offset(cx - 16, seatY - 8), arm);
      }
    }

    if (g.nightmare) {
      // Not a bottle anymore: a small cauldron, bubbling with lava, tips
      // over and rolls exactly the same way a bottle would.
      if (g.bottleFlying) {
        final bo = _w(g.bottleFx, g.bottleFy);
        c.save();
        c.translate(bo.dx, bo.dy);
        c.rotate(g.time * 10);
        _cauldron(c);
        c.restore();
      } else {
        final bo = _w(World.bottleX, 0);
        c.save();
        c.translate(bo.dx, bo.dy - World.bottleH * _scale * 0.5);
        _cauldron(c);
        c.restore();
      }
      return;
    }
    // The bottle: on the ground, or in low orbit.
    final bottleP = Paint()..color = const Color(0xFF3E7A46);
    if (g.bottleFlying) {
      final bo = _w(g.bottleFx, g.bottleFy);
      c.save();
      c.translate(bo.dx, bo.dy);
      c.rotate(g.time * 10);
      c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(-4, -12, 8, 24),
              const Radius.circular(3)),
          bottleP);
      c.restore();
    } else {
      final bo = _w(World.bottleX, 0);
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(bo.dx - 4, bo.dy - World.bottleH * _scale, 8,
                  World.bottleH * _scale),
              const Radius.circular(3)),
          bottleP);
      c.drawRect(
          Rect.fromLTWH(bo.dx - 2, bo.dy - World.bottleH * _scale - 5, 4, 6),
          bottleP);
    }
  }

  /// A small cauldron of lava, standing in for the bottle in the
  /// nightmare yard. Drawn centered on the local origin.
  void _cauldron(Canvas c) {
    final pot = Paint()..color = const Color(0xFF1B1920);
    c.drawArc(const Rect.fromLTWH(-9, -8, 18, 16), 0, math.pi, false,
        pot..style = PaintingStyle.stroke..strokeWidth = 5);
    // Handles.
    c.drawCircle(const Offset(-9, -6), 2, Paint()..color = const Color(0xFF1B1920));
    c.drawCircle(const Offset(9, -6), 2, Paint()..color = const Color(0xFF1B1920));
    // Bubbling lava, glowing.
    final glow = 0.6 + 0.3 * math.sin(g.time * 6);
    c.drawOval(const Rect.fromLTWH(-8, -9, 16, 7),
        Paint()..color = Color.fromRGBO(255, 110, 40, 0.5 + glow * 0.3));
    c.drawOval(const Rect.fromLTWH(-6, -8, 12, 5),
        Paint()..color = Color.fromRGBO(255, 200, 90, 0.7 + glow * 0.3));
    // A stray bubble popping.
    c.drawCircle(Offset(-2 + math.sin(g.time * 8) * 2, -9), 1.4,
        Paint()..color = const Color(0xFFFFD873));
  }

  /// A proper martini, standing in for the bottle on the beach. Drawn
  /// centered on the local origin, stem-down.
  void _martiniGlass(Canvas c) {
    final glass = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    // The iconic V bowl.
    final bowl = Path()
      ..moveTo(-9, -13)
      ..lineTo(9, -13)
      ..lineTo(0, -1)
      ..close();
    c.drawPath(bowl, glass);
    // The cocktail itself, filled almost to the rim.
    final liquid = Path()
      ..moveTo(-7, -11.5)
      ..lineTo(7, -11.5)
      ..lineTo(0, -2.5)
      ..close();
    c.drawPath(liquid, Paint()..color = const Color(0xFFE8E3C8));
    c.drawPath(
        Path()
          ..moveTo(-7, -11.5)
          ..lineTo(7, -11.5)
          ..lineTo(4.5, -8)
          ..lineTo(-4.5, -8)
          ..close(),
        Paint()..color = Colors.white.withValues(alpha: 0.4));
    // Stem and base.
    c.drawLine(const Offset(0, -1), const Offset(0, 8),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..strokeWidth = 1.6);
    c.drawLine(const Offset(-6, 9), const Offset(6, 9),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..strokeWidth = 2);
    // An olive, because standards.
    c.drawCircle(const Offset(3, -9), 2.4, Paint()..color = const Color(0xFF6E8A3E));
    c.drawLine(const Offset(3, -9), const Offset(8, -13),
        Paint()
          ..color = const Color(0xFFE8E3C8)
          ..strokeWidth = 1);
  }

  /// Uncle Gena on the warpath, weapon of choice held high (a broom on
  /// dry land, a flip-flop on the beach, and a pitchfork in the
  /// nightmare yard, where he's stopped pretending otherwise).
  void _genaWithBroom(Canvas c) {
    final o = _w(g.drunkardX, 0);
    final skin = Paint()
      ..color = g.nightmare ? const Color(0xFFB33A2E) : const Color(0xFFE0B48C);
    final coat = Paint()
      ..color = g.nightmare
          ? const Color(0xFF3A1418)
          : g.beach
              ? const Color(0xFFD8543C)
              : const Color(0xFF6E7B65);
    // Alternating gait (front leg forward while the other trails back),
    // plus a small body bounce — matches the _dog/_bear running style so
    // the advance and the stroll-back read as actual locomotion instead
    // of twitching in place.
    final strideA = math.sin(g.time * 16) * 9;
    final strideB = math.sin(g.time * 16 + math.pi) * 9;
    final bounce = math.sin(g.time * 16).abs() * -3;

    c.save();
    if (g.drunkardFacingRight) {
      // Mirror around Gena's position, same trick as _dog/_bear: he
      // genuinely turns around and struts back toward the bench.
      c.translate(o.dx * 2, 0);
      c.scale(-1, 1);
    }

    // Legs, moving with unexpected athleticism.
    final leg = Paint()
      ..color = const Color(0xFF4C4C46)
      ..strokeWidth = 7;
    c.drawLine(Offset(o.dx, o.dy - 32 + bounce), Offset(o.dx - 7 + strideA, o.dy), leg);
    c.drawLine(Offset(o.dx, o.dy - 32 + bounce), Offset(o.dx + 7 + strideB, o.dy), leg);
    // Torso.
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(o.dx - 11, o.dy - 60 + bounce, 22, 30),
            const Radius.circular(6)),
        coat);
    // Head + ushanka (sunglasses on the beach; horns punch straight
    // through the ushanka in the nightmare yard).
    final head = Offset(o.dx, o.dy - 68 + bounce);
    c.drawCircle(head, 9, skin);
    if (g.beach) {
      final shade = Paint()..color = const Color(0xFF2A2830);
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(head.dx - 8, head.dy - 3, 16, 5),
              const Radius.circular(2)),
          shade);
    } else {
      c.drawArc(Rect.fromCircle(center: head, radius: 10.5), math.pi * 0.95,
          math.pi, true, Paint()..color = const Color(0xFF5A4632));
    }
    if (g.nightmare) {
      final horn = Paint()..color = const Color(0xFF8B3A22);
      for (final side in [-1.0, 1.0]) {
        final base = head.translate(side * 6, -8);
        final tip = head.translate(side * 11, -19);
        c.drawPath(
            Path()
              ..moveTo(base.dx - 2, base.dy)
              ..lineTo(tip.dx, tip.dy)
              ..lineTo(base.dx + 2, base.dy)
              ..close(),
            horn);
      }
    }
    c.drawCircle(
        head.translate(-7, 2), 3, Paint()..color = const Color(0xFFD08B6E));

    // Arm raised with the weapon of justice.
    final arm = Paint()
      ..color = coat.color
      ..strokeWidth = 6;
    final hand = Offset(o.dx - 16, o.dy - 74 + bounce + strideA * 0.5);
    c.drawLine(Offset(o.dx - 8, o.dy - 54 + bounce), hand, arm);
    if (g.beach) {
      // A flip-flop, brandished with real intent.
      final sandal = Paint()..color = const Color(0xFF3E9A5B);
      final tip = hand.translate(-18, -10);
      c.drawOval(
          Rect.fromCenter(center: tip, width: 20, height: 10), sandal);
      c.drawLine(hand.translate(4, 4), tip, Paint()
        ..color = const Color(0xFF8B5E34)
        ..strokeWidth = 4);
    } else if (g.nightmare) {
      // A pitchfork: stick + three prongs, appropriately dramatic.
      final stick = Paint()
        ..color = const Color(0xFF1B1920)
        ..strokeWidth = 3;
      final tip = hand.translate(-22, -16);
      c.drawLine(hand.translate(10, 8), tip, stick);
      final prong = Paint()
        ..color = const Color(0xFF3A3742)
        ..strokeWidth = 2;
      for (final dx in [-6.0, 0.0, 6.0]) {
        c.drawLine(tip.translate(dx * 0.4, 2), tip.translate(dx, -10), prong);
      }
    } else {
      // Broom: stick + bristles.
      final stick = Paint()
        ..color = const Color(0xFF8B5E34)
        ..strokeWidth = 4;
      final tip = hand.translate(-20, -14);
      c.drawLine(hand.translate(10, 8), tip, stick);
      final bristle = Paint()
        ..color = const Color(0xFFC9A44C)
        ..strokeWidth = 2;
      for (int i = -2; i <= 2; i++) {
        c.drawLine(tip, tip.translate(-10 + i * 2.0, -12 + i * 3.0), bristle);
      }
    }
    c.restore();

    // Comic-strip "ENOUGH!!" — only while actually advancing on the
    // player (drawn outside the mirrored canvas so it never flips, same
    // convention as the dog's "WOOF!!").
    if (!g.drunkardFacingRight) {
      final tp = TextPainter(
        text: const TextSpan(
            text: 'ENOUGH!!',
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(c, head.translate(-24, -30));
    }
  }

  // ----------------------------------------------------------------
  // Pins
  // ----------------------------------------------------------------

  void _pins(Canvas c) {
    if (g.phase == Phase.pinDance) {
      _pinDance(c);
      return;
    }
    // Far pins first (painter's algorithm for our modest depth axis).
    final sorted = [...g.pins]
      ..sort((a, b) => b.spec.v.compareTo(a.spec.v));
    for (final p in sorted) {
      if (p.removed && !p.flying) continue;
      if (p.flying) {
        _pinAt(c, _w(p.fx, p.fy), p.fang, depth: p.spec.v);
      } else if (p.standing) {
        final depthDx = (p.spec.v - 1) * 0.07;
        final o = _w(p.worldX + depthDx, 0);
        if (p.toppled) {
          // Knocked over by the mole: lies at a haphazard angle.
          _lyingPin(c, o, 0.4 + p.offsetU * 2, depth: p.spec.v);
        } else if (p.spec.lying) {
          _lyingPin(c, o, p.spec.lyingAngle, depth: p.spec.v);
        } else {
          _pinAt(c, Offset(o.dx, o.dy - World.pinHeight * _scale / 2), 0,
              depth: p.spec.v);
          if (g.nightmare) {
            _pinFlame(c, Offset(o.dx, o.dy - World.pinHeight * _scale));
          }
        }
      }
    }
  }

  /// Level 4's other storyline: while the player idles with the figure
  /// still fully standing, the remaining gorodki pull themselves up
  /// into a crude dancing humanoid for a few seconds, then settle back
  /// into their normal spots. Purely cosmetic — the underlying pin data
  /// (standing/removed/worldX) never changes; this only touches how
  /// they're drawn for the duration of Phase.pinDance.
  void _pinDance(Canvas c) {
    final dancers = g.pins.where((p) => !p.removed).toList();
    if (dancers.isEmpty) return;
    final t = g.pinDanceT;

    // Ease in for the first 0.7s, hold fully assembled, ease back out
    // for the last 0.7s — so the blocks fly together and apart instead
    // of snapping.
    double formT;
    if (t < 0.7) {
      formT = (t / 0.7).clamp(0.0, 1.0);
    } else if (t > 4.3) {
      formT = ((5.0 - t) / 0.7).clamp(0.0, 1.0);
    } else {
      formT = 1.0;
    }
    final ease = formT * formT * (3 - 2 * formT);

    const centerX = (World.gorodFront + World.gorodBack) / 2;
    const bodySlots = [
      Offset(0, 1.55), // head
      Offset(0, 1.05), // torso
      Offset(-0.4, 1.2), // left arm
      Offset(0.4, 1.2), // right arm
      Offset(-0.18, 0.35), // left leg
      Offset(0.18, 0.35), // right leg
    ];

    for (int i = 0; i < dancers.length; i++) {
      final p = dancers[i];
      final depthDx = (p.spec.v - 1) * 0.07;
      final standX = p.worldX + depthDx;
      const standY = World.pinHeight / 2;

      double slotDx, slotDy, wiggleAngle;
      if (i < bodySlots.length) {
        final slot = bodySlots[i];
        final freq = 3.0 + i * 0.7;
        final phase = i * 1.7;
        final amp = i == 0 ? 0.05 : 0.13;
        final wiggle = math.sin(g.time * freq + phase) * amp;
        slotDx = slot.dx + wiggle * (i.isOdd ? 1 : -1);
        slotDy = slot.dy + math.sin(g.time * 4 + phase) * 0.06;
        wiggleAngle = math.sin(g.time * freq + phase) * (i == 0 ? 0.15 : 0.55);
      } else {
        // Extra blocks beyond the 6 body slots just orbit the head —
        // a little entourage of sparks.
        final orbitAngle = g.time * 2 + i * (math.pi * 2 / 3);
        slotDx = math.cos(orbitAngle) * 0.55;
        slotDy = 1.55 + math.sin(orbitAngle) * 0.3;
        wiggleAngle = orbitAngle;
      }

      final worldX = standX + (centerX + slotDx - standX) * ease;
      final worldY = standY + (slotDy - standY) * ease;
      final angle = wiggleAngle * ease;

      final o = _w(worldX, worldY);
      _pinAt(c, o, angle, depth: p.spec.v);
      if (g.nightmare) {
        _pinFlame(c, Offset(o.dx, o.dy - World.pinHeight * _scale * 0.5));
      }
    }
  }

  /// A small flickering flame, for the nightmare yard's ever-burning
  /// gorodki. Purely cosmetic — extinguishes the instant its pin is hit.
  void _pinFlame(Canvas c, Offset tip) {
    final flicker = math.sin(g.time * 18 + tip.dx) * 2;
    final h = 10 + math.sin(g.time * 11 + tip.dx * 0.7) * 2;
    final outer = Path()
      ..moveTo(tip.dx, tip.dy + 2)
      ..quadraticBezierTo(tip.dx - 5 + flicker, tip.dy - h * 0.5,
          tip.dx + flicker * 0.5, tip.dy - h)
      ..quadraticBezierTo(tip.dx + 5 + flicker, tip.dy - h * 0.5, tip.dx, tip.dy + 2)
      ..close();
    c.drawPath(outer, Paint()..color = const Color(0xFFE8622E).withValues(alpha: 0.85));
    final inner = Path()
      ..moveTo(tip.dx, tip.dy + 1)
      ..quadraticBezierTo(tip.dx - 2.5 + flicker * 0.6, tip.dy - h * 0.35,
          tip.dx + flicker * 0.3, tip.dy - h * 0.65)
      ..quadraticBezierTo(tip.dx + 2.5 + flicker * 0.6, tip.dy - h * 0.35, tip.dx,
          tip.dy + 1)
      ..close();
    c.drawPath(inner, Paint()..color = const Color(0xFFFFD873));
    c.drawCircle(Offset(tip.dx, tip.dy - h * 0.4), 2.5,
        Paint()..color = const Color(0x33FF8A3C));
  }

  /// Draws a pin centered at [center], rotated by [angle].
  void _pinAt(Canvas c, Offset center, double angle, {double depth = 1}) {
    final h = World.pinHeight * _scale;
    final w = World.pinWidth * _scale;
    final shade = 1 - (depth / 2) * 0.25;
    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(angle);
    final body = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        Radius.circular(w / 3));
    c.drawRRect(
        body,
        Paint()
          ..color = Color.lerp(const Color(0xFF3A2A18), const Color(0xFFE7D3AE),
              shade)!);
    // Stripes — a well-dressed gorodok.
    final stripe = Paint()
      ..color = Color.lerp(const Color(0xFF5A1F1F), const Color(0xFFC0392B),
          shade)!;
    c.drawRect(
        Rect.fromCenter(
            center: Offset(0, -h * 0.3), width: w, height: h * 0.16),
        stripe);
    c.drawRect(
        Rect.fromCenter(center: Offset(0, h * 0.3), width: w, height: h * 0.16),
        stripe);
    c.restore();
  }

  /// A pin lying on the ground; [axisAngle] is its yaw relative to the
  /// throw axis, so we foreshorten its on-screen length.
  void _lyingPin(Canvas c, Offset groundPoint, double axisAngle,
      {double depth = 1}) {
    final len =
        World.pinHeight * _scale * (0.35 + 0.65 * math.cos(axisAngle).abs());
    final w = World.pinWidth * _scale;
    final shade = 1 - (depth / 2) * 0.25;
    final r = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(groundPoint.dx, groundPoint.dy - w / 2),
            width: len,
            height: w),
        Radius.circular(w / 3));
    c.drawRRect(
        r,
        Paint()
          ..color = Color.lerp(const Color(0xFF3A2A18), const Color(0xFFE7D3AE),
              shade)!);
    c.drawRect(
        Rect.fromCenter(
            center: Offset(groundPoint.dx - len * 0.28,
                groundPoint.dy - w / 2),
            width: len * 0.14,
            height: w),
        Paint()
          ..color = Color.lerp(const Color(0xFF5A1F1F), const Color(0xFFC0392B),
              shade)!);
  }

  // ----------------------------------------------------------------
  // Player & bat
  // ----------------------------------------------------------------

  void _player(Canvas c) {
    if (g.playerBuried) return; // rendered by _avalanche instead
    final px = g.playerX + g.playerRunOffset;
    if (px < -1.5) return; // fully fled
    final o = _w(px, 0);
    final skin = Paint()..color = const Color(0xFFE0B48C);
    final shirt = Paint()
      ..color = g.nightmare
          ? const Color(0xFF17151C)
          : (g.beach ? const Color(0xFF2FA0A8) : const Color(0xFF3B6EA5));
    final pants = Paint()
      ..color = g.nightmare
          ? const Color(0xFF0E0D12)
          : (g.beach ? const Color(0xFFE8543C) : const Color(0xFF444B54));

    // Wrapped up by the spider — takes priority over everything else.
    if (g.playerCocooned) {
      final wiggle = math.sin(g.time * 12) * (1 - g.cocoonWrap * 0.6) * 3;
      final silk = Paint()..color = const Color(0xFFE9E3D6);
      final wrapH = 12 + 46 * g.cocoonWrap;
      final center = Offset(o.dx + wiggle, o.dy - 8 - wrapH / 2);
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(center: center, width: 22, height: wrapH),
              const Radius.circular(11)),
          silk);
      // Cross-hatched wrap lines.
      final strand = Paint()
        ..color = const Color(0xFFCFC8B4)
        ..strokeWidth = 1.3;
      for (int i = 0; i < 5; i++) {
        final ly = center.dy - wrapH / 2 + wrapH * (i / 4);
        c.drawLine(Offset(center.dx - 11, ly + 5),
            Offset(center.dx + 11, ly - 5), strand);
      }
      // Wide, terrified eyes, once mostly wrapped.
      if (g.cocoonWrap > 0.55) {
        final eyeY = center.dy - wrapH / 2 + 9;
        for (final dx in [-4.0, 4.0]) {
          c.drawCircle(Offset(center.dx + dx, eyeY), 2.4,
              Paint()..color = Colors.white);
          c.drawCircle(Offset(center.dx + dx, eyeY), 1.1,
              Paint()..color = Colors.black);
        }
      }
      return;
    }

    // Special poses after the bat's unscheduled return.
    if (g.playerBonked) {
      final leg = Paint()
        ..color = pants.color
        ..strokeWidth = 7;
      final arm = Paint()
        ..color = shirt.color
        ..strokeWidth = 6;
      if (!g.bonkCrawling) {
        // Squatting, arms clutched over the head.
        c.drawLine(Offset(o.dx - 2, o.dy - 16), Offset(o.dx - 10, o.dy), leg);
        c.drawLine(Offset(o.dx + 2, o.dy - 16), Offset(o.dx + 10, o.dy), leg);
        c.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(o.dx - 10, o.dy - 34, 20, 20),
                const Radius.circular(6)),
            shirt);
        final head = Offset(o.dx, o.dy - 40);
        c.drawCircle(head, 9, skin);
        // Arms wrapped over the head.
        c.drawLine(Offset(o.dx - 9, o.dy - 28), head.translate(-3, -9), arm);
        c.drawLine(Offset(o.dx + 9, o.dy - 28), head.translate(4, -9), arm);
        // Cartoon stars orbiting the bump.
        final tp = TextPainter(
          text: TextSpan(
            text: '✶  ✶',
            style: TextStyle(
              color: const Color(0xFFFFE082),
              fontSize: 14 + math.sin(g.time * 8) * 2,
              fontWeight: FontWeight.w900,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(c, head.translate(-14, -34));
      } else {
        // Crawling off the field, flat and humbled.
        final paddle = math.sin(g.time * 10) * 4;
        c.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(o.dx - 14, o.dy - 13, 30, 9),
                const Radius.circular(4)),
            shirt);
        final head = Offset(o.dx - 19, o.dy - 11);
        c.drawCircle(head, 7, skin);
        c.drawArc(Rect.fromCircle(center: head, radius: 8), math.pi * 1.1,
            math.pi * 0.8, true, Paint()..color = const Color(0xFF7A6A4F));
        // Paddling limbs.
        c.drawLine(Offset(o.dx - 8, o.dy - 6), Offset(o.dx - 12 + paddle, o.dy),
            arm);
        c.drawLine(
            Offset(o.dx + 8, o.dy - 6), Offset(o.dx + 12 - paddle, o.dy), leg);
      }
      return;
    }

    final run = g.playerFleeing ? math.sin(g.time * 16) * 6 : 0.0;

    // Legs.
    final leg = Paint()
      ..color = pants.color
      ..strokeWidth = 7;
    c.drawLine(Offset(o.dx, o.dy - 34), Offset(o.dx - 7 - run, o.dy), leg);
    c.drawLine(Offset(o.dx, o.dy - 34), Offset(o.dx + 7 + run, o.dy), leg);
    // Torso.
    c.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(o.dx - 10, o.dy - 62, 20, 30),
            const Radius.circular(6)),
        shirt);
    final head = Offset(o.dx, o.dy - 70);
    if (g.winter) {
      // Padded winter coat instead of the light shirt.
      c.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(o.dx - 11, o.dy - 63, 22, 32),
              const Radius.circular(7)),
          Paint()..color = const Color(0xFFC94F7C));
      c.drawCircle(head, 9, skin);
      // Scarf, wrapped and trailing.
      final scarf = Paint()..color = const Color(0xFFE8C63C);
      c.drawRect(Rect.fromLTWH(o.dx - 9, o.dy - 62, 18, 7), scarf);
      c.drawRect(Rect.fromLTWH(o.dx + 4, o.dy - 58, 6, 16), scarf);
      // Knit hat with pompom.
      c.drawArc(Rect.fromCircle(center: head.translate(0, -1), radius: 10.5),
          math.pi, math.pi, true, Paint()..color = const Color(0xFF3E7ABF));
      c.drawRect(Rect.fromLTWH(head.dx - 10, head.dy - 2, 20, 5),
          Paint()..color = const Color(0xFF2E5D96));
      c.drawCircle(head.translate(0, -12), 4,
          Paint()..color = const Color(0xFFF3F8FC));
    } else if (g.nightmare) {
      // A cape, flowing out from behind the shoulders (drawn wide so it
      // reads past the torso already painted above)...
      final cape = Path()
        ..moveTo(o.dx - 9, o.dy - 58)
        ..lineTo(o.dx - 17, o.dy - 4)
        ..lineTo(o.dx - 3, o.dy - 18)
        ..lineTo(o.dx + 3, o.dy - 18)
        ..lineTo(o.dx + 17, o.dy - 4)
        ..lineTo(o.dx + 9, o.dy - 58)
        ..close();
      c.drawPath(cape, Paint()..color = const Color(0xFF0C0B10));
      // ...and a sealed black helmet, with the iconic breathing grille.
      c.drawCircle(head, 10, Paint()..color = const Color(0xFF15131A));
      c.drawArc(Rect.fromCircle(center: head.translate(0, -2), radius: 10.2),
          math.pi * 1.1,
          math.pi * 0.8,
          false,
          Paint()
            ..color = const Color(0xFF3A3742)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4);
      final grille = Paint()..color = const Color(0xFF3A3742);
      for (int i = -1; i <= 1; i++) {
        c.drawRect(Rect.fromLTWH(head.dx - 3 + i * 3.0, head.dy + 2, 2, 5),
            grille);
      }
      c.drawCircle(
          head.translate(0, -3),
          1.4,
          Paint()
            ..color = Color.fromRGBO(255, 40, 30, 0.6 + 0.3 * math.sin(g.time * 4)));
    } else if (g.beach) {
      // Head + sunglasses. No cap needed — the sun is a friend here.
      c.drawCircle(head, 9, skin);
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(head.dx - 8, head.dy - 3, 16, 5),
              const Radius.circular(2)),
          Paint()..color = const Color(0xFF2A2830));
    } else {
      // Head + flat cap (kepka).
      c.drawCircle(head, 9, skin);
      c.drawArc(Rect.fromCircle(center: head, radius: 10), math.pi * 1.05,
          math.pi * 0.9, true, Paint()..color = const Color(0xFF7A6A4F));
      c.drawRect(Rect.fromLTWH(head.dx, head.dy - 8, 12, 3),
          Paint()..color = const Color(0xFF7A6A4F));
    }

    // The verdict, delivered directly onto the cap: a splattered rotten
    // fruit in the evening, an old-fashioned dropping everywhere else.
    if (g.playerSoiled) {
      if (g.evening) {
        final mush = Paint()..color = const Color(0xFF7A6A2E);
        final mush2 = Paint()..color = const Color(0xFF9C8A3C);
        c.drawCircle(head.translate(1, -10), 5, mush);
        c.drawCircle(head.translate(-4, -7), 2.6, mush2);
        c.drawCircle(head.translate(5, -6), 2.2, mush2);
        c.drawCircle(head.translate(2, -13), 1.8, mush2);
      } else if (g.nightmare) {
        // Ectoplasm. Distinctly non-negotiable.
        final goo = Paint()..color = const Color(0xFF5FA86A);
        final goo2 = Paint()..color = const Color(0xFF8FCF9A);
        c.drawCircle(head.translate(1, -10), 5, goo);
        c.drawCircle(head.translate(-4, -7), 2.6, goo2);
        c.drawCircle(head.translate(5, -6), 2.2, goo2);
        c.drawCircle(head.translate(2, -13), 1.8, goo2);
      } else {
        final splat = Paint()..color = const Color(0xFFF5F2E8);
        c.drawCircle(head.translate(2, -9), 4, splat);
        c.drawCircle(head.translate(-3, -7), 2.5, splat);
        c.drawCircle(head.translate(6, -6), 2, splat);
      }
    }

    // The bandage: a lingering souvenir of the coconut, worn with dignity
    // for exactly ten seconds.
    if (g.coconutBandaged) {
      c.save();
      c.translate(head.dx, head.dy);
      c.rotate(-0.35);
      c.drawRRect(
          RRect.fromRectAndRadius(
              const Rect.fromLTWH(-11, -3, 22, 6), const Radius.circular(3)),
          Paint()..color = Colors.white.withValues(alpha: 0.95));
      c.restore();
      c.drawCircle(head.translate(7, -7), 1.8,
          Paint()..color = const Color(0xFFE8E8E0));
      c.drawCircle(head.translate(-3, 3), 2.2,
          Paint()..color = const Color(0x66335577));
    }

    // Arms.
    final arm = Paint()
      ..color = shirt.color
      ..strokeWidth = 6;
    if (g.playerFleeing) {
      // Arms flailing with great athletic purpose.
      c.drawLine(Offset(o.dx - 8, o.dy - 56),
          Offset(o.dx - 18, o.dy - 70 + run), arm);
      c.drawLine(Offset(o.dx + 8, o.dy - 56),
          Offset(o.dx + 16, o.dy - 68 - run), arm);
      final tp = TextPainter(
        text: const TextSpan(
            text: '!!',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(c, head.translate(-4, -30));
    } else if (g.phase == Phase.aiming) {
      // Wind-up arm holding the bat.
      final pull = g.aimingDrag ? (g.aimVx / 16.5) : 0.0;
      final handO = Offset(o.dx + 10 - pull * 16, o.dy - 60 - pull * 6);
      c.drawLine(Offset(o.dx + 8, o.dy - 56), handO, arm);
      // Bat in hand.
      c.save();
      c.translate(handO.dx, handO.dy);
      c.rotate(-0.9 - pull * 0.8);
      _batShape(c);
      c.restore();
      // Other arm.
      c.drawLine(Offset(o.dx - 8, o.dy - 56), Offset(o.dx - 14, o.dy - 44),
          arm);
    } else {
      c.drawLine(
          Offset(o.dx - 8, o.dy - 56), Offset(o.dx - 13, o.dy - 42), arm);
      c.drawLine(
          Offset(o.dx + 8, o.dy - 56), Offset(o.dx + 13, o.dy - 42), arm);
    }
  }

  void _batShape(Canvas c) {
    final len = World.batLength * _scale;
    final r = World.batRadius * 2.4 * _scale;
    if (g.nightmare) {
      // Not a bat anymore, strictly speaking: a glowing pink blade, held
      // together by nothing but vibes and a small dark hilt.
      final glow = 0.7 + 0.3 * math.sin(g.time * 6);
      final blade = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: len, height: r),
          Radius.circular(r / 2));
      c.drawRRect(blade.inflate(9),
          Paint()..color = Color.fromRGBO(255, 60, 180, 0.08 * glow));
      c.drawRRect(blade.inflate(5),
          Paint()..color = Color.fromRGBO(255, 70, 190, 0.16 * glow));
      c.drawRRect(blade.inflate(2),
          Paint()..color = Color.fromRGBO(255, 90, 200, 0.35 * glow));
      c.drawRRect(blade, Paint()..color = const Color(0xFFFF6FC6));
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset.zero, width: len * 0.88, height: r * 0.32),
              Radius.circular(r * 0.2)),
          Paint()..color = Colors.white.withValues(alpha: 0.85));
      // A small dark hilt at the grip end.
      c.drawRect(
          Rect.fromCenter(
              center: Offset(-len * 0.44, 0), width: len * 0.14, height: r * 1.3),
          Paint()..color = const Color(0xFF1B1920));
      return;
    }
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: len, height: r),
            Radius.circular(r / 2)),
        Paint()..color = const Color(0xFF8B5E34));
    // Grip tape.
    c.drawRect(
        Rect.fromCenter(
            center: Offset(-len * 0.38, 0), width: len * 0.16, height: r),
        Paint()..color = const Color(0xFF5A3A1E));
  }

  void _bat(Canvas c) {
    if (!g.bat.active) return;
    final o = _w(g.bat.x, g.bat.y);
    c.save();
    c.translate(o.dx, o.dy);
    if (g.bat.onRope) {
      c.rotate(math.pi / 2 + math.sin(g.bat.ropeSwing * 6) * 0.35);
      _batShape(c);
      if (!g.nightmare) {
        // The underpants, now with a new owner. (On the nightmare yard
        // it's chains, not a laundry line — no cloth to snag.)
        c.rotate(-math.pi / 2);
        final pantsP = Paint()..color = const Color(0xFFCF6679);
        c.drawRect(const Rect.fromLTWH(-10, -4, 20, 14), pantsP);
      }
    } else if (g.bat.inTree) {
      // Lodged among the yolka's branches, gently swaying. This is the
      // single source of truth for the "stuck in tree" sprite — it must
      // not also be drawn from _yolka(), or the bat visibly duplicates.
      c.translate(math.sin(g.bat.treeSwing * 3) * 4, 0);
      c.rotate(0.9 + math.sin(g.bat.treeSwing * 5) * 0.2);
      _batShape(c);
    } else if (g.bat.onWeb) {
      // Cocooned in silk, swaying gently from the strand.
      c.rotate(math.pi / 2 + math.sin(g.bat.webSwing * 7) * 0.25);
      _batShape(c);
    } else {
      c.rotate(g.bat.angle);
      _batShape(c);
    }
    c.restore();
  }

  void _pigeon(Canvas c) {
    if (!g.pigeon.active) return;
    final o = _w(g.pigeon.x, g.pigeon.y);
    if (g.evening) {
      // The night shift: a bat, all elbows and chaos.
      c.save();
      c.translate(o.dx, o.dy);
      if (g.pigeon.vx > 0.1) c.scale(-1, 1);
      final dark = Paint()..color = const Color(0xFF2E2633);
      final flap = math.sin(g.time * 26) * 9;
      // Jagged wings.
      for (final side in [-1.0, 1.0]) {
        final wing = Path()
          ..moveTo(0, 0)
          ..lineTo(side * 8, -6 - flap * side.sign)
          ..lineTo(side * 16, -2 - flap)
          ..lineTo(side * 12, 2)
          ..lineTo(side * 18, 5 - flap * 0.5)
          ..close();
        c.drawPath(wing, dark);
      }
      // Body + ears.
      c.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 10, height: 12), dark);
      final ear = Path()
        ..moveTo(-4, -5)
        ..lineTo(-3, -11)
        ..lineTo(-1, -5)
        ..close();
      c.drawPath(ear, dark);
      final ear2 = Path()
        ..moveTo(1, -5)
        ..lineTo(3, -11)
        ..lineTo(4, -5)
        ..close();
      c.drawPath(ear2, dark);
      // Tiny judgmental eyes.
      final eye = Paint()..color = const Color(0xFFFFD98A);
      c.drawCircle(const Offset(-2, -2), 1.3, eye);
      c.drawCircle(const Offset(2, -2), 1.3, eye);
      c.restore();
      return;
    }
    if (g.winter) {
      // The insolent crow: same silhouette as the heist sprite.
      c.save();
      c.translate(o.dx, o.dy);
      if (g.pigeon.vx > 0.1) c.scale(-1, 1);
      final dark = Paint()..color = const Color(0xFF23262B);
      final flap = math.sin(g.time * 15) * 6;
      for (final side in [-1.0, 1.0]) {
        final wing = Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(
              side * 10, -4 - flap * side.sign, side * 16, 1 - flap * 0.4)
          ..quadraticBezierTo(side * 10, 3, 0, 2)
          ..close();
        c.drawPath(wing, dark);
      }
      c.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 14, height: 10), dark);
      c.drawCircle(const Offset(-9, -2), 4, dark);
      final beak = Path()
        ..moveTo(-12, -2)
        ..lineTo(-17, -1)
        ..lineTo(-12, 1)
        ..close();
      c.drawPath(beak, Paint()..color = const Color(0xFFE8C63C));
      c.restore();
      return;
    }
    if (g.nightmare) {
      // The sky dragon: big, dark, soaring in slow circles overhead —
      // broad membrane wings with visible finger struts spread wide
      // (gliding, not flapping frantically), horns, a tapering tail,
      // and small clawed feet dangling beneath.
      c.save();
      c.translate(o.dx, o.dy);
      if (g.pigeon.vx > 0.1) c.scale(-1, 1);
      final dark = Paint()..color = const Color(0xFF201C24);
      final darker = Paint()..color = const Color(0xFF14111A);
      final flap = math.sin(g.time * 3.2) * 6; // slow, deliberate wingbeat

      // Wings.
      for (final side in [-1.0, 1.0]) {
        final wing = Path()
          ..moveTo(-2, -2)
          ..lineTo(side * 30, -20 - flap * side.sign)
          ..lineTo(side * 22, -6 - flap * 0.6 * side.sign)
          ..lineTo(side * 34, -2 - flap * 0.3 * side.sign)
          ..lineTo(side * 14, 6)
          ..close();
        c.drawPath(wing, dark);
        final strut = Paint()
          ..color = darker.color
          ..strokeWidth = 1.2;
        for (final f in [0.35, 0.65, 0.9]) {
          c.drawLine(const Offset(-1, -1),
              Offset(side * 30 * f, (-20 - flap * side.sign) * f), strut);
        }
      }

      // Tail, tapering away behind.
      final tail = Path()
        ..moveTo(10, 1)
        ..quadraticBezierTo(24, 3, 34, -2 + math.sin(g.time * 4) * 2)
        ..lineTo(34, 2 + math.sin(g.time * 4) * 2)
        ..quadraticBezierTo(22, 6, 10, 4)
        ..close();
      c.drawPath(tail, dark);

      // Body.
      c.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 26, height: 13), dark);
      // Neck + head.
      const head = Offset(-16, -3);
      c.drawOval(
          Rect.fromCenter(center: head, width: 15, height: 9), dark);
      // Horns.
      final horn = Paint()..color = const Color(0xFF3A3040);
      c.drawPath(
          Path()
            ..moveTo(head.dx - 2, head.dy - 4)
            ..lineTo(head.dx - 5, head.dy - 11)
            ..lineTo(head.dx + 1, head.dy - 5)
            ..close(),
          horn);
      c.drawPath(
          Path()
            ..moveTo(head.dx + 3, head.dy - 4)
            ..lineTo(head.dx + 2, head.dy - 10)
            ..lineTo(head.dx + 6, head.dy - 4)
            ..close(),
          horn);
      // Jaw.
      final jaw = Path()
        ..moveTo(head.dx - 7, head.dy - 1)
        ..lineTo(head.dx - 13, head.dy + 1)
        ..lineTo(head.dx - 7, head.dy + 3)
        ..close();
      c.drawPath(jaw, dark);
      // Glowing eye.
      c.drawCircle(head.translate(-3, -2), 1.6,
          Paint()..color = const Color(0xFFFF5A30));
      // Small clawed legs, dangling.
      final leg = Paint()
        ..color = darker.color
        ..strokeWidth = 2;
      c.drawLine(const Offset(-2, 5),
          Offset(-4 + math.sin(g.time * 3) * 2, 13), leg);
      c.drawLine(const Offset(4, 5),
          Offset(6 + math.sin(g.time * 3 + 1) * 2, 12), leg);
      c.restore();
      return;
    }
    if (g.beach) {
      // The seagull: long, bent wings held mostly still, gliding on the
      // sea breeze with the occasional lazy flap — nothing like a
      // pigeon's frantic wingbeat.
      c.save();
      c.translate(o.dx, o.dy);
      if (g.pigeon.vx > 0.1) c.scale(-1, 1);
      final body = Paint()..color = const Color(0xFFF5F5F0);
      final grey = Paint()..color = const Color(0xFFAEB6BE);
      // Long, slender body and small head.
      c.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 26, height: 9), body);
      c.drawCircle(const Offset(-12, -3), 4.5, body);
      c.drawCircle(const Offset(-14, -4), 1.1, Paint()..color = Colors.black);
      // Beak — a proper orange-yellow gull hook.
      final beak = Path()
        ..moveTo(-16, -3)
        ..lineTo(-21, -2)
        ..lineTo(-16, -0.5)
        ..close();
      c.drawPath(beak, Paint()..color = const Color(0xFFE8912E));
      // Wings: a slow glide-flap, bent sharply at the wrist like a real
      // gull — mostly held flat, with a gentle rise-and-fall.
      final glide = math.sin(g.time * 4.5) * 4;
      for (final side in [-1.0, 1.0]) {
        final wing = Path()
          ..moveTo(side * 2, -1)
          ..quadraticBezierTo(side * 12, -4 - glide, side * 22, -1 - glide * 1.4)
          ..quadraticBezierTo(side * 14, 1, side * 2, 1)
          ..close();
        c.drawPath(wing, side < 0 ? body : grey);
      }
      // Grey wingtip accents.
      for (final side in [-1.0, 1.0]) {
        c.drawLine(
            Offset(side * 20, -1 - glide * 1.3),
            Offset(side * 24, 1 - glide),
            Paint()
              ..color = const Color(0xFF3A3A3E)
              ..strokeWidth = 2);
      }
      c.restore();
      return;
    }
    c.save();
    c.translate(o.dx, o.dy);
    // Always fly beak-first: mirror the sprite when moving right.
    if (g.pigeon.vx > 0.1) c.scale(-1, 1);
    final body = Paint()..color = const Color(0xFF8E9AA8);
    c.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 22, height: 13), body);
    c.drawCircle(const Offset(-10, -4), 5, body);
    c.drawCircle(const Offset(-12, -5), 1.2, Paint()..color = Colors.black);
    // Beak.
    final beak = Path()
      ..moveTo(-15, -4)
      ..lineTo(-19, -3)
      ..lineTo(-15, -1)
      ..close();
    c.drawPath(beak, Paint()..color = const Color(0xFFD8A03C));
    // Flapping wing.
    final flap = math.sin(g.time * 20) * 8;
    final wing = Path()
      ..moveTo(0, -2)
      ..quadraticBezierTo(8, -14 - flap, 14, -4)
      ..close();
    c.drawPath(wing, Paint()..color = const Color(0xFF6F7B89));
    c.restore();
  }

  /// The mole: a dirt mound erupts inside the gorod, then a smug little
  /// digger pops out, wiggles its nose and redecorates the figure.
  void _mole(Canvas c) {
    if (!g.moleOut) return;
    final o = _w(World.gorodFront + g.moleU, 0);
    final k = _scale;
    // 0..1 emergence over the first 0.9 s, retreat near the end.
    final t = g.time; // for wiggles
    final up = math.min(1.0, g.moleT / 0.9) *
        math.min(1.0, math.max(0.0, (2.8 - g.moleT)) / 0.5);

    // Dirt mound (sand on the beach, scorched earth in the nightmare yard).
    final mound = Paint()
      ..color = g.beach
          ? const Color(0xFFD8C48A)
          : g.nightmare
              ? const Color(0xFF2E2A24)
              : const Color(0xFF5E4326);
    c.drawOval(
        Rect.fromCenter(
            center: Offset(o.dx, o.dy - 2),
            width: 0.7 * k * (0.4 + 0.6 * up),
            height: 0.22 * k * (0.4 + 0.6 * up)),
        mound);
    // Crumbs of earth hopping while it digs.
    final crumb = Paint()..color = const Color(0xFF6E5233);
    for (int i = 0; i < 4; i++) {
      final a = t * 6 + i * 1.7;
      c.drawCircle(
          Offset(o.dx + math.sin(a) * 0.28 * k,
              o.dy - 6 - (math.sin(a * 1.3).abs()) * 10 * up),
          2.5,
          crumb);
    }

    // The mole itself (sandy brown on the beach, a proper hellbeast in
    // the nightmare yard — same rig, considerably different disposition).
    final body = Paint()
      ..color = g.beach
          ? const Color(0xFFC98A4B)
          : g.nightmare
              ? const Color(0xFF8C8478)
              : const Color(0xFF4A3B4F);
    final rise = 0.34 * k * up;
    final head = Offset(o.dx, o.dy - 4 - rise);
    c.drawOval(
        Rect.fromCenter(
            center: Offset(o.dx, o.dy - 4 - rise / 2),
            width: 0.26 * k,
            height: rise + 0.06 * k),
        body);
    c.drawCircle(head, 0.13 * k, body);
    if (g.nightmare) {
      // Not a nose anymore: a small jet of flame, straight from the
      // mouth. Moles in the nightmare yard have given up on subtlety.
      final flick = math.sin(t * 16) * 1.6;
      final base = head.translate(math.sin(t * 14) * 1.2, -0.02 * k);
      final flameH = 9 + math.sin(t * 11) * 2.5;
      final flame = Path()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(base.dx - 4 + flick, base.dy - flameH * 0.5,
            base.dx + flick * 0.5, base.dy - flameH)
        ..quadraticBezierTo(
            base.dx + 4 + flick, base.dy - flameH * 0.5, base.dx, base.dy)
        ..close();
      c.drawPath(flame, Paint()..color = const Color(0xFFE8622E).withValues(alpha: 0.85));
      c.drawCircle(base.translate(0, -flameH * 0.45), 2,
          Paint()..color = const Color(0xFFFFD873));
    } else {
      // Pink nose, wiggling.
      c.drawCircle(head.translate(math.sin(t * 14) * 1.5, -0.1 * k), 3.5,
          Paint()..color = const Color(0xFFE8A0A8));
    }
    // Squinty eyes (moles famously skipped the eye exam) — or, in the
    // nightmare yard, a pair of small burning coals that skipped a lot
    // more than that.
    if (g.nightmare) {
      for (final dx in [-4.0, 4.0]) {
        final ex = head.translate(dx, -3.5);
        c.drawCircle(ex, 3, Paint()..color = const Color(0x55FF3B30));
        c.drawCircle(ex, 1.5, Paint()..color = const Color(0xFFFF3B30));
      }
    } else {
      final eye = Paint()
        ..color = Colors.black87
        ..strokeWidth = 1.6;
      c.drawLine(head.translate(-6, -4), head.translate(-2, -3), eye);
      c.drawLine(head.translate(6, -4), head.translate(2, -3), eye);
    }
    // Digging paws.
    final paw = Paint()..color = const Color(0xFFB9A0BC);
    c.drawCircle(head.translate(-0.11 * k, 0.06 * k + math.sin(t * 12) * 2), 4, paw);
    c.drawCircle(head.translate(0.11 * k, 0.06 * k - math.sin(t * 12) * 2), 4, paw);
  }

  /// Beach reskin of the quadcopter: a paraglider, lazily patrolling the
  /// same airspace with considerably worse intentions.
  void _paraglider(Canvas c) {
    if (!g.drone.active) return;
    final o = _w(g.drone.x, g.drone.y);
    final sway = math.sin(g.time * 2.2) * 4;
    // Bigger canopy, and it banks visibly into its direction of travel —
    // a real glider commits to a heading instead of hovering in place.
    const scale = 1.45;
    final heading = g.drone.vx.sign; // -1 left, +1 right, 0 while carrying
    final bank = heading * 0.08 +
        math.sin(g.drone.t * 0.8) * 0.05; // gentle roll from the thermals
    final canopyC = o.translate(sway, -20 * scale);

    c.save();
    c.translate(canopyC.dx, canopyC.dy);
    c.rotate(bank);
    c.translate(-canopyC.dx, -canopyC.dy);

    final canopy = Path()
      ..moveTo(canopyC.dx - 32 * scale, canopyC.dy)
      ..quadraticBezierTo(canopyC.dx, canopyC.dy - 13 * scale,
          canopyC.dx + 32 * scale, canopyC.dy)
      ..quadraticBezierTo(
          canopyC.dx, canopyC.dy - 5 * scale, canopyC.dx - 32 * scale, canopyC.dy)
      ..close();
    c.drawPath(canopy, Paint()..color = const Color(0xFFE85B4B));
    final panel = Path()
      ..moveTo(canopyC.dx - 11 * scale, canopyC.dy - 1 * scale)
      ..quadraticBezierTo(canopyC.dx, canopyC.dy - 12 * scale,
          canopyC.dx + 11 * scale, canopyC.dy - 1 * scale)
      ..quadraticBezierTo(canopyC.dx, canopyC.dy - 5 * scale,
          canopyC.dx - 11 * scale, canopyC.dy - 1 * scale)
      ..close();
    c.drawPath(panel, Paint()..color = const Color(0xFFF2CE7E));
    c.restore();

    final pilot = o.translate(sway * 0.35, 6 * scale);
    final lineP = Paint()
      ..color = const Color(0xFF2A2830)
      ..strokeWidth = 1;
    c.drawLine(canopyC.translate(-28 * scale, 0), pilot.translate(-4, -4), lineP);
    c.drawLine(canopyC.translate(28 * scale, 0), pilot.translate(4, -4), lineP);
    c.drawLine(canopyC.translate(0, -3), pilot, lineP);

    // The pilot, dangling in a harness, thrilled about all this.
    c.drawCircle(pilot, 5 * scale, Paint()..color = const Color(0xFFE0B48C));
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: pilot.translate(0, 8 * scale),
                width: 8 * scale,
                height: 10 * scale),
            Radius.circular(3 * scale)),
        Paint()..color = const Color(0xFF2FA0A8));

    // Winch cable down to the confiscated bat.
    if (g.drone.carrying) {
      c.drawLine(pilot.translate(0, 13 * scale), _w(g.bat.x, g.bat.y),
          Paint()
            ..color = const Color(0xFF2A2830)
            ..strokeWidth = 1.4);
    }
  }

  void _drone(Canvas c) {
    if (g.beach) {
      _paraglider(c);
      return;
    }
    if (!g.drone.active) return;
    final o = _w(g.drone.x, g.drone.y);
    final k = _scale;
    final bob = math.sin(g.time * 5) * 2; // hover wobble
    final ctr = o.translate(0, bob);

    // Body.
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: ctr, width: 0.34 * k, height: 0.13 * k),
            const Radius.circular(5)),
        Paint()..color = const Color(0xFF4A4F57));
    // Camera eye, watching you specifically.
    c.drawCircle(ctr.translate(0, 0.05 * k), 3.5,
        Paint()..color = const Color(0xFF88C9E8));

    // Arms + spinning rotor blur.
    final arm = Paint()
      ..color = const Color(0xFF33373D)
      ..strokeWidth = 3;
    for (final dx in [-0.24, 0.24]) {
      final hub = ctr.translate(dx * k, -0.08 * k);
      c.drawLine(ctr, hub, arm);
      final blurW =
          0.28 * k * (0.55 + 0.45 * math.sin(g.time * 40 + dx * 10).abs());
      c.drawOval(
          Rect.fromCenter(
              center: hub.translate(0, -3), width: blurW, height: 4),
          Paint()..color = Colors.black.withValues(alpha: 0.35));
    }

    // Blinking status LED (definitely recording).
    if ((g.time * 3) % 1 < 0.5) {
      c.drawCircle(ctr.translate(-0.15 * k, -2), 2.2,
          Paint()..color = const Color(0xFFE05B4B));
    }

    // Winch cable down to the confiscated bat.
    if (g.drone.carrying) {
      c.drawLine(
          ctr.translate(0, 0.07 * k),
          _w(g.bat.x, g.bat.y),
          Paint()
            ..color = const Color(0xFF33373D)
            ..strokeWidth = 2);
    }
  }

  // ----------------------------------------------------------------
  // Level 2: the evening yard
  // ----------------------------------------------------------------

  void _eveningLight(Canvas c, Size s) {
    if (!g.evening) return;
    final r = Offset.zero & s;
    // Warm sunset cast over everything...
    c.drawRect(r, Paint()..color = const Color(0x2AFF6A3A));
    // ...and dusk itself, deeper once the streetlamp is out.
    c.drawRect(r,
        Paint()..color = Color(g.lampBroken ? 0x3D101030 : 0x1E101030));
  }

  void _lamp(Canvas c, double x, bool broken, {double scale = 1.0}) {
    final base = _w(x, 0);
    final top = _w(x, World.lampY * scale);
    // Light cone first, so the pole sits on top of it.
    if (!broken) {
      final cone = Path()
        ..moveTo(top.dx, top.dy)
        ..lineTo(base.dx - 0.9 * _scale * scale, base.dy)
        ..lineTo(base.dx + 0.9 * _scale * scale, base.dy)
        ..close();
      c.drawPath(cone, Paint()..color = const Color(0x2EFFD98A));
      c.drawOval(
          Rect.fromCenter(
              center: base,
              width: 1.8 * _scale * scale,
              height: 0.2 * _scale * scale),
          Paint()..color = const Color(0x24FFD98A));
    }
    final pole = Paint()
      ..color = const Color(0xFF3E4348)
      ..strokeWidth = 5 * scale;
    c.drawLine(base, top, pole);
    // Lamp head.
    final head = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: top.translate(0, -4 * scale),
            width: 22 * scale,
            height: 12 * scale),
        Radius.circular(4 * scale));
    c.drawRRect(head, Paint()..color = const Color(0xFF2E3338));
    c.drawCircle(
        top.translate(0, 2 * scale),
        4.5 * scale,
        Paint()
          ..color =
              broken ? const Color(0xFF3A3F44) : const Color(0xFFFFE6A8));
    if (broken) {
      // A sad little zigzag of what used to be glass.
      final crack = Paint()
        ..color = const Color(0xFF1E2328)
        ..strokeWidth = 1.5;
      c.drawLine(top.translate(-4, 4), top.translate(0, 8), crack);
      c.drawLine(top.translate(0, 8), top.translate(4, 5), crack);
    }
  }

  /// The spider's web strung between the two lamps — draws the strand
  /// grid while weaving/active, and the spider herself while she works.
  /// A proper orb web, framed by four anchor points on the two lamp
  /// POLES themselves (top-near-pole, top-far-pole, bottom-near-pole,
  /// bottom-far-pole) — spiders weave across a gap between solid
  /// structures, not as a single line floating between two treetops.
  // A pair of fireflies drifting lazily over the yard, purely for
  // atmosphere — no gameplay effect. They fade in and out on a slow duty
  // cycle so they don't feel like they're always there.
  void _fireflies(Canvas c, Size s) {
    for (int f = 0; f < 2; f++) {
      final phase = f * 3.7;
      final cycle = ((g.time * 0.12) + f * 0.5) % 1.0;
      // Visible for roughly the middle 55% of each cycle, fading at the
      // edges.
      double vis;
      if (cycle < 0.2 || cycle > 0.75) {
        vis = 0;
      } else if (cycle < 0.3) {
        vis = (cycle - 0.2) / 0.1;
      } else if (cycle > 0.65) {
        vis = (0.75 - cycle) / 0.1;
      } else {
        vis = 1;
      }
      if (vis <= 0) continue;
      final t = g.time * 0.55 + phase;
      final wx = 11.5 + f * 3.2 + math.sin(t) * 2.3 + math.sin(t * 0.37) * 1.1;
      final wy = 1.1 + f * 0.3 + math.sin(t * 0.8) * 0.5 + math.cos(t * 0.29) * 0.3;
      final o = _w(wx, wy);
      final glow = 0.55 + 0.45 * math.sin(g.time * 9 + phase * 4);
      final alpha = (vis * (0.4 + glow * 0.5)).clamp(0.0, 1.0);
      c.drawCircle(o, 6.5, Paint()..color = Color.fromRGBO(214, 255, 140, alpha * 0.28));
      c.drawCircle(o, 2.2, Paint()..color = Color.fromRGBO(224, 255, 170, alpha));
    }
  }

  // A cheap deterministic hash (0..1 fract of a big sine), seeded by the
  // web's fixed webSeed so the asymmetry is stable across frames instead
  // of crawling every repaint.
  double _webHash(int i) {
    final x = math.sin(i * 12.9898 + g.webSeed * 78.233) * 43758.5453;
    return x - x.floorToDouble();
  }

  void _spiderWeb(Canvas c) {
    if (g.webAlpha <= 0) return;
    final tl = _w(World.lampX, World.webTopY);
    final tr = _w(World.lampX2, World.webTopY);
    final bl = _w(World.lampX, World.webBottomY);
    final br = _w(World.lampX2, World.webBottomY);

    double j(int i) => _webHash(i) - 0.5; // -0.5..0.5

    // Center of the pole gap, then nudged off-true — a real web is never
    // dead-centered in its frame.
    final cx = (tl.dx + tr.dx + bl.dx + br.dx) / 4;
    final cy = (tl.dy + tr.dy + bl.dy + br.dy) / 4;
    final halfW = ((tr.dx - tl.dx).abs() + (br.dx - bl.dx).abs()) / 4;
    final halfH = ((bl.dy - tl.dy).abs() + (br.dy - tr.dy).abs()) / 4;
    final hub = Offset(cx + j(1) * halfW * 0.4, cy + j(2) * halfH * 0.4);

    final silk = Paint()
      ..color = Colors.white.withValues(alpha: 0.55 * g.webAlpha)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    final silkFaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35 * g.webAlpha)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Bridge threads: the only dead-straight lines, anchoring the web to
    // the two poles — this is really all a spider's frame is.
    c.drawLine(hub, tl, silk);
    c.drawLine(hub, tr, silk);
    c.drawLine(hub, bl, silk);
    c.drawLine(hub, br, silk);

    // A handful of extra radial spokes, unevenly spaced and unevenly
    // long, reaching toward the boundary of the pole gap.
    const spokeCount = 11;
    final angles = List<double>.generate(spokeCount, (i) {
      final base = (i / spokeCount) * math.pi * 2;
      return base + j(i * 3 + 5) * (math.pi / spokeCount) * 0.9;
    });
    final lens = List<double>.generate(spokeCount, (i) {
      final cosA = math.cos(angles[i]), sinA = math.sin(angles[i]);
      final denom = math.sqrt(
          (cosA * cosA) / (halfW * halfW) + (sinA * sinA) / (halfH * halfH));
      final r = denom > 0.0001 ? 1 / denom : halfW;
      return r * (0.8 + j(i * 5 + 1) * 0.25);
    });
    for (int i = 0; i < spokeCount; i++) {
      final tip = hub + Offset(math.cos(angles[i]), math.sin(angles[i])) * lens[i];
      c.drawLine(hub, tip, silkFaint);
    }

    // Concentric capture rings — genuine circles per spoke radius (a bit
    // lumpy, like hand-spun silk) instead of straight polygon facets.
    // One ring is left with a small gap, as if she hasn't finished yet.
    final gapRing = j(99) > 0 ? 2 : 3;
    final gapSpoke = (spokeCount * (0.5 + j(77) * 0.9)).floor() % spokeCount;
    for (int ring = 1; ring <= 4; ring++) {
      final t = ring / 4.0;
      final path = Path();
      bool started = false;
      for (int i = 0; i <= spokeCount; i++) {
        final idx = i % spokeCount;
        if (ring == gapRing && idx == gapSpoke) {
          started = false;
          continue;
        }
        final rr = lens[idx] * t * (0.9 + j(idx + ring * 13) * 0.16);
        final pt = hub + Offset(math.cos(angles[idx]), math.sin(angles[idx])) * rr;
        if (!started) {
          path.moveTo(pt.dx, pt.dy);
          started = true;
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      c.drawPath(path, ring.isEven ? silkFaint : silk);
    }

    // The spider herself, only visible while actively weaving — scurries
    // out along one spoke and back as she spins the rings.
    if (g.spiderWeaving) {
      final a = angles[0];
      final len = lens[0];
      final tt = (g.time * 0.5) % 1.0;
      final travel = tt < 0.5 ? tt * 2 : (1 - tt) * 2;
      final pos = hub + Offset(math.cos(a), math.sin(a)) * (len * travel);
      final body = Paint()..color = const Color(0xFF1E1B22);
      c.drawCircle(pos, 4, body);
      c.drawCircle(pos.translate(-3, -2), 2.2, body);
      final leg = Paint()
        ..color = const Color(0xFF1E1B22)
        ..strokeWidth = 1.2;
      for (int i = 0; i < 4; i++) {
        final la = (i - 1.5) * 0.5;
        c.drawLine(pos, pos + Offset(math.cos(la) * 7, math.sin(la) * 7 - 3),
            leg);
        c.drawLine(
            pos,
            pos +
                Offset(math.cos(math.pi - la) * 7, math.sin(math.pi - la) * 7 - 3),
            leg);
      }
    }
  }

  /// The rotten fruit, mid-arc, on its way to the player's cap.
  void _fruit(Canvas c) {
    if (!g.fruitFlying) return;
    final o = _w(g.fruitX, g.fruitY);
    c.save();
    c.translate(o.dx, o.dy);
    c.rotate(g.time * 8);
    c.drawCircle(Offset.zero, 6, Paint()..color = const Color(0xFF7A6A2E));
    c.drawCircle(const Offset(-1.5, -1.5), 2.2,
        Paint()..color = const Color(0xFF9C8A3C));
    // A sad little stem/leaf.
    c.drawLine(const Offset(0, -6), const Offset(1, -9),
        Paint()
          ..color = const Color(0xFF5A3E24)
          ..strokeWidth = 1.5);
    c.restore();
  }

  /// The coconut, falling from the suspiciously tall palm — a straight,
  /// unglamorous drop, tumbling as it goes.
  void _coconut(Canvas c) {
    if (!g.coconutFalling) return;
    final o = _w(g.coconutX, g.coconutY);
    c.save();
    c.translate(o.dx, o.dy);
    c.rotate(g.time * 9);
    c.drawCircle(Offset.zero, 6.5, Paint()..color = const Color(0xFF5A3E24));
    c.drawCircle(const Offset(-1.5, -1.5), 2.4,
        Paint()..color = const Color(0xFF7A5A38));
    // The three little "face" marks every coconut is contractually
    // obligated to have.
    final face = Paint()..color = const Color(0xFF2A1E14);
    c.drawCircle(const Offset(-2, 1), 0.9, face);
    c.drawCircle(const Offset(2, 1), 0.9, face);
    c.drawCircle(const Offset(0, 3.5), 1.0, face);
    c.restore();
  }

  /// The window dragon's actual retaliation: three distinct fireballs,
  /// lobbed one after another from the broken window at wherever the
  /// player is standing. World-space, so it works regardless of
  /// kon/half-kon.
  void _dragonFireBreath(Canvas c) {
    if (!g.dragonBreathing) return;
    // Roughly where the dragon's snout ends up, leaning out of the sill.
    final src = _w(World.buildingRX + 1.15,
        (World.windowY1 + World.windowY2) / 2 + 0.15);
    final dst = _w(g.playerX + 0.15, 1.9);
    final dx = dst.dx - src.dx, dy = dst.dy - src.dy;
    final len = math.sqrt(dx * dx + dy * dy).clamp(1.0, 9999).toDouble();
    final nx = dx / len, ny = dy / len;
    final px = -ny, py = nx; // perpendicular, for the lob arc

    const flightDuration = 0.8;
    const launchGap = 0.32;
    const impactFade = 0.25;
    final t = g.dragonBreathT;

    Offset ballPos(double p) {
      // A gentle lob arc rather than a straight line — this is a
      // thrown fireball, not a laser.
      final arc = math.sin(p * math.pi) * 20;
      return Offset(
        src.dx + dx * p + px * arc,
        src.dy + dy * p + py * arc - 12 * math.sin(p * math.pi),
      );
    }

    for (int i = 0; i < 3; i++) {
      final launch = i * launchGap;
      if (t < launch) continue;
      final since = t - launch;
      final p = (since / flightDuration).clamp(0.0, 1.0);
      final fizzle = since <= flightDuration
          ? 1.0
          : (1.0 - (since - flightDuration) / impactFade).clamp(0.0, 1.0);
      if (fizzle <= 0) continue;

      // A short comet tail trailing behind the fireball.
      for (int j = 1; j <= 4; j++) {
        final tp = (p - j * 0.045).clamp(0.0, 1.0);
        final talpha = (0.4 - j * 0.08) * fizzle;
        if (talpha <= 0) continue;
        final pos = ballPos(tp);
        c.drawCircle(pos, 5.0 - j * 0.7,
            Paint()..color = Color.fromRGBO(255, 110, 30, talpha));
      }

      // The fireball itself: layered outer glow, flame, hot core.
      final pos = ballPos(p);
      final wobble = 1.0 + 0.12 * math.sin(g.time * 26 + i * 2.1);
      c.drawCircle(pos, 13 * wobble * fizzle,
          Paint()..color = Color.fromRGBO(255, 90, 20, 0.3 * fizzle));
      c.drawCircle(pos, 8.5 * wobble * fizzle,
          Paint()..color = Color.fromRGBO(255, 140, 40, 0.85 * fizzle));
      c.drawCircle(pos, 4.2 * wobble * fizzle,
          Paint()..color = Color.fromRGBO(255, 224, 130, 0.95 * fizzle));

      // A few sparks peeling off, for good measure.
      for (int k = 0; k < 3; k++) {
        final sparkT = (g.time * 5 + i * 2.1 + k * 1.7) % 1.0;
        c.drawCircle(
            pos.translate(math.sin(g.time * 7 + k) * 6 * sparkT,
                -6 * sparkT - math.cos(g.time * 5 + k) * 3),
            (2.2 - sparkT * 1.6) * fizzle,
            Paint()..color = Color.fromRGBO(255, 190, 90, (1 - sparkT) * 0.8 * fizzle));
      }
    }
  }

  void _car(Canvas c) {
    final x1 = _w(World.carX1, 0).dx;
    final x2 = _w(World.carX2, 0).dx;
    final k = _scale;
    final groundedY = _groundY;
    final bodyColor = Paint()..color = const Color(0xFF8A3A46); // cherry
    final darkTrim = Paint()..color = const Color(0xFF4E2228);

    // Wheels.
    for (final wx in [x1 + 0.35 * k, x2 - 0.35 * k]) {
      c.drawCircle(Offset(wx, groundedY - 0.16 * k), 0.17 * k,
          Paint()..color = const Color(0xFF23262B));
      c.drawCircle(Offset(wx, groundedY - 0.16 * k), 0.07 * k,
          Paint()..color = const Color(0xFF8E959C));
    }
    // Lower body.
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTRB(
                x1, groundedY - 0.62 * k, x2, groundedY - 0.12 * k),
            Radius.circular(0.1 * k)),
        bodyColor);
    // Cabin.
    final cabin = RRect.fromRectAndRadius(
        Rect.fromLTRB(x1 + 0.35 * k, groundedY - 1.05 * k, x2 - 0.35 * k,
            groundedY - 0.55 * k),
        Radius.circular(0.09 * k));
    c.drawRRect(cabin, bodyColor);
    // Windows: pristine, or freshly ventilated.
    final winRect = Rect.fromLTRB(x1 + 0.42 * k, groundedY - 0.99 * k,
        x2 - 0.42 * k, groundedY - 0.58 * k);
    if (g.carHits == 0) {
      c.drawRect(winRect, Paint()..color = const Color(0xFFAECDE0));
      c.drawLine(winRect.topCenter, winRect.bottomCenter, darkTrim);
    } else {
      c.drawRect(winRect, Paint()..color = const Color(0xFF5E7484));
      final crack = Paint()
        ..color = Colors.white70
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke;
      final ctr = winRect.center;
      for (int i = 0; i < 6; i++) {
        final a = i * math.pi / 3 + 0.3;
        c.drawLine(
            ctr,
            ctr +
                Offset(math.cos(a), math.sin(a)) *
                    (winRect.shortestSide * 0.6),
            crack);
      }
    }
    // Headlight + taillight.
    c.drawCircle(Offset(x1 + 0.06 * k, groundedY - 0.5 * k), 3.5,
        Paint()..color = const Color(0xFFFFE6A8));
    c.drawCircle(Offset(x2 - 0.06 * k, groundedY - 0.5 * k), 3.5,
        Paint()..color = const Color(0xFFD84A3A));
    // Alarm: flashing indicators + expanding sound rings.
    if (g.alarmT > 0 && (g.time * 6) % 1 < 0.5) {
      final flash = Paint()..color = const Color(0xFFFFA13A);
      c.drawCircle(Offset(x1 + 0.12 * k, groundedY - 0.62 * k), 5, flash);
      c.drawCircle(Offset(x2 - 0.12 * k, groundedY - 0.62 * k), 5, flash);
      final ring = Paint()
        ..color = const Color(0x66FFA13A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final t = (g.time * 2) % 1;
      c.drawCircle(Offset((x1 + x2) / 2, groundedY - 0.8 * k),
          (0.4 + t) * k * 0.8, ring);
    }
  }

  /// Angry silhouette in a lit window while the alarm wails.
  void _ownerInWindow(Canvas c, Rect win) {
    c.drawRect(win, Paint()..color = const Color(0xFFF2CE7E));
    final sil = Paint()..color = const Color(0xFF2E2633);
    final cx = win.center.dx;
    final cy = win.center.dy + win.height * 0.12;
    // Profile head (nose pointing toward the crime scene).
    c.drawCircle(Offset(cx + 2, cy - win.height * 0.18), win.width * 0.14, sil);
    final nose = Path()
      ..moveTo(cx - win.width * 0.10, cy - win.height * 0.20)
      ..lineTo(cx - win.width * 0.22, cy - win.height * 0.15)
      ..lineTo(cx - win.width * 0.09, cy - win.height * 0.12)
      ..close();
    c.drawPath(nose, sil);
    // Shoulders.
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(cx + 2, cy + win.height * 0.16),
                width: win.width * 0.5,
                height: win.height * 0.34),
            const Radius.circular(6)),
        sil);
    // Shaking fist.
    final shake = math.sin(g.time * 22) * 2.5;
    c.drawCircle(
        Offset(cx - win.width * 0.3 + shake, cy - win.height * 0.02),
        win.width * 0.09,
        sil);
    final tp = TextPainter(
      text: const TextSpan(
          text: '!!',
          style: TextStyle(
              color: Color(0xFFB33A3A),
              fontSize: 14,
              fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset(cx - win.width * 0.42, win.top + 2));
  }

  /// The car owner: undershirt, slippers, righteous fury.
  void _ownerRunner(Canvas c) {
    final o = _w(g.ownerX, 0);
    c.save();
    if (!g.ownerFacingRight) {
      // Mirror around o.dx so he turns to face the direction he's
      // actually walking, instead of retreating backwards.
      c.translate(o.dx * 2, 0);
      c.scale(-1, 1);
    }
    final skin = Paint()..color = const Color(0xFFE0B48C);
    final shirt = Paint()..color = const Color(0xFFEDE8DC); // the undershirt
    final run = math.sin(g.time * 16) * 6;

    final leg = Paint()
      ..color = const Color(0xFF3E4348)
      ..strokeWidth = 7;
    c.drawLine(Offset(o.dx, o.dy - 32), Offset(o.dx - 7 - run, o.dy - 3), leg);
    c.drawLine(Offset(o.dx, o.dy - 32), Offset(o.dx + 7 + run, o.dy - 3), leg);
    // Slippers (barely holding on).
    final slipper = Paint()..color = const Color(0xFF7A4E9E);
    c.drawOval(
        Rect.fromCenter(
            center: Offset(o.dx - 7 - run, o.dy - 2), width: 14, height: 6),
        slipper);
    c.drawOval(
        Rect.fromCenter(
            center: Offset(o.dx + 7 + run, o.dy - 2), width: 14, height: 6),
        slipper);
    // Torso.
    c.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(o.dx - 11, o.dy - 60, 22, 30),
            const Radius.circular(6)),
        shirt);
    // Head: bald, magnificent.
    final head = Offset(o.dx, o.dy - 68);
    c.drawCircle(head, 9, skin);
    // Angry brow.
    final brow = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2;
    c.drawLine(head.translate(2, -3), head.translate(8, -1), brow);
    // Raised fist.
    final arm = Paint()
      ..color = skin.color
      ..strokeWidth = 6;
    final fist = Offset(o.dx + 14, o.dy - 78 + run * 0.4);
    c.drawLine(Offset(o.dx + 8, o.dy - 54), fist, arm);
    c.drawCircle(fist, 5.5, skin);

    final tp = TextPainter(
      text: const TextSpan(
          text: '!!!',
          style: TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, head.translate(-6, -30));
    c.restore();
  }

  void _manholeProp(Canvas c) {
    final o = _w(World.manholeX, 0);
    final k = _scale;
    // The open hole.
    c.drawOval(
        Rect.fromCenter(
            center: Offset(o.dx, o.dy), width: 0.85 * k, height: 0.18 * k),
        Paint()..color = const Color(0xFF17130E));
    c.drawOval(
        Rect.fromCenter(
            center: Offset(o.dx, o.dy), width: 0.85 * k, height: 0.18 * k),
        Paint()
          ..color = const Color(0xFF6E675E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
    // The lid, leaned aside like it has somewhere better to be.
    c.save();
    c.translate(o.dx + 0.6 * k, o.dy - 0.16 * k);
    c.rotate(-1.15);
    c.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 0.5 * k, height: 0.5 * k),
        Paint()..color = const Color(0xFF565048));
    c.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 0.34 * k, height: 0.34 * k),
        Paint()
          ..color = const Color(0xFF3E3933)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    c.restore();

    // The resident, if currently making an acquisition.
    if (g.manholeManUp) {
      final rise =
          math.min(1.0, g.moleT / 0.4) * math.min(1.0, (2.4 - g.moleT) / 0.4)
              .clamp(0.0, 1.0)
              .toDouble();
      final top = o.dy - 0.75 * k * rise;
      final coat = Paint()..color = const Color(0xFF55604E);
      final skin = Paint()..color = const Color(0xFFE0B48C);
      // Torso emerging from the depths.
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTRB(
                  o.dx - 0.16 * k, top + 0.18 * k, o.dx + 0.16 * k, o.dy),
              Radius.circular(0.05 * k)),
          coat);
      // Head + ushanka + celebratory nose.
      final head = Offset(o.dx, top + 0.1 * k);
      c.drawCircle(head, 0.11 * k, skin);
      c.drawArc(Rect.fromCircle(center: head, radius: 0.13 * k),
          math.pi * 0.95, math.pi, true,
          Paint()..color = const Color(0xFF6E6258));
      c.drawCircle(head.translate(0.08 * k, 0.02 * k), 3.5,
          Paint()..color = const Color(0xFFD08B6E));
      // Both arms up, triumphantly holding the confiscated bat.
      final arm = Paint()
        ..color = coat.color
        ..strokeWidth = 5;
      final handL = head.translate(-0.16 * k, -0.14 * k);
      final handR = head.translate(0.16 * k, -0.14 * k);
      c.drawLine(head.translate(-0.1 * k, 0.15 * k), handL, arm);
      c.drawLine(head.translate(0.1 * k, 0.15 * k), handR, arm);
      c.save();
      c.translate(o.dx, handL.dy - 4);
      c.rotate(math.sin(g.time * 3) * 0.08);
      _batShape(c);
      c.restore();
    }
  }

  /// A small 6-wheeled sidewalk delivery rover that trundles across the
  /// level-2 yard: rounded white cargo pod on a glossy black chassis,
  /// twin vertical light strips up front, a little sensor knob on the
  /// hood, and a tall antenna with a flag on top. Generic rover look —
  /// no branding. If the bat clips it, it doesn't curl up — it turns
  /// tail and drives off the way it came.
  void _hedgehogProp(Canvas c) {
    if (!g.hogActive) return;
    final o = _w(g.hogX, 0);
    final k = _scale;

    c.save();
    if (g.hogTurned) {
      // Same mirror trick as _dog/_bear: it's genuinely turned around.
      c.translate(o.dx * 2, 0);
      c.scale(-1, 1);
    }

    final pod = Paint()..color = const Color(0xFFEDEAE2);
    final podShade = Paint()..color = const Color(0xFFD8D4C6);
    final chassisP = Paint()..color = const Color(0xFF1C1A1C);
    final dark = Paint()..color = const Color(0xFF201E1E);
    final bob = math.sin(g.time * 20) * 0.4; // a little motorized jitter

    // 6 small wheels along the base, evenly spaced, so the silhouette
    // reads clearly as a 6-wheeled rover from the side.
    final wheelY = o.dy - 0.025 * k;
    for (final wx in [-0.20, -0.12, -0.04, 0.04, 0.12, 0.20]) {
      final wc = Offset(o.dx + wx * k, wheelY);
      c.drawCircle(wc, 0.042 * k, dark);
      c.drawCircle(wc, 0.015 * k, Paint()..color = const Color(0xFF4A4744));
    }

    // Chassis: the glossy black lower deck the pod sits on.
    final chassisCenter = o.translate(0, -0.13 * k + bob);
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: chassisCenter, width: 0.46 * k, height: 0.15 * k),
            Radius.circular(0.05 * k)),
        chassisP);

    // Twin vertical light strips set into the chassis, up front.
    final glowPulse = 0.75 + 0.25 * math.sin(g.time * 10);
    for (final lx in [-0.16, -0.09]) {
      final stripC = o.translate(lx * k, -0.13 * k + bob);
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(center: stripC, width: 0.05 * k, height: 0.16 * k),
              Radius.circular(0.02 * k)),
          Paint()
            ..color = Color.fromRGBO(190, 230, 255, 0.4 * glowPulse)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(center: stripC, width: 0.022 * k, height: 0.1 * k),
              Radius.circular(0.01 * k)),
          Paint()..color = Color.fromRGBO(225, 245, 255, glowPulse));
    }

    // Cargo pod on top: rounded, set back slightly from the front deck.
    final podCenter = o.translate(0.02 * k, -0.28 * k + bob);
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: podCenter, width: 0.38 * k, height: 0.22 * k),
            Radius.circular(0.08 * k)),
        pod);
    // A soft shading band along the base of the pod for a bit of form.
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: podCenter.translate(0, 0.07 * k),
                width: 0.36 * k,
                height: 0.05 * k),
            Radius.circular(0.02 * k)),
        podShade);

    // A small grey sensor knob on the hood, front of the pod.
    final knob = o.translate(-0.14 * k, -0.22 * k + bob);
    c.drawCircle(knob, 0.028 * k, Paint()..color = const Color(0xFF8A8680));
    c.drawCircle(knob, 0.014 * k, Paint()..color = const Color(0xFF5A5650));

    // A tall, gently swaying antenna with a little flag on top.
    final sway = math.sin(g.time * 2.5) * 0.02 * k;
    final antennaBase = o.translate(-0.06 * k, -0.38 * k + bob);
    final antennaTip = Offset(o.dx - 0.03 * k + sway, o.dy - 0.62 * k + bob);
    c.drawPath(
        Path()
          ..moveTo(antennaBase.dx, antennaBase.dy)
          ..quadraticBezierTo(antennaTip.dx - 0.01 * k,
              (antennaBase.dy + antennaTip.dy) / 2, antennaTip.dx, antennaTip.dy),
        Paint()
          ..color = const Color(0xFF2A2726)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6);
    c.drawPath(
        Path()
          ..moveTo(antennaTip.dx, antennaTip.dy)
          ..lineTo(antennaTip.dx - 0.08 * k + sway * 1.5, antennaTip.dy + 0.025 * k)
          ..lineTo(antennaTip.dx, antennaTip.dy + 0.05 * k)
          ..close(),
        Paint()..color = const Color(0xFFD8483C));

    c.restore();

    // Dust puffs trailing behind, drawn outside the mirror so they
    // always billow away from the direction of travel.
    final trailDir = g.hogTurned ? -1.0 : 1.0;
    final dust = Paint()..color = const Color(0xFFC9C2A8).withValues(alpha: 0.5);
    for (int i = 0; i < 3; i++) {
      final dx = trailDir * (0.22 + i * 0.07) * k;
      c.drawCircle(
          o.translate(dx, -0.02 * k - i * 2 + math.sin(g.time * 10 + i) * 2),
          3.0 + i, dust);
    }
  }

  /// The trash bin, minding its own business in the right corner — until
  /// it isn't.
  void _trashBin(Canvas c) {
    final o = _w(World.binX, 0);
    final w = World.binW * _scale;
    final h = World.binH * _scale;
    final metal = Paint()..color = const Color(0xFF6E7580);
    final dark = Paint()..color = const Color(0xFF4A5058);
    final body = Rect.fromLTWH(o.dx - w / 2, o.dy - h, w, h);
    c.drawRRect(RRect.fromRectAndRadius(body, const Radius.circular(3)), metal);
    for (int i = 1; i < 3; i++) {
      c.drawLine(Offset(body.left, body.top + h * i / 3),
          Offset(body.right, body.top + h * i / 3),
          dark
            ..strokeWidth = 1.5);
    }
    // The lid — still visibly askew for a moment after the recent exit.
    final lidTilt = (g.catsFleeing && g.catsT < 1.2) ? -0.5 : 0.0;
    c.save();
    c.translate(body.center.dx, body.top);
    c.rotate(lidTilt);
    c.drawOval(
        Rect.fromCenter(center: Offset.zero, width: w * 1.05, height: h * 0.22),
        dark);
    c.restore();
  }

  /// Two extremely startled cats, launching out of the bin and scurrying
  /// off in opposite directions.
  void _fleeingCats(Canvas c) {
    if (!g.catsFleeing) return;
    final t = g.catsT;
    if (t < 0.35) {
      final o = _w(World.binX, World.binH);
      final pop = t / 0.35;
      for (final side in [-1.0, 1.0]) {
        _archedCat(c, o.translate(side * 10 * pop, -10 * pop - 6), pop);
      }
      return;
    }
    final run = t - 0.35;
    for (final side in [-1.0, 1.0]) {
      final x = World.binX + side * run * 3.2;
      _runningCat(c, _w(x, 0), side < 0);
    }
  }

  void _archedCat(Canvas c, Offset pos, double pop) {
    final body = Paint()..color = const Color(0xFF3A3530);
    c.save();
    c.translate(pos.dx, pos.dy);
    c.scale(1.0, 0.6 + 0.4 * pop);
    final p = Path()
      ..moveTo(-10, 4)
      ..quadraticBezierTo(0, -14, 10, 4)
      ..quadraticBezierTo(0, 0, -10, 4)
      ..close();
    c.drawPath(p, body);
    c.drawLine(const Offset(8, 2), const Offset(13, -10),
        Paint()
          ..color = body.color
          ..strokeWidth = 4);
    c.drawPath(
        Path()
          ..moveTo(-6, -8)
          ..lineTo(-8, -14)
          ..lineTo(-3, -9)
          ..close(),
        body);
    c.drawPath(
        Path()
          ..moveTo(4, -9)
          ..lineTo(6, -15)
          ..lineTo(8, -9)
          ..close(),
        body);
    c.drawCircle(const Offset(-2, -6), 1.2, Paint()..color = const Color(0xFFFFD040));
    c.drawCircle(const Offset(3, -6), 1.2, Paint()..color = const Color(0xFFFFD040));
    c.restore();
  }

  void _runningCat(Canvas c, Offset pos, bool facingLeft) {
    final body = Paint()..color = const Color(0xFF3A3530);
    final legPhase = math.sin(g.time * 24) * 4;
    c.save();
    c.translate(pos.dx, pos.dy);
    if (!facingLeft) c.scale(-1, 1);
    c.drawOval(
        Rect.fromCenter(center: const Offset(0, -6), width: 22, height: 9),
        body);
    c.drawCircle(const Offset(-10, -9), 4.5, body);
    c.drawPath(
        Path()
          ..moveTo(-13, -12)
          ..lineTo(-14, -17)
          ..lineTo(-10, -13)
          ..close(),
        body);
    c.drawLine(const Offset(10, -6),
        Offset(17, -6 - math.sin(g.time * 10) * 3),
        Paint()
          ..color = body.color
          ..strokeWidth = 3);
    final leg = Paint()
      ..color = body.color
      ..strokeWidth = 3;
    c.drawLine(const Offset(-6, -2), Offset(-6 + legPhase, 2), leg);
    c.drawLine(const Offset(4, -2), Offset(4 - legPhase, 2), leg);
    c.restore();
  }

  // ----------------------------------------------------------------
  // Level 3: the winter yard
  // ----------------------------------------------------------------

  /// Draws a 5-pointed star centered at [c0] with given outer radius,
  /// returning nothing (paints directly).
  void _drawStar(Canvas c, Offset c0, double outerR, double innerR,
      Paint paint, double rotation) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / 5 + rotation;
      final a2 = a + math.pi / 5;
      final outer = c0 + Offset(math.cos(a), math.sin(a)) * outerR;
      final inner = c0 + Offset(math.cos(a2), math.sin(a2)) * innerR;
      if (i == 0) {
        path.moveTo(outer.dx, outer.dy);
      } else {
        path.lineTo(outer.dx, outer.dy);
      }
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    c.drawPath(path, paint);
  }

  void _yolka(Canvas c) {
    final base = _w(World.treeX, 0);
    final k = _scale;
    final green = Paint()..color = const Color(0xFF2F6B4A);
    final snow = Paint()..color = const Color(0xFFF3F8FC);
    final trunk = Paint()..color = const Color(0xFF5A3E24);

    c.drawRect(
        Rect.fromCenter(
            center: base.translate(0, -0.06 * k),
            width: 0.14 * k,
            height: 0.16 * k),
        trunk);

    // Three stacked tiers, apex-first: (apexY, baseY, halfWidth), all in
    // meters. The topmost tier's apex is the actual visual treetop —
    // everything else (the star, the branch-snag collision zone) is
    // defined relative to World.treeH, which this apex sits just under.
    final tiers = [
      (1.30, 0.10, 0.62), // bottom, widest
      (2.05, 0.95, 0.46), // middle
      (World.treeH * 0.92, 1.75, 0.30), // top
    ];
    for (final (apexY, baseY, hw) in tiers) {
      final top = base.translate(0, -apexY * k);
      final bl = base.translate(-hw * k, -baseY * k);
      final br = base.translate(hw * k, -baseY * k);
      c.drawPath(
          Path()
            ..moveTo(top.dx, top.dy)
            ..lineTo(bl.dx, bl.dy)
            ..lineTo(br.dx, br.dy)
            ..close(),
          green);
      // A light snow dusting near the tip of each tier.
      c.drawPath(
          Path()
            ..moveTo(top.dx, top.dy)
            ..lineTo(top.dx - hw * k * 0.4, top.dy + hw * k * 0.4)
            ..lineTo(top.dx + hw * k * 0.4, top.dy + hw * k * 0.4)
            ..close(),
          snow);
    }
    // Ornaments — including the red ball the star sometimes gets
    // mistaken for.
    final orn = Paint()..color = const Color(0xFFD8484D);
    final orn2 = Paint()..color = const Color(0xFFE8C63C);
    for (final (dx, dy, p) in [
      (-0.20, 0.55, orn),
      (0.16, 0.85, orn2),
      (-0.12, 1.35, orn),
      (0.20, 1.65, orn2),
      (-0.10, 2.05, orn),
    ]) {
      c.drawCircle(base.translate(dx * k, -dy * k), 4, p);
    }

    // The star, sitting right on the treetop. It wobbles if the bat is
    // currently caught in the branches below.
    final wobble = g.bat.inTree ? math.sin(g.time * 10) * 0.18 : 0.0;
    final starC = base.translate(wobble * 6, -World.treeH * k * 0.98);
    _drawStar(c, starC, 10, 4, Paint()..color = const Color(0xFFFFD84A),
        wobble);
  }

  /// The Star of Bethlehem: a lone, brighter star that twinkles high
  /// above the winter yard — purely for atmosphere.
  void _bethlehemStar(Canvas c, Size s) {
    final tw = 0.55 + 0.45 * math.sin(g.time * 2.2) * math.sin(g.time * 0.7);
    final o = Offset(s.width * 0.72, s.height * 0.14);
    // A soft glow halo.
    c.drawCircle(
        o, 22 + tw * 6, Paint()..color = Color.fromRGBO(255, 250, 224, 0.10 + tw * 0.08));
    c.drawCircle(
        o, 10 + tw * 3, Paint()..color = Color.fromRGBO(255, 250, 224, 0.18 + tw * 0.12));
    // Long, thin cross-rays — the classic "twinkle".
    final ray = Paint()
      ..color = Color.fromRGBO(255, 255, 255, 0.55 + tw * 0.4)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final len = 16 + tw * 10;
    c.drawLine(o.translate(-len, 0), o.translate(len, 0), ray);
    c.drawLine(o.translate(0, -len), o.translate(0, len), ray);
    final len2 = (len * 0.45);
    c.drawLine(o.translate(-len2, -len2), o.translate(len2, len2), ray);
    c.drawLine(o.translate(-len2, len2), o.translate(len2, -len2), ray);
    // The star's small bright core.
    _drawStar(c, o, 4.5 + tw * 1.5, 1.8, Paint()..color = Colors.white, 0);
  }

  void _snowmanProp(Canvas c) {
    if (g.snowmanStage >= World.snowmanHeights.length) {
      // The humble stump: what remains after three solid hits.
      final o = _w(World.snowmanX, 0);
      c.drawOval(
          Rect.fromCenter(
              center: o.translate(0, -8), width: 44, height: 20),
          Paint()..color = const Color(0xFFF3F8FC));
      return;
    }
    final o = _w(World.snowmanX, 0);
    final k = _scale;
    final snow = Paint()..color = const Color(0xFFF6FAFD);
    final shade = Paint()..color = const Color(0xFFDCE9F2);

    // Stage 0: full 3-ball snowman with bucket. Stage 1: bucket knocked
    // off. Stage 2: just base + mid ball, carrot perched on top.
    final ballCount = 3 - g.snowmanStage;
    double y = 0;
    final sizes = [0.55, 0.4, 0.28]; // base, mid, head diameters (meters)
    for (int i = 0; i < ballCount; i++) {
      final d = sizes[i] * k;
      y += d * 0.42;
      final center = o.translate(0, -y);
      c.drawCircle(center, d / 2, snow);
      c.drawCircle(center.translate(d * 0.12, d * 0.08), d * 0.42, shade);
      y += d * 0.42;
      if (i == ballCount - 1) {
        // Face + carrot nose, on whichever ball is currently on top.
        final eye = Paint()..color = Colors.black87;
        c.drawCircle(center.translate(-d * 0.16, -d * 0.05), 1.8, eye);
        c.drawCircle(center.translate(d * 0.16, -d * 0.05), 1.8, eye);
        final nose = Path()
          ..moveTo(center.dx, center.dy)
          ..lineTo(center.dx - 5, center.dy + 3)
          ..lineTo(center.dx, center.dy + 5)
          ..close();
        c.drawPath(nose, Paint()..color = const Color(0xFFE07A2E));
        // The bucket — a stage-0 exclusive.
        if (g.snowmanStage == 0) {
          c.drawRect(
              Rect.fromCenter(
                  center: center.translate(0, -d * 0.62),
                  width: d * 0.5,
                  height: d * 0.3),
              Paint()..color = const Color(0xFF3E4348));
        }
        // Twiggy arms.
        final twig = Paint()
          ..color = const Color(0xFF5A3E24)
          ..strokeWidth = 2;
        c.drawLine(center.translate(-d * 0.4, 0), center.translate(-d, -6), twig);
        c.drawLine(center.translate(d * 0.4, 0), center.translate(d, -6), twig);
      }
    }
  }

  /// The huge, suspiciously occupied snowdrift in the corner.
  void _snowdriftProp(Canvas c) {
    final o = _w(World.snowdriftX, 0);
    final w = World.snowdriftW * _scale;
    final h = World.snowdriftH * _scale;
    final snow = Paint()..color = const Color(0xFFF3F8FC);
    final shade = Paint()..color = const Color(0xFFDCE9F2);

    // A big lumpy mound — not the tidy geometric kind.
    c.drawOval(
        Rect.fromCenter(
            center: o.translate(0, -h * 0.32), width: w, height: h),
        snow);
    c.drawOval(
        Rect.fromCenter(
            center: o.translate(-w * 0.16, -h * 0.58),
            width: w * 0.55,
            height: h * 0.6),
        snow);
    c.drawOval(
        Rect.fromCenter(
            center: o.translate(w * 0.14, -h * 0.5),
            width: w * 0.4,
            height: h * 0.45),
        snow);
    c.drawOval(
        Rect.fromCenter(
            center: o.translate(w * 0.12, -h * 0.16),
            width: w * 0.5,
            height: h * 0.28),
        shade);

    if (g.bearOut) {
      _bear(c, g.bearX, running: true, facingRight: g.bearFacingRight);
    } else if (g.snowdriftHits > 0) {
      // A suspicious dark snout, barely poking out.
      final peek = o.translate(-w * 0.05, -h * 0.55);
      c.drawCircle(peek, w * 0.05, Paint()..color = const Color(0xFF4A3322));
      c.drawCircle(peek.translate(-w * 0.045, -h * 0.02), 2,
          Paint()..color = const Color(0xFFFF3B30));
    }
  }

  void _bear(Canvas c, double x,
      {bool running = false, bool facingRight = false}) {
    final o = _w(x, 0);
    final k = _scale;
    final body = Paint()..color = const Color(0xFF6B4A2E);
    final dark = Paint()..color = const Color(0xFF5A3A22);
    final bounce = running ? math.sin(g.time * 14) * 3 : 0.0;

    c.save();
    if (facingRight) {
      c.translate(o.dx * 2, 0);
      c.scale(-1, 1);
    }

    // A big, unmistakably large body — this is not Barbos.
    c.drawOval(
        Rect.fromCenter(
            center: Offset(o.dx, o.dy - 0.44 * k + bounce),
            width: 0.9 * k,
            height: 0.5 * k),
        body);
    // Head.
    final head = Offset(o.dx - 0.44 * k, o.dy - 0.64 * k + bounce);
    c.drawCircle(head, 0.22 * k, body);
    // Round ears.
    c.drawCircle(head.translate(-0.09 * k, -0.19 * k), 0.075 * k, dark);
    c.drawCircle(head.translate(0.11 * k, -0.19 * k), 0.075 * k, dark);
    // Snout.
    c.drawOval(
        Rect.fromCenter(
            center: head.translate(-0.17 * k, 0.05 * k),
            width: 0.17 * k,
            height: 0.13 * k),
        Paint()..color = const Color(0xFF8A6540));
    c.drawCircle(head.translate(-0.24 * k, 0.03 * k), 2.8,
        Paint()..color = Colors.black87);
    // Eyes.
    c.drawCircle(head.translate(-0.06 * k, -0.04 * k), 2.2,
        Paint()..color = Colors.black);

    // Legs (blurred windmill while charging).
    final leg = Paint()..color = dark.color..strokeWidth = 7;
    for (int i = 0; i < 4; i++) {
      final phase = running ? math.sin(g.time * 14 + i * 1.6) * 7 : 0.0;
      final lx = o.dx - 0.32 * k + i * 0.21 * k;
      c.drawLine(Offset(lx, o.dy - 0.26 * k + bounce),
          Offset(lx + phase, o.dy), leg);
    }
    c.restore();

    // Comic-strip "GRRR!!" — drawn outside the mirrored canvas so the
    // text never flips.
    if (running && !facingRight) {
      final tp = TextPainter(
        text: const TextSpan(
            text: 'GRRR!!',
            style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(c, head.translate(-24, -36));
    }
  }

  /// A skier who carves across the level-3 yard at speed — same
  /// mechanics as the old sled kid (Phase.sledCarry etc.), new look.
  void _skierProp(Canvas c) {
    if (!g.sledActive) return;
    final o = _w(g.sledX, 0);
    final skin = Paint()..color = const Color(0xFFE8B99A);
    final jacket = Paint()..color = const Color(0xFF3E7ABF);
    final pants = Paint()..color = const Color(0xFF2A2E38);
    final skiPaint = Paint()
      ..color = const Color(0xFFD8484D)
      ..strokeWidth = 3;

    c.save();
    if (g.sledHasBat) {
      // Caught! It's turned tail and is fleeing back the way it came —
      // mirror the whole figure so the skis/poles/lean face the new
      // direction of travel, same trick as _dog/_bear/the robot.
      c.translate(o.dx * 2, 0);
      c.scale(-1, 1);
    }

    final wobble = math.sin(g.time * 14) * 1.5;

    // Two skis, angled downhill toward the front (it travels leftward),
    // tips curled up.
    for (final dy in [4.0, -3.0]) {
      final back = o.translate(10, dy + wobble * 0.3);
      final front = o.translate(-16, dy - 3 + wobble * 0.3);
      final tip = o.translate(-21, dy - 9 + wobble * 0.3);
      c.drawLine(back, front, skiPaint);
      c.drawLine(front, tip, skiPaint);
    }

    // Legs, tucked into a crouch.
    final leg = Paint()
      ..color = pants.color
      ..strokeWidth = 6;
    final hip = o.translate(0, -20);
    c.drawLine(hip, o.translate(-10, -1), leg);
    c.drawLine(hip, o.translate(6, -5), leg);

    // Torso, leaning into the wind.
    c.save();
    c.translate(o.dx, o.dy - 32);
    c.rotate(-0.3);
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: 18, height: 22),
            const Radius.circular(7)),
        jacket);
    c.restore();

    // Head + helmet + goggles, out front leading the charge.
    final head = o.translate(-9, -46);
    c.drawCircle(head, 8, skin);
    c.drawArc(Rect.fromCircle(center: head, radius: 8.5), math.pi * 1.15,
        math.pi * 1.5, true, Paint()..color = const Color(0xFF2A2E38));
    c.drawOval(
        Rect.fromCenter(center: head.translate(2, -1), width: 11, height: 5),
        Paint()..color = const Color(0xFF8AD1E8));

    // Poles, planted back and trailing at speed.
    final pole = Paint()
      ..color = const Color(0xFF6B6B6B)
      ..strokeWidth = 2;
    c.drawLine(o.translate(-2, -30), o.translate(16, -6), pole);
    c.drawLine(o.translate(2, -28), o.translate(20, -10), pole);

    // The stolen bat, clamped triumphantly under an arm, if applicable.
    if (g.sledHasBat) {
      c.save();
      c.translate(head.dx - 4, head.dy + 8);
      c.rotate(-0.5);
      _batShape(c);
      c.restore();
    }

    // Snow spray kicked up from the trailing edge of the skis.
    final spray = Paint()..color = const Color(0xFFF3F8FC).withValues(alpha: 0.8);
    for (int i = 0; i < 4; i++) {
      c.drawCircle(
          o.translate(14 + i * 6.0, 3 + math.sin(g.time * 20 + i) * 3), 3, spray);
    }
    c.restore();
  }

  /// The crow mid-heist: swoops in, grabs a gorodok, carries it off.
  void _crowSteal(Canvas c) {
    if (g.phase != Phase.crowSteal) return;
    final o = _w(g.crowX, g.crowY);
    final dark = Paint()..color = const Color(0xFF23262B);
    c.save();
    c.translate(o.dx, o.dy);
    final flap = math.sin(g.time * 22) * 7;
    for (final side in [-1.0, 1.0]) {
      final wing = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(
            side * 10, -4 - flap * side.sign, side * 16, 1 - flap * 0.4)
        ..quadraticBezierTo(side * 10, 3, 0, 2)
        ..close();
      c.drawPath(wing, dark);
    }
    c.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 14, height: 10), dark);
    c.drawCircle(const Offset(-9, -2), 4, dark);
    final beak = Path()
      ..moveTo(-12, -2)
      ..lineTo(-17, -1)
      ..lineTo(-12, 1)
      ..close();
    c.drawPath(beak, Paint()..color = const Color(0xFFE8C63C));
    c.restore();

    // The captive gorodok, dangling beneath.
    if (g.crowStage >= 1) {
      c.save();
      c.translate(o.dx, o.dy + 10);
      c.rotate(math.sin(g.time * 8) * 0.3);
      final w = World.pinWidth * _scale;
      final h = World.pinHeight * _scale * 0.7;
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset.zero, width: w, height: h),
              Radius.circular(w / 3)),
          Paint()..color = const Color(0xFFE7D3AE));
      c.restore();
    }
  }

  /// The skeleton trio, clawing their way up out of the ground. Each one
  /// is clipped to the ground line and translated down by however much
  /// of it hasn't "risen" yet, so it genuinely looks like it's emerging
  /// from the dirt rather than just fading in.
  void _skeletons(Canvas c) {
    for (int i = 0; i < 3; i++) {
      final frac = g.skeletonRiseFrac[i];
      if (frac <= 0) continue;
      final o = _w(g.skeletonX[i], 0);
      const riseHeight = 66.0;
      c.save();
      c.clipRect(Rect.fromLTRB(-9999, -9999, 9999, _groundY + 1));
      c.translate(0, (1 - frac) * riseHeight);
      _skeletonShape(c, o, i);
      c.restore();
    }
  }

  void _skeletonShape(Canvas c, Offset o, int i) {
    final bone = Paint()..color = const Color(0xFFE8E2D0);
    final dark = Paint()..color = const Color(0xFF16121A);
    final shuffle = math.sin(g.time * 6 + i * 2.1) * 3;
    final legP = Paint()
      ..color = bone.color
      ..strokeWidth = 4;
    final armP = Paint()
      ..color = bone.color
      ..strokeWidth = 3.5;
    // Legs.
    c.drawLine(
        Offset(o.dx, o.dy - 30), Offset(o.dx - 6 - shuffle, o.dy), legP);
    c.drawLine(
        Offset(o.dx, o.dy - 30), Offset(o.dx + 6 + shuffle, o.dy), legP);
    // Ribcage.
    c.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(o.dx - 9, o.dy - 54, 18, 26),
            const Radius.circular(4)),
        bone);
    for (int r = 0; r < 3; r++) {
      c.drawLine(Offset(o.dx - 8, o.dy - 48 + r * 7),
          Offset(o.dx + 8, o.dy - 48 + r * 7),
          Paint()
            ..color = dark.color
            ..strokeWidth = 1.4);
    }
    // Arms, reaching forward.
    c.drawLine(Offset(o.dx - 8, o.dy - 50), Offset(o.dx - 16 - shuffle, o.dy - 38),
        armP);
    c.drawLine(Offset(o.dx + 8, o.dy - 50), Offset(o.dx + 16 + shuffle, o.dy - 38),
        armP);
    // Skull.
    final skull = Offset(o.dx, o.dy - 62);
    c.drawCircle(skull, 9, bone);
    c.drawCircle(skull.translate(-3, -1), 1.6, dark);
    c.drawCircle(skull.translate(3, -1), 1.6, dark);
    c.drawRect(
        Rect.fromCenter(center: skull.translate(0, 5), width: 6, height: 3),
        dark);
  }

  /// The nightmare yard's spider, descending on idle players to wrap
  /// them up. World-space, tracks wherever the player is standing.
  void _spiderDescent(Canvas c) {
    final anchor = _w(g.spiderCocoonX, 9.4);
    final o = _w(g.spiderCocoonX, g.spiderCocoonY);
    final sway = math.sin(g.time * 2.4) * 6;
    final pos = o.translate(sway, 0);
    c.drawLine(anchor, pos,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..strokeWidth = 1.3);

    final body = Paint()..color = const Color(0xFF1B1420);
    c.drawOval(
        Rect.fromCenter(center: pos, width: 26, height: 32), body);
    c.drawCircle(pos.translate(0, -16), 11, body);
    for (final dx in [-4.0, -1.3, 1.3, 4.0]) {
      c.drawCircle(pos.translate(dx, -18), 1.4,
          Paint()..color = const Color(0xFFFF3B30));
    }
    final leg = Paint()
      ..color = body.color
      ..strokeWidth = 2.4;
    for (int i = 0; i < 4; i++) {
      final la = (i - 1.5) * 0.55;
      final flex = math.sin(g.time * 8 + i) * 4;
      c.drawLine(pos, pos + Offset(math.cos(la) * 20 + flex, math.sin(la) * 20 - 6),
          leg);
      c.drawLine(
          pos,
          pos +
              Offset(math.cos(math.pi - la) * 20 - flex,
                  math.sin(math.pi - la) * 20 - 6),
          leg);
    }
  }

  void _snowfall(Canvas c, Size s) {
    // Gentle, endless snow — purely decorative.
    for (int i = 0; i < 40; i++) {
      final seed = i * 37.0;
      final x = (seed * 13 + g.time * (20 + (i % 5) * 6)) % (s.width + 40) - 20;
      final y = (seed * 7 + g.time * (28 + (i % 7) * 5)) % (s.height + 20) - 10;
      final r = 1.2 + (i % 3) * 0.8;
      c.drawCircle(Offset(x, y), r,
          Paint()..color = Colors.white.withValues(alpha: 0.75));
    }
  }

  /// The roof avalanche: only the player's head sticks out.
  void _avalanche(Canvas c, Size s) {
    final o = _w(g.playerX, 0);
    // A proper cascade — many staggered streams of snow pouring down
    // together like a waterfall off the roof, rather than one rigid
    // parcel dropping on a string.
    if (g.snowChunkY > 0.2) {
      final topY = _w(g.playerX, 8.5).dy;
      final landY = o.dy - 18;
      final progress = ((8.5 - g.snowChunkY) / 8.5).clamp(0.0, 1.0);
      final snowP = Paint()..color = const Color(0xFFF3F8FC);
      final snowP2 = Paint()..color = const Color(0xFFDCE9F2);
      for (int i = 0; i < 16; i++) {
        final seed = i * 12.9898;
        final xJitter = math.sin(seed) * 26;
        final speed = 0.8 + 0.5 * ((math.sin(seed * 1.7) + 1) / 2);
        final startDelay = (i / 16) * 0.5;
        final localT = ((progress - startDelay) * speed).clamp(0.0, 1.0);
        if (localT <= 0) continue;
        final y = topY + (landY - topY) * localT;
        final sway = math.sin(g.time * 7 + seed) * 4;
        final clumpSize = 9 + 7 * ((math.sin(seed * 2.3) + 1) / 2);
        c.drawOval(
            Rect.fromCenter(
                center: Offset(o.dx + xJitter + sway, y),
                width: clumpSize,
                height: clumpSize * 0.75),
            i.isEven ? snowP : snowP2);
      }
      // A hazy falling curtain, for a bit of waterfall density behind the
      // individual clumps.
      final curtainH = (landY - topY) * progress;
      if (curtainH > 0) {
        c.drawRect(
            Rect.fromLTWH(o.dx - 34, topY, 68, curtainH),
            Paint()..color = Colors.white.withValues(alpha: 0.10));
      }
    }
    // The mound, with just the head peeking out.
    c.drawOval(
        Rect.fromCenter(
            center: o.translate(0, -18), width: 90, height: 46),
        Paint()..color = const Color(0xFFF3F8FC));
    c.drawOval(
        Rect.fromCenter(
            center: o.translate(-18, -8), width: 26, height: 14),
        Paint()..color = const Color(0xFFDCE9F2));
    final skin = Paint()..color = const Color(0xFFE0B48C);
    c.drawCircle(o.translate(0, -40), 9, skin);
    // The hat, comically still in place.
    c.drawArc(Rect.fromCircle(center: o.translate(0, -40), radius: 10),
        math.pi, math.pi, true, Paint()..color = const Color(0xFFC94F7C));
    // Dizzy stars.
    final tp = TextPainter(
      text: TextSpan(
        text: '✶',
        style: TextStyle(
            color: const Color(0xFFFFE082),
            fontSize: 14 + math.sin(g.time * 8) * 2),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, o.translate(14, -52));
  }

  void _splash(Canvas c) {
    if (g.splashT <= 0) return;
    final t = 1.2 - g.splashT;
    final o = _w((World.puddleX1 + World.puddleX2) / 2, 0);
    final p = Paint()
      ..color = const Color(0xFF7FA0B8)
          .withValues(alpha: (1 - t).clamp(0.0, 1.0).toDouble())
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 5; i++) {
      final a = math.pi * (0.15 + 0.175 * i);
      final d = 10 + t * 40;
      c.drawCircle(
          o.translate(math.cos(a) * d, -math.sin(a) * d - t * 20), 3, p);
    }
  }

  void _aim(Canvas c) {
    if (g.phase != Phase.aiming || !g.aimingDrag) return;
    final pts = g.previewTrajectory();
    final dot = Paint()..color = Colors.white.withValues(alpha: 0.75);
    for (int i = 0; i < pts.length; i++) {
      final (x, y) = pts[i];
      c.drawCircle(_w(x, y), 3.5 * (1 - i / pts.length) + 1, dot);
    }
    // Power indicator.
    final power = (math.sqrt(g.aimVx * g.aimVx + g.aimVy * g.aimVy) / 20)
        .clamp(0.0, 1.0)
        .toDouble();
    final o = _w(g.playerX, 0);
    final bar = Rect.fromLTWH(o.dx - 30, o.dy - 110, 60, 8);
    c.drawRRect(RRect.fromRectAndRadius(bar, const Radius.circular(4)),
        Paint()..color = Colors.black38);
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(bar.left, bar.top, bar.width * power, bar.height),
            const Radius.circular(4)),
        Paint()
          ..color = Color.lerp(
              const Color(0xFF7BC67E), const Color(0xFFE05B4B), power)!);
  }

  /// Animated "how to play" hint: a hand pulls back from the player
  /// (slingshot-style), then a ghost arrow shows the resulting throw.
  /// Loops until the very first throw is made.
  void _tutorial(Canvas c, Size s) {
    if (!g.showTutorial) return;
    final t = (g.time % 2.2) / 2.2; // loop phase 0..1
    // Anchored to the middle of the screen rather than the player sprite
    // (which sits near the left edge) — the drag gesture works from
    // anywhere, and showing it dead center makes that obvious.
    final start = Offset(s.width * 0.5, s.height * 0.58);
    final end = start + Offset(-1.3 * _scale, 0.85 * _scale);

    double fade = 1;
    if (t < 0.1) fade = t / 0.1;
    if (t > 0.85) fade = (1 - t) / 0.15;

    // Drag progress: pull back during the first half, then hold.
    final p = ((t - 0.1) / 0.45).clamp(0.0, 1.0).toDouble();
    final e = Curves.easeInOut.transform(p);
    final hand = Offset.lerp(start, end, e)!;

    // Dotted trail behind the hand.
    final trail = Paint()..color = Colors.white.withValues(alpha: 0.8 * fade);
    final n = (8 * e).round();
    for (int i = 0; i <= n; i++) {
      c.drawCircle(Offset.lerp(start, hand, i / 8)!, 2.5, trail);
    }

    // Once fully pulled: pulsing ghost arrow showing the throw direction.
    if (p >= 1) {
      final pulse = 0.6 + 0.4 * math.sin(g.time * 6);
      final arrowP = Paint()
        ..color = const Color(0xFFFFE082)
            .withValues(alpha: (fade * pulse).clamp(0.0, 1.0).toDouble())
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      final dir = Offset(1.9 * _scale, -1.15 * _scale);
      final tip = start + dir;
      c.drawLine(start, tip, arrowP);
      final an = math.atan2(dir.dy, dir.dx);
      for (final da in [2.6, -2.6]) {
        c.drawLine(tip,
            tip + Offset(math.cos(an + da), math.sin(an + da)) * 14, arrowP);
      }
    }

    // The pointing hand.
    final skin = Paint()
      ..color = Colors.white.withValues(alpha: 0.95 * fade);
    final outline = Paint()
      ..color = Colors.black.withValues(alpha: 0.6 * fade)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    c.save();
    c.translate(hand.dx, hand.dy);
    c.rotate(-0.4);
    final finger = RRect.fromRectAndRadius(
        const Rect.fromLTWH(-3.5, 0, 7, 18), const Radius.circular(3.5));
    c.drawRRect(finger, skin);
    c.drawRRect(finger, outline);
    c.drawCircle(const Offset(0, 24), 10, skin);
    c.drawCircle(const Offset(0, 24), 10, outline);
    c.restore();

    // Hint text.
    final tp = TextPainter(
      text: TextSpan(
        text: L10n.t.aimHint,
        style: TextStyle(
          color: Colors.white.withValues(alpha: fade),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(blurRadius: 4, color: Colors.black87)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset(start.dx - tp.width / 2 - 20, start.dy + 60));
  }

  /// Rotating 3D showcase of the freshly built figure: the gorod square
  /// with its pins, slowly spinning in axonometric projection, so the
  /// player can see exactly what they're up against.
  void _figurePreview(Canvas c, Size s) {
    if (g.phase != Phase.figurePreview) return;

    // Scale in for 0.35 s, out for the last 0.4 s.
    final elapsed = GameController.previewDuration - g.previewT;
    final k = (math.min(1.0, elapsed / 0.35) *
            math.min(1.0, math.max(0.0, g.previewT) / 0.4))
        .clamp(0.0, 1.0)
        .toDouble();

    // Dim the courtyard.
    c.drawRect(Offset.zero & s,
        Paint()..color = Colors.black.withValues(alpha: 0.5 * k));

    final cx = s.width / 2;
    final cy = s.height * 0.56;
    final scale = s.height * 0.24 * k; // pixels per meter of the showcase
    final rot = g.time * 0.7; // slow turntable

    // Axonometric projection of gorod-local (u, v, height).
    Offset proj(double u, double v, double h) {
      final du = u - 1.0, dv = v - 1.0;
      final x = du * math.cos(rot) - dv * math.sin(rot);
      final d = du * math.sin(rot) + dv * math.cos(rot);
      return Offset(cx + x * scale, cy + d * scale * 0.45 - h * scale * 0.85);
    }

    double depth(PinSpec p) =>
        (p.u - 1) * math.sin(rot) + (p.v - 1) * math.cos(rot);

    // The platform: asphalt slab with chalk edges.
    final corners = [proj(0, 0, 0), proj(2, 0, 0), proj(2, 2, 0), proj(0, 2, 0)];
    final slab = Path()..addPolygon(corners, true);
    c.drawPath(slab,
        Paint()..color = const Color(0xFF7C7C74).withValues(alpha: 0.95 * k));
    c.drawPath(
        slab,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.9 * k)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);

    // Pins, far ones first.
    final pins = [...g.figure.pins]
      ..sort((a, b) => depth(a).compareTo(depth(b)));
    final wood = Paint()
      ..color = const Color(0xFFE7D3AE).withValues(alpha: k)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = World.pinWidth * scale;
    final stripe = Paint()
      ..color = const Color(0xFFC0392B).withValues(alpha: k)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = World.pinWidth * scale;
    final shadow = Paint()..color = Colors.black.withValues(alpha: 0.25 * k);

    for (final p in pins) {
      const len = World.pinHeight;
      if (p.lying) {
        final ca = math.cos(p.lyingAngle) * len / 2;
        final sa = math.sin(p.lyingAngle) * len / 2;
        final a = proj(p.u - ca, p.v - sa, 0.06);
        final b = proj(p.u + ca, p.v + sa, 0.06);
        c.drawLine(a, b, wood);
        // A stripe near one end.
        c.drawLine(Offset.lerp(a, b, 0.72)!, Offset.lerp(a, b, 0.88)!, stripe);
      } else {
        final base = proj(p.u, p.v, 0);
        final top = proj(p.u, p.v, len);
        c.drawOval(
            Rect.fromCenter(
                center: base,
                width: World.pinWidth * scale * 2,
                height: World.pinWidth * scale * 0.9),
            shadow);
        c.drawLine(base, top, wood);
        c.drawLine(Offset.lerp(base, top, 0.22)!,
            Offset.lerp(base, top, 0.36)!, stripe);
        c.drawLine(Offset.lerp(base, top, 0.64)!,
            Offset.lerp(base, top, 0.78)!, stripe);
        if (p.isStamp) {
          // The Letter's stamp gets a pulsing halo — knock it out first!
          c.drawCircle(
              Offset.lerp(base, top, 0.5)!,
              World.pinWidth * scale *
                  (1.6 + 0.4 * math.sin(g.time * 6)),
              Paint()
                ..color = const Color(0xFFFFE082).withValues(alpha: 0.5 * k)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3);
        }
      }
    }

    // Title.
    final tp = TextPainter(
      text: TextSpan(
        text:
            '${L10n.t.figureWord} ${g.figureIndex + 1}/${kFigures.length}\n'
            '${L10n.t.figureNames[g.figureIndex]}',
        style: TextStyle(
          color: Colors.white.withValues(alpha: k),
          fontSize: 26,
          height: 1.25,
          fontWeight: FontWeight.w900,
          shadows: const [Shadow(blurRadius: 6, color: Colors.black)],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset(cx - tp.width / 2, s.height * 0.1));

    final sub = TextPainter(
      text: TextSpan(
        text: g.figure.russianName,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8 * k),
          fontSize: 15,
          shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    sub.paint(c, Offset(cx - sub.width / 2, s.height * 0.1 + tp.height + 6));
  }

  @override
  bool shouldRepaint(covariant ScenePainter oldDelegate) => true;
}
