"""
Generates 4 stylistic re-arrangements of the existing level-1 "Akh,
Samara-gorodok" chiptune theme (transcribed by ear/pitch-detection from
assets/audio/music.wav: an 8-bar, 64-eighth-note melody in D harmonic
minor, chords i-V-iv-V-i-V-iv-V / Dm-A7-Gm-A7-Dm-A7-Gm-A7), one per
level:

  level 2 - jazz (swung, walking bass, comping chords, brushed hats)
  level 3 - upbeat icy winter (bright bells, crisp shaker, shimmer)
  level 4 - hellish heavy rock (distorted power chords, drums, gallop)
  level 5 - relaxed blues (slow shuffle, warm bends, soft brushes)

Pure numpy + stdlib `wave` synthesis, no external audio libraries.
"""
import numpy as np
import wave
import math

SR = 22050

# ---------------------------------------------------------------------
# Note / frequency utilities
# ---------------------------------------------------------------------

NOTE_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']


def note_freq(name):
    """e.g. 'D4' -> Hz. None -> 0 (rest)."""
    if name is None:
        return 0.0
    pitch = name[:-1]
    octave = int(name[-1])
    semitone = NOTE_NAMES.index(pitch)
    midi = (octave + 1) * 12 + semitone
    return 440.0 * 2 ** ((midi - 69) / 12)


# ---------------------------------------------------------------------
# Shared musical material: the theme, transcribed from music.wav
# ---------------------------------------------------------------------

# (note, duration in eighth-notes). 8 bars x 8 eighths = 64 eighths.
MELODY = [
    ('D4', 1), ('F4', 1), ('A4', 4), ('F4', 2), ('A4', 1), ('F4', 1),
    ('D4', 1), ('F4', 1),
    ('E4', 6), ('A#4', 4), ('G3', 2), ('A#4', 1), ('G4', 2), ('C#4', 1),
    ('D4', 4),
    ('A4', 2), ('G4', 1), ('F4', 1), ('G4', 2), ('F4', 1), ('E4', 1),
    ('F4', 2), ('E4', 1), ('D4', 1), ('E4', 1), ('C#4', 1), ('A3', 2),
    ('A4', 2), ('G4', 1), ('F4', 1), ('G4', 1), ('E4', 3), ('D4', 1),
    ('F4', 2), ('C#4', 1), ('D4', 4),
]
assert sum(d for _, d in MELODY) == 64, sum(d for _, d in MELODY)

# One chord per bar (8 bars), i-V-iv-V-i-V-iv-V in D harmonic minor.
CHORDS = ['Dm', 'A7', 'Gm', 'A7', 'Dm', 'A7', 'Gm', 'A7']

CHORD_TONES = {
    'Dm': ['D3', 'F3', 'A3'],
    'A7': ['A2', 'C#3', 'E3', 'G3'],
    'Gm': ['G2', 'A#2', 'D3'],
}
CHORD_ROOT = {'Dm': 'D2', 'A7': 'A1', 'Gm': 'G1'}


# ---------------------------------------------------------------------
# Oscillators / envelopes / effects
# ---------------------------------------------------------------------

def _t(dur):
    return np.linspace(0, dur, int(SR * dur), endpoint=False)


def osc_square(freq, dur, duty=0.5):
    if freq <= 0:
        return np.zeros(int(SR * dur))
    tt = _t(dur)
    phase = (tt * freq) % 1.0
    return np.where(phase < duty, 1.0, -1.0)


def osc_saw(freq, dur):
    if freq <= 0:
        return np.zeros(int(SR * dur))
    tt = _t(dur)
    phase = (tt * freq) % 1.0
    return 2 * phase - 1


def osc_triangle(freq, dur):
    if freq <= 0:
        return np.zeros(int(SR * dur))
    tt = _t(dur)
    phase = (tt * freq) % 1.0
    return 2 * np.abs(2 * phase - 1) - 1


def osc_sine(freq, dur, phase0=0.0):
    if freq <= 0:
        return np.zeros(int(SR * dur))
    tt = _t(dur)
    return np.sin(2 * np.pi * freq * tt + phase0)


