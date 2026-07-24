import 'dart:ui' show PlatformDispatcher;

/// Replaces `{key}` placeholders in a template.
String tr(String tpl, Map<String, String> args) =>
    args.entries.fold(tpl, (s, e) => s.replaceAll('{${e.key}}', e.value));

/// All user-facing strings for one language.
class GameStrings {
  final String code, flag, langName;
  final List<String> figureNames; // 15, official order
  final String figureIntro,
      newGameMsg,
      pigeonSteal,
      ropeSnag,
      dogChase,
      windowCrash,
      windowAgain,
      buildingThud,
      splashMsg,
      halfKon,
      letterSealed,
      broomChase,
      pigeonImpatient,
      pigeonHit,
      washed,
      batBonk,
      droneIntercept,
      moleMsg,
      figureCleared,
      letterHint,
      gameOverMsg,
      throwsLabel,
      lineKon,
      lineHalf,
      aimHint,
      figureWord,
      goTitle,
      goTotal,
      goCoo,
      playAgain,
      sfxTooltip,
      musicTooltip,
      level2Intro,
      windGust,
      carFirst,
      carAgain,
      ownerChase,
      manholeSteal,
      lampOut,
      hedgehogMsg,
      batSteal,
      batImpatient,
      batHit,
      spiderWeaving,
      webCatch,
      levelMenuTitle,
      level1Name,
      level2Name,
      level3Name,
      level3Intro,
      snowBuryMsg,
      crowStealPin,
      crowBatSteal,
      crowImpatient,
      crowHit,
      treeHit,
      iceSlide,
      sledKid,
      level4Intro,
      level5Intro,
      level4Name,
      level5Name,
      seaBreeze,
      portalMsg,
      crabChaseMsg,
      flipFlopChase,
      chainSnag,
      netSnag,
      nightmareWindowCrash,
      nightmareWindowAgain,
      beachKioskCrash,
      beachKioskAgain,
      beachThud,
      ravenImpatient,
      ravenHit,
      seagullImpatient,
      seagullHit,
      moleMsgNightmare,
      moleMsgBeach,
      ravenSteal,
      seagullSteal,
      paragliderIntercept,
      coconutMsg,
      dragonBreathMsg,
      catsFlee,
      bearChase,
      skeletonAttack,
      spiderCocoonMsg,
      cocoonBreakFree;
  final List<String> missLines,
      bottleLines,
      bottleLinesNightmare,
      bottleLinesBeach,
      snowmanLines,
      snowdriftLines;

  const GameStrings({
    required this.code,
    required this.flag,
    required this.langName,
    required this.figureNames,
    required this.figureIntro,
    required this.newGameMsg,
    required this.pigeonSteal,
    required this.ropeSnag,
    required this.dogChase,
    required this.windowCrash,
    required this.windowAgain,
    required this.buildingThud,
    required this.splashMsg,
    required this.halfKon,
    required this.letterSealed,
    required this.broomChase,
    required this.pigeonImpatient,
    required this.pigeonHit,
    required this.washed,
    required this.batBonk,
    required this.droneIntercept,
    required this.moleMsg,
    required this.figureCleared,
    required this.letterHint,
    required this.gameOverMsg,
    required this.throwsLabel,
    required this.lineKon,
    required this.lineHalf,
    required this.aimHint,
    required this.figureWord,
    required this.goTitle,
    required this.goTotal,
    required this.goCoo,
    required this.playAgain,
    required this.sfxTooltip,
    required this.musicTooltip,
    required this.level2Intro,
    required this.windGust,
    required this.carFirst,
    required this.carAgain,
    required this.ownerChase,
    required this.manholeSteal,
    required this.lampOut,
    required this.hedgehogMsg,
    required this.batSteal,
    required this.batImpatient,
    required this.batHit,
    required this.spiderWeaving,
    required this.webCatch,
    required this.levelMenuTitle,
    required this.level1Name,
    required this.level2Name,
    required this.level3Name,
    required this.level3Intro,
    required this.snowBuryMsg,
    required this.crowStealPin,
    required this.crowBatSteal,
    required this.crowImpatient,
    required this.crowHit,
    required this.treeHit,
    required this.iceSlide,
    required this.sledKid,
    required this.level4Intro,
    required this.level5Intro,
    required this.level4Name,
    required this.level5Name,
    required this.seaBreeze,
    required this.portalMsg,
    required this.crabChaseMsg,
    required this.flipFlopChase,
    required this.chainSnag,
    required this.netSnag,
    required this.nightmareWindowCrash,
    required this.nightmareWindowAgain,
    required this.beachKioskCrash,
    required this.beachKioskAgain,
    required this.beachThud,
    required this.ravenImpatient,
    required this.ravenHit,
    required this.seagullImpatient,
    required this.seagullHit,
    required this.moleMsgNightmare,
    required this.moleMsgBeach,
    required this.ravenSteal,
    required this.seagullSteal,
    required this.paragliderIntercept,
    required this.coconutMsg,
    required this.dragonBreathMsg,
    required this.catsFlee,
    required this.bearChase,
    required this.skeletonAttack,
    required this.spiderCocoonMsg,
    required this.cocoonBreakFree,
    required this.missLines,
    required this.bottleLines,
    required this.bottleLinesNightmare,
    required this.bottleLinesBeach,
    required this.snowmanLines,
    required this.snowdriftLines,
  });
}

