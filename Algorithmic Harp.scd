// ---------------------------------- //
// Jonathan Coon
// Algorithmic Harp assignment (A4)
// MUSC 9 - Intro to Electronic Music
// ---------------------------------- //

// -----------------
// SYNTH DEFINITION
// -----------------

(
SynthDef("plucking", {arg amp = 0.1, freq = 440, decay = 5, coef = 0.1;
	var env, snd;
	env = EnvGen.kr(Env.linen(0, decay, 0), doneAction: 2);
	snd = Pluck.ar(
		in: WhiteNoise.ar(amp),
		trig: Impulse.kr(0),
		maxdelaytime: 0.1,
		delaytime: freq.reciprocal,
		decaytime: decay,
		coef: coef);
	Out.ar(0, [snd, snd]);
}).add;
)

// -----------
// ARRANGEMENT
// -----------

(
Pseq(
	[
		~twinkle,
		Ppar([~drone1, ~drone2], 1),
		Ppar([~drone1, ~drone2, ~accent], 1),
		Ppar([~drone1, ~drone2, ~accent, ~high1, ~high2], 1),
		~romanianMinor,
		~melody,
		Pn(a, 16),
		Ppar([Pn(a, 4), b], 2),
		Ppar([Pn(a, 4), b, c], 1),
		Ppar([Pn(a, 4), d], 2),
		d,
		Ppar([d, Pn(e, 4)], 1),
		Pn(f, 4),
		Ppar([f, g], 4),
		Ppar([Pn(a, 4), b], 2),
		d,
		Ppar([d, Pn(e, 4)], 1),
		Pn(f, 4),
		Ppar([f, g], 4),
		Ppar([Pn(a, 4), b], 4),
		~mixolydian,
		~spanish,
		~egyptian2,
		~egyptian1,
		~egyptian3,
		~egyptian1,
		~freq1,
		Ppar([~freq1, ~siren2], 1),
		~freq3,
		Ppar([~freq2, ~siren3], 1),
		Ppar([~drone1, ~drone2, ~up, ~down], 1),
		~twinkle
	]
).play;
)

// ---------------
// PLUCK PATTERNS
// ---------------

// Twinkle
(
~twinkle = Pbind(
	\instrument, "plucking",
	\scale, Scale.major,
	\degree, Pwhite(0,12),
	\ctranspose, 36,
	\amp, Pwhite(0.5, 0.9),
	\decay, Pwhite(7, 12),
	\coef, Pwhite(0.01, 0.1),
	\dur, Prand([3/16, 3/8, 1/8, 1/16], 50);
);
)

// Drones
(
~drone1 = Pbind(
	\instrument, "plucking",
	\degree, 0,
	\ctranspose, -36,
	\amp, Pseq([Pseries(0.1,0.1,9), Pseries(0.9,-0.1,9)], 4),
	\decay, Pseq([7, 6, 6, 5, 4, 3], inf),
	\coef, Pseq([Pseries(0.1,0.1,9), Pseries(0.9,-0.1,9)], 4),
	\dur, 1/8
);

~drone2 = Pbind(
	\instrument, "plucking",
	\degree, 0,
	\ctranspose, -24,
	\amp, Pseq([Pseries(0.1,0.1,9), Pseries(0.9,-0.1,9)], 4),
	\decay, Pseq([7, 6, 6, 5, 4, 3], inf),
	\coef, Pseq([Pseries(0.1,0.1,9), Pseries(0.9,-0.1,9)], 4),
	\dur, 1/8
);
)

// Accent
(
~accent = Pbind(
	\instrument, "plucking",
	\degree, 0,
	\ctranspose, -12,
	\amp, 0.5,
	\decay, 1,
	\coef, 0.1,
	\dur, Pseq([3/8, 3/8, 1.25], 5)
);
)

// Highs
(
~high1 = Pbind(
	\instrument, "plucking",
	\degree, 0,
	\ctranspose, 36,
	\amp, Pseq([Pseries(0.7,0.1,3), Pseries(0.9,-0.1,3)], 12),
	\decay, 12,
	\coef, Pseq([Pseries(0.1,0.1,3), Pseries(0.9,-0.1,3)], 12),
	\dur, 1/8
);

~high2 = Pbind(
	\instrument, "plucking",
	\degree, 0,
	\ctranspose, 24,
	\amp, Pseq([Pseries(0.7,0.1,3), Pseries(0.9,-0.1,3)], 12),
	\decay, 12,
	\coef, Pseq([Pseries(0.1,0.1,3), Pseries(0.9,-0.1,3)], 12),
	\dur, 1/8
);
)