def noise(dur, seed=None):
    rng = np.random.default_rng(seed)
    return rng.uniform(-1, 1, int(SR * dur))


def adsr(n, a, d, s, r, sustain_level=0.6):
    """Envelope of length n samples, a/d/r given in seconds."""
    a = max(1, int(a * SR))
    d = max(1, int(d * SR))
    r = max(1, int(r * SR))
    s = max(0, n - a - d - r)
    env = np.concatenate([
        np.linspace(0, 1, a, endpoint=False),
        np.linspace(1, sustain_level, d, endpoint=False),
        np.full(max(s, 0), sustain_level),
        np.linspace(sustain_level, 0, r, endpoint=False),
    ])
    if len(env) < n:
        env = np.pad(env, (0, n - len(env)))
    return env[:n]


def one_pole_lowpass(sig, cutoff_hz):
    a = math.exp(-2 * math.pi * cutoff_hz / SR)
    out = np.empty_like(sig)
    acc = 0.0
    for i, x in enumerate(sig):
        acc = (1 - a) * x + a * acc
        out[i] = acc
    return out


def one_pole_highpass(sig, cutoff_hz):
    return sig - one_pole_lowpass(sig, cutoff_hz)


def soft_clip(sig, drive=1.0):
    return np.tanh(sig * drive)


def simple_delay(sig, delay_s, feedback=0.3, mix=0.25):
    n = len(sig)
    d = int(delay_s * SR)
    out = sig.copy()
    buf = np.zeros(n + d)
    buf[:n] = sig
    delayed = np.zeros(n)
    for i in range(n):
        src = buf[i]
        tap = buf[i - d] if i - d >= 0 else 0.0
        delayed[i] = tap
        buf[i] += tap * feedback if i - d >= 0 else 0
    return out * (1 - mix) + delayed[:n] * mix


def mix_into(buf, sig, start_sample, gain=1.0):
    end = start_sample + len(sig)
    if end > len(buf):
        sig = sig[:len(buf) - start_sample]
        end = len(buf)
    buf[start_sample:end] += sig * gain


def normalize(buf, peak=0.9):
    m = np.abs(buf).max()
    if m > 1e-9:
        buf = buf / m * peak
    return buf


def write_wav(path, buf):
    buf = np.clip(buf, -1, 1)
    pcm = (buf * 32767).astype(np.int16)
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())


# ---------------------------------------------------------------------
# Percussion hits (shared building blocks, timbre varies by call site)
# ---------------------------------------------------------------------

def kick(dur=0.16, freq0=110, freq1=45, punch=0.5, seed=0):
    n = int(SR * dur)
    tt = np.linspace(0, dur, n, endpoint=False)
    f = np.linspace(freq0, freq1, n)
    phase = np.cumsum(2 * np.pi * f / SR)
    tone = np.sin(phase)
    click = noise(0.006, seed) * np.linspace(1, 0, int(SR * 0.006))
    env = np.exp(-tt * 14)
    out = tone * env
    out[:len(click)] += click * punch
    return out


def snare(dur=0.14, tone_freq=180, seed=1, bright=1.0):
    n = int(SR * dur)
    tt = np.linspace(0, dur, n, endpoint=False)
    body = np.sin(2 * np.pi * tone_freq * tt) * np.exp(-tt * 22)
    hiss = noise(dur, seed) * np.exp(-tt * 18)
    hiss = one_pole_highpass(hiss, 1800 * bright)
    return body * 0.5 + hiss * 0.9


def hat(dur=0.05, seed=2, bright=1.0, decay=35):
    n = int(SR * dur)
    tt = np.linspace(0, dur, n, endpoint=False)
    sig = noise(dur, seed)
    sig = one_pole_highpass(sig, 6000 * bright)
    return sig * np.exp(-tt * decay)


def shaker(dur=0.05, seed=3):
    n = int(SR * dur)
    tt = np.linspace(0, dur, n, endpoint=False)
    sig = noise(dur, seed)
    sig = one_pole_highpass(sig, 4000)
    return sig * np.exp(-tt * 45)


