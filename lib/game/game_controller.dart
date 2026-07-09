import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'figures.dart';
import 'world.dart';

/// What the game is currently doing.
enum Phase {
  figurePreview, // rotating 3D showcase of the freshly built figure
  aiming, // bat in hand, waiting for a throw
  flying, // bat is in the air
  settling, // bat has stopped, knocked pins are still tumbling
  dogChase, // Barbos is escorting the player off the premises
  pigeonCarry, // a pigeon has unionized your bat
  pigeonStrike, // the pigeon punishes idleness; player goes to wash up
  broomChase, // Uncle Gena has had enough of bottle abuse
  cooldown, // short pause before the next throw / figure
  gameOver,
}

/// A pin on the field.
class Pin {
  final PinSpec spec;
  bool standing = true; // part of the figure, waiting to be hit
  bool flying = false; // knocked, tumbling through the air
  bool removed = false; // gone from the square (scored)

  // Flight state.
  double fx = 0, fy = 0, fvx = 0, fvy = 0, fang = 0, fspin = 0;

  Pin(this.spec);

  /// World x of the pin while standing/lying in the square.
  double get worldX => World.gorodFront + spec.u;
}

/// The bat in flight.
class Bat {
  double x = 0, y = 0, vx = 0, vy = 0, angle = 0, spin = 0;
  bool active = false;
  bool onRope = false; // tangled in the laundry
  double ropeSwing = 0; // swing phase while hanging
}

class Pigeon {
  bool active = false;
  bool carrying = false;
  double x = 0, y = 0, vx = 0, vy = 0;
}

/// One-line messages shown as a banner.
class GameMessage {
  final String text;
  final String emoji;
  double ttl;
  GameMessage(this.emoji, this.text, {this.ttl = 3.4});
}

class GameController extends ChangeNotifier {
  static const double previewDuration = 3.0;

  final math.Random _rng = math.Random();

  Phase phase = Phase.aiming;
  double previewT = 0; // remaining 3D-preview time
  int figureIndex = 0;
  int throwsTotal = 0;
  int throwsThisFigure = 0;
  bool fromKon = true; // true = 13 m line, false = half-kon 6.5 m
  bool _figureOpened = false; // at least one pin knocked out this figure

  final List<Pin> pins = [];
  final Bat bat = Bat();
  final Pigeon pigeon = Pigeon();
  final List<GameMessage> messages = [];

  // Aiming (slingshot drag).
  bool aimingDrag = false;
  double aimVx = 0, aimVy = 0;

  // Player position & animation.
  double playerX = World.konX;
  double playerRunOffset = 0; // <0 when fleeing from the dog
  bool playerFleeing = false;

  // Dog.
  double dogX = World.kennelX + 0.4;
  bool dogOut = false;
  bool dogFacingRight = false; // true on the smug trot back to the kennel
  double _eventT = 0;

  // Drunkard (Uncle Gena).
  bool drunkardAngry = false;
  double drunkardAngryT = 0;
  bool bottleFlying = false;
  double bottleFx = 0, bottleFy = 0, bottleFvx = 0, bottleFvy = 0;
  int bottleHits = 0;
  int _broomThreshold = 3; // 3..6, randomized
  bool drunkardChasing = false;
  double drunkardX = World.benchX + 0.7;

  // Idle punishment: the pigeon strikes back.
  double idleT = 0;
  double _idleLimit = 18;
  bool playerSoiled = false;

  // Window.
  bool windowBroken = false;

  // Laundry snag flag per throw.
  bool _ropeChecked = false;

  // Puddle splash animation.
  double splashT = 0;

  double _cooldownT = 0;
  bool _throwHadContact = false; // did the bat hit anything at all
  double time = 0; // global clock for idle animations

  /// Sound hook — set by the UI layer (see AudioManager). Keeps the game
  /// logic free of any audio-plugin dependency.
  void Function(String name)? onSound;
  void _sfx(String name) => onSound?.call(name);

  FigureSpec get figure => kFigures[figureIndex];
  double get throwLineX =>
      (figure.isLetter || fromKon) ? World.konX : World.polukonX;

