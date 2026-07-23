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
      sledKid;
  final List<String> missLines, bottleLines, snowmanLines;

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
    required this.missLines,
    required this.bottleLines,
    required this.snowmanLines,
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
  snowmanLines: [
    'The snowman lost his bucket. He is above such things.',
    'The snowman is now a third shorter. The carrot remains optimistic.',
    'Only a snow stump remains. It forgives you. Probably.',
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
  snowmanLines: [
    'Der Schneemann hat seinen Eimer verloren. Er steht über solchen Dingen.',
    'Der Schneemann ist jetzt ein Drittel kürzer. Die Karotte bleibt optimistisch.',
    'Nur ein Schneestumpf ist übrig. Er verzeiht dir. Wahrscheinlich.',
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
  snowmanLines: [
    'El muñeco de nieve perdió su cubo. Está por encima de esas cosas.',
    'El muñeco de nieve es ahora un tercio más bajo. La zanahoria sigue optimista.',
    'Solo queda un tocón de nieve. Te perdona. Probablemente.',
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
  snowmanLines: [
    'De sneeuwpop is zijn emmer kwijt. Hij staat boven zulke dingen.',
    'De sneeuwpop is nu een derde korter. De wortel blijft optimistisch.',
    'Alleen een sneeuwstronk is over. Hij vergeeft het je. Waarschijnlijk.',
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
