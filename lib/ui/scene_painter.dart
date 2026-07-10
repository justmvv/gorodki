import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/figures.dart';
import '../game/game_controller.dart';
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
    _clouds(canvas, size);
    _buildingLeft(canvas, size);
    _buildingRight(canvas, size);
    _ground(canvas, size);
    _chalkLines(canvas);
    _laundry(canvas);
    _puddle(canvas);
    _kennel(canvas);
    _bench(canvas);
    _pins(canvas);
    _player(canvas);
    _bat(canvas);
    _pigeon(canvas);
    _drone(canvas);
    _splash(canvas);
    _aim(canvas);
    _tutorial(canvas);
    _figurePreview(canvas, size);
  }

  // ----------------------------------------------------------------
  // Backdrop
  // ----------------------------------------------------------------

  void _sky(Canvas c, Size s) {
    final r = Offset.zero & s;
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

  void _clouds(Canvas c, Size s) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.85);
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
        c.drawRect(rect, wall);
        c.drawLine(rect.topCenter, rect.bottomCenter, frame..strokeWidth = 1.5);
      }
    }
  }

  void _buildingLeft(Canvas c, Size s) {
    final right = _w(1.6, 0).dx;
    final facade = Rect.fromLTRB(-10, s.height * 0.06, right, _groundY);
    c.drawRect(facade, Paint()..color = const Color(0xFFC9B49A));
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
    c.drawRect(facade, Paint()..color = const Color(0xFFB8C0A8));

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
        c.drawRect(
            rect,
            isZina
                ? (Paint()..color = const Color(0xFFDDEBF2))
                : glass);
        c.drawLine(
            rect.topCenter, rect.bottomCenter, frame..strokeWidth = 1.5);
        if (isZina) _zinaWindow(c, rect);
      }
    }
  }

  /// The famous accented window: curtains, geraniums, and (after the
  /// unfortunate incident) cracks and Baba Zina herself.
  void _zinaWindow(Canvas c, Rect win) {
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

  void _ground(Canvas c, Size s) {
    // Asphalt with a hint of heroic Soviet patching.
    final r = Rect.fromLTRB(0, _groundY, s.width, s.height);
    c.drawRect(r, Paint()..color = const Color(0xFF8D8D85));
    final patch = Paint()..color = const Color(0xFF7C7C74);
    for (final (px, pw) in [(3.0, 1.4), (10.6, 2.0), (17.4, 1.2)]) {
      c.drawOval(
          Rect.fromLTWH(_w(px, 0).dx, _groundY + 8, pw * _scale, 14), patch);
    }
  }

  void _chalkLines(Canvas c) {
    final chalk = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 3;

    void line(double x, String label) {
      c.drawLine(_w(x, 0), Offset(_w(x, 0).dx, _groundY + 26), chalk);
      final tp = TextPainter(
        text: TextSpan(
            text: label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
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
          ..color = Colors.white.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
    final tp = TextPainter(
      text: TextSpan(
          text: 'GOROD',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset(gorod.center.dx - tp.width / 2, gorod.center.dy - 6));
  }

  // ----------------------------------------------------------------
  // Props
  // ----------------------------------------------------------------

  void _laundry(Canvas c) {
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
    c.drawOval(r, Paint()..color = const Color(0xFF5F7E96));
    c.drawOval(r.deflate(3), Paint()..color = const Color(0xFF7FA0B8));
  }

  void _kennel(Canvas c) {
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

  void _dog(Canvas c, double x, {bool running = false, bool facingRight = false}) {
    final o = _w(x, 0);
    final k = _scale; // pixels per meter
    final body = Paint()..color = const Color(0xFFC98A4B);
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
        Paint()..color = Colors.black);
    c.drawCircle(head.translate(-0.13 * k, 0.02 * k), 2.5,
        Paint()..color = Colors.black87);
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
        text: const TextSpan(
            text: 'WOOF!!',
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(c, head.translate(-20, -34));
    }
  }

  void _bench(Canvas c) {
    final o = _w(World.benchX, 0);
    final w = World.benchW * _scale;
    final seatY = o.dy - 0.45 * _scale;

    // Bench.
    final wood = Paint()..color = const Color(0xFF7A5230);
    c.drawRect(Rect.fromLTWH(o.dx, seatY, w, 6), wood);
    c.drawRect(Rect.fromLTWH(o.dx, seatY - 0.45 * _scale, w, 5), wood); // back
    c.drawRect(Rect.fromLTWH(o.dx + 4, seatY, 5, o.dy - seatY), wood);
    c.drawRect(Rect.fromLTWH(o.dx + w - 9, seatY, 5, o.dy - seatY), wood);

    if (g.drunkardChasing) {
      _genaWithBroom(c);
    } else {
      // Uncle Gena, seated.
      final cx = o.dx + w * 0.45;
      final skin = Paint()..color = const Color(0xFFE0B48C);
      final coat = Paint()..color = const Color(0xFF6E7B65);
      // Torso (slouched at a physically improbable but spiritually accurate
      // angle).
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(cx - 11, seatY - 34, 24, 34),
              const Radius.circular(7)),
          coat);
      // Head + ushanka.
      final head = Offset(cx + 1, seatY - 42);
      c.drawCircle(head, 9, skin);
      c.drawArc(Rect.fromCircle(center: head, radius: 10.5), math.pi * 0.95,
          math.pi, true, Paint()..color = const Color(0xFF5A4632));
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

  /// Uncle Gena on the warpath, broom held high.
  void _genaWithBroom(Canvas c) {
    final o = _w(g.drunkardX, 0);
    final skin = Paint()..color = const Color(0xFFE0B48C);
    final coat = Paint()..color = const Color(0xFF6E7B65);
    final run = math.sin(g.time * 16) * 6;

    // Legs, moving with unexpected athleticism.
    final leg = Paint()
      ..color = const Color(0xFF4C4C46)
      ..strokeWidth = 7;
    c.drawLine(Offset(o.dx, o.dy - 32), Offset(o.dx - 7 - run, o.dy), leg);
    c.drawLine(Offset(o.dx, o.dy - 32), Offset(o.dx + 7 + run, o.dy), leg);
    // Torso.
    c.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(o.dx - 11, o.dy - 60, 22, 30),
            const Radius.circular(6)),
        coat);
    // Head + ushanka.
    final head = Offset(o.dx, o.dy - 68);
    c.drawCircle(head, 9, skin);
    c.drawArc(Rect.fromCircle(center: head, radius: 10.5), math.pi * 0.95,
        math.pi, true, Paint()..color = const Color(0xFF5A4632));
    c.drawCircle(
        head.translate(-7, 2), 3, Paint()..color = const Color(0xFFD08B6E));

    // Arm raised with the broom of justice.
    final arm = Paint()
      ..color = coat.color
      ..strokeWidth = 6;
    final hand = Offset(o.dx - 16, o.dy - 74 + run * 0.5);
    c.drawLine(Offset(o.dx - 8, o.dy - 54), hand, arm);
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

    final tp = TextPainter(
      text: const TextSpan(
          text: 'ENOUGH!!',
          style: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, head.translate(-24, -30));
  }

  // ----------------------------------------------------------------
  // Pins
  // ----------------------------------------------------------------

  void _pins(Canvas c) {
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
        if (p.spec.lying) {
          _lyingPin(c, o, p.spec.lyingAngle, depth: p.spec.v);
        } else {
          _pinAt(c, Offset(o.dx, o.dy - World.pinHeight * _scale / 2), 0,
              depth: p.spec.v);
        }
      }
    }
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
    final px = g.playerX + g.playerRunOffset;
    if (px < -1.5) return; // fully fled
    final o = _w(px, 0);
    final skin = Paint()..color = const Color(0xFFE0B48C);
    final shirt = Paint()..color = const Color(0xFF3B6EA5);
    final pants = Paint()..color = const Color(0xFF444B54);

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
    // Head + flat cap (kepka).
    final head = Offset(o.dx, o.dy - 70);
    c.drawCircle(head, 9, skin);
    c.drawArc(Rect.fromCircle(center: head, radius: 10), math.pi * 1.05,
        math.pi * 0.9, true, Paint()..color = const Color(0xFF7A6A4F));
    c.drawRect(Rect.fromLTWH(head.dx, head.dy - 8, 12, 3),
        Paint()..color = const Color(0xFF7A6A4F));

    // The pigeon's one-star review, delivered directly onto the cap.
    if (g.playerSoiled) {
      final splat = Paint()..color = const Color(0xFFF5F2E8);
      c.drawCircle(head.translate(2, -9), 4, splat);
      c.drawCircle(head.translate(-3, -7), 2.5, splat);
      c.drawCircle(head.translate(6, -6), 2, splat);
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
      // The underpants, now with a new owner.
      c.rotate(-math.pi / 2);
      final pantsP = Paint()..color = const Color(0xFFCF6679);
      c.drawRect(const Rect.fromLTWH(-10, -4, 20, 14), pantsP);
    } else {
      c.rotate(g.bat.angle);
      _batShape(c);
    }
    c.restore();
  }

  void _pigeon(Canvas c) {
    if (!g.pigeon.active) return;
    final o = _w(g.pigeon.x, g.pigeon.y);
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

  void _drone(Canvas c) {
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
  void _tutorial(Canvas c) {
    if (!g.showTutorial) return;
    final t = (g.time % 2.2) / 2.2; // loop phase 0..1
    final start = _w(g.playerX + 0.35, World.throwHandY);
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
        text: 'Pull back & release!',
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
            'Figure ${g.figureIndex + 1}/${kFigures.length}\n${g.figure.name}',
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