  /// Show the animated "how to throw" hint until the very first throw.
  bool get showTutorial =>
      phase == Phase.aiming && throwsTotal == 0 && !aimingDrag;

  GameController() {
    _broomThreshold = 3 + _rng.nextInt(4);
    _idleLimit = 15 + _rng.nextDouble() * 10;
    _setupFigure();
    _startPreview();
    _say('🏏', 'Figure 1: ${figure.name}. Drag back from the player to aim!');
  }

  void _startPreview() {
    phase = Phase.figurePreview;
    previewT = previewDuration;
  }

  // ------------------------------------------------------------------
  // Setup / reset
  // ------------------------------------------------------------------

  void _setupFigure() {
    pins
      ..clear()
      ..addAll(figure.pins.map(Pin.new));
    throwsThisFigure = 0;
    fromKon = true;
    _figureOpened = false;
    playerX = throwLineX;
  }

  void newGame() {
    figureIndex = 0;
    throwsTotal = 0;
    windowBroken = false;
    bottleHits = 0;
    _broomThreshold = 3 + _rng.nextInt(4);
    drunkardChasing = false;
    playerSoiled = false;
    playerFleeing = false;
    playerRunOffset = 0;
    pigeon.active = false;
    idleT = 0;
    _setupFigure();
    _startPreview();
    _say('🏏', 'New game! Figure 1: ${figure.name}.');
    notifyListeners();
  }

  void _say(String emoji, String text, {double ttl = 3.4}) {
    messages.add(GameMessage(emoji, text, ttl: ttl));
    if (messages.length > 2) messages.removeAt(0);
  }

  // ------------------------------------------------------------------
  // Input
  // ------------------------------------------------------------------

  /// Update the aim from a drag vector in world units.
  /// Dragging back (left/down) throws forward (right/up), like a slingshot.
  void updateAim(double dragDx, double dragDy) {
    if (phase != Phase.aiming) return;
    idleT = 0;
    aimingDrag = true;
    aimVx = (-dragDx * 2.2).clamp(0.0, 16.5).toDouble();
    aimVy =
        (dragDy * 2.2).clamp(0.0, 11.0).toDouble(); // drag down = throw up
    notifyListeners();
  }

  void releaseThrow() {
    if (phase != Phase.aiming || !aimingDrag) return;
    aimingDrag = false;
    final speed = math.sqrt(aimVx * aimVx + aimVy * aimVy);
    if (speed < 2.5) {
      // Too feeble — the bat stays in hand.
      notifyListeners();
      return;
    }
    throwsTotal++;
    throwsThisFigure++;
    _throwHadContact = false;
    _ropeChecked = false;

    bat
      ..active = true
      ..onRope = false
      ..x = playerX + 0.35
      ..y = World.throwHandY
      ..vx = aimVx
      ..vy = aimVy
      ..angle = 0
      ..spin = -(speed * 1.1);

    // Occasionally a pigeon takes an interest in aviation regulations.
    if (_rng.nextDouble() < 0.09) {
      pigeon
        ..active = true
        ..carrying = false
        ..x = World.width + 1
        ..y = 3.6 + _rng.nextDouble() * 1.6
        ..vx = -3.2 - _rng.nextDouble() * 1.5
        ..vy = 0;
    }

    phase = Phase.flying;
    _sfx('whoosh');
    notifyListeners();
  }