def crash(dur=0.9, seed=4):
    n = int(SR * dur)
    tt = np.linspace(0, dur, n, endpoint=False)
    sig = noise(dur, seed)
    sig = one_pole_highpass(sig, 3500)
    return sig * np.exp(-tt * 3)


# ---------------------------------------------------------------------
# Beat-grid helper: converts the shared MELODY (in eighths) into a list
# of (start_beat_in_eighths, note, duration_in_eighths, bar_index)
# ---------------------------------------------------------------------

def melody_events():
    events = []
    pos = 0
    bar_len = 8
    for note, dur in MELODY:
        bar = pos // bar_len
        events.append((pos, note, dur, bar))
        pos += dur
    return events


# =======================================================================
# LEVEL 2 — JAZZ
# =======================================================================

def render_jazz():
    bpm = 132
    eighth = 60 / bpm / 2
    swing = 0.66  # long-short swing ratio for eighth pairs

    def swung_time(pos_eighths):
        """pos_eighths may be fractional; convert to seconds with swing."""
        pair = int(pos_eighths // 1)
        frac = pos_eighths - pair
        # even eighths land on the beat, odd eighths pushed late (swing)
        base = (pair // 2) * (2 * eighth)
        if pair % 2 == 0:
            t0 = base
        else:
            t0 = base + eighth * (2 * swing)
        return t0 + frac * eighth  # fractional durations rarely occur here

    total_eighths = 64
    total_dur = swung_time(total_eighths) + 1.0
    buf = np.zeros(int(SR * total_dur) + SR)

    # --- Melody: mellow vibraphone-ish tone (sine + soft triangle) ----
    for pos, note, dur, bar in melody_events():
        f = note_freq(note)
        t_start = swung_time(pos)
        t_end = swung_time(pos + dur)
        d = max(0.05, t_end - t_start) * 0.92
        if f <= 0:
            continue
        vib_env = 0.006 * np.sin(2 * np.pi * 5.5 * _t(d))
        tone = 0.7 * osc_sine(f, d) * (1 + vib_env) + 0.3 * osc_triangle(f, d)
        env = adsr(len(tone), 0.012, 0.08, 0.55, 0.18, sustain_level=0.55)
        mix_into(buf, tone * env, int(t_start * SR), gain=0.55)

    # --- Walking bass: quarter notes outlining chord tones ------------
    rng = np.random.default_rng(7)
    for bar_i, chord in enumerate(CHORDS):
        tones = CHORD_TONES[chord]
        root = CHORD_ROOT[chord]
        # 4 quarter notes per bar = 8 eighths; walk root-5th-octave-3rd-ish
        walk_notes = [root, tones[1], tones[0] if len(tones) > 0 else root, tones[-1]]
        for qi in range(4):
            pos = bar_i * 8 + qi * 2
            t0 = swung_time(pos)
            t1 = swung_time(pos + 2)
            d = (t1 - t0) * 0.85
            note = walk_notes[qi % len(walk_notes)]
            f = note_freq(note) / 2  # drop an octave for a real bass register
            tone = osc_triangle(f, d) * 0.8 + osc_sine(f, d) * 0.2
            env = adsr(len(tone), 0.006, 0.05, 0.5, 0.08, sustain_level=0.5)
            mix_into(buf, tone * env, int(t0 * SR), gain=0.34)

    # --- Comping chords on the "and" of 2 and 4 (soft piano stabs) ----
    for bar_i, chord in enumerate(CHORDS):
        tones = [note_freq(n) for n in CHORD_TONES[chord]]
        for hit_pos in (2.5 * 2, 6.5 * 2):  # placeholder, replaced below
            pass
        for eighth_pos in (3, 7):  # "and of 2", "and of 4" -> eighth idx
            pos = bar_i * 8 + eighth_pos
            t0 = swung_time(pos)
            d = eighth * 1.3
            chord_sig = np.zeros(int(SR * d))
            for f in tones:
                chord_sig = chord_sig + osc_triangle(f, d) * 0.5 + osc_sine(f, d) * 0.5
            env = adsr(len(chord_sig), 0.004, 0.05, 0.0, 0.12, sustain_level=0.0)
            mix_into(buf, chord_sig * env, int(t0 * SR), gain=0.10)

    # --- Brushed hi-hat, swung eighths ---------------------------------
    for pos in range(64):
        t0 = swung_time(pos)
        h = hat(0.045, seed=100 + pos, bright=0.5, decay=45)
        mix_into(buf, h, int(t0 * SR), gain=0.12 if pos % 2 == 0 else 0.07)

    buf = buf[:int(swung_time(64) * SR)]
    buf = normalize(buf, 0.85)
    return buf


# =======================================================================
# LEVEL 3 — UPBEAT ICY WINTER
# =======================================================================

def render_winter():
    bpm = 172
    eighth = 60 / bpm / 2
    total_dur = 64 * eighth + 0.6
    buf = np.zeros(int(SR * total_dur) + SR)

    # --- Melody: bright bell/glockenspiel, doubled an octave up (quiet)
    for pos, note, dur, bar in melody_events():
        f = note_freq(note)
        t0 = pos * eighth
        d = dur * eighth * 0.9
        if f <= 0:
            continue
        bell = (osc_sine(f, d) * 0.55 + osc_sine(f * 2.01, d) * 0.28 +
                osc_sine(f * 3.0, d) * 0.12)
        env = adsr(len(bell), 0.003, 0.14, 0.15, 0.1, sustain_level=0.25)
        mix_into(buf, bell * env, int(t0 * SR), gain=0.5)
        # quiet shimmer an octave up
        shimmer = osc_sine(f * 2, d) * adsr(int(SR * d), 0.003, 0.1, 0.1, 0.08,
                                             sustain_level=0.15)
        mix_into(buf, shimmer, int(t0 * SR), gain=0.14)

    # --- Staccato chord stabs on strong beats (1 and 3 of each bar) ---
    for bar_i, chord in enumerate(CHORDS):
        tones = [note_freq(n) for n in CHORD_TONES[chord]]
        for beat_eighth in (0, 4):
            t0 = (bar_i * 8 + beat_eighth) * eighth
            d = eighth * 0.7
            chord_sig = np.zeros(int(SR * d))
            for f in tones:
                chord_sig = chord_sig + osc_triangle(f, d)
            env = adsr(len(chord_sig), 0.002, 0.06, 0.0, 0.05, sustain_level=0.0)
            mix_into(buf, chord_sig * env, int(t0 * SR), gain=0.09)

    # --- Crisp "frost crunch" shaker on every eighth, jingle on offbeats
    for pos in range(64):
        t0 = pos * eighth
        s = shaker(0.035, seed=200 + pos)
        mix_into(buf, s, int(t0 * SR), gain=0.10)
        if pos % 4 == 2:
            jingle = hat(0.09, seed=300 + pos, bright=1.4, decay=22)
            mix_into(buf, jingle, int(t0 * SR), gain=0.10)

    # --- Sparse wind swells between phrases -----------------------------
    for bar_i in (3, 7):
        t0 = bar_i * 8 * eighth
        d = 2 * eighth
        wind = noise(d, seed=400 + bar_i)
        wind = one_pole_lowpass(wind, 2200)
        wind = one_pole_highpass(wind, 400)
        env = adsr(len(wind), d * 0.4, d * 0.3, 0.4, d * 0.3, sustain_level=0.5)
        mix_into(buf, wind * env, int(t0 * SR), gain=0.06)

    buf = buf[:int(64 * eighth * SR)]
    buf = normalize(buf, 0.88)
    return buf


# =======================================================================
# LEVEL 4 — HELLISH HEAVY ROCK
# =======================================================================

def render_rock():
    bpm = 156
    eighth = 60 / bpm / 2
    total_dur = 64 * eighth + 0.8
    buf = np.zeros(int(SR * total_dur) + SR)

    # --- Melody: distorted lead, doubled an octave below for weight ---
    for pos, note, dur, bar in melody_events():
        f = note_freq(note)
        t0 = pos * eighth
        d = dur * eighth * 0.95
        if f <= 0:
            continue
        lead = soft_clip(osc_saw(f, d) * 1.6 + osc_square(f, d, 0.4) * 0.5, drive=1.8)
        sub = soft_clip(osc_square(f / 2, d, 0.5), drive=1.4) * 0.35
        lead = lead * (0.85 + 0.15 * np.sin(2 * np.pi * 6.5 * _t(d)))
        env = adsr(len(lead), 0.005, 0.05, 0.75, 0.06, sustain_level=0.7)
        mix_into(buf, lead * env, int(t0 * SR), gain=0.34)
        mix_into(buf, sub * env[:len(sub)], int(t0 * SR), gain=0.22)

    # --- Rhythm guitar: distorted power chords, chugging eighths ------
    for bar_i, chord in enumerate(CHORDS):
        root_f = note_freq(CHORD_ROOT[chord])
        fifth_f = root_f * 1.5
        for pos in range(8):
            t0 = (bar_i * 8 + pos) * eighth
            d = eighth * 0.55  # palm-muted, short and punchy
            chug = soft_clip(osc_saw(root_f, d) + osc_saw(fifth_f, d) * 0.85 +
                              osc_square(root_f / 2, d, 0.5) * 0.6, drive=2.2)
            env = adsr(len(chug), 0.002, 0.02, 0.3, 0.05, sustain_level=0.25)
            mix_into(buf, chug * env, int(t0 * SR), gain=0.16)

    # --- Bass: driving eighths on the root, gritty -----------------------
    for bar_i, chord in enumerate(CHORDS):
        root_f = note_freq(CHORD_ROOT[chord]) / 2
        for pos in range(8):
            t0 = (bar_i * 8 + pos) * eighth
            d = eighth * 0.9
            b = soft_clip(osc_square(root_f, d, 0.5), drive=1.3)
            env = adsr(len(b), 0.003, 0.03, 0.6, 0.05, sustain_level=0.55)
            mix_into(buf, b * env, int(t0 * SR), gain=0.24)

    # --- Drums: galloping kick, snare on 2 & 4, driving hats/crash -----
    for bar_i in range(8):
        bar_t0 = bar_i * 8 * eighth
        # gallop kick pattern: 1, "and of 2" (2.5), 3, "and of 4" (4.5) in
        # quarter-note terms -> eighth positions 0, 3, 4, 7
        for kpos in (0, 3, 4, 7):
            mix_into(buf, kick(0.17, seed=bar_i * 10 + kpos),
                     int((bar_t0 + kpos * eighth) * SR), gain=0.55)
        for spos in (2, 6):
            mix_into(buf, snare(0.15, seed=bar_i * 10 + spos, bright=1.2),
                     int((bar_t0 + spos * eighth) * SR), gain=0.5)
        for hpos in range(8):
            mix_into(buf, hat(0.05, seed=bar_i * 20 + hpos, bright=1.3, decay=28),
                     int((bar_t0 + hpos * eighth) * SR), gain=0.14)
        if bar_i % 4 == 0:
            mix_into(buf, crash(0.7, seed=900 + bar_i), int(bar_t0 * SR), gain=0.18)

    buf = buf[:int(64 * eighth * SR)]
    buf = soft_clip(buf, 1.05)
    buf = normalize(buf, 0.92)
    return buf


# =======================================================================
# LEVEL 5 — RELAXED BLUES
# =======================================================================

def render_blues():
    bpm = 88
    eighth = 60 / bpm / 2
    shuffle = 0.68  # heavier shuffle swing

    def swung_time(pos_eighths):
        pair = int(pos_eighths // 1)
        base = (pair // 2) * (2 * eighth)
        if pair % 2 == 0:
            t0 = base
        else:
            t0 = base + eighth * (2 * shuffle)
        return t0

    total_dur = swung_time(64) + 1.4
    buf = np.zeros(int(SR * total_dur) + SR)

    # --- Melody: warm bending guitar/harmonica tone --------------------
    for i, (pos, note, dur, bar) in enumerate(melody_events()):
        f = note_freq(note)
        t0 = swung_time(pos)
        t1 = swung_time(pos + dur)
        d = max(0.08, t1 - t0) * 0.96
        if f <= 0:
            continue
        n = int(SR * d)
        # slight slide up into the note for the first ~9%, blues-style
        slide_len = max(1, int(n * 0.09))
        freq_curve = np.concatenate([
            np.linspace(f * 0.94, f, slide_len),
            np.full(n - slide_len, f),
        ])
        phase = np.cumsum(2 * np.pi * freq_curve / SR)
        tone = 0.6 * np.sin(phase) + 0.4 * (2 * np.abs(2 * ((phase / (2 * np.pi)) % 1) - 1) - 1)
        env = adsr(n, 0.02, 0.12, 0.55, 0.22, sustain_level=0.5)
        mix_into(buf, tone * env, int(t0 * SR), gain=0.5)

    # --- Walking/shuffle bass, warm and round --------------------------
    for bar_i, chord in enumerate(CHORDS):
        tones = CHORD_TONES[chord]
        root = CHORD_ROOT[chord]
        walk = [root, tones[0], tones[1] if len(tones) > 1 else tones[0], tones[0]]
        for qi in range(4):
            pos = bar_i * 8 + qi * 2
            t0 = swung_time(pos)
            t1 = swung_time(pos + 2)
            d = (t1 - t0) * 0.88
            f = note_freq(walk[qi % len(walk)]) / 2
            tone = osc_sine(f, d) * 0.6 + osc_triangle(f, d) * 0.4
            env = adsr(len(tone), 0.01, 0.08, 0.5, 0.12, sustain_level=0.5)
            mix_into(buf, tone * env, int(t0 * SR), gain=0.3)

    # --- Soft electric-piano-ish comping on the off-beat ---------------
    for bar_i, chord in enumerate(CHORDS):
        tones = [note_freq(n) for n in CHORD_TONES[chord]]
        for eighth_pos in (1, 5):
            pos = bar_i * 8 + eighth_pos
            t0 = swung_time(pos)
            d = eighth * 1.6
            chord_sig = np.zeros(int(SR * d))
            for f in tones:
                chord_sig = chord_sig + osc_sine(f, d) * 0.6 + osc_triangle(f, d) * 0.4
            env = adsr(len(chord_sig), 0.02, 0.15, 0.2, 0.3, sustain_level=0.25)
            mix_into(buf, chord_sig * env, int(t0 * SR), gain=0.08)

    # --- Brushed shuffle percussion: soft hats + gentle backbeat -------
    for pos in range(64):
        t0 = swung_time(pos)
        h = hat(0.06, seed=500 + pos, bright=0.35, decay=22)
        mix_into(buf, h, int(t0 * SR), gain=0.06)
    for bar_i in range(8):
        for spos in (2, 6):
            t0 = swung_time(bar_i * 8 + spos)
            s = snare(0.16, seed=600 + bar_i * 8 + spos, bright=0.4)
            mix_into(buf, s, int(t0 * SR), gain=0.16)

    buf = buf[:int(swung_time(64) * SR)]
    # gentle slap-back delay for warmth/space
    buf = simple_delay(buf, 0.09, feedback=0.18, mix=0.16)
    buf = normalize(buf, 0.8)
    return buf


# ---------------------------------------------------------------------

if __name__ == '__main__':
    import time
    jobs = [
        ('music_level2.wav', render_jazz, 'jazz (level 2)'),
        ('music_level3.wav', render_winter, 'icy winter (level 3)'),
        ('music_level4.wav', render_rock, 'heavy rock (level 4)'),
        ('music_level5.wav', render_blues, 'blues (level 5)'),
    ]
    for fname, fn, label in jobs:
        t0 = time.time()
        buf = fn()
        write_wav(fname, buf)
        dur = len(buf) / SR
        print(f"{fname}: {label} -- {dur:.2f}s, rms={np.sqrt(np.mean(buf**2)):.3f}, "
              f"took {time.time()-t0:.1f}s")
