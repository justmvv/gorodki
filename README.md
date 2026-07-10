# Gorodki: Courtyard Edition 🏏🐕

The Russian folk game of Gorodki, set in a residential courtyard where
everything that can go wrong will go wrong — hilariously.

## The game

Knock all 5 pins ("gorodki") out of the 2×2 m square ("gorod") by throwing
a bat. All **15 canonical figures** are included, in official order: Cannon,
Fork, Star, Arrow, Well, Crankshaft, Artillery, Racquet, Machine Gun Nest,
Lobster, Watchmen, Sickle, Shooting Gallery, Airplane, and Letter.

Official rules implemented:

* You start each figure from the **kon** line (13 m).
* Once the first pin is knocked out, you move up to the **half-kon** (6.5 m).
* The **Letter** is special: it is thrown from the kon only, and the center
  pin (the stamp) must be knocked out first — otherwise the corner pins
  politely walk back to their places.
* Score = total number of throws for all 15 figures. Fewer is better.

## The courtyard hazards 😱

* **Barbos's kennel** — hit it and the dog will personally escort you off
  the field (+1 penalty throw).
* **Uncle Gena's bottle** — overshoot into his bottle and receive a
  heartfelt fist-shaking about the sentimental value of kefir. Hit it
  3–6 times (he decides how patient he feels today) and he grabs the
  broom and sweeps you off the field (+1 penalty throw).
* **The impatient pigeon** — dawdle too long between throws and it
  dive-bombs you with a one-star review. You'll have to run off and
  wash up.
* **Baba Zina's window** — fly too high past the gorod and... CRASH.
  She knows your mother (+1 penalty throw).
* **The laundry line** — your bat may end the throw wearing Uncle Tolya's
  finest polka-dot underpants.
* **Pigeons** — occasionally requisition your bat for the flock. No receipt.
* **The puddle** — splash. A cat judges you.
* **Return to sender** — throw the bat too vertically and it lands right
  on your cap: you clutch your head, squat, and crawl off the field.
* **The quadcopter** — occasionally descends on patrol and confiscates
  your bat mid-air. Estimated delivery: 3–5 business days.

## Sound 🎵

All audio is genuine home-grown 8-bit, synthesized programmatically
(square waves + noise, NES style):

* **Sound effects** (whoosh, wooden knock, bark, glass, splash, clink,
  boing, coo, fanfares) — on by default, toggle with the 🔊 button.
* **Music** — a chiptune arrangement of the folk song
  *"Akh, Samara-gorodok"*, looped. **Off by default**, toggle with the
  ♪ button.

## Controls

Touch (or click) anywhere and **drag back and down** from the player —
like a slingshot. The dotted line previews the trajectory; release to throw.

## Running

```bash
cd gorodki
flutter create .   # generates the android/ios/web platform folders
flutter pub get
flutter run        # best in landscape; also works with -d chrome
```

Requires Flutter 3.x (Dart ≥ 3.0).

## Publishing (Galaxy Store / AppGallery)

The project is store-ready on the code side:

* `applicationId` / `namespace`: `com.mvv.gorodki` (change in
  `android/app/build.gradle.kts` + `MainActivity.kt` package if needed)
* App label: «Городки», landscape-locked, version `1.0.0+1` (bump the
  `+N` versionCode in `pubspec.yaml` for every store upload)
* Launcher icons: `dart run flutter_launcher_icons` (suprematist artwork
  in `assets/icon/`, adaptive icon included)
* Release signing via `android/key.properties` (git-ignored):

  ```
  keytool -genkey -v -keystore ~/gorodki-release.jks \
      -keyalg RSA -keysize 2048 -validity 10000 -alias gorodki
  ```

  ```properties
  # android/key.properties
  storeFile=/Users/you/gorodki-release.jks
  storePassword=...
  keyAlias=gorodki
  keyPassword=...
  ```

* Build: `flutter build apk --release --split-per-abi` (Galaxy Store)
  and/or `flutter build appbundle --release` (AppGallery accepts AAB).

Store checklist (outside the code): developer accounts (Samsung Seller
Portal / Huawei AppGallery Connect), a privacy policy URL (easy one —
the game collects no data, everything runs offline), landscape
screenshots, a 512×512 icon export, content rating questionnaires.
The game uses no Google Mobile Services, so it runs fine on
GMS-free Huawei devices.

## Project layout

```
lib/
  main.dart                  # app entry
  game/
    figures.dart             # the 15 canonical figures
    world.dart               # courtyard geometry constants
    game_controller.dart     # physics, rules, absurd events
  ui/
    game_screen.dart         # input, HUD, banners
    scene_painter.dart       # the whole courtyard, hand-painted
```
