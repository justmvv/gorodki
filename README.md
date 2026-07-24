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
* **The mole** — rarely surfaces right inside the gorod, scatters and
  topples your remaining pins, and leaves looking proud of itself.

## Level 2: the evening yard 🌇

Clear all 15 figures and dusk falls — a new courtyard, lit by a low red
sun. It plays harder: **20% of throws are caught by a gust of wind**,
and the hazards change completely: a parked car (alarm, an angry
profile in the window, and eventually the owner himself, in slippers),
an open manhole with a resident who catches bats mid-flight, an actual
bat (the animal) with a chaotic zigzag flight instead of the pigeon,
a breakable streetlamp (the yard gets darker without it), and a
hedgehog that bounces your bat right back.

Dev cheat: press **K**, then **U** — a level select menu appears.

## Level 3: the winter yard ❄️

Clear level 2 and the whole yard turns white overnight — bright sun,
blue sky, and your player now bundled up in a knit hat and scarf. It's
the hardest round: **wind now derails 40% of throws**, the mole is
asleep for the season, but new locals have opinions:

* **The yolka** — a decorated tree with a star on top; the bat can get
  stuck in its branches for a couple of seconds.
* **The snowman** — a sturdy 3-hit obstacle: loses his bucket, then his
  head, then he's just a stump.
* **The frozen puddle** — no splash, just an uncontrollable ice slide
  that carries the bat much further than intended.
* **The insolent crow** — replaces the pigeon. She still poops on
  players who nap too long, but she'll also swoop down between throws
  and relocate one of your standing gorodki purely to spite you.
* **A kid on a sled** — occasionally zooms through at ground level and
  makes off with the bat.
* **The roof avalanche** — rare and unrelated to your throws: a chunk
  of snow slides off a roof and buries the player up to the neck.
  It's an instant level loss — level 3 restarts from figure 1.

## Level 4: the nightmare yard 🌕

Clear level 3 and a blood moon rises — the same yard, now half horror movie,
half something worse. It's brutal: **wind derails 80% of throws**, the
gorodki themselves burn with an ever-present flame, and the courtyard cast
has been replaced with their afterlife counterparts:

* **The grave portal** — stands where the kennel used to be. Hit it and
  Cerberus climbs out, all three heads barking, to escort you off the
  premises.
* **The ghost of Uncle Gena** — translucent, faintly green, and still
  fiercely protective of his bottle. Push your luck and he still grabs the
  broom.
* **Rusty chains** — hang where the laundry line was; get caught and your
  bat swings ominously while something giggles nearby.
* **A raven** — replaces the pigeon, with a distinctly supernatural
  opinion of napping players.
* **A haunted window** — crash into it and a pale face appears to complain
  about property values.

Your own outfit gets an upgrade too, for reasons the yard does not explain.

## Level 5: gorodki on vacation 🏖️

Clear level 4 and dawn breaks over golden sand — the courtyard swaps for a
beach, complete with sea, a volleyball net, and Uncle Gena (very much
alive, working on his tan). It's the hardest round in a different way:
**the sea breeze catches 100% of throws**, no exceptions. New hazards:

* **A sandcastle guarded by a crab** — hit it and an outraged crustacean
  pinches its way out and chases you down the beach.
* **Uncle Gena, towel edition** — same guy, same bottle, same threshold
  for patience — except now he chases you with a flip-flop.
* **The volleyball net** — strung where the laundry line was; get tangled
  and somewhere a beach team is down a player.
* **A seagull** — replaces the pigeon. It has clearly done this before.
* **A rogue beach ball** — occasionally rolls straight through the gorod
  and scatters your figure. Someone yells "SORRY!" from far away.

## Languages 🌍

English, Deutsch, Español, Nederlands. The app picks the language from
the device locale at startup (offline, falls back to English); switch
any time via the flag button next to the sound toggles.

## Sound 🎵

All audio is genuine home-grown 8-bit, synthesized programmatically
(square waves + noise, NES style):

* **Sound effects** (whoosh, wooden knock, bark, glass, splash, clink,
  boing, coo, fanfares) — on by default, toggle with the 🔊 button.
* **Music** — the folk song *"Akh, Samara-gorodok"*, looped, with a
  different arrangement of the same theme per level: chiptune (level
  1), jazz (level 2), upbeat icy winter (level 3), hellish heavy rock
  (level 4), relaxed blues (level 5). **Off by default**, toggle with
  the ♪ button.

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