  void cancelAim() {
    aimingDrag = false;
    aimVx = 0;
    aimVy = 0;
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Simulation
  // ------------------------------------------------------------------

  void tick(double dt) {
    if (dt <= 0) return;
    dt = math.min(dt, 1 / 20); // avoid tunneling after app pauses
    time += dt;

    for (final m in messages) {
      m.ttl -= dt;
    }
    messages.removeWhere((m) => m.ttl <= 0);

    if (splashT > 0) splashT -= dt;
    if (drunkardAngry) {
      drunkardAngryT -= dt;
      if (drunkardAngryT <= 0) drunkardAngry = false;
    }
    _tickBottle(dt);
    _tickPigeon(dt);
    _tickPins(dt);

    switch (phase) {
      case Phase.flying:
        _tickBat(dt);
      case Phase.settling:
        if (!_pinsInFlight) _resolveThrow();
      case Phase.dogChase:
        _tickDogChase(dt);
      case Phase.pigeonCarry:
        if (!pigeon.active) _endThrow();
      case Phase.pigeonStrike:
        _tickPigeonStrike(dt);
      case Phase.broomChase:
        _tickBroomChase(dt);
      case Phase.cooldown:
        _cooldownT -= dt;
        if (_cooldownT <= 0) _startNextThrow();
      case Phase.aiming:
        if (!aimingDrag) {
          idleT += dt;
          if (idleT > _idleLimit) _startPigeonStrike();
        }
      case Phase.figurePreview:
        previewT -= dt;
        if (previewT <= 0) _startNextThrow();
      case Phase.gameOver:
        break;
    }
    notifyListeners();
  }

  bool get _pinsInFlight => pins.any((p) => p.flying);

  void _tickBat(double dt) {
    if (bat.onRope) {
      bat.ropeSwing += dt;
      if (bat.ropeSwing > 2.2) {
        bat.active = false;
        _endThrow();
      }
      return;
    }

    bat.vy -= World.g * dt;
    bat.x += bat.vx * dt;
    bat.y += bat.vy * dt;
    bat.angle += bat.spin * dt;

    // --- Pigeon interception -----------------------------------------
    if (pigeon.active && !pigeon.carrying) {
      final dx = bat.x - pigeon.x, dy = bat.y - pigeon.y;
      if (dx * dx + dy * dy < 0.45) {
        pigeon.carrying = true;
        pigeon.vx = -2.5;
        pigeon.vy = 2.8;
        phase = Phase.pigeonCarry;
        _sfx('coo');
        _say('🕊️', 'A pigeon has requisitioned your bat for the flock. '
            'It offered no receipt.');
        return;
      }
    }

    // --- Laundry line -------------------------------------------------
    if (!_ropeChecked &&
        bat.x > World.ropeX1 &&
        bat.x < World.ropeX2 &&
        (bat.y - World.ropeY).abs() < 0.28) {
      _ropeChecked = true;
      if (_rng.nextDouble() < 0.35) {
        bat
          ..onRope = true
          ..ropeSwing = 0
          ..y = World.ropeY
          ..vx = 0
          ..vy = 0;
        _throwHadContact = true;
        _sfx('boing');
        _say('🩲', "Your bat is now modeling Uncle Tolya's finest "
            'underpants. The jury is impressed.');
        return;
      }
    }

    // --- Dog kennel -----------------------------------------------------
    if (bat.x > World.kennelX &&
        bat.x < World.kennelX + World.kennelW &&
        bat.y < World.kennelH) {
      bat.active = false;
      _throwHadContact = true;
      _startDogChase();
      return;
    }

    // --- Pins in the gorod ---------------------------------------------
    if (bat.x > World.gorodFront - 0.4 &&
        bat.x < World.gorodBack + 0.4 &&
        bat.y < World.pinHeight + 0.35) {
      _hitPinsAt(bat.x);
    }

    // --- The bottle (and its owner) -------------------------------------
    if (!bottleFlying &&
        (bat.x - World.bottleX).abs() < World.bottleR + 0.25 &&
        bat.y < World.bottleH + 0.2) {
      _hitBottle();
    }

    // --- Right building / the window -------------------------------------
    if (bat.x >= World.buildingRX) {
      _throwHadContact = true;
      if (bat.y > World.windowY1 && bat.y < World.windowY2) {
        if (!windowBroken) {
          windowBroken = true;
          throwsTotal++; // penalty throw
          _sfx('glass');
          _say('🪟', 'CRASH! A window! Baba Zina: "MY GERANIUMS! '
              'I know your mother!" (+1 penalty throw)');
        } else {
          _sfx('knock');
          _say('🪟', "That window was already broken. Now it's just rude.");
        }
      } else {
        _sfx('knock');
        _say('🧱', 'THUD. The building remains unimpressed.');
      }
      bat.x = World.buildingRX - 0.1;
      bat.vx = -1.5;
      bat.vy = math.min(bat.vy, 0.0);
    }

    // --- Ground ----------------------------------------------------------
    if (bat.y <= World.batRadius + 0.02) {
      bat.y = World.batRadius + 0.02;
      if (bat.vy < -3.5) {
        bat.vy = -bat.vy * 0.25; // small bounce
      } else {
        bat.vy = 0;
      }
      // Splash!
      if (splashT <= 0 &&
          bat.x > World.puddleX1 &&
          bat.x < World.puddleX2 &&
          bat.vx.abs() > 1) {
        splashT = 1.2;
        _sfx('splash');
        _say('💦', 'SPLASH. A nearby cat looks at you with '
            'centuries of disappointment.');
      }
      // Slide with friction.
      bat.vx *= math.pow(0.05, dt).toDouble();
      bat.spin *= math.pow(0.02, dt).toDouble();
      if (bat.vx.abs() < 0.4 && bat.vy.abs() < 0.5) {
        bat.active = false;
        phase = Phase.settling;
      }
    }

    if (bat.x > World.width + 2 || bat.x < -2) {
      bat.active = false;
      phase = Phase.settling;
    }
  }

  void _hitPinsAt(double x) {
    var hitAny = false;
    for (final p in pins) {
      if (!p.standing) continue;
      if ((p.worldX - x).abs() < 0.38) {
        p
          ..standing = false
          ..flying = true
          ..fx = p.worldX
          ..fy = p.spec.lying ? 0.1 : World.pinHeight / 2
          ..fvx = bat.vx * (0.45 + _rng.nextDouble() * 0.25)
          ..fvy = 2.0 + _rng.nextDouble() * 2.5
          ..fang = 0
          ..fspin = (_rng.nextDouble() - 0.5) * 14;
        bat.vx *= 0.86;
        _throwHadContact = true;
        hitAny = true;
      }
    }
    if (hitAny) _sfx('knock');
  }

  void _tickPins(double dt) {
    for (final p in pins) {
      if (!p.flying) continue;
      p.fvy -= World.g * dt;
      p.fx += p.fvx * dt;
      p.fy += p.fvy * dt;
      p.fang += p.fspin * dt;
      if (p.fy <= 0.06 && p.fvy < 0) {
        if (p.fvy < -2.5) {
          p.fvy = -p.fvy * 0.3;
          p.fvx *= 0.6;
        } else {
          p.flying = false;
          p.removed = true; // out of the square (we're generous)
        }
      }
      if (p.fx > World.width + 1) {
        p.flying = false;
        p.removed = true;
      }
    }
  }

  void _tickBottle(double dt) {
    if (!bottleFlying) return;
    bottleFvy -= World.g * dt;
    bottleFx += bottleFvx * dt;
    bottleFy += bottleFvy * dt;
    if (bottleFy <= 0.05 && bottleFvy < 0) {
      bottleFlying = false; // he quietly retrieves it later
    }
  }

  void _tickPigeon(double dt) {
    if (!pigeon.active) return;
    if (phase == Phase.pigeonStrike) return; // steered by _tickPigeonStrike
    pigeon.x += pigeon.vx * dt;
    pigeon.y += pigeon.vy * dt + math.sin(time * 9) * 0.4 * dt;
    if (pigeon.carrying) {
      bat.x = pigeon.x;
      bat.y = pigeon.y - 0.35;
      bat.angle += dt * 2;
      if (pigeon.y > 9 || pigeon.x < -2) {
        pigeon.active = false;
        bat.active = false;
      }
    } else if (pigeon.x < -2) {
      pigeon.active = false;
    }
  }

  // ------------------------------------------------------------------
  // Absurd events
  // ------------------------------------------------------------------

  void _startPigeonStrike() {
    phase = Phase.pigeonStrike;
    _eventT = 0;
    pigeon
      ..active = true
      ..carrying = false
      ..x = playerX + 4.5
      ..y = 7.5
      ..vx = 0
      ..vy = 0;
    _sfx('coo');
    _say('🕊️', 'The pigeon grows impatient with your tactical pause...');
  }

  void _tickPigeonStrike(double dt) {
    _eventT += dt;
    if (!playerSoiled) {
      // Dive at the player's cap.
      final tx = playerX + 0.1, ty = 1.9;
      final dx = tx - pigeon.x, dy = ty - pigeon.y;
      final d = math.sqrt(dx * dx + dy * dy);
      if (d < 0.35) {
        playerSoiled = true;
        playerFleeing = true;
        _eventT = 0;
        pigeon
          ..vx = 3.0
          ..vy = 2.5;
        _sfx('splash');
        _say('💩', 'Direct hit! The pigeon leaves a one-star review. '
            'You run off to wash up.', ttl: 4.2);
      } else {
        // Keep velocity on the pigeon so the sprite faces its dive
        // direction (down one stroke of the V, up the other).
        const sp = 6.5;
        pigeon
          ..vx = dx / d * sp
          ..vy = dy / d * sp
          ..x += dx / d * sp * dt
          ..y += dy / d * sp * dt;
      }
    } else {
      // Pigeon departs with dignity; player flees to the washroom.
      pigeon
        ..x += pigeon.vx * dt
        ..y += pigeon.vy * dt;
      if (pigeon.y > 9) pigeon.active = false;
      playerRunOffset -= dt * 5;
      if (_eventT > 2.6) {
        playerSoiled = false;
        playerFleeing = false;
        playerRunOffset = 0;
        pigeon.active = false;
        idleT = 0;
        _idleLimit = 15 + _rng.nextDouble() * 10;
        phase = Phase.aiming;
        _say('🧼', 'Freshly washed and ready to continue.');
      }
    }
  }

  void _startBroomChase() {
    phase = Phase.broomChase;
    drunkardChasing = true;
    _eventT = 0;
    bat.active = false;
    throwsTotal++; // penalty throw
    _sfx('whoosh');
    _say('🧹', 'That was the LAST one! Uncle Gena grabs the broom and '
        'sweeps you off the field! (+1 penalty throw)', ttl: 5);
  }

  void _tickBroomChase(double dt) {
    _eventT += dt;
    if (_eventT < 1.8) {
      // Gena advances, broom held high.
      final t = _eventT / 1.8;
      drunkardX =
          World.benchX + 0.7 - (World.benchX + 0.7 - (playerX + 1.0)) * t;
      if (_eventT > 0.4) {
        playerFleeing = true;
        playerRunOffset -= dt * 6;
      }
    } else if (_eventT < 3.6) {
      playerRunOffset -= dt * 4;
      // Point made; he strolls back to the bench.
      drunkardX += (World.benchX + 0.7 - drunkardX) * dt * 2;
    } else {
      drunkardChasing = false;
      playerFleeing = false;
      playerRunOffset = 0;
      drunkardX = World.benchX + 0.7;
      bottleHits = 0; // he cools down... until next time
      _broomThreshold = 3 + _rng.nextInt(4);
      _endThrow();
    }
  }

  void _startDogChase() {
    phase = Phase.dogChase;
    dogOut = true;
    dogFacingRight = false;
    playerFleeing = true;
    _eventT = 0;
    throwsTotal++; // penalty throw
    _sfx('bark');
    _say('🐕', 'You hit the kennel! Barbos is escorting you off the '
        'premises. (+1 penalty throw)', ttl: 4.5);
  }

  void _tickDogChase(double dt) {
    _eventT += dt;
    if (_eventT < 1.4) {
      // Dog sprints toward the player.
      final t = _eventT / 1.4;
      dogX = World.kennelX + 0.4 - (World.kennelX + 0.4 - (playerX + 0.8)) * t;
      if (_eventT > 0.5) {
        playerRunOffset -= dt * 6; // player flees left
      }
    } else if (_eventT < 3.0) {
      playerRunOffset -= dt * 4;
      dogFacingRight = true; // turns around, trots back head-first, smug
      dogX += (World.kennelX + 0.4 - dogX) * dt * 2;
    } else {
      dogOut = false;
      dogFacingRight = false;
      playerFleeing = false;
      playerRunOffset = 0;
      _endThrow();
    }
  }

  void _hitBottle() {
    bottleFlying = true;
    bottleFx = World.bottleX;
    bottleFy = 0.3;
    bottleFvx = bat.vx * 0.4 + 1;
    bottleFvy = 3.5;
    bat.vx *= 0.7;
    drunkardAngry = true;
    drunkardAngryT = 4.0;
    bottleHits++;
    _throwHadContact = true;
    _sfx('clink');
    if (bottleHits >= _broomThreshold) {
      _startBroomChase();
      return;
    }
    const lines = [
      'The bottle! Uncle Gena shakes his fist: "I was saving that '
          'for a SPECIAL occasion!"',
      'Uncle Gena, tragically: "That kefir had sentimental value!"',
      'Uncle Gena stands up. Sits back down. Shakes fist in your '
          'general direction. He is running out of patience...',
    ];
    _say('🍾', lines[math.min(bottleHits - 1, lines.length - 1)], ttl: 4.2);
  }

  // ------------------------------------------------------------------
  // Turn resolution
  // ------------------------------------------------------------------

  void _resolveThrow() {
    // Letter rule: the stamp must be knocked out first.
    if (figure.isLetter) {
      final stamp = pins.firstWhere((p) => p.spec.isStamp);
      if (!stamp.removed) {
        final backfired =
            pins.where((p) => p.removed && !p.spec.isStamp).toList();
        if (backfired.isNotEmpty) {
          for (final p in backfired) {
            p
              ..removed = false
              ..standing = true
              ..flying = false;
          }
          _say('✉️', 'The letter stays sealed! Knock out the STAMP '
              '(center pin) first — the corners walked back.', ttl: 4.5);
        }
      }
    }

    final knockedAny = pins.any((p) => p.removed);
    if (knockedAny && !_figureOpened) {
      _figureOpened = true;
      if (!figure.isLetter) {
        _say('📏', 'First blood! You now throw from the half-kon (6.5 m).');
        fromKon = false;
      }
    }

    if (pins.every((p) => p.removed)) {
      _finishFigure();
      return;
    }

    if (!_throwHadContact && _rng.nextDouble() < 0.3) {
      const misses = [
        'Uncle Gena applauds. Ironically.',
        'A sparrow lands on the gorod and chirps something sarcastic.',
        'Somewhere, a babushka sighs at your technique.',
        'The bat rolls away with quiet dignity.',
      ];
      _say('😐', misses[_rng.nextInt(misses.length)]);
    }
    _endThrow();
  }

  void _finishFigure() {
    if (figureIndex >= kFigures.length - 1) {
      phase = Phase.gameOver;
      _sfx('gameover');
      _say('🏆', 'All 15 figures! Total: $throwsTotal throws. '
          'Even Barbos looks impressed.', ttl: 8);
      return;
    }
    figureIndex++;
    _setupFigure();
    _sfx('fanfare');
    _say('🎉', 'Figure cleared! Next: ${figure.name} '
        '(${figureIndex + 1}/15)${figure.isLetter ? ' — kon only, stamp first!' : ''}',
        ttl: 4);
    _startPreview();
  }

  void _endThrow() {
    phase = Phase.cooldown;
    _cooldownT = 0.7;
  }

  void _startNextThrow() {
    playerX = throwLineX;
    playerRunOffset = 0;
    idleT = 0;
    bat
      ..active = false
      ..onRope = false;
    aimVx = 0;
    aimVy = 0;
    phase = Phase.aiming;
  }

  /// Simulated trajectory preview for aiming (list of world points).
  List<(double, double)> previewTrajectory() {
    if (!aimingDrag) return const [];
    final pts = <(double, double)>[];
    double x = playerX + 0.35, y = World.throwHandY;
    double vx = aimVx, vy = aimVy;
    const dt = 0.045;
    for (int i = 0; i < 28; i++) {
      vy -= World.g * dt;
      x += vx * dt;
      y += vy * dt;
      if (y < 0) break;
      pts.add((x, y));
    }
    return pts;
  }
}