// Romanian Minor Scale
(
~romanianMinor = Pbind(
	\instrument, "plucking",
	\scale, Scale.romanianMinor, // choose any scale
	\degree, Pwhite(0, 15), // think of 'white notes' of piano keyboard (0 = middle C)
	\amp, Pwhite(0.3, 0.7),
	\decay, Pwhite(7, 12),
	\coef, Pwhite(0.01, 0.1),
	\dur, Prand([0.1, 0.2, 0.4, 0.27, 0.13, 0.38], 50)
);
)

// Melody
(
~melody = Pbind(
	\instrument, "plucking",
	\degree, Pwhite(0,5),
	\ctranspose, -12,
	\amp, 0.5,
	\decay, 5,
	\coef, 0.1,
	\dur, Pseq([3/8, 3/8, 1, 1/16, 1/16, 1/16], 5),
);
)

// Diddle
(
a = Pbind(
	\instrument, "plucking",
	\scale, Scale.major,
	\degree, 0,
	\ctranspose, -12,
	\amp, 0.5,
	\decay, 10,
	\coef, 0.3,
	\dur, Pseq([1/2], 1)
);
)

(
b = Pbind(
	\instrument, "plucking",
	\scale, Scale.major,
	\degree, 2,
	\ctranspose, -12,
	\amp, 0.5,
	\decay, 10,
	\coef, 0.3,
	\dur, Pseq([1/4], 8)
);
)

(
c = Pbind(
	\instrument, "plucking",
	\scale, Scale.major,
	\degree, 3,
	\ctranspose, -12,
	\amp, 0.5,
	\decay, 10,
	\coef, 0.3,
	\dur, Pseq([1/16], 16)
);
)

(
d = Pbind(
	\instrument, "plucking",
	\scale, Scale.major,
	\degree, -2,
	\ctranspose, -12,
	\amp, 0.5,
	\decay, 10,
	\coef, 0.3,
	\dur, Pseq([3/8], 5)
);
)

(
e = Pbind(
	\instrument, "plucking",
	\scale, Scale.minor,
	\degree, -2,
	\ctranspose, -12,
	\amp, 0.5,
	\decay, 10,
	\coef, 0.3,
	\dur, Pseq([1/4], 2)
);
)

(
f = Pbind(
	\instrument, "plucking",
	\scale, Scale.major,
	\degree, -1,
	\ctranspose, -12,
	\amp, 0.5,
	\decay, 10,
	\coef, 0.3,
	\dur, Pseq([1/4], 2),
);
)

(
g = Pbind(
	\instrument, "plucking",
	\scale, Scale.major,
	\degree, -3,
	\ctranspose, -12,
	\amp, 0.5,
	\decay, 10,
	\coef, 0.3,
	\dur, Pseq([1/2], 2),
);
)

// Mixolydian
(
~mixolydian = Pbind(
	\instrument, "plucking",
	\scale, Scale.mixolydian,
	\degree, Pwhite(0, 15),
	\ctranspose, 0,
	\amp,0.8,
	\decay, 15,
	\coef, 0.4,
	\dur, Pseq([1/8], 128),
);
)

// Spanish
(
~spanish = Pbind(
	\instrument, "plucking",
	\scale, Scale.spanish,
	\degree, Pseq([Pwhite([-7, -3, 1, 5], [-4, 0, 4, 8]), Pwhite([5, 1, -3, -7], [8, 4, 0, -4])], inf),
	\ctranspose, 12,
	\strum, 0.03,
	\amp,0.5,
	\decay, 4,
	\coef, 0.2,
	\dur, Pseq([3/4, 1/4, 1/2, 1/2], 3),
);
)

// Egyptian
(
~egyptian1 = Pbind(
	\instrument, "plucking",
	\scale, Scale.egyptian,
	\degree, Pseq([Pwhite([-7, -3, 1, 5], [-4, 0, 4, 8]), Pwhite([5, 1, -3, -7], [8, 4, 0, -4])], inf),
	\ctranspose, 12,
	\strum, 0.04,
	\amp,0.7,
	\decay, 20,
	\coef, 0.25,
	\dur, Pseq([Pn(1/8, 32), Pn(8, 1), Pn(2, 4), Pn(1, 4)], 1),
);
)