const en = GameStrings(
  code: 'en',
  flag: '🇬🇧',
  langName: 'English',
  figureNames: [
    'Cannon', 'Fork', 'Star', 'Arrow', 'Well', 'Crankshaft', 'Artillery',
    'Racquet', 'Machine Gun Nest', 'Lobster', 'Watchmen', 'Sickle',
    'Shooting Gallery', 'Airplane', 'Letter',
  ],
  figureIntro: 'Figure 1: {name}. Drag back from the player to aim!',
  newGameMsg: 'New game! Figure 1: {name}.',
  pigeonSteal:
      'A pigeon has requisitioned your bat for the flock. It offered no receipt.',
  ropeSnag:
      "Your bat is now modeling Uncle Tolya's finest underpants. The jury is impressed.",
  dogChase:
      'You hit the kennel! Barbos is escorting you off the premises. (+1 penalty throw)',
  windowCrash:
      'CRASH! A window! Baba Zina: "MY GERANIUMS! I know your mother!" (+1 penalty throw)',
  windowAgain: "That window was already broken. Now it's just rude.",
  buildingThud: 'THUD. The building remains unimpressed.',
  splashMsg:
      'SPLASH. A nearby cat looks at you with centuries of disappointment.',
  halfKon: 'First blood! You now throw from the half-kon (6.5 m).',
  letterSealed:
      'The letter stays sealed! Knock out the STAMP (center pin) first — the corners walked back.',
  broomChase:
      'That was the LAST one! Uncle Gena grabs the broom and sweeps you off the field! (+1 penalty throw)',
  pigeonImpatient: 'The pigeon grows impatient with your tactical pause...',
  pigeonHit:
      'Direct hit! The pigeon leaves a one-star review. You run off to wash up.',
  washed: 'Freshly washed and ready to continue.',
  batBonk:
      'Right on the cap! You clutch your head, squat... and crawl off the field with what dignity remains.',
  droneIntercept:
      'A quadcopter has intercepted your bat! Estimated delivery: 3–5 business days.',
  moleMsg:
      'A mole! It surfaced right in the gorod and redecorated your figure. It seems proud.',
  figureCleared: 'Figure cleared! Next: {name} ({n}/15){letter}',
  letterHint: ' — kon only, stamp first!',
  gameOverMsg:
      'All 15 figures! Total: {n} throws. Even Barbos looks impressed.',
  throwsLabel: 'Throws',
  lineKon: 'Kon · 13 m',
  lineHalf: 'Half-kon · 6.5 m',
  aimHint: 'Pull back & release!',
  figureWord: 'Figure',
  goTitle: 'All 15 figures cleared!',
  goTotal: 'Total throws:',
  goCoo: 'The pigeons rate your performance: "coo".',
  playAgain: 'Play again',
  sfxTooltip: 'Sound effects',
  musicTooltip: '8-bit "Akh, Samara-gorodok"',
  level2Intro:
      'Evening falls... Level 2: the evening yard! The wind is up, and somebody parked IN the court.',
  windGust: 'A gust of wind! The bat now has opinions of its own.',
  carFirst:
      'CRUNCH-tinkle! The car alarm wails! An angry profile fills a window: "MY LADA!!"',
  carAgain: 'The alarm again. The whole yard hums along by now.',
  ownerChase:
      'The owner bursts out of the entrance in slippers and chases you off the field! (+1 penalty throw)',
  manholeSteal:
      'A resident of the manhole surfaces and catches your bat mid-flight. "Mine now," he explains.',
  lampOut:
      'POP! The streetlamp is out. The yard is now 20% more mysterious.',
  hedgehogMsg:
      'BOING! The hedgehog curls up; the bat ricochets. Nature is undefeated.',
  batSteal:
      'A bat (the animal) has claimed your bat (the stick). Confusing for everyone involved.',
  batImpatient: 'The bat hangs upside down nearby, eyeing your nap with interest...',
  batHit: 'SPLAT! The bat leaves a droppings-based review of your napping technique. You run off to wash up.',
  spiderWeaving: 'A spider is spinning a truly ambitious web between the two lamps.',
  webCatch: 'Caught in the spider\'s web! It really committed to that thing.',
  levelMenuTitle: 'Select level',
  level1Name: 'Level 1 — Daytime yard',
  level2Name: 'Level 2 — Evening yard',
  level3Name: 'Level 3 — Winter yard',
  level3Intro:
      'Snow has fallen! Level 3: winter gorodki. The wind is fierce (40%!), the mole is asleep, and the crow is watching.',
  snowBuryMsg:
      'WHUMP! An avalanche slides off the roof — only your head sticks out! Level lost. Winter wins this round.',
  crowStealPin:
      'The crow stole a gorodok, inspected it, and dropped it somewhere else. Utterly unapologetic.',
  crowBatSteal:
      'The crow has claimed your bat. She has plans for it.',
  crowImpatient: 'The crow eyes your nap with growing interest...',
  crowHit:
      'SPLAT! The crow expresses her opinion of sleeping players. You run off to wash up.',
  treeHit:
      'The bat is stuck in the yolka! The star wobbles disapprovingly.',
  iceSlide: 'The frozen puddle! The bat glides like it never learned to stop.',
  sledKid:
      'A kid on a sled zooms by and carries your bat away. "MIIINE!"',
  level4Intro:
      'A blood moon rises... Level 4: Gorodki in a Nightmare! The pins are on fire, the wind is a brutal 80%, and something is watching from the portal.',
  level5Intro:
      'Dawn breaks over the sand... Level 5: Gorodki on Vacation! The sea breeze catches every throw (100%!), and Uncle Gena is already working on his tan.',
  level4Name: 'Level 4 — Nightmare yard',
  level5Name: 'Level 5 — Beach yard',
  seaBreeze: 'A sea breeze off the water! The bat drifts wherever it pleases.',
  portalMsg:
      'You hit the grave! Cerberus climbs out of the portal and escorts you off the premises, all three heads barking. (+1 penalty throw)',
  crabChaseMsg:
      'You hit the sandcastle! An outraged crab pinches its way out and chases you off the beach. (+1 penalty throw)',
  flipFlopChase:
      'That was the LAST one! Uncle Gena grabs his flip-flop and chases you off the beach! (+1 penalty throw)',
  chainSnag:
      'Your bat is now hanging from a rusty chain, swinging ominously. Something giggles nearby.',
  netSnag:
      'BOING! The volleyball net is strung tight and springs the bat right back at you. A nearby team briefly applauds the form.',
  nightmareWindowCrash:
      'CRASH! That was no ordinary window — a dragon lived behind it, and it is significantly less amused than Baba Zina ever was. (+1 penalty throw)',
  nightmareWindowAgain: 'The dragon eyes the broken frame. Still smoldering, still watching.',
  beachKioskCrash:
      'CRASH! You\'ve hit the ice-cream kiosk. The vendor is unimpressed and charges you for a cone anyway. (+1 penalty throw)',
  beachKioskAgain: 'The kiosk window was already cracked. The vendor shrugs.',
  beachThud: 'THUD. A sand dune absorbs the impact with total indifference.',
  ravenImpatient:
      'The raven perches nearby, one red eye fixed on your nap with growing interest...',
  ravenHit:
      'SPLAT! The raven delivers a distinctly supernatural verdict on your napping. You run off to wash up.',
  seagullImpatient:
      'The seagull is circling. It has clearly done this before...',
  seagullHit:
      'SPLAT! The seagull claims victory (and your sandwich). You run off to wash up.',
  moleMsgNightmare:
      'A bony hand bursts from the grave and redecorates your figure with theatrical malice.',
  moleMsgBeach:
      'A rogue beach ball rolls straight through the gorod, scattering your figure. Someone yells "SORRY!" from far away.',
  ravenSteal:
      'The dragon breaks off from its circling, snatches your bat mid-air, and wheels away with it.',
  seagullSteal:
      'A seagull has claimed your bat for the flock. It has done this exact maneuver before.',
  paragliderIntercept:
      'A paraglider swoops low and snags your bat mid-air! "Sorry, mate, thermal\'s calling!"',
  coconutMsg:
      'THOCK! A coconut, dropped by that suspiciously tall palm tree, lands square on your head. You see stars, and possibly a lawyer.',
  dragonBreathMsg:
      'The dragon leans out of the shattered window and breathes a jet of fire straight at you! You duck, cover, and reconsider several life choices.',
  catsFlee:
      'You hit the trash bin! Two extremely startled cats launch out, backs arched, and vanish in opposite directions.',
  bearChase:
      'The snowdrift erupts! A very large brown bear climbs out and chases you off the field. (+1 penalty throw)',
  skeletonAttack:
      'The ground splits open — THREE SKELETONS climb out, bones rattling, and shuffle you right off the field. (+1 penalty throw)',
  spiderCocoonMsg:
      'A monstrous spider descends from above on a thread of silk and wraps you head to toe in webbing. You are, for the moment, extremely stuck.',
  cocoonBreakFree:
      'With a final heave, the silk gives way. Freedom — and several new personal fears.',
  snowmanLines: [
    'The snowman lost his bucket. He is above such things.',
    'The snowman is now a third shorter. The carrot remains optimistic.',
    'Only a snow stump remains. It forgives you. Probably.',
  ],
  snowdriftLines: [
    'THUMP. The snowdrift shudders. Something inside grumbles.',
    'THUMP. A low growl rolls out from under the snow.',
    'THUMP. The whole drift is shaking now. This seems unwise.',
  ],
  missLines: [
    'Uncle Gena applauds. Ironically.',
    'A sparrow lands on the gorod and chirps something sarcastic.',
    'Somewhere, a babushka sighs at your technique.',
    'The bat rolls away with quiet dignity.',
  ],
  bottleLines: [
    'The bottle! Uncle Gena shakes his fist: "I was saving that for a SPECIAL occasion!"',
    'Uncle Gena, tragically: "That kefir had sentimental value!"',
    'Uncle Gena stands up. Sits back down. Shakes fist in your general direction. He is running out of patience...',
  ],
  bottleLinesNightmare: [
    'The cauldron! Uncle Gena\'s ghost roars: "MY LAVA IS FOR SINNERS!"',
    'Uncle Gena, aghast: "That lava took CENTURIES to properly curse!"',
    'Uncle Gena rises. Sits back down. Points a smoking finger at you. His patience: also cursed, also running out...',
  ],
  bottleLinesBeach: [
    'The martini! Uncle Gena gasps: "Do you have ANY idea how many olives that took?!"',
    'Uncle Gena, wounded: "That was a PREMIUM vermouth!"',
    'Uncle Gena stands up. Sits back down. Adjusts his sunglasses menacingly. He is running out of patience...',
  ],
);

