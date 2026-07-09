/// The 15 canonical gorodki figures.
///
/// Each figure is built from 5 pins ("gorodki") placed inside the 2x2 m
/// "gorod" square. Coordinates are local to the square:
///   * [u] — along the throw axis, 0.0 = front edge (nearest the player),
///     2.0 = back edge.
///   * [v] — across the square (depth from the camera in our side view),
///     0.0 = near side, 2.0 = far side.
///
/// [lying] pins rest on the ground; [lyingAngle] is the angle (radians)
/// of the pin's long axis relative to the throw axis, used for rendering.
library;

import 'dart:math' as math;

class PinSpec {
  final double u;
  final double v;
  final bool lying;
  final double lyingAngle;
  final bool isStamp; // the center pin of the "Letter" figure

  const PinSpec(
    this.u,
    this.v, {
    this.lying = false,
    this.lyingAngle = 0,
    this.isStamp = false,
  });
}

class FigureSpec {
  final String name; // English name
  final String russianName; // transliteration + cyrillic
  final List<PinSpec> pins;

  /// The "Letter" figure has special rules: it is always thrown from the
  /// kon line (13 m) and the center pin (the stamp) must be knocked out
  /// first, otherwise knocked pins are put back.
  final bool isLetter;

  const FigureSpec(this.name, this.russianName, this.pins,
      {this.isLetter = false});
}

const double _d = math.pi / 4; // 45 degrees, for diagonal lying pins

/// All 15 figures, in the official order.
const List<FigureSpec> kFigures = [
  FigureSpec('Cannon', 'Pushka — Пушка', [
    PinSpec(0.4, 1.0, lying: true), // barrel
    PinSpec(0.9, 1.0, lying: true),
    PinSpec(1.4, 1.0, lying: true),
    PinSpec(1.7, 0.6), // wheels
    PinSpec(1.7, 1.4),
  ]),
  FigureSpec('Fork', 'Vilka — Вилка', [
    PinSpec(0.4, 1.0, lying: true), // handle
    PinSpec(1.5, 0.3), // tines
    PinSpec(1.6, 0.8),
    PinSpec(1.6, 1.2),
    PinSpec(1.5, 1.7),
  ]),
  FigureSpec('Star', 'Zvezda — Звезда', [
    PinSpec(1.0, 1.0), // heart of the star
    PinSpec(0.5, 0.5, lying: true, lyingAngle: _d),
    PinSpec(0.5, 1.5, lying: true, lyingAngle: -_d),
    PinSpec(1.5, 0.5, lying: true, lyingAngle: -_d),
    PinSpec(1.5, 1.5, lying: true, lyingAngle: _d),
  ]),
  FigureSpec('Arrow', 'Strela — Стрела', [
    PinSpec(0.3, 1.0, lying: true), // shaft
    PinSpec(0.8, 1.0, lying: true),
    PinSpec(1.3, 1.0, lying: true),
    PinSpec(1.7, 0.6, lying: true, lyingAngle: _d), // arrowhead
    PinSpec(1.7, 1.4, lying: true, lyingAngle: -_d),
  ]),
  FigureSpec('Well', 'Kolodets — Колодец', [
    PinSpec(0.6, 1.0, lying: true, lyingAngle: math.pi / 2), // frame
    PinSpec(1.4, 1.0, lying: true, lyingAngle: math.pi / 2),
    PinSpec(1.0, 0.6, lying: true),
    PinSpec(1.0, 1.4, lying: true),
    PinSpec(1.0, 1.0), // the bucket pole
  ]),
  FigureSpec('Crankshaft', 'Kolenchaty val — Коленчатый вал', [
    PinSpec(0.3, 0.7, lying: true),
    PinSpec(0.7, 1.3, lying: true),
    PinSpec(1.1, 0.7, lying: true),
    PinSpec(1.5, 1.3, lying: true),
    PinSpec(1.8, 0.7, lying: true),
  ]),
  FigureSpec('Artillery', 'Artilleriya — Артиллерия', [
    PinSpec(0.5, 0.5, lying: true),
    PinSpec(0.5, 1.5, lying: true),
    PinSpec(1.5, 0.4),
    PinSpec(1.5, 1.0),
    PinSpec(1.5, 1.6),
  ]),
  FigureSpec('Racquet', 'Raketka — Ракетка', [
    PinSpec(0.3, 1.0, lying: true), // handle
    PinSpec(1.0, 0.5, lying: true), // rim
    PinSpec(1.0, 1.5, lying: true),
    PinSpec(1.5, 0.8, lying: true, lyingAngle: math.pi / 2),
    PinSpec(1.5, 1.2, lying: true, lyingAngle: math.pi / 2),
  ]),
  FigureSpec('Machine Gun Nest', 'Pulemyotnoe gnezdo — Пулемётное гнездо', [
    PinSpec(0.5, 0.6, lying: true, lyingAngle: _d),
    PinSpec(0.5, 1.4, lying: true, lyingAngle: -_d),
    PinSpec(1.0, 1.0, lying: true),
    PinSpec(1.6, 0.7),
    PinSpec(1.6, 1.3),
  ]),
  FigureSpec('Lobster', 'Rak — Рак', [
    PinSpec(0.4, 0.5, lying: true, lyingAngle: _d), // claws
    PinSpec(0.4, 1.5, lying: true, lyingAngle: -_d),
    PinSpec(1.0, 1.0, lying: true), // body
    PinSpec(1.5, 0.8, lying: true),
    PinSpec(1.5, 1.2, lying: true),
  ]),
  FigureSpec('Watchmen', 'Chasovye — Часовые', [
    PinSpec(0.4, 0.4),
    PinSpec(0.7, 1.6),
    PinSpec(1.0, 1.0),
    PinSpec(1.3, 0.4),
    PinSpec(1.6, 1.6),
  ]),
  FigureSpec('Sickle', 'Serp — Серп', [
    PinSpec(0.3, 1.0, lying: true), // handle
    PinSpec(0.9, 0.6, lying: true, lyingAngle: _d), // blade arc
    PinSpec(1.4, 0.5, lying: true, lyingAngle: math.pi / 2),
    PinSpec(1.8, 0.9, lying: true, lyingAngle: -_d),
    PinSpec(1.9, 1.4, lying: true),
  ]),
  FigureSpec('Shooting Gallery', 'Tir — Тир', [
    PinSpec(1.7, 0.2),
    PinSpec(1.7, 0.6),
    PinSpec(1.7, 1.0),
    PinSpec(1.7, 1.4),
    PinSpec(1.7, 1.8),
  ]),
  FigureSpec('Airplane', 'Samolyot — Самолёт', [
    PinSpec(0.4, 1.0, lying: true), // fuselage
    PinSpec(1.0, 1.0, lying: true),
    PinSpec(1.6, 1.0, lying: true),
    PinSpec(1.0, 0.4, lying: true, lyingAngle: math.pi / 2), // wings
    PinSpec(1.0, 1.6, lying: true, lyingAngle: math.pi / 2),
  ]),
  FigureSpec(
    'Letter',
    "Pis'mo — Письмо",
    [
      PinSpec(0.2, 0.2), // corners of the envelope
      PinSpec(0.2, 1.8),
      PinSpec(1.8, 0.2),
      PinSpec(1.8, 1.8),
      PinSpec(1.0, 1.0, isStamp: true), // the stamp — open it first!
    ],
    isLetter: true,
  ),
];
