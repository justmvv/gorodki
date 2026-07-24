import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'figures.dart';
import 'strings.dart';
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
  batBonk, // the bat came back; player clutches head and crawls away
  droneCarry, // a quadcopter has confiscated the bat
  moleAttack, // a mole surfaces in the gorod and redecorates the figure
  ownerChase, // the car owner, in slippers, restores order (level 2)
  manholeGrab, // the manhole resident has acquired your bat (level 2)
  crowSteal, // the crow relocates one of your pins (level 3)
  snowBury, // roof avalanche: only the head sticks out — level lost (level 3)
  sledCarry, // a kid on a sled has made off with the bat (level 3)
  bearChase, // the snowdrift's resident has had enough (level 3)
  coconutBonk, // a coconut has fallen from the palm tree (level 5)
  dragonBreath, // the window dragon retaliates for the broken glass (level 4)
  cooldown, // short pause before the next throw / figure
  gameOver,
}

/// A pin on the field.
class Pin {
  final PinSpec spec;
  bool standing = true; // part of the figure, waiting to be hit
  bool flying = false; // knocked, tumbling through the air
  bool removed = false; // gone from the square (scored)
  bool toppled = false; // knocked over (but not out) by the mole
  double offsetU = 0; // mole-induced displacement along the throw axis

  // Flight state.
  double fx = 0, fy = 0, fvx = 0, fvy = 0, fang = 0, fspin = 0;

  Pin(this.spec);

  /// World x of the pin while standing/lying in the square.
  double get worldX => World.gorodFront + spec.u + offsetU;
}

/// The bat in flight.
class Bat {
  double x = 0, y = 0, vx = 0, vy = 0, angle = 0, spin = 0;
  bool active = false;
  bool onRope = false; // tangled in the laundry
  double ropeSwing = 0; // swing phase while hanging
  bool inTree = false; // lodged in the yolka's branches (level 3)
  double treeSwing = 0;
  bool onWeb = false; // tangled in the spider's web (level 2)
  double webSwing = 0;
}

class Pigeon {
  bool active = false;
  bool carrying = false;
  double x = 0, y = 0, vx = 0, vy = 0;
}

class Drone {
  bool active = false;
  bool carrying = false;
  double x = 0, y = 0;
  double t = 0; // patrol lifetime
  double vx = 0; // horizontal glide speed (paraglider only)
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
  final Drone drone = Drone();
  final List<GameMessage> messages = [];

  // Bat-on-the-head aftermath.
  bool playerBonked = false;
  bool bonkCrawling = false;

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

  // Idle punishment: the pigeon (or bat, or crow) strikes back.
  double idleT = 0;
  double _idleLimit = 18;
  bool playerSoiled = false;

  // Level 2: the bat throws a rotten fruit instead of pooping. It never
  // actually touches the player — it lobs the fruit and wings off.
  bool fruitFlying = false;
  double fruitX = 0, fruitY = 0, fruitVx = 0, fruitVy = 0;
  bool _fruitThrown = false;

  // ---- Level 2: the evening yard --------------------------------------
  int level = 1;
  bool get evening => level == 2;
  bool get winter => level == 3;
  bool get nightmare => level == 4;
  bool get beach => level == 5;

  /// True for levels that reuse the level-1 hazard set (kennel/dog,
  /// bench/bottle, laundry rope) under a different skin.
  bool get level1Style => level == 1 || nightmare || beach;

  // ---- Level 3: the winter yard ---------------------------------------
  int snowmanStage = 0; // 0 = pristine ... 3 = humble stump
  bool _iceSaid = false;
  bool sledActive = false;
  double sledX = 0;
  bool sledHasBat = false;
  bool playerBuried = false;
  double snowChunkY = 8;
  // Crow theft.
  double crowX = 0, crowY = 0;
  int _crowPin = -1;
  double _crowDropU = 1.0;
  int crowStage = 0; // 0 approach, 1 carry, 2 leave
  int carHits = 0;
  double alarmT = 0; // car alarm lights flashing
  double ownerWindowT = 0; // angry profile in the window
  bool ownerChasing = false;
  bool ownerFacingRight = true; // faces the player while chasing
  double ownerX = 1.4;
  bool lampBroken = false;
  bool lampBroken2 = false;
  bool manholeManUp = false;
  bool _manholeChecked = false; // once per throw
  bool _treeChecked = false; // once per throw (level 3)
  bool hogActive = false;

  // The snowdrift — huge, suspiciously occupied.
  int snowdriftHits = 0;
  int _bearThreshold = 3; // 3..5, randomized
  bool bearOut = false;
  double bearX = World.snowdriftX;
  bool bearFacingRight = false;

  // The trash bin's two startled residents.
  bool catsFleeing = false;
  double catsT = 0;

  // The spider, who occasionally weaves a web between the two lamps.
  bool spiderWeaving = false; // actively spinning right now
  bool webActive = false; // web is finished and can snag the bat
  double _spiderT = 0;
  double webAlpha = 0; // 0..1, for fade in/out in the painter
  bool _webChecked = false; // once per throw
  double webSeed = 0; // fixes this web's asymmetric shape until it fades
  double hogX = 0;
  bool hogCurled = false;
  double _hogCurlT = 0;

  // The mole.
  bool moleOut = false;
  double moleU = 1.0; // position across the gorod (0..2)
  bool _moleScattered = false;

  // The coconut, an unprovoked hazard of the beach's newly-taller palm.
  bool coconutFalling = false;
  bool coconutDazed = false;
  double coconutX = 0, coconutY = 0;
  double _coconutDazedT = 0;
  bool coconutBandaged = false;
  double coconutBandageT = 0;

  // The dragon who has been living in Baba Zina's window this whole time.
  bool dragonBreathing = false;

  /// Mole animation clock for the painter (valid while [moleOut]).
  double get moleT => _eventT;

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
    _bearThreshold = 3 + _rng.nextInt(3);
    _idleLimit = 15 + _rng.nextDouble() * 10;
    _setupFigure();
    _startPreview();
    _say('🏏',
        tr(L10n.t.figureIntro, {'name': L10n.t.figureNames[figureIndex]}));
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