const de = GameStrings(
  code: 'de',
  flag: '🇩🇪',
  langName: 'Deutsch',
  figureNames: [
    'Kanone', 'Gabel', 'Stern', 'Pfeil', 'Brunnen', 'Kurbelwelle',
    'Artillerie', 'Schläger', 'MG-Nest', 'Hummer', 'Wachposten', 'Sichel',
    'Schießbude', 'Flugzeug', 'Brief',
  ],
  figureIntro: 'Figur 1: {name}. Vom Spieler nach hinten ziehen und zielen!',
  newGameMsg: 'Neues Spiel! Figur 1: {name}.',
  pigeonSteal:
      'Eine Taube hat dein Schlagholz für den Schwarm beschlagnahmt. Ohne Quittung.',
  ropeSnag:
      'Dein Schlagholz trägt jetzt Onkel Toljas feinste Unterhose. Die Jury ist beeindruckt.',
  dogChase:
      'Du hast die Hundehütte getroffen! Barbos begleitet dich vom Hof. (+1 Strafwurf)',
  windowCrash:
      'KLIRR! Ein Fenster! Oma Sina: "MEINE GERANIEN! Ich kenne deine Mutter!" (+1 Strafwurf)',
  windowAgain: 'Das Fenster war schon kaputt. Jetzt ist es einfach unhöflich.',
  buildingThud: 'RUMMS. Das Haus bleibt unbeeindruckt.',
  splashMsg:
      'PLATSCH. Eine Katze schaut dich mit jahrhundertealter Enttäuschung an.',
  halfKon: 'Erster Treffer! Du wirfst jetzt vom Halb-Kon (6,5 m).',
  letterSealed:
      'Der Brief bleibt zu! Erst die MARKE (Mitte) rauswerfen — die Ecken sind zurückspaziert.',
  broomChase:
      'Das war die LETZTE! Onkel Gena greift zum Besen und fegt dich vom Feld! (+1 Strafwurf)',
  pigeonImpatient: 'Die Taube verliert die Geduld mit deiner Taktikpause...',
  pigeonHit:
      'Volltreffer! Die Taube hinterlässt eine Ein-Sterne-Bewertung. Ab zum Waschen.',
  washed: 'Frisch gewaschen und bereit.',
  batBonk:
      'Direkt auf die Mütze! Kopf halten, hinhocken... und mit letzter Würde vom Feld kriechen.',
  droneIntercept:
      'Ein Quadrocopter hat dein Schlagholz abgefangen! Lieferzeit: 3–5 Werktage.',
  moleMsg:
      'Ein Maulwurf! Mitten im Gorod aufgetaucht und die Figur umdekoriert. Er wirkt stolz.',
  figureCleared: 'Figur geschafft! Weiter: {name} ({n}/15){letter}',
  letterHint: ' — nur vom Kon, erst die Marke!',
  gameOverMsg:
      'Alle 15 Figuren! Insgesamt {n} Würfe. Sogar Barbos ist beeindruckt.',
  throwsLabel: 'Würfe',
  lineKon: 'Kon · 13 m',
  lineHalf: 'Halb-Kon · 6,5 m',
  aimHint: 'Zurückziehen und loslassen!',
  figureWord: 'Figur',
  goTitle: 'Alle 15 Figuren geschafft!',
  goTotal: 'Würfe insgesamt:',
  goCoo: 'Die Tauben bewerten deine Leistung: "gurr".',
  playAgain: 'Nochmal spielen',
  sfxTooltip: 'Soundeffekte',
  musicTooltip: '8-Bit "Ach, Samara-Gorodok"',
  level2Intro:
      'Es wird Abend... Level 2: der Abendhof! Der Wind frischt auf, und jemand hat IM Hof geparkt.',
  windGust: 'Eine Windböe! Das Schlagholz hat jetzt eine eigene Meinung.',
  carFirst:
      'KRACH-klirr! Die Autoalarmanlage heult! Ein wütendes Profil am Fenster: "MEIN LADA!!"',
  carAgain: 'Wieder der Alarm. Der ganze Hof summt die Melodie schon mit.',
  ownerChase:
      'Der Besitzer stürmt in Pantoffeln aus dem Hauseingang und jagt dich vom Feld! (+1 Strafwurf)',
  manholeSteal:
      'Ein Bewohner des Gullys taucht auf und fängt dein Schlagholz. "Jetzt meins", erklärt er.',
  lampOut:
      'PLOPP! Die Straßenlaterne ist aus. Der Hof ist jetzt 20% mysteriöser.',
  hedgehogMsg:
      'BOING! Der Igel rollt sich ein; das Holz prallt ab. Die Natur bleibt ungeschlagen.',
  batSteal:
      'Eine Fledermaus hat dein Schlagholz beschlagnahmt. Verwirrend für alle Beteiligten.',
  batImpatient: 'Die Fledermaus hängt kopfüber daneben und beäugt dein Nickerchen interessiert...',
  batHit: 'PATSCH! Die Fledermaus hinterlässt eine Kot-basierte Kritik deiner Schlaftechnik. Ab zum Waschen.',
  spiderWeaving: 'Eine Spinne webt ein wirklich ambitioniertes Netz zwischen den beiden Laternen.',
  webCatch: 'Im Spinnennetz gefangen! Sie hat sich da richtig reingehängt.',
  levelMenuTitle: 'Level wählen',
  level1Name: 'Level 1 — Hof am Tag',
  level2Name: 'Level 2 — Abendhof',
  level3Name: 'Level 3 — Winterhof',
  level3Intro:
      'Schnee ist gefallen! Level 3: Winter-Gorodki. Der Wind ist heftig (40%!), der Maulwurf schläft, die Krähe beobachtet dich.',
  snowBuryMsg:
      'WUMMS! Eine Dachlawine — nur noch dein Kopf schaut raus! Level verloren. Der Winter gewinnt diese Runde.',
  crowStealPin:
      'Die Krähe hat ein Gorodok gestohlen, begutachtet und woanders fallen lassen. Völlig reuelos.',
  crowBatSteal: 'Die Krähe hat dein Schlagholz beschlagnahmt. Sie hat Pläne.',
  crowImpatient: 'Die Krähe beäugt dein Nickerchen mit wachsendem Interesse...',
  crowHit:
      'KLATSCH! Die Krähe äußert ihre Meinung über schlafende Spieler. Ab zum Waschen.',
  treeHit:
      'Das Schlagholz steckt in der Jolka! Der Stern wackelt missbilligend.',
  iceSlide: 'Die gefrorene Pfütze! Das Holz gleitet, als hätte es Bremsen nie gelernt.',
  sledKid:
      'Ein Kind auf dem Schlitten saust vorbei und nimmt dein Schlagholz mit. "MEINS!"',
  level4Intro:
      'Ein Blutmond geht auf... Level 4: Städtchen im Albtraum! Die Kegel brennen, der Wind liegt bei brutalen 80%, und etwas beobachtet dich aus dem Portal.',
  level5Intro:
      'Die Sonne geht über dem Sand auf... Level 5: Städtchen im Urlaub! Die Meeresbrise erwischt jeden Wurf (100%!), und Onkel Gena arbeitet schon an seiner Bräune.',
  level4Name: 'Level 4 — Albtraumhof',
  level5Name: 'Level 5 — Strandhof',
  seaBreeze: 'Eine Meeresbrise vom Wasser! Das Schlagholz treibt, wohin es will.',
  portalMsg:
      'Du hast das Grab getroffen! Cerberus klettert aus dem Portal und begleitet dich vom Hof, alle drei Köpfe bellend. (+1 Strafwurf)',
  crabChaseMsg:
      'Du hast die Sandburg getroffen! Eine empörte Krabbe kneift sich heraus und jagt dich vom Strand. (+1 Strafwurf)',
  flipFlopChase:
      'Das war die LETZTE! Onkel Gena greift zur Flip-Flop und jagt dich vom Strand! (+1 Strafwurf)',
  chainSnag:
      'Dein Schlagholz hängt jetzt an einer rostigen Kette und schwingt unheilvoll. Irgendwo kichert etwas.',
  netSnag:
      'BOING! Das Volleyballnetz ist straff gespannt und schleudert das Schlagholz zurück. Ein Team in der Nähe applaudiert kurz der Technik.',
  nightmareWindowCrash:
      'KRACH! Das war kein gewöhnliches Fenster — dahinter lebte ein Drache, und der ist deutlich weniger amüsiert, als Oma Sina es je war. (+1 Strafwurf)',
  nightmareWindowAgain: 'Der Drache mustert den zerbrochenen Rahmen. Immer noch schwelend, immer noch wachsam.',
  beachKioskCrash:
      'KRACH! Du hast den Eiskiosk getroffen. Der Verkäufer ist unbeeindruckt und berechnet dir trotzdem eine Kugel. (+1 Strafwurf)',
  beachKioskAgain: 'Das Kioskfenster war schon gesprungen. Der Verkäufer zuckt mit den Schultern.',
  beachThud: 'RUMMS. Eine Sanddüne schluckt den Aufprall mit völliger Gleichgültigkeit.',
  ravenImpatient:
      'Der Rabe sitzt in der Nähe, ein rotes Auge fest auf dein Nickerchen gerichtet...',
  ravenHit:
      'PATSCH! Der Rabe fällt ein deutlich übernatürliches Urteil über dein Nickerchen. Ab zum Waschen.',
  seagullImpatient: 'Die Möwe kreist. Das hat sie eindeutig schon öfter gemacht...',
  seagullHit:
      'PATSCH! Die Möwe beansprucht den Sieg (und dein Sandwich). Ab zum Waschen.',
  moleMsgNightmare:
      'Eine knochige Hand bricht aus dem Grab hervor und dekoriert deine Figur mit theatralischer Bosheit um.',
  moleMsgBeach:
      'Ein entlaufener Wasserball rollt mitten durch den Gorod und wirft deine Figur um. Jemand ruft von weitem "SORRY!".',
  ravenSteal:
      'Der Drache bricht aus seiner Kreisbahn aus, schnappt sich dein Schlagholz mitten in der Luft und fliegt damit davon.',
  seagullSteal:
      'Eine Möwe hat dein Schlagholz für den Schwarm beschlagnahmt. Dieses Manöver hat sie eindeutig schon geübt.',
  paragliderIntercept:
      'Ein Gleitschirmflieger saust tief herab und schnappt sich dein Schlagholz mitten in der Luft! "Sorry, die Thermik ruft!"',
  coconutMsg:
      'PLONK! Eine Kokosnuss von dieser verdächtig hohen Palme landet mitten auf deinem Kopf. Du siehst Sterne, und womöglich einen Anwalt.',
  dragonBreathMsg:
      'Der Drache lehnt sich aus dem zerbrochenen Fenster und speit einen Feuerstoß direkt auf dich! Du duckst dich, deckst dich und überdenkst mehrere Lebensentscheidungen.',
  catsFlee:
      'Du hast den Mülleimer getroffen! Zwei zutiefst erschrockene Katzen schießen heraus, Rücken hochgestellt, und verschwinden in entgegengesetzte Richtungen.',
  bearChase:
      'Die Schneewehe explodiert! Ein sehr großer Braunbär klettert heraus und jagt dich vom Feld. (+1 Strafwurf)',
  skeletonAttack:
      'Der Boden reißt auf — DREI SKELETTE klettern heraus, Knochen klappernd, und scheuchen dich vom Feld. (+1 Strafwurf)',
  spiderCocoonMsg:
      'Eine monströse Spinne lässt sich an einem Seidenfaden herab und wickelt dich von Kopf bis Fuß in Spinnweben ein. Du steckst, vorerst, gründlich fest.',
  cocoonBreakFree:
      'Mit einem letzten Ruck gibt die Seide nach. Freiheit — und ein paar neue Ängste fürs Leben.',
  snowmanLines: [
    'Der Schneemann hat seinen Eimer verloren. Er steht über solchen Dingen.',
    'Der Schneemann ist jetzt ein Drittel kürzer. Die Karotte bleibt optimistisch.',
    'Nur ein Schneestumpf ist übrig. Er verzeiht dir. Wahrscheinlich.',
  ],
  snowdriftLines: [
    'BUMM. Die Schneewehe zittert. Etwas darin knurrt.',
    'BUMM. Ein tiefes Grollen dringt unter dem Schnee hervor.',
    'BUMM. Die ganze Wehe wackelt jetzt. Das wirkt unklug.',
  ],
  missLines: [
    'Onkel Gena applaudiert. Ironisch.',
    'Ein Spatz landet auf dem Gorod und zwitschert etwas Sarkastisches.',
    'Irgendwo seufzt eine Babuschka über deine Technik.',
    'Das Schlagholz rollt mit stiller Würde davon.',
  ],
  bottleLines: [
    'Die Flasche! Onkel Gena droht mit der Faust: "Die war für einen BESONDEREN Anlass!"',
    'Onkel Gena, tragisch: "Dieser Kefir hatte ideellen Wert!"',
    'Onkel Gena steht auf. Setzt sich wieder. Droht in deine Richtung. Seine Geduld schwindet...',
  ],
  bottleLinesNightmare: [
    'Der Kessel! Onkel Genas Geist brüllt: "MEINE LAVA IST FÜR SÜNDER!"',
    'Onkel Gena, entsetzt: "Diese Lava brauchte JAHRHUNDERTE, um richtig verflucht zu werden!"',
    'Onkel Gena erhebt sich. Setzt sich wieder. Deutet mit rauchendem Finger auf dich. Seine Geduld: auch verflucht, auch am Ende...',
  ],
  bottleLinesBeach: [
    'Der Martini! Onkel Gena japst: "Hast du eine AHNUNG, wie viele Oliven das gekostet hat?!"',
    'Onkel Gena, verwundet: "Das war ein PREMIUM-Wermut!"',
    'Onkel Gena steht auf. Setzt sich wieder. Rückt bedrohlich seine Sonnenbrille zurecht. Seine Geduld schwindet...',
  ],
);

