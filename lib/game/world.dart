/// World geometry constants. Units are meters, side view:
/// x grows to the right (toward the gorod), y grows upward from the ground.
library;

class World {
  static const double width = 23.0; // visible world width

  // Throw lines. The gorod front edge is 13 m from the kon line.
  static const double konX = 2.0; // full distance (13 m)
  static const double polukonX = 8.5; // half distance (6.5 m)

  // The gorod ("city") square, 2x2 m.
  static const double gorodFront = 15.0;
  static const double gorodBack = 17.0;

  // Pin dimensions (cartoonishly enlarged for visibility).
  static const double pinHeight = 0.55;
  static const double pinWidth = 0.13;

  // Bat.
  static const double batLength = 0.85;
  static const double batRadius = 0.05;
  static const double throwHandY = 1.45; // release height

  // Gravity.
  static const double g = 9.8;

  // --- Absurd courtyard furniture -------------------------------------

  // Dog kennel, sitting suspiciously close to the gorod.
  static const double kennelX = 12.3;
  static const double kennelW = 1.15;
  static const double kennelH = 1.0;

  // Bench with the local connoisseur of fermented beverages.
  static const double benchX = 18.3; // left edge of bench
  static const double benchW = 1.6;
  static const double bottleX = 18.05; // his bottle, on the ground
  static const double bottleR = 0.18; // collision half-width
  static const double bottleH = 0.5;

  // Right building facade (overshooting hits it).
  static const double buildingRX = 20.7;
  // The one window low enough to be in danger.
  static const double windowY1 = 3.9;
  static const double windowY2 = 5.2;

  // Laundry line between two poles.
  static const double ropeX1 = 9.7;
  static const double ropeX2 = 11.5;
  static const double ropeY = 2.75;

  // --- Level 2: the evening yard ---------------------------------------
  // Somebody's pride and joy, parked IN the court.
  static const double carX1 = 11.3;
  static const double carX2 = 13.2;
  static const double carH = 1.45;
  // An open manhole with a resident.
  static const double manholeX = 10.0;
  static const double manholeR = 0.4;
  // The streetlamps — one nearer the gorod, one further into the yard
  // (drawn slightly smaller to suggest depth). They flank the gorod
  // tightly on purpose: the spider's web (below) spans the gap between
  // their poles, directly across the throwing lane into the square.
  static const double lampX = 14.4;
  static const double lampX2 = 17.6;
  static const double lampY = 3.2;

  // The spider weaves her web directly between the two lamp POLES (not
  // floating between their tops) — a proper frame anchored high and low
  // on each pole, low enough to actually threaten a throw into the gorod.
  static const double webTopY = 2.25;
  static const double webBottomY = 0.35;

  // A trash bin, tucked into the right corner near the building — home
  // to at least two very startled cats.
  static const double binX = 20.15;
  static const double binW = 0.5;
  static const double binH = 0.7;

  // --- Level 3: the winter yard ----------------------------------------
  // The yolka, complete with star.
  static const double treeX = 12.15;
  static const double treeH = 3.0;
  // The snowman (heights per demolition stage).
  static const double snowmanX = 10.45;
  static const List<double> snowmanHeights = [1.6, 1.15, 0.7];

  // A deep, philosophical puddle (frozen solid in winter).
  static const double puddleX1 = 13.6;
  static const double puddleX2 = 14.3;

  // A huge snowdrift in the right corner. Something is living in there.
  static const double snowdriftX = 19.9; // center
  static const double snowdriftW = 1.5;
  static const double snowdriftH = 0.95;
}