  void newGame({int startLevel = 1}) {
    level = startLevel;
    figureIndex = 0;
    throwsTotal = 0;
    windowBroken = false;
    bottleHits = 0;
    carHits = 0;
    alarmT = 0;
    ownerWindowT = 0;
    ownerChasing = false;
    lampBroken = false;
    lampBroken2 = false;
    spiderWeaving = false;
    webActive = false;
    webAlpha = 0;
    hogActive = false;
    manholeManUp = false;
    _broomThreshold = 3 + _rng.nextInt(4);
    drunkardChasing = false;
    playerSoiled = false;
    fruitFlying = false;
    _fruitThrown = false;
    playerFleeing = false;
    playerRunOffset = 0;
    pigeon.active = false;
    drone.active = false;
    playerBonked = false;
    bonkCrawling = false;
    moleOut = false;
    idleT = 0;
    snowmanStage = 0;
    sledActive = false;
    sledHasBat = false;
    playerBuried = false;
    bat.inTree = false;
    coconutFalling = false;
    coconutDazed = false;
    coconutBandaged = false;
    dragonBreathing = false;
    catsFleeing = false;
    snowdriftHits = 0;
    _bearThreshold = 3 + _rng.nextInt(3);
    bearOut = false;
    bearFacingRight = false;
    _setupFigure();
    _startPreview();
    _say('🏏',
        tr(L10n.t.newGameMsg, {'name': L10n.t.figureNames[figureIndex]}));
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
    _manholeChecked = false;
    _treeChecked = false;
    _webChecked = false;
    _iceSaid = false;

    // Wind: 10% on the daytime yard, 20% in the evening, a brutal 40% in
    // winter, a nightmarish 80% in the nightmare yard, and a merciless
    // 100% sea breeze on the beach — nobody escapes level 5 unaimed.
    final windChance =
        beach ? 1.0 : (nightmare ? 0.8 : (winter ? 0.4 : (evening ? 0.2 : 0.1)));
    if (windChance > 0 && _rng.nextDouble() < windChance) {
      aimVx *= 0.65 + _rng.nextDouble() * 0.7;
      aimVy *= 0.7 + _rng.nextDouble() * 0.6;
      _say('💨', beach ? L10n.t.seaBreeze : L10n.t.windGust, ttl: 2.5);
    }

    // Level 3: a kid on a sled may cross the yard.
    if (winter && !sledActive && _rng.nextDouble() < 0.10) {
      sledActive = true;
      sledX = World.width + 1;
      sledHasBat = false;
    }

    bat
      ..active = true
      ..onRope = false
      ..x = playerX + 0.35
      ..y = World.throwHandY
      ..vx = aimVx
      ..vy = aimVy
      ..angle = 0
      ..spin = -(speed * 1.1);

    // Level 2 only: a hedgehog may wander across the field.
    if (evening && !hogActive && _rng.nextDouble() < 0.12) {
      hogActive = true;
      hogX = World.gorodBack + 1.5;
      hogCurled = false;
    }

    // Occasionally the local air force takes an interest.
    final roll = _rng.nextDouble();
    if (roll < 0.09) {
      pigeon
        ..active = true
        ..carrying = false
        ..x = World.width + 1
        ..y = 3.6 + _rng.nextDouble() * 1.6
        ..vx = -3.2 - _rng.nextDouble() * 1.5
        ..vy = 0;
    } else if (roll < 0.15 && !drone.active && (level == 1 || beach)) {
      // The quadcopter flies only in good daylight (optics, warranty).
      // On the beach it's a paraglider instead — same airspace, but it
      // actually flies like one: a steady cross-sky glide, not a hover.
      if (beach) {
        final fromLeft = _rng.nextBool();
        drone
          ..active = true
          ..carrying = false
          ..x = fromLeft ? -2.5 : World.width + 2.5
          ..y = 3.7
          ..t = 0
          ..vx = (fromLeft ? 1 : -1) * (1.5 + _rng.nextDouble() * 0.7);
      } else {
        drone
          ..active = true
          ..carrying = false
          ..x = 10 + _rng.nextDouble() * 4
          ..y = 9.5
          ..t = 0
          ..vx = 0;
      }
      _sfx('drone');
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
    if (alarmT > 0) alarmT -= dt;
    if (ownerWindowT > 0) ownerWindowT -= dt;
    if (coconutBandaged) {
      coconutBandageT -= dt;
      if (coconutBandageT <= 0) coconutBandaged = false;
    }
    if (hogActive) {
      if (hogCurled) {
        _hogCurlT -= dt;
        if (_hogCurlT <= 0) hogCurled = false;
      } else {
        hogX -= 0.45 * dt;
        if (hogX < 9.0) hogActive = false;
      }
    }
    if (catsFleeing) {
      catsT += dt;
      if (catsT > 2.6) catsFleeing = false;
    }
    if (sledActive && phase != Phase.sledCarry) {
      sledX -= 5.5 * dt;
      if (sledX < -2) sledActive = false;
    }
    // The spider: weaves for ~2.5s, then the web stands for a while,
    // then fades away as she moves on to other projects.
    if (spiderWeaving) {
      _spiderT += dt;
      webAlpha = (_spiderT / 2.5).clamp(0.0, 1.0).toDouble();
      if (_spiderT > 2.5) {
        spiderWeaving = false;
        webActive = true;
        _spiderT = 0;
      }
    } else if (webActive) {
      _spiderT += dt;
      if (_spiderT > 14) {
        webAlpha = (1 - (_spiderT - 14) / 1.5).clamp(0.0, 1.0).toDouble();
        if (_spiderT > 15.5) {
          webActive = false;
          webAlpha = 0;
        }
      }
    }
    if (drunkardAngry) {
      drunkardAngryT -= dt;
      if (drunkardAngryT <= 0) drunkardAngry = false;
    }
    _tickBottle(dt);
    _tickPigeon(dt);
    _tickDrone(dt);
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
      case Phase.batBonk:
        _tickBatBonk(dt);
      case Phase.droneCarry:
        if (!drone.active) _endThrow();
      case Phase.moleAttack:
        _tickMole(dt);
      case Phase.ownerChase:
        _tickOwnerChase(dt);
      case Phase.manholeGrab:
        _eventT += dt;
        if (_eventT > 2.4) {
          manholeManUp = false;
          _endThrow();
        }
      case Phase.sledCarry:
        _tickSledCarry(dt);
      case Phase.bearChase:
        _tickBearChase(dt);
      case Phase.coconutBonk:
        _tickCoconutBonk(dt);
      case Phase.dragonBreath:
        _tickDragonBreath(dt);
      case Phase.crowSteal:
        _tickCrowSteal(dt);
      case Phase.snowBury:
        _tickSnowBury(dt);
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
    if (bat.inTree) {
      bat.treeSwing += dt;
      if (bat.treeSwing > 2.0) {
        // Branches give up; the bat tumbles free with a little outward
        // nudge so it actually leaves the branch zone instead of
        // drifting straight back into it.
        bat.inTree = false;
        bat.vx = (_rng.nextBool() ? 1 : -1) * (1.0 + _rng.nextDouble());
        bat.vy = -0.5;
      }
      return;
    }
    if (bat.onWeb) {
      bat.webSwing += dt;
      if (bat.webSwing > 1.8) {
        // The silk finally gives; the bat drops free with an outward
        // nudge so it can't immediately re-snag the same strand.
        bat.onWeb = false;
        bat.vx = (_rng.nextBool() ? 1 : -1) * (1.0 + _rng.nextDouble());
        bat.vy = -0.5;
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
        _sfx(evening ? 'coo' : ((winter || nightmare) ? 'caw' : 'coo'));
        _say(
            evening
                ? '🦇'
                : (winter || nightmare)
                    ? '🐦‍⬛'
                    : '🕊️',
            evening
                ? L10n.t.batSteal
                : winter
                    ? L10n.t.crowBatSteal
                    : nightmare
                        ? L10n.t.ravenSteal
                        : beach
                            ? L10n.t.seagullSteal
                            : L10n.t.pigeonSteal);
        return;
      }
    }

    // --- Quadcopter interception ---------------------------------------
    if (drone.active && !drone.carrying) {
      final ddx = bat.x - drone.x, ddy = bat.y - drone.y;
      final catchR = beach ? 0.55 : 0.35;
      if (ddx * ddx + ddy * ddy < catchR) {
        drone.carrying = true;
        phase = Phase.droneCarry;
        _sfx('drone');
        _say(beach ? '🪂' : '🚁',
            beach ? L10n.t.paragliderIntercept : L10n.t.droneIntercept);
        return;
      }
    }

    // --- The bat returns to sender ---------------------------------------
    if (bat.vy < -1 &&
        bat.y < 1.9 &&
        (bat.x - (playerX + 0.35)).abs() < 0.45) {
      bat
        ..y = World.batRadius + 0.02
        ..vx = 0
        ..vy = 0
        ..spin = 0; // drops at his feet, mission accomplished
      _throwHadContact = true;
      _startBatBonk();
      return;
    }

    // --- Level 2 hazards -------------------------------------------------
    if (evening) {
      // The car.
      if (bat.x > World.carX1 && bat.x < World.carX2 && bat.y < World.carH) {
        _hitCar();
        if (phase != Phase.flying) return; // owner chase started
        bat.vx *= -0.2; // bounces off the bodywork
        bat.x = World.carX1 - 0.05;
      }
      // The manhole resident.
      if (!_manholeChecked &&
          !manholeManUp &&
          (bat.x - World.manholeX).abs() < World.manholeR &&
          bat.y < 1.2) {
        _manholeChecked = true;
        if (_rng.nextDouble() < 0.35) {
          manholeManUp = true;
          bat.active = false;
          phase = Phase.manholeGrab;
          _eventT = 0;
          _throwHadContact = true;
          _sfx('boing');
          _say('🕳️', L10n.t.manholeSteal, ttl: 4.5);
          return;
        }
      }
      // The streetlamps.
      if (!lampBroken &&
          (bat.x - World.lampX).abs() < 0.3 &&
          bat.y > 2.8 &&
          bat.y < 3.7) {
        lampBroken = true;
        bat.vx *= 0.6;
        _throwHadContact = true;
        _sfx('glass');
        _say('💡', L10n.t.lampOut, ttl: 4);
      }
      if (!lampBroken2 &&
          (bat.x - World.lampX2).abs() < 0.3 &&
          bat.y > 2.8 &&
          bat.y < 3.7) {
        lampBroken2 = true;
        bat.vx *= 0.6;
        _throwHadContact = true;
        _sfx('glass');
        _say('💡', L10n.t.lampOut, ttl: 4);
      }
      // The spider's web, woven directly between the two lamp poles —
      // low enough to actually threaten a throw headed into the gorod.
      if (webActive &&
          !_webChecked &&
          !bat.onWeb &&
          bat.x > World.lampX &&
          bat.x < World.lampX2 &&
          bat.y > World.webBottomY &&
          bat.y < World.webTopY) {
        _webChecked = true;
        if (_rng.nextDouble() < 0.5) {
          bat
            ..onWeb = true
            ..webSwing = 0
            ..vx = 0
            ..vy = 0;
          _throwHadContact = true;
          _sfx('boing');
          _say('🕸️', L10n.t.webCatch, ttl: 4);
        }
      }
      // The trash bin, right in the corner.
      if (!catsFleeing &&
          (bat.x - World.binX).abs() < World.binW / 2 + 0.2 &&
          bat.y < World.binH + 0.3) {
        catsFleeing = true;
        catsT = 0;
        bat.vx *= -0.3;
        bat.vy = math.max(bat.vy, 1.2);
        _throwHadContact = true;
        _sfx('boing');
        _say('🐱', L10n.t.catsFlee, ttl: 4);
      }
      // The hedgehog.
      if (hogActive &&
          !hogCurled &&
          (bat.x - hogX).abs() < 0.35 &&
          bat.y < 0.45) {
        bat.vy = 3.2;
        bat.vx = -bat.vx * 0.35;
        hogCurled = true;
        _hogCurlT = 2.5;
        _throwHadContact = true;
        _sfx('boing');
        _say('🦔', L10n.t.hedgehogMsg, ttl: 4);
      }
    }

    // --- Level 3 hazards --------------------------------------------------
    if (winter) {
      // The sled kid — a low, fast horizontal intercept.
      if (sledActive && !sledHasBat && bat.y < 0.9) {
        if ((bat.x - sledX).abs() < 0.6) {
          sledHasBat = true;
          bat.active = false;
          phase = Phase.sledCarry;
          _throwHadContact = true;
          _sfx('whoosh');
          _say('🛷', L10n.t.sledKid, ttl: 4);
          return;
        }
      }
      // The yolka: branches may catch the bat. Checked once per throw
      // (like the laundry line) so the bat can't get re-snagged every
      // single frame while drifting through the same spot — that was
      // causing an effectively endless catch-and-drop loop.
      if (!_treeChecked &&
          !bat.inTree &&
          (bat.x - World.treeX).abs() < 0.45 &&
          bat.y > 0.3 &&
          bat.y < World.treeH * 0.82) {
        _treeChecked = true;
        if (_rng.nextDouble() < 0.4) {
          bat
            ..inTree = true
            ..treeSwing = 0
            ..vx = 0
            ..vy = 0;
          _throwHadContact = true;
          _sfx('boing');
          _say('🎄', L10n.t.treeHit, ttl: 4);
          return;
        }
      }
      // The snowman: a sturdy, gradually shrinking obstacle.
      if (snowmanStage < World.snowmanHeights.length &&
          (bat.x - World.snowmanX).abs() < 0.4 &&
          bat.y < World.snowmanHeights[snowmanStage]) {
        _sfx('knock');
        _say('⛄', L10n.t.snowmanLines[snowmanStage], ttl: 3.5);
        snowmanStage++;
        bat.vx *= -0.4;
        bat.vy = math.max(bat.vy, 1.5);
        _throwHadContact = true;
      }
      // The huge snowdrift in the corner — something in there is
      // counting the hits.
      if (!bearOut &&
          (bat.x - World.snowdriftX).abs() < World.snowdriftW / 2 + 0.15 &&
          bat.y < World.snowdriftH) {
        snowdriftHits++;
        bat.vx *= -0.4;
        bat.vy = math.max(bat.vy, 1.3);
        _throwHadContact = true;
        _sfx('knock');
        if (snowdriftHits >= _bearThreshold) {
          _startBearChase();
          return;
        }
        final lines = L10n.t.snowdriftLines;
        _say('❄️', lines[math.min(snowdriftHits - 1, lines.length - 1)],
            ttl: 3.5);
      }
    }

    // --- Laundry line / chains / volleyball net --------------------------
    if (level1Style &&
        !_ropeChecked &&
        bat.x > World.ropeX1 &&
        bat.x < World.ropeX2 &&
        (bat.y - World.ropeY).abs() < 0.28) {
      _ropeChecked = true;
      if (beach) {
        // The net doesn't snag — it's strung taut and springs the bat
        // straight back out, a little humbled.
        if (_rng.nextDouble() < 0.5) {
          bat.vx = -bat.vx.abs() * 0.65 - 0.5;
          bat.vy = bat.vy.abs() * 0.35 + 1.2;
          _throwHadContact = true;
          _sfx('boing');
          _say('🏐', L10n.t.netSnag);
          return;
        }
      } else if (_rng.nextDouble() < 0.35) {
        bat
          ..onRope = true
          ..ropeSwing = 0
          ..y = World.ropeY
          ..vx = 0
          ..vy = 0;
        _throwHadContact = true;
        _sfx('boing');
        _say(nightmare ? '⛓️' : '🩲',
            nightmare ? L10n.t.chainSnag : L10n.t.ropeSnag);
        return;
      }
    }

    // --- Dog kennel / grave portal / sandcastle ---------------------------
    if (level1Style &&
        bat.x > World.kennelX &&
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

    // --- The bottle (and its owner) ---------------------------------------
    if (level1Style &&
        !bottleFlying &&
        (bat.x - World.bottleX).abs() < World.bottleR + 0.25 &&
        bat.y < World.bottleH + 0.2) {
      _hitBottle();
    }

    // --- Right building / the window (or its stand-ins) -------------------
    if (bat.x >= World.buildingRX) {
      _throwHadContact = true;
      if (bat.y > World.windowY1 && bat.y < World.windowY2) {
        if (!windowBroken) {
          windowBroken = true;
          throwsTotal++; // penalty throw
          _sfx('glass');
          _say('🪟', nightmare
              ? L10n.t.nightmareWindowCrash
              : (beach ? L10n.t.beachKioskCrash : L10n.t.windowCrash));
          if (nightmare) {
            _startDragonBreath();
            return;
          }
        } else {
          _sfx('knock');
          _say('🪟', nightmare
              ? L10n.t.nightmareWindowAgain
              : (beach ? L10n.t.beachKioskAgain : L10n.t.windowAgain));
        }
      } else {
        _sfx('knock');
        _say('🧱', beach ? L10n.t.beachThud : L10n.t.buildingThud);
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
      final onIce = winter && bat.x > World.puddleX1 && bat.x < World.puddleX2;
      // Splash! (Summer/evening only — winter puddles are frozen solid.)
      if (!winter &&
          splashT <= 0 &&
          bat.x > World.puddleX1 &&
          bat.x < World.puddleX2 &&
          bat.vx.abs() > 1) {
        splashT = 1.2;
        _sfx('splash');
        _say('💦', L10n.t.splashMsg);
      }
      if (onIce && !_iceSaid && bat.vx.abs() > 1) {
        _iceSaid = true;
        _say('🧊', L10n.t.iceSlide, ttl: 3);
      }
      // Slide with friction (the frozen puddle offers almost none).
      bat.vx *= math.pow(onIce ? 0.55 : 0.05, dt).toDouble();
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
    if (evening && !pigeon.carrying) {
      // A bat flies nothing like a pigeon: lurching speed, zigzag flutter.
      pigeon.x += pigeon.vx * dt * (0.5 + 0.9 * math.sin(time * 7).abs());
      pigeon.y += math.sin(time * 13) * 3.2 * dt +
          math.sin(time * 3.7) * 1.1 * dt;
    } else if (beach) {
      // A seagull soars: long, near-flat glides on the sea breeze, with a
      // slow rise-and-fall instead of a pigeon's fast, level beeline.
      pigeon.x += pigeon.vx * dt * (0.85 + 0.2 * math.sin(time * 2.2).abs());
      pigeon.y += math.sin(time * 2.6) * 1.6 * dt + math.sin(time * 0.9) * 0.5 * dt;
    } else {
      pigeon.x += pigeon.vx * dt;
      pigeon.y += pigeon.vy * dt + math.sin(time * 9) * 0.4 * dt;
    }
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
  // Level flow
  // ------------------------------------------------------------------

  void jumpToLevel(int l) => newGame(startLevel: l);

  void _tickDrone(double dt) {
    if (!drone.active) return;
    if (beach) {
      _tickParaglider(dt);
      return;
    }
    if (drone.carrying) {
      // Ascends with the confiscated bat.
      drone.y += 2.6 * dt;
      drone.x += 0.6 * dt;
      bat.x = drone.x;
      bat.y = drone.y - 0.5;
      bat.angle = math.sin(time * 4) * 0.25;
      if (drone.y > 9.5) {
        drone.active = false;
        bat.active = false;
      }
      return;
    }
    drone.t += dt;
    if (drone.t > 7) {
      // Nothing to confiscate. Leaves, disappointed.
      drone.y += 4 * dt;
      if (drone.y > 9.5) drone.active = false;
      return;
    }
    // Descends to patrol altitude, lazily tracking the bat.
    drone.y += (3.6 - drone.y) * dt * 1.2;
    if (bat.active && phase == Phase.flying) {
      drone.x += (bat.x - drone.x).clamp(-3.0, 3.0) * dt * 1.4;
    }
  }

  /// Real glider dynamics, not a quadcopter's hover-and-track: the
  /// paraglider commits to one steady cross-sky heading and rides the
  /// thermals, so catching a bat is a matter of luck and timing, not
  /// homing.
  void _tickParaglider(double dt) {
    if (drone.carrying) {
      // Climbs away with its catch, still drifting the way it was going.
      drone.x += drone.vx * dt;
      drone.y += 1.0 * dt;
      bat.x = drone.x;
      bat.y = drone.y - 0.55;
      bat.angle = math.sin(time * 3) * 0.2;
      if (drone.y > 9.8 || drone.x < -4 || drone.x > World.width + 4) {
        drone.active = false;
        bat.active = false;
      }
      return;
    }
    drone.t += dt;
    drone.x += drone.vx * dt;
    // A lazy soaring bob riding the thermals — altitude drifts on its
    // own schedule, never snapping toward the bat.
    drone.y = 3.7 + math.sin(drone.t * 0.8) * 1.1;
    if (drone.x < -4 || drone.x > World.width + 4) {
      drone.active = false;
    }
  }

  // ------------------------------------------------------------------
  // Absurd events
  // ------------------------------------------------------------------

  void _hitCar() {
    carHits++;
    alarmT = 3.0;
    _sfx('siren');
    _throwHadContact = true;
    if (carHits == 1) {
      _sfx('glass');
      ownerWindowT = 4.5;
      _say('🚗', L10n.t.carFirst, ttl: 4.5);
    } else if (carHits >= 3 && _rng.nextDouble() < 0.45) {
      _startOwnerChase();
    } else {
      _say('🚨', L10n.t.carAgain);
    }
  }

  void _startOwnerChase() {
    phase = Phase.ownerChase;
    ownerChasing = true;
    ownerFacingRight = true;
    _eventT = 0;
    ownerX = 1.4;
    bat.active = false;
    throwsTotal++; // penalty throw
    _say('🥿', L10n.t.ownerChase, ttl: 5);
  }

  void _tickOwnerChase(double dt) {
    _eventT += dt;
    if (_eventT < 1.8) {
      // Out of the entrance, slippers slapping — facing the player.
      ownerFacingRight = true;
      final t = _eventT / 1.8;
      ownerX = 1.4 + ((playerX - 0.9) - 1.4) * t;
      if (_eventT > 0.4) {
        playerFleeing = true;
        playerRunOffset += dt * 6; // flees RIGHT, past the gorod
      }
    } else if (_eventT < 3.6) {
      // Point made; turns around and stomps back to the entrance.
      ownerFacingRight = false;
      playerRunOffset += dt * 4;
      ownerX += (1.4 - ownerX) * dt * 2;
    } else {
      ownerChasing = false;
      playerFleeing = false;
      playerRunOffset = 0;
      _endThrow();
    }
  }

  void _startBatBonk() {
    phase = Phase.batBonk;
    _eventT = 0;
    playerBonked = true;
    bonkCrawling = false;
    _sfx('bonk');
    _say('🤕', L10n.t.batBonk, ttl: 4.5);
  }

  void _tickBatBonk(double dt) {
    _eventT += dt;
    if (_eventT < 1.0) {
      // Clutching head, squatting, reconsidering life choices.
    } else if (_eventT < 3.4) {
      bonkCrawling = true;
      playerRunOffset -= dt * 2.2; // slow, humbled crawl
    } else {
      playerBonked = false;
      bonkCrawling = false;
      playerRunOffset = 0;
      _endThrow();
    }
  }

  void _startPigeonStrike() {
    phase = Phase.pigeonStrike;
    _eventT = 0;
    _fruitThrown = false;
    fruitFlying = false;
    pigeon
      ..active = true
      ..carrying = false
      ..x = playerX + 4.5
      ..y = 7.5
      ..vx = 0
      ..vy = 0;
    _sfx(evening ? 'drone' : ((winter || nightmare) ? 'caw' : 'coo'));
    _say(
        evening ? '🦇' : ((winter || nightmare) ? '🐦‍⬛' : '🕊️'),
        evening
            ? L10n.t.batImpatient
            : winter
                ? L10n.t.crowImpatient
                : nightmare
                    ? L10n.t.ravenImpatient
                    : beach
                        ? L10n.t.seagullImpatient
                        : L10n.t.pigeonImpatient);
  }

  /// Erratic bat-style flutter velocity aimed roughly at ([tx],[ty]),
  /// used both while closing in and while winging away afterwards.
  (double, double) _batFlutter(double fromX, double fromY, double tx,
      double ty, double speed) {
    final dx = tx - fromX, dy = ty - fromY;
    final d = math.sqrt(dx * dx + dy * dy).clamp(0.15, 999).toDouble();
    final zz = math.sin(time * 16) * 2.6;
    final zy = math.cos(time * 11) * 1.8;
    return (dx / d * speed + zz, dy / d * speed + zy);
  }

  void _tickPigeonStrike(double dt) {
    _eventT += dt;

    // The thrown fruit, once airborne, always obeys gravity.
    if (fruitFlying) {
      fruitVy -= World.g * dt;
      fruitX += fruitVx * dt;
      fruitY += fruitVy * dt;
      if (fruitY <= 1.85) {
        fruitFlying = false;
        playerSoiled = true;
        playerFleeing = true;
        _eventT = 0;
        _sfx('splash');
        _say('🍎', L10n.t.batHit, ttl: 4.2);
      }
    }

    if (!playerSoiled) {
      if (evening) {
        // The bat never touches the player at all — it flutters to a
        // point above the cap, lobs a rotten fruit, then wings off.
        if (!_fruitThrown) {
          final tx = playerX + 0.1, ty = 2.7;
          final dx = tx - pigeon.x, dy = ty - pigeon.y;
          final d = math.sqrt(dx * dx + dy * dy);
          if (d < 0.5) {
            _fruitThrown = true;
            fruitFlying = true;
            fruitX = pigeon.x;
            fruitY = pigeon.y;
            fruitVx = (playerX + 0.1 - fruitX) / 0.4;
            fruitVy = 0.6;
            _sfx('boing');
          } else {
            final (vx, vy) = _batFlutter(pigeon.x, pigeon.y, tx, ty, 6.0);
            pigeon
              ..vx = vx
              ..vy = vy
              ..x += vx * dt
              ..y += vy * dt;
          }
        } else {
          // Fruit's away — flap off into the evening sky, still erratic.
          final (vx, vy) =
              _batFlutter(pigeon.x, pigeon.y, pigeon.x + 6, 8.5, 5.5);
          pigeon
            ..vx = vx
            ..vy = vy
            ..x += vx * dt
            ..y += vy * dt;
          if (pigeon.y > 8.5 || pigeon.x > World.width) pigeon.active = false;
        }
      } else {
        // Pigeon / crow: dive straight at the player's cap.
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
          _say(
              '💩',
              winter
                  ? L10n.t.crowHit
                  : nightmare
                      ? L10n.t.ravenHit
                      : beach
                          ? L10n.t.seagullHit
                          : L10n.t.pigeonHit,
              ttl: 4.2);
        } else if (beach) {
          // A seagull doesn't beeline — it glides in on a long, gently
          // banking approach with a lazy up-down wobble.
          const sp = 6.0;
          final wobble = math.sin(time * 3.2) * 1.4;
          pigeon
            ..vx = dx / d * sp
            ..vy = dy / d * sp + wobble
            ..x += dx / d * sp * dt
            ..y += (dy / d * sp + wobble) * dt;
        } else {
          // Keep velocity on the bird so the sprite faces its dive
          // direction (down one stroke of the V, up the other).
          const sp = 6.5;
          pigeon
            ..vx = dx / d * sp
            ..vy = dy / d * sp
            ..x += dx / d * sp * dt
            ..y += dy / d * sp * dt;
        }
      }
    } else {
      // Departure: player flees to the washroom. The bat/pigeon/crow
      // keeps flying off on its own (erratically, if it's a bat; soaring,
      // if it's a gull).
      if (pigeon.active) {
        if (evening) {
          final (vx, vy) =
              _batFlutter(pigeon.x, pigeon.y, pigeon.x + 6, 8.5, 5.5);
          pigeon
            ..x += vx * dt
            ..y += vy * dt;
        } else if (beach) {
          pigeon
            ..x += pigeon.vx * dt
            ..y += (pigeon.vy + math.sin(time * 2.6) * 1.4) * dt;
        } else {
          pigeon
            ..x += pigeon.vx * dt
            ..y += pigeon.vy * dt;
        }
        if (pigeon.y > 9) pigeon.active = false;
      }
      playerRunOffset -= dt * 5;
      if (_eventT > 2.6) {
        playerSoiled = false;
        playerFleeing = false;
        playerRunOffset = 0;
        pigeon.active = false;
        fruitFlying = false;
        idleT = 0;
        _idleLimit = 15 + _rng.nextDouble() * 10;
        phase = Phase.aiming;
        _say('🧼', L10n.t.washed);
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
    _say(beach ? '🩴' : '🧹', beach ? L10n.t.flipFlopChase : L10n.t.broomChase,
        ttl: 5);
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
    _say(
        nightmare ? '💀' : (beach ? '🦀' : '🐕'),
        nightmare
            ? L10n.t.portalMsg
            : (beach ? L10n.t.crabChaseMsg : L10n.t.dogChase),
        ttl: 4.5);
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

  void _startBearChase() {
    phase = Phase.bearChase;
    bearOut = true;
    bearFacingRight = false;
    playerFleeing = true;
    _eventT = 0;
    throwsTotal++; // penalty throw
    _sfx('bark');
    _say('🐻', L10n.t.bearChase, ttl: 4.5);
  }

  void _tickBearChase(double dt) {
    _eventT += dt;
    if (_eventT < 1.4) {
      // The bear charges out of the drift.
      final t = _eventT / 1.4;
      bearX = World.snowdriftX - (World.snowdriftX - (playerX + 0.8)) * t;
      if (_eventT > 0.5) {
        playerRunOffset -= dt * 6;
      }
    } else if (_eventT < 3.2) {
      playerRunOffset -= dt * 4;
      bearFacingRight = true; // ambles back, unbothered
      bearX += (World.snowdriftX - bearX) * dt * 2;
    } else {
      bearOut = false;
      bearFacingRight = false;
      playerFleeing = false;
      playerRunOffset = 0;
      snowdriftHits = 0;
      _bearThreshold = 3 + _rng.nextInt(3);
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
    final lines = nightmare
        ? L10n.t.bottleLinesNightmare
        : (beach ? L10n.t.bottleLinesBeach : L10n.t.bottleLines);
    _say(nightmare ? '🔥' : (beach ? '🍸' : '🍾'),
        lines[math.min(bottleHits - 1, lines.length - 1)], ttl: 4.2);
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
          _say('✉️', L10n.t.letterSealed, ttl: 4.5);
        }
      }
    }

    final knockedAny = pins.any((p) => p.removed);
    if (knockedAny && !_figureOpened) {
      _figureOpened = true;
      if (!figure.isLetter) {
        _say('📏', L10n.t.halfKon);
        fromKon = false;
      }
    }

    if (pins.every((p) => p.removed)) {
      _finishFigure();
      return;
    }

    if (!_throwHadContact && _rng.nextDouble() < 0.3) {
      final misses = L10n.t.missLines;
      _say('😐', misses[_rng.nextInt(misses.length)]);
    }
    _endThrow();
  }

  void _finishFigure() {
    if (figureIndex >= kFigures.length - 1) {
      if (level == 1) {
        // Dusk settles over the yard — level 2 begins.
        level = 2;
        figureIndex = 0;
        carHits = 0;
        alarmT = 0;
        ownerWindowT = 0;
        lampBroken = false;
        lampBroken2 = false;
        spiderWeaving = false;
        webActive = false;
        webAlpha = 0;
        hogActive = false;
        catsFleeing = false;
        manholeManUp = false;
        drone.active = false;
        pigeon.active = false;
        _setupFigure();
        _sfx('fanfare');
        _say('🌇', L10n.t.level2Intro, ttl: 6);
        _startPreview();
        return;
      }
      if (level == 2) {
        // Overnight, the whole yard turns white — level 3 begins.
        level = 3;
        figureIndex = 0;
        snowmanStage = 0;
        sledActive = false;
        manholeManUp = false;
        lampBroken = false;
        lampBroken2 = false;
        spiderWeaving = false;
        webActive = false;
        webAlpha = 0;
        playerBuried = false;
        drone.active = false;
        pigeon.active = false;
        catsFleeing = false;
        snowdriftHits = 0;
        bearOut = false;
        _bearThreshold = 3 + _rng.nextInt(3);
        _setupFigure();
        _sfx('fanfare');
        _say('🌨️', L10n.t.level3Intro, ttl: 6);
        _startPreview();
        return;
      }
      if (level == 3) {
        // A blood moon rises over the yard — level 4 begins.
        level = 4;
        figureIndex = 0;
        manholeManUp = false;
        lampBroken = false;
        lampBroken2 = false;
        spiderWeaving = false;
        webActive = false;
        webAlpha = 0;
        playerBuried = false;
        snowmanStage = 0;
        sledActive = false;
        sledHasBat = false;
        drone.active = false;
        pigeon.active = false;
        dogOut = false;
        drunkardChasing = false;
        bottleHits = 0;
        _broomThreshold = 3 + _rng.nextInt(4);
        dragonBreathing = false;
        snowdriftHits = 0;
        bearOut = false;
        _setupFigure();
        _sfx('fanfare');
        _say('🌕', L10n.t.level4Intro, ttl: 6);
        _startPreview();
        return;
      }
      if (level == 4) {
        // Dawn breaks, and mercifully, over golden sand — level 5 begins.
        level = 5;
        figureIndex = 0;
        dogOut = false;
        drunkardChasing = false;
        bottleHits = 0;
        _broomThreshold = 3 + _rng.nextInt(4);
        pigeon.active = false;
        drone.active = false;
        moleOut = false;
        coconutFalling = false;
        coconutDazed = false;
        coconutBandaged = false;
        _setupFigure();
        _sfx('fanfare');
        _say('🏖️', L10n.t.level5Intro, ttl: 6);
        _startPreview();
        return;
      }
      phase = Phase.gameOver;
      _sfx('gameover');
      _say('🏆', tr(L10n.t.gameOverMsg, {'n': '$throwsTotal'}), ttl: 8);
      return;
    }
    figureIndex++;
    _setupFigure();
    _sfx('fanfare');
    _say(
        '🎉',
        tr(L10n.t.figureCleared, {
          'name': L10n.t.figureNames[figureIndex],
          'n': '${figureIndex + 1}',
          'letter': figure.isLetter ? L10n.t.letterHint : '',
        }),
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
      ..onRope = false
      ..inTree = false;
    aimVx = 0;
    aimVy = 0;
    // Rarely, the underground resident has opinions about your figure.
    // (He sleeps through winter — moles are sensible that way.)
    if (!winter &&
        throwsThisFigure >= 1 &&
        pins.where((p) => p.standing).length >= 2 &&
        _rng.nextDouble() < 0.06) {
      _startMole();
      return;
    }
    if (winter) {
      // The roof avalanche: rare, ambient, and unrelated to your aim.
      if (_rng.nextDouble() < 0.035) {
        _startSnowBury();
        return;
      }
      // The crow relocates a gorodok when it gets bored.
      if (throwsThisFigure >= 1 &&
          pins.where((p) => p.standing).length >= 2 &&
          _rng.nextDouble() < 0.08) {
        _startCrowSteal();
        return;
      }
    }
    // The beach's palm tree, being taller than it has any business being,
    // occasionally drops a coconut squarely on the player.
    if (beach && !coconutFalling && !coconutDazed && _rng.nextDouble() < 0.08) {
      _startCoconutBonk();
      return;
    }
    // The spider, rarely, decides the space between the lamps needs
    // decorating. She only bothers if there isn't already a web up.
    if (evening &&
        !spiderWeaving &&
        !webActive &&
        _rng.nextDouble() < 0.05) {
      spiderWeaving = true;
      _spiderT = 0;
      webSeed = _rng.nextDouble() * 1000;
      _sfx('boing');
      _say('🕷️', L10n.t.spiderWeaving, ttl: 4);
    }
    phase = Phase.aiming;
  }

  void _startSnowBury() {
    phase = Phase.snowBury;
    playerBuried = true;
    _eventT = 0;
    snowChunkY = 8.5;
    _sfx('rumble');
    _say('❄️', L10n.t.snowBuryMsg, ttl: 5);
  }

  void _tickSnowBury(double dt) {
    _eventT += dt;
    snowChunkY -= 9 * dt;
    if (snowChunkY < 0) snowChunkY = 0;
    if (_eventT > 3.2) {
      // Winter wins this round: level 3 restarts from figure 1.
      playerBuried = false;
      figureIndex = 0;
      carHits = 0;
      snowmanStage = 0;
      lampBroken = false;
      hogActive = false;
      sledActive = false;
      manholeManUp = false;
      snowdriftHits = 0;
      bearOut = false;
      _bearThreshold = 3 + _rng.nextInt(3);
      _setupFigure();
      _startPreview();
    }
  }

  void _startCoconutBonk() {
    phase = Phase.coconutBonk;
    coconutFalling = true;
    coconutDazed = false;
    coconutX = playerX + 0.15;
    coconutY = 6.0;
    _sfx('rumble');
  }

  void _tickCoconutBonk(double dt) {
    if (coconutFalling) {
      coconutY -= 8.5 * dt;
      if (coconutY <= 1.75) {
        coconutFalling = false;
        coconutDazed = true;
        playerBonked = true;
        bonkCrawling = false;
        _coconutDazedT = 0;
        _sfx('knock');
        _say('🥥', L10n.t.coconutMsg, ttl: 3.5);
      }
    } else if (coconutDazed) {
      _coconutDazedT += dt;
      if (_coconutDazedT < 1.0) {
        // Clutching head, squatting, reconsidering the whole vacation.
      } else if (_coconutDazedT < 3.4) {
        bonkCrawling = true;
        playerRunOffset -= dt * 2.2; // slow, humbled crawl
      } else {
        // Back on their feet, sporting a fresh bandage.
        coconutDazed = false;
        playerBonked = false;
        bonkCrawling = false;
        playerRunOffset = 0;
        coconutBandaged = true;
        coconutBandageT = 10.0;
        phase = Phase.aiming;
      }
    }
  }

  void _startDragonBreath() {
    phase = Phase.dragonBreath;
    _eventT = 0;
    dragonBreathing = true;
    playerBonked = true;
    bonkCrawling = false;
    bat.active = false;
    _sfx('rumble');
    _say('🐉', L10n.t.dragonBreathMsg, ttl: 4.5);
  }

  void _tickDragonBreath(double dt) {
    _eventT += dt;
    if (_eventT > 1.9) {
      dragonBreathing = false;
      playerBonked = false;
      bonkCrawling = false;
      _endThrow();
    }
  }

  void _startCrowSteal() {
    final standing = pins.where((p) => p.standing).toList();
    if (standing.isEmpty) {
      phase = Phase.aiming;
      return;
    }
    _crowPin = pins.indexOf(standing[_rng.nextInt(standing.length)]);
    phase = Phase.crowSteal;
    crowStage = 0;
    _eventT = 0;
    final pin = pins[_crowPin];
    crowX = World.gorodFront + pin.spec.u + pin.offsetU;
    crowY = 7.5;
    _crowDropU = 0.15 + _rng.nextDouble() * 1.7;
    _sfx('caw');
  }

  void _tickCrowSteal(double dt) {
    _eventT += dt;
    final pin = pins[_crowPin];
    final targetX = World.gorodFront + pin.spec.u + pin.offsetU;
    if (crowStage == 0) {
      // Swoop down to the pin.
      final dy = 1.4 - crowY;
      crowY += dy * dt * 3;
      crowX += (targetX - crowX) * dt * 3;
      if (crowY < 1.6) {
        crowStage = 1;
        _eventT = 0;
        pin.standing = false; // aloft, in the crow's grasp
      }
    } else if (crowStage == 1) {
      // Carry it up and across to the drop point.
      crowY += 2.2 * dt;
      crowX += ((World.gorodFront + _crowDropU) - crowX) * dt * 1.8;
      if (crowY > 4.0) {
        crowStage = 2;
        _eventT = 0;
      }
    } else {
      // Drop it — the gorodok lands wherever gravity and spite decide.
      crowY -= 5.5 * dt;
      if (crowY <= 1.6) {
        pin
          ..standing = true
          ..offsetU = _crowDropU - pin.spec.u
          ..toppled = true;
        _sfx('knock');
        _say('🐦‍⬛', L10n.t.crowStealPin, ttl: 4);
        phase = Phase.aiming;
        idleT = 0;
      }
    }
  }

  void _tickSledCarry(double dt) {
    _eventT += dt;
    sledX -= 7.0 * dt;
    if (_eventT > 1.2) {
      sledActive = false;
      sledHasBat = false;
      bat.active = false;
      _endThrow();
    }
  }

  void _startMole() {
    phase = Phase.moleAttack;
    moleOut = true;
    _moleScattered = false;
    _eventT = 0;
    moleU = 0.4 + _rng.nextDouble() * 1.2;
    _sfx('rumble');
  }

  void _tickMole(double dt) {
    _eventT += dt;
    if (!_moleScattered && _eventT > 0.9) {
      _moleScattered = true;
      // The mole redecorates: surviving pins hop, topple and shift.
      for (final p in pins) {
        if (!p.standing) continue;
        final newU = (p.spec.u + p.offsetU + (_rng.nextDouble() - 0.5) * 0.9)
            .clamp(0.15, 1.85)
            .toDouble();
        p
          ..offsetU = newU - p.spec.u
          ..toppled = true;
      }
      _sfx('knock');
      _say(
          nightmare ? '💀' : (beach ? '🦀' : '🐹'),
          nightmare
              ? L10n.t.moleMsgNightmare
              : (beach ? L10n.t.moleMsgBeach : L10n.t.moleMsg),
          ttl: 4.5);
    }
    if (_eventT > 2.8) {
      moleOut = false;
      phase = Phase.aiming;
      idleT = 0;
    }
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