const es = GameStrings(
  code: 'es',
  flag: '🇪🇸',
  langName: 'Español',
  figureNames: [
    'Cañón', 'Tenedor', 'Estrella', 'Flecha', 'Pozo', 'Cigüeñal',
    'Artillería', 'Raqueta', 'Nido de ametralladora', 'Langosta',
    'Centinelas', 'Hoz', 'Barraca de tiro', 'Avión', 'Carta',
  ],
  figureIntro: 'Figura 1: {name}. ¡Arrastra hacia atrás desde el jugador para apuntar!',
  newGameMsg: '¡Nueva partida! Figura 1: {name}.',
  pigeonSteal:
      'Una paloma ha requisado tu bate para la bandada. No dio recibo.',
  ropeSnag:
      'Tu bate ahora luce los mejores calzoncillos del tío Tolia. El jurado está impresionado.',
  dogChase:
      '¡Le diste a la caseta! Barbos te escolta fuera del patio. (+1 tiro de castigo)',
  windowCrash:
      '¡CRASH! ¡Una ventana! Abuela Zina: "¡MIS GERANIOS! ¡Conozco a tu madre!" (+1 tiro de castigo)',
  windowAgain: 'Esa ventana ya estaba rota. Ahora es simplemente de mala educación.',
  buildingThud: 'PUMBA. El edificio sigue impasible.',
  splashMsg:
      'CHOF. Un gato cercano te mira con siglos de decepción.',
  halfKon: '¡Primer golpe! Ahora lanzas desde el medio kon (6,5 m).',
  letterSealed:
      '¡La carta sigue sellada! Primero el SELLO (bolo central) — las esquinas volvieron a su sitio.',
  broomChase:
      '¡Esa fue la ÚLTIMA! ¡El tío Gena agarra la escoba y te barre del campo! (+1 tiro de castigo)',
  pigeonImpatient: 'La paloma pierde la paciencia con tu pausa táctica...',
  pigeonHit:
      '¡Impacto directo! La paloma deja una reseña de una estrella. Corres a lavarte.',
  washed: 'Recién lavado y listo para seguir.',
  batBonk:
      '¡Justo en la gorra! Te agarras la cabeza, te agachas... y sales del campo a rastras con la dignidad que queda.',
  droneIntercept:
      '¡Un cuadricóptero ha interceptado tu bate! Entrega estimada: 3–5 días laborables.',
  moleMsg:
      '¡Un topo! Salió justo en el gorod y redecoró tu figura. Parece orgulloso.',
  figureCleared: '¡Figura completada! Siguiente: {name} ({n}/15){letter}',
  letterHint: ' — solo desde el kon, ¡primero el sello!',
  gameOverMsg:
      '¡Las 15 figuras! Total: {n} tiros. Hasta Barbos está impresionado.',
  throwsLabel: 'Tiros',
  lineKon: 'Kon · 13 m',
  lineHalf: 'Medio kon · 6,5 m',
  aimHint: '¡Tira hacia atrás y suelta!',
  figureWord: 'Figura',
  goTitle: '¡Las 15 figuras completadas!',
  goTotal: 'Tiros totales:',
  goCoo: 'Las palomas califican tu actuación: "curr".',
  playAgain: 'Jugar de nuevo',
  sfxTooltip: 'Efectos de sonido',
  musicTooltip: '8 bits "Aj, Samara-gorodok"',
  level2Intro:
      'Cae la tarde... ¡Nivel 2: el patio al atardecer! Sopla el viento y alguien aparcó DENTRO del patio.',
  windGust: '¡Una ráfaga de viento! El bate ahora tiene opiniones propias.',
  carFirst:
      '¡CRAC-tintineo! ¡La alarma del coche aúlla! Un perfil furioso asoma a la ventana: "¡¡MI LADA!!"',
  carAgain: 'Otra vez la alarma. Todo el patio ya tararea la melodía.',
  ownerChase:
      '¡El dueño sale disparado del portal en zapatillas y te echa del campo! (+1 tiro de castigo)',
  manholeSteal:
      'Un residente de la alcantarilla emerge y atrapa tu bate al vuelo. "Ahora es mío", explica.',
  lampOut:
      '¡POP! La farola se apagó. El patio ahora es un 20% más misterioso.',
  hedgehogMsg:
      '¡BOING! El erizo se hace bola; el bate rebota. La naturaleza sigue invicta.',
  batSteal:
      'Un murciélago ha confiscado tu bate. Confuso para todos los implicados.',
  batImpatient: 'El murciélago cuelga cerca, boca abajo, mirando tu siesta con interés...',
  batHit: '¡PLAF! El murciélago deja una reseña fecal de tu técnica para sestear. Corres a lavarte.',
  spiderWeaving: 'Una araña está tejiendo una telaraña realmente ambiciosa entre las dos farolas.',
  webCatch: '¡Atrapado en la telaraña! Se lo curró de verdad.',
  levelMenuTitle: 'Elegir nivel',
  level1Name: 'Nivel 1 — Patio de día',
  level2Name: 'Nivel 2 — Patio al atardecer',
  level3Name: 'Nivel 3 — Patio invernal',
  level3Intro:
      '¡Ha nevado! Nivel 3: gorodki de invierno. El viento es feroz (¡40%!), el topo duerme y el cuervo vigila.',
  snowBuryMsg:
      '¡PLOF! ¡Un alud cae del tejado y solo asoma tu cabeza! Nivel perdido. El invierno gana esta ronda.',
  crowStealPin:
      'El cuervo robó un gorodok, lo inspeccionó y lo soltó en otro sitio. Sin el menor remordimiento.',
  crowBatSteal: 'El cuervo ha confiscado tu bate. Tiene planes.',
  crowImpatient: 'El cuervo observa tu siesta con creciente interés...',
  crowHit:
      '¡PLAF! El cuervo expresa su opinión sobre los jugadores dormidos. Corres a lavarte.',
  treeHit:
      '¡El bate se quedó atascado en el árbol! La estrella se tambalea con desaprobación.',
  iceSlide:
      '¡El charco helado! El bate se desliza como si nunca hubiera aprendido a frenar.',
  sledKid:
      'Un niño en trineo pasa zumbando y se lleva tu bate. "¡¡MÍO!!"',
  level4Intro:
      'Sale una luna de sangre... ¡Nivel 4: Gorodki en una Pesadilla! Los bolos están en llamas, el viento sopla al 80% brutal, y algo observa desde el portal.',
  level5Intro:
      'Amanece sobre la arena... ¡Nivel 5: Gorodki de Vacaciones! La brisa marina atrapa cada lanzamiento (¡100%!), y el tío Gena ya está trabajando en su bronceado.',
  level4Name: 'Nivel 4 — Patio de pesadilla',
  level5Name: 'Nivel 5 — Patio de playa',
  seaBreeze: '¡Una brisa marina desde el agua! El bate flota a su antojo.',
  portalMsg:
      '¡Has golpeado la tumba! Cerbero sale del portal y te escolta fuera del patio, ladrando con sus tres cabezas. (+1 lanzamiento de penalización)',
  crabChaseMsg:
      '¡Has golpeado el castillo de arena! Un cangrejo indignado sale a pellizcos y te persigue fuera de la playa. (+1 lanzamiento de penalización)',
  flipFlopChase:
      '¡Esa fue la ÚLTIMA! El tío Gena agarra su chancla y te persigue fuera de la playa! (+1 lanzamiento de penalización)',
  chainSnag:
      'Tu bate cuelga ahora de una cadena oxidada, balanceándose de forma inquietante. Algo se ríe por ahí cerca.',
  netSnag:
      '¡BOING! La red de vóley playa está bien tensa y devuelve el bate directo hacia ti. Un equipo cercano aplaude brevemente la técnica.',
  nightmareWindowCrash:
      '¡CRASH! Esa no era una ventana cualquiera — detrás vivía un dragón, y está bastante menos divertido de lo que la tía Zina jamás estuvo. (+1 lanzamiento de penalización)',
  nightmareWindowAgain: 'El dragón observa el marco roto. Todavía humeante, todavía vigilando.',
  beachKioskCrash:
      '¡CRASH! Has golpeado el quiosco de helados. Al vendedor no le impresiona y te cobra un cono de todos modos. (+1 lanzamiento de penalización)',
  beachKioskAgain: 'La ventana del quiosco ya estaba agrietada. El vendedor se encoge de hombros.',
  beachThud: 'PLOF. Una duna de arena absorbe el impacto con total indiferencia.',
  ravenImpatient:
      'El cuervo se posa cerca, con un ojo rojo fijo en tu siesta con creciente interés...',
  ravenHit:
      '¡SPLAT! El cuervo emite un veredicto claramente sobrenatural sobre tu siesta. Corres a lavarte.',
  seagullImpatient: 'La gaviota está sobrevolando. Claramente ya ha hecho esto antes...',
  seagullHit:
      '¡SPLAT! La gaviota reclama la victoria (y tu bocadillo). Corres a lavarte.',
  moleMsgNightmare:
      'Una mano huesuda sale de la tumba y redecora tu figura con malicia teatral.',
  moleMsgBeach:
      'Una pelota de playa fuera de control rueda directamente por el gorod, dispersando tu figura. Alguien grita "¡PERDÓN!" desde lejos.',
  ravenSteal:
      'El dragón se aparta de su vuelo en círculos, atrapa tu bate en el aire y se aleja volando con él.',
  seagullSteal:
      'Una gaviota ha reclamado tu bate para la bandada. Claramente ya ha hecho esta maniobra antes.',
  paragliderIntercept:
      '¡Un parapente baja en picado y atrapa tu bate en pleno vuelo! "¡Perdona, me llama el térmico!"',
  coconutMsg:
      '¡PLAF! Un coco de esa palmera sospechosamente alta te cae justo en la cabeza. Ves estrellas, y posiblemente a un abogado.',
  dragonBreathMsg:
      '¡El dragón se asoma por la ventana rota y te lanza un chorro de fuego directo! Te agachas, te cubres y reconsideras varias decisiones de vida.',
  catsFlee:
      '¡Golpeaste el cubo de basura! Dos gatos absolutamente aterrorizados salen disparados, con el lomo arqueado, y desaparecen en direcciones opuestas.',
  bearChase:
      '¡El montón de nieve estalla! Un enorme oso pardo sale trepando y te persigue fuera del campo. (+1 tiro de penalización)',
  skeletonAttack:
      'El suelo se abre — ¡TRES ESQUELETOS salen trepando, con los huesos traqueteando, y te empujan fuera del campo! (+1 tiro de penalización)',
  spiderCocoonMsg:
      'Una araña monstruosa desciende desde arriba por un hilo de seda y te envuelve de pies a cabeza en telaraña. Por el momento, estás completamente atrapado.',
  cocoonBreakFree:
      'Con un último esfuerzo, la seda cede. Libertad — y varios miedos nuevos para toda la vida.',
  snowmanLines: [
    'El muñeco de nieve perdió su cubo. Está por encima de esas cosas.',
    'El muñeco de nieve es ahora un tercio más bajo. La zanahoria sigue optimista.',
    'Solo queda un tocón de nieve. Te perdona. Probablemente.',
  ],
  snowdriftLines: [
    'PUM. El montón de nieve tiembla. Algo dentro gruñe.',
    'PUM. Un gruñido grave sale de debajo de la nieve.',
    'PUM. Todo el montón se sacude ahora. Esto parece imprudente.',
  ],
  missLines: [
    'El tío Gena aplaude. Irónicamente.',
    'Un gorrión aterriza en el gorod y pía algo sarcástico.',
    'En algún lugar, una babushka suspira por tu técnica.',
    'El bate rueda lejos con silenciosa dignidad.',
  ],
  bottleLines: [
    '¡La botella! El tío Gena agita el puño: "¡La guardaba para una ocasión ESPECIAL!"',
    'El tío Gena, trágico: "¡Ese kéfir tenía valor sentimental!"',
    'El tío Gena se levanta. Se vuelve a sentar. Agita el puño hacia ti. Se le acaba la paciencia...',
  ],
  bottleLinesNightmare: [
    '¡El caldero! El fantasma del tío Gena ruge: "¡MI LAVA ES PARA LOS PECADORES!"',
    'El tío Gena, horrorizado: "¡Esa lava tardó SIGLOS en maldecirse correctamente!"',
    'El tío Gena se levanta. Se vuelve a sentar. Te señala con un dedo humeante. Su paciencia: también maldita, también agotándose...',
  ],
  bottleLinesBeach: [
    '¡El martini! El tío Gena jadea: "¿¡Tienes IDEA de cuántas aceitunas costó eso!?"',
    'El tío Gena, herido: "¡Ese era un vermut PREMIUM!"',
    'El tío Gena se levanta. Se vuelve a sentar. Se ajusta las gafas de sol con aire amenazante. Se le acaba la paciencia...',
  ],
);