(
~egyptian2 = Pbind(
	\instrument, "plucking",
	\scale, Scale.egyptian,
	\degree, Pseq([Pwhite([-7, -3, 1, 5], [-4, 0, 4, 8]), Pwhite([5, 1, -3, -7], [8, 4, 0, -4])], inf),
	\ctranspose, 12,
	\strum, 0.06,
	\amp,0.7,
	\decay, 10,
	\coef, 0.25,
	\dur, Pn(1/4, 32),
);
)

(
~egyptian3 = Pbind(
	\instrument, "plucking",
	\scale, Scale.egyptian,
	\degree, Pseq([Pwhite([-7, -3, 1, 5], [-4, 0, 4, 8]), Pwhite([5, 1, -3, -7], [8, 4, 0, -4])], inf),
	\ctranspose, 12,
	\strum, 0.02,
	\amp,0.9,
	\decay, 4,
	\coef, 0.8,
	\dur, Pn(1/8, 32),
);
)

// Freq1
(
~freq1 = Pbind(
	\instrument, "plucking",
	\freq, Pwhite(0, 880),
	\amp, 0.5,
	\decay, 50,
	\coef, 0.1,
	\dur, Pseq([Prand([0.51, 0.1, 0.1], 4), Pwhite(0, 4, 4), Pwhite(0, 1, 4)], 2)
);
)

// Freq2
(
~freq2 = Pbind(
	\instrument, "plucking",
	\freq, Pwhite(0, 880),
	\amp, 0.5,
	\decay, 50,
	\coef, 0.1,
	\dur, Pwrand([Prand([0.51, 0.1, 0.1], 4), Pwhite(0, 4, 8), Pwhite(0, 1, 4)], [0.9, 0.05, 0.05] , 4)
);
)

// Freq3
(
~freq3 = Pbind(
	\instrument, "plucking",
	\freq, Pwhite(0, 880),
	\amp, 0.5,
	\decay, 50,
	\coef, 0.1,
	\dur, Pwrand([Prand([0.51, 0.1, 0.1], 4), Pwhite(0, 4, 1), Pwhite(0, 1, 1)], [0.5, 0.25, 0.25] , 10)
);
)

// Siren1
(
~siren1 = Pbind(
	\instrument, "plucking",
	\degree, 0,
	\ctranspose, Pseq([Pseries(24, 0.1, 100), Pseries(34, -0.1, 100)], 1),
	\amp, 0.5,
	\decay, 20,
	\coef, 0.1,
	\dur, 0.04
);
)

// Siren2
(
~siren2 = Pbind(
	\instrument, "plucking",
	\freq, Pseq([Pseries(600, 4, 100), Pseries(1000, -4, 100)], 1),
	\amp, 0.5,
	\decay, 10,
	\coef, 0.1,
	\dur, 0.04
);
)

// Siren3
(
~siren3 = Pbind(
	\instrument, "plucking",
	\freq, Pseq([Pseries(600, 4, 100), Pseries(1000, -4, 100)], 1),
	\amp, 0.5,
	\decay, 3,
	\coef, 0,
	\dur, 0.04
);
)

// Ending
(
~up = Pbind(
	\instrument, "plucking",
	\degree, 0,
	\ctranspose, Pseries(24, 0.1),
	\amp, Pseq([Pseries(0.7,0.1,3), Pseries(0.9,-0.1,3)], 24),
	\decay, 1,
	\coef, Pseq([Pseries(0.1,0.1,3), Pseries(0.9,-0.1,3)], 24),
	\dur, 1/16
);

~down = Pbind(
	\instrument, "plucking",
	\degree, 0,
	\ctranspose, Pseries(24, -1),
	\amp, Pseq([Pseries(0.7,0.1,1), Pseries(0.9,-0.1,1)], 64),
	\decay, 1,
	\coef, Pseq([Pseries(0.1,0.1,1), Pseries(0.9,-0.1,1)], 64),
	\dur, 1/16
);
)

// Melodic Minor Chords
(
Pbind(
	\instrument, "plucking",
	\scale, Scale.melodicMinor,
	\degree, Prand([
		[0, 2, 4, 6],
		[0, 2, 4, 5],
		[-4, 1, 5, 7]
	], inf),
	\amp, Pwhite(0.1, 0.2),
	\decay, Pwhite(2, 4),
	\coef, Pseq([0.2, 0.3, 0.4], inf),
	\dur, Pwrand([1/4, 1/8, 3/16], [0.8, 0.1, 0.1], inf)
).play;
)