const nl = GameStrings(
  code: 'nl',
  flag: '🇳🇱',
  langName: 'Nederlands',
  figureNames: [
    'Kanon', 'Vork', 'Ster', 'Pijl', 'Waterput', 'Krukas', 'Artillerie',
    'Racket', 'Mitrailleursnest', 'Kreeft', 'Wachtposten', 'Sikkel',
    'Schiettent', 'Vliegtuig', 'Brief',
  ],
  figureIntro: 'Figuur 1: {name}. Sleep vanaf de speler naar achteren om te richten!',
  newGameMsg: 'Nieuw spel! Figuur 1: {name}.',
  pigeonSteal:
      'Een duif heeft je knuppel gevorderd voor de zwerm. Zonder bonnetje.',
  ropeSnag:
      'Je knuppel showt nu de mooiste onderbroek van oom Tolja. De jury is onder de indruk.',
  dogChase:
      'Je raakte het hondenhok! Barbos begeleidt je van het veld. (+1 strafworp)',
  windowCrash:
      'KLETTER! Een raam! Oma Zina: "MIJN GERANIUMS! Ik ken je moeder!" (+1 strafworp)',
  windowAgain: 'Dat raam was al kapot. Nu is het gewoon onbeleefd.',
  buildingThud: 'BONK. Het gebouw blijft onbewogen.',
  splashMsg:
      'PLONS. Een kat kijkt je aan met eeuwen aan teleurstelling.',
  halfKon: 'Eerste treffer! Je gooit nu vanaf de halve kon (6,5 m).',
  letterSealed:
      'De brief blijft dicht! Eerst de POSTZEGEL (middelste kegel) — de hoeken zijn teruggewandeld.',
  broomChase:
      'Dat was de LAATSTE! Oom Gena grijpt de bezem en veegt je van het veld! (+1 strafworp)',
  pigeonImpatient: 'De duif verliest zijn geduld met je tactische pauze...',
  pigeonHit:
      'Voltreffer! De duif laat een één-ster-recensie achter. Je rent weg om je te wassen.',
  washed: 'Fris gewassen en klaar om door te gaan.',
  batBonk:
      'Recht op je pet! Je grijpt naar je hoofd, hurkt... en kruipt met je laatste waardigheid van het veld.',
  droneIntercept:
      'Een quadcopter heeft je knuppel onderschept! Geschatte levertijd: 3–5 werkdagen.',
  moleMsg:
      'Een mol! Dook op midden in de gorod en heeft je figuur herschikt. Hij lijkt trots.',
  figureCleared: 'Figuur klaar! Volgende: {name} ({n}/15){letter}',
  letterHint: ' — alleen vanaf de kon, eerst de zegel!',
  gameOverMsg:
      'Alle 15 figuren! Totaal: {n} worpen. Zelfs Barbos is onder de indruk.',
  throwsLabel: 'Worpen',
  lineKon: 'Kon · 13 m',
  lineHalf: 'Halve kon · 6,5 m',
  aimHint: 'Trek terug en laat los!',
  figureWord: 'Figuur',
  goTitle: 'Alle 15 figuren klaar!',
  goTotal: 'Totaal worpen:',
  goCoo: 'De duiven beoordelen je optreden: "roekoe".',
  playAgain: 'Opnieuw spelen',
  sfxTooltip: 'Geluidseffecten',
  musicTooltip: '8-bit "Ach, Samara-gorodok"',
  level2Intro:
      'De avond valt... Level 2: de avondtuin! De wind steekt op en iemand parkeerde IN de hof.',
  windGust: 'Een windvlaag! De knuppel heeft nu een eigen mening.',
  carFirst:
      'KRAK-rinkel! Het autoalarm loeit! Een boos profiel verschijnt voor het raam: "MIJN LADA!!"',
  carAgain: 'Weer het alarm. De hele hof neuriet de melodie inmiddels mee.',
  ownerChase:
      'De eigenaar stormt op pantoffels het portiek uit en jaagt je van het veld! (+1 strafworp)',
  manholeSteal:
      'Een bewoner van het riool duikt op en vangt je knuppel in de vlucht. "Nu van mij," legt hij uit.',
  lampOut:
      'PLOP! De lantaarn is uit. De hof is nu 20% mysterieuzer.',
  hedgehogMsg:
      'BOING! De egel rolt zich op; de knuppel ketst af. De natuur blijft ongeslagen.',
  batSteal:
      'Een vleermuis heeft je knuppel gevorderd. Verwarrend voor alle betrokkenen.',
  batImpatient: 'De vleermuis hangt ondersteboven vlakbij en bekijkt je dutje met interesse...',
  batHit: 'PLETS! De vleermuis geeft een op ontlasting gebaseerde recensie van je dutje. Je rent weg om je te wassen.',
  spiderWeaving: 'Een spin weeft een werkelijk ambitieus web tussen de twee lantaarns.',
  webCatch: 'Gevangen in het spinnenweb! Ze heeft er echt haar best op gedaan.',
  levelMenuTitle: 'Kies level',
  level1Name: 'Level 1 — Hof overdag',
  level2Name: 'Level 2 — Avondhof',
  level3Name: 'Level 3 — Winterhof',
  level3Intro:
      'Er ligt sneeuw! Level 3: winter-gorodki. De wind is fel (40%!), de mol slaapt en de kraai houdt je in de gaten.',
  snowBuryMsg:
      'WOEMP! Een daklawine — alleen je hoofd steekt er nog uit! Level verloren. De winter wint deze ronde.',
  crowStealPin:
      'De kraai stal een gorodok, inspecteerde hem en liet hem ergens anders vallen. Totaal onbeschaamd.',
  crowBatSteal: 'De kraai heeft je knuppel gevorderd. Ze heeft plannen.',
  crowImpatient: 'De kraai bekijkt je dutje met groeiende interesse...',
  crowHit:
      'PLETS! De kraai geeft haar mening over slapende spelers. Je rent weg om je te wassen.',
  treeHit:
      'De knuppel zit vast in de kerstboom! De ster wiebelt afkeurend.',
  iceSlide: 'De bevroren plas! De knuppel glijdt alsof hij nooit heeft leren remmen.',
  sledKid:
      'Een kind op een slee zoeft voorbij en neemt je knuppel mee. "VAN MIJ!"',
  level4Intro:
      'Er komt een bloedmaan op... Level 4: Gorodki in een Nachtmerrie! De pinnen staan in brand, de wind zit op een brute 80%, en iets houdt je in de gaten vanuit het portaal.',
  level5Intro:
      'De zon komt op boven het zand... Level 5: Gorodki op Vakantie! Het zeebriesje grijpt elke worp (100%!), en oom Gena werkt al aan zijn bruintje.',
  level4Name: 'Level 4 — Nachtmerrietuin',
  level5Name: 'Level 5 — Strandtuin',
  seaBreeze: 'Een zeebriesje vanaf het water! De knuppel drijft waarheen het wil.',
  portalMsg:
      'Je raakte het graf! Cerberus klimt uit het portaal en begeleidt je van het terrein, alle drie de koppen blaffend. (+1 strafworp)',
  crabChaseMsg:
      'Je raakte het zandkasteel! Een verontwaardigde krab knijpt zich naar buiten en jaagt je van het strand. (+1 strafworp)',
  flipFlopChase:
      'Dat was de LAATSTE! Oom Gena grijpt zijn slipper en jaagt je van het strand! (+1 strafworp)',
  chainSnag:
      'Je knuppel hangt nu aan een roestige ketting, onheilspellend zwaaiend. Er giechelt iets in de buurt.',
  netSnag:
      'BOING! Het volleybalnet staat strak gespannen en katapulteert de knuppel terug. Een team verderop applaudisseert kort voor de techniek.',
  nightmareWindowCrash:
      'KRAK! Dat was geen gewoon raam — er woonde een draak achter, en die is aanzienlijk minder vermaakt dan Baba Zina ooit was. (+1 strafworp)',
  nightmareWindowAgain: 'De draak bekijkt het gebroken kozijn. Nog steeds smeulend, nog steeds waakzaam.',
  beachKioskCrash:
      'KRAK! Je raakte de ijskraam. De verkoper is onder de indruk noch ontroerd en rekent je toch een bolletje aan. (+1 strafworp)',
  beachKioskAgain: 'Het raam van de kraam was al gebarsten. De verkoper haalt zijn schouders op.',
  beachThud: 'BOF. Een zandduin absorbeert de klap met volslagen onverschilligheid.',
  ravenImpatient:
      'De raaf zit vlakbij, één rood oog strak op je dutje gericht, met groeiende interesse...',
  ravenHit:
      'SPLAT! De raaf velt een uitgesproken bovennatuurlijk oordeel over je dutje. Je rent weg om je te wassen.',
  seagullImpatient: 'De meeuw cirkelt rond. Ze heeft dit duidelijk al vaker gedaan...',
  seagullHit:
      'SPLAT! De meeuw claimt de overwinning (en je boterham). Je rent weg om je te wassen.',
  moleMsgNightmare:
      'Een benige hand breekt uit het graf en herdecoreert je figuur met theatrale kwaadaardigheid.',
  moleMsgBeach:
      'Een losgeslagen strandbal rolt recht door de gorod en gooit je figuur omver. Iemand roept van veraf "SORRY!".',
  ravenSteal:
      'De draak breekt uit zijn cirkels, grist je knuppel midden in de lucht weg en vliegt ermee weg.',
  seagullSteal:
      'Een meeuw heeft je knuppel opgeëist voor de zwerm. Dit trucje heeft ze duidelijk al eerder gedaan.',
  paragliderIntercept:
      'Een parapente duikt laag over en grist je knuppel zo uit de lucht! "Sorry hoor, de thermiek roept!"',
  coconutMsg:
      'PLOF! Een kokosnoot van die verdacht hoge palmboom komt recht op je hoofd terecht. Je ziet sterretjes, en mogelijk een advocaat.',
  dragonBreathMsg:
      'De draak leunt uit het gebroken raam en spuwt een vuurstraal recht op je af! Je duikt weg, dekt je in en overdenkt een aantal levenskeuzes.',
  catsFlee:
      'Je raakte de vuilnisbak! Twee doodsbange katten schieten eruit, rug gebold, en verdwijnen in tegengestelde richtingen.',
  bearChase:
      'De sneeuwhoop ontploft! Een enorme bruine beer klimt eruit en jaagt je van het veld. (+1 strafworp)',
  skeletonAttack:
      'De grond scheurt open — DRIE SKELETTEN klimmen eruit, botten ratelend, en jagen je van het veld. (+1 strafworp)',
  spiderCocoonMsg:
      'Een monsterlijke spin daalt af aan een zijden draad en wikkelt je van top tot teen in spinrag. Je zit, voorlopig, grondig vast.',
  cocoonBreakFree:
      'Met een laatste ruk geeft het spinsel mee. Vrijheid — en een paar nieuwe angsten voor het leven.',
  snowmanLines: [
    'De sneeuwpop is zijn emmer kwijt. Hij staat boven zulke dingen.',
    'De sneeuwpop is nu een derde korter. De wortel blijft optimistisch.',
    'Alleen een sneeuwstronk is over. Hij vergeeft het je. Waarschijnlijk.',
  ],
  snowdriftLines: [
    'BONK. De sneeuwhoop schudt. Iets erin gromt.',
    'BONK. Een diep gegrom klinkt onder de sneeuw vandaan.',
    'BONK. De hele hoop schudt nu. Dit lijkt onverstandig.',
  ],
  missLines: [
    'Oom Gena applaudisseert. Ironisch.',
    'Een mus landt op de gorod en tjilpt iets sarcastisch.',
    'Ergens zucht een baboesjka om je techniek.',
    'De knuppel rolt weg met stille waardigheid.',
  ],
  bottleLines: [
    'De fles! Oom Gena schudt zijn vuist: "Die bewaarde ik voor een SPECIALE gelegenheid!"',
    'Oom Gena, tragisch: "Die kefir had emotionele waarde!"',
    'Oom Gena staat op. Gaat weer zitten. Schudt zijn vuist jouw kant op. Zijn geduld raakt op...',
  ],
  bottleLinesNightmare: [
    'De ketel! Oom Gena\'s geest brult: "MIJN LAVA IS VOOR ZONDAARS!"',
    'Oom Gena, ontzet: "Die lava deed er EEUWEN over om goed vervloekt te raken!"',
    'Oom Gena staat op. Gaat weer zitten. Wijst met een rokende vinger naar je. Zijn geduld: ook vervloekt, ook bijna op...',
  ],
  bottleLinesBeach: [
    'De martini! Oom Gena hapt naar adem: "Heb je enig IDEE hoeveel olijven dat gekost heeft?!"',
    'Oom Gena, gekwetst: "Dat was een PREMIUM vermout!"',
    'Oom Gena staat op. Gaat weer zitten. Schikt dreigend zijn zonnebril. Zijn geduld raakt op...',
  ],
);

const List<GameStrings> kLanguages = [en, de, es, nl];

/// Global language holder. UI switches [t]; everyone reads it live.
class L10n {
  static GameStrings t = en;

  /// Picks the best language from the device/system locale (offline,
  /// respects the user's own settings). Falls back to English.
  static void detect() {
    final lc = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    t = kLanguages.firstWhere((l) => l.code == lc, orElse: () => en);
  }
}
