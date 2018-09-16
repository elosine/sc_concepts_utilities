(
SynthDef('snaredrum', {

var drumosc, filterenv, volenv, drumoutput, snaposc, snapenv, fulloutput;

drumosc = {Pulse.ar(100)};
filterenv = {Line.ar(1, 0, 0.2, doneAction: 0)};
volenv = {Line.ar(1, 0, 0.6, doneAction: 2)};
drumoutput = {LPF.ar(drumosc,(filterenv *1000) + 30)};

snaposc = {BPF.ar(HPF.ar(WhiteNoise.ar(1),500),1500)};
snapenv = {Line.ar(1, 0, 0.2, doneAction: 0)};

fulloutput = (drumoutput * volenv) + (snaposc * snapenv);
//fulloutput = (drumoutput * volenv);

Out.ar(0,
Pan2.ar(fulloutput, 0)
)

}).send(s);
)

t = Synth('snaredrum');





(
SynthDef(\neurosnare, {
    var snd;
    // a percussive click to give it some attack
    snd = LPF.ar(HPF.ar(WhiteNoise.ar, 300), 8000) * Env.linen(0.001, 0.01, 0.001).ar;
    // sine sweep body. very important!
    snd = snd + (SinOsc.ar(Env([400, 196, 160], [0.04, 0.2], \exp).ar) * Env.perc(0.04, 0.2).ar * 6.dbamp).tanh;
    // sound of snare coils rattling
    snd = snd + (HPF.ar(BPeakEQ.ar(WhiteNoise.ar, 4000, 0.5, 3), 300) * Env.perc(0.05, 0.2).delay(0.01).ar(2) * -3.dbamp);
    // another sound sweep to improve the attack, optional
    snd = snd + (SinOsc.ar(XLine.kr(3000, 1500, 0.01)) * Env.perc(0.001, 0.02).ar);
    // distortion helps glue everything together and acts as a compressor
    snd = (snd * 1.4).tanh;
    snd = Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1));
    Out.ar(\out.kr(0), snd);
}).add;
)

Synth(\neurosnare, [amp: 0.4]);


(
SynthDef(\kick, {
    |out = 0, pan = 0, amp = 0.3|
    var body, bodyFreq, bodyAmp;
    var pop, popFreq, popAmp;
    var click, clickAmp;
    var snd;

    // body starts midrange, quickly drops down to low freqs, and trails off
    bodyFreq = EnvGen.ar(Env([261, 120, 51], [0.035, 0.08], curve: \exp));
    bodyAmp = EnvGen.ar(Env.linen(0.005, 0.1, 0.3), doneAction: 2);
    body = SinOsc.ar(bodyFreq) * bodyAmp;
    // pop sweeps over the midrange
    popFreq = XLine.kr(750, 261, 0.02);
    popAmp = EnvGen.ar(Env.linen(0.001, 0.02, 0.001)) * 0.15;
    pop = SinOsc.ar(popFreq) * popAmp;
    // click is spectrally rich, covering the high-freq range
    // you can use Formant, FM, noise, whatever
    clickAmp = EnvGen.ar(Env.perc(0.001, 0.01)) * 0.15;
    click = LPF.ar(Formant.ar(910, 4760, 2110), 3140) * clickAmp;

    snd = body + pop + click;
    snd = snd.tanh;

    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;

SynthDef(\snare, {
    |out = 0, pan = 0, amp = 0.3|
    var pop, popAmp, popFreq;
    var noise, noiseAmp;
    var snd;

    // pop makes a click coming from very high frequencies
    // slowing down a little and stopping in mid-to-low
    popFreq = EnvGen.ar(Env([3261, 410, 160], [0.005, 0.01], curve: \exp));
    popAmp = EnvGen.ar(Env.perc(0.001, 0.11)) * 0.7;
    pop = SinOsc.ar(popFreq) * popAmp;
    // bandpass-filtered white noise
    noiseAmp = EnvGen.ar(Env.perc(0.001, 0.15), doneAction: 2);
    noise = BPF.ar(WhiteNoise.ar, 810, 1.6) * noiseAmp;

    snd = (pop + noise) * 1.3;

    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;

SynthDef(\hihat, {
    |out = 0, pan = 0, amp = 0.3|
    var click, clickAmp;
    var noise, noiseAmp;
    var snd;

    // noise -> resonance -> expodec envelope
    noiseAmp = EnvGen.ar(Env.perc(0.001, 0.3, curve: -8), doneAction: 2);
    noise = Mix(BPF.ar(ClipNoise.ar, [4010, 4151], [0.15, 0.56], [1.0, 0.6])) * 0.7 * noiseAmp;

    snd = noise;

    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;

// adapted from a post by Neil Cosgrove (other three are original)
SynthDef(\clap, {
    |out = 0, amp = 0.5, pan = 0, dur = 1|
    var env1, env2, snd, noise1, noise2;

    // noise 1 - 4 short repeats
    env1 = EnvGen.ar(
        Env.new(
            [0, 1, 0, 0.9, 0, 0.7, 0, 0.5, 0],
            [0.001, 0.009, 0, 0.008, 0, 0.01, 0, 0.03],
            [0, -3, 0, -3, 0, -3, 0, -4]
        )
    );

    noise1 = WhiteNoise.ar(env1);
    noise1 = HPF.ar(noise1, 600);
    noise1 = LPF.ar(noise1, XLine.kr(7200, 4000, 0.03));
    noise1 = BPF.ar(noise1, 1620, 3);

    // noise 2 - 1 longer single
    env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.18], [0, -4]), doneAction:2);

    noise2 = WhiteNoise.ar(env2);
    noise2 = HPF.ar(noise2, 1000);
    noise2 = LPF.ar(noise2, 7600);
    noise2 = BPF.ar(noise2, 1230, 0.7, 0.7);

    snd = noise1 + noise2;
    snd = snd * 2;
    snd = snd.softclip;

    Out.ar(out, Pan2.ar(snd,pan,amp));
}).add;
)

(
var base;

base = Pbind(\amp, 0.3);

Ppar([
    Pbindf(
        base,
        \instrument, Pseq([\kick, \snare, \kick, \kick, \snare], inf),
        \dur, Pseq([4, 3, 3, 2, 4], inf)
    ),
    Pbindf(
        base,
        \instrument, Pseq([Pn(\hihat, 16), Pn(\clap, 16)], inf),
        \dur, Pseq([Rest(2), 2, Rest(2), 2], inf)
    )
]).play(TempoClock(2.3 * 4));
)



(
// Basic drum kit

SynthDef("hihat", {arg out = 0, amp = 0.5, att = 0.01, rel = 0.2, ffreq = 6000, pan = 0;
	var env, snd;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd = WhiteNoise.ar;
	snd = HPF.ar(in: snd, freq: ffreq, mul: env);
	Out.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef("snare", {arg out = 0, amp = 0.1, sinfreq = 180, att = 0.01, rel = 0.2, ffreq = 2000, pan = 0;
	var env, snd1, snd2, sum;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd1 = HPF.ar(
		in: WhiteNoise.ar,
		freq: ffreq,
		mul: env
	);
	snd2 = SinOsc.ar(freq: sinfreq, mul: env);
	sum = snd1 + snd2;
	Out.ar(out, Pan2.ar(sum, pan));
}).add;

SynthDef("kick", {arg out = 0, amp = 0.3, sinfreq = 60, glissf = 0.9, att = 0.01, rel = 0.45, pan = 0;
	var env, snd, ramp;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	ramp = XLine.kr(
		start: sinfreq,
		end: sinfreq * glissf,
		dur: rel
	);
	snd = SinOsc.ar(freq: ramp, mul: env);
	snd = Pan2.ar(snd, pan);
	Out.ar(out, snd);
}).add;

// Basic saw synth for chords and bass
SynthDef("sawSynth", { arg freq = 440, amp = 0.1, att = 0.1, rel = 2, lofreq = 1000, hifreq = 3000;
    var env, snd;
    env = Env.perc(
		attackTime: att,
		releaseTime: rel,
		level: amp
	).kr(doneAction: 2);
    snd = Saw.ar(freq: freq * [0.99, 1, 1.001, 1.008], mul: env);
	snd = LPF.ar(
		in: snd,
		freq: LFNoise2.kr(1).range(lofreq, hifreq)
	);
    snd = Splay.ar(snd);
    Out.ar(0, snd);
}).add;
)



// Example
(
Pbind(
	\instrument, "hihat",
	\dur, Pseq([Rest(1/4), 1/4], inf),
	\att, 0.01,
	\rel, 0.1,
	\ffreq, 11000,
	\pan, 0,
	\amp, 0.3
).play;

Pbind(
	\instrument, "snare",
	\dur, Pseq([Rest(1/2), 1/2], inf),
	\att, 0.01,
	\rel, 0.1,
	\sinfreq, 180,
	\ffreq, 2000,
	\amp, 0.25

).play;

Pbind(
	\instrument, "kick",
	\dur, 1/2,
	\att, 0.01,
	\rel, 0.22,
	\sinfreq, 60,
	\glissf, 0.9,
	\amp, 1,
).play;

Pbind(
    \instrument, "sawSynth",
    \midinote, Pseq([
        [50, 53, 55, 57],
        [53, 56, 58, 60],
		Prand([
			[56, 59, 61, 63],
            [49, 52, 54, 56],
		], 1)
		],
        inf
    ),
    \dur, Prand([1, 3, 4, 4.5], inf),
	\att, 0.1,
	\rel, Pkey(\dur) + 1,
	\hifreq, 5000,
    \amp, 0.2
).play;

Pbind(
	\instrument, "sawSynth",
	\midinote, Pseq([36, 32, 32, 37], inf),
	\dur, Pseq([1/4, 1/4, 1/2, Rest(3), 1/4], inf),
	\ctranspose, [0, -12],
	\att, 0.01,
	\rel, 0.2,
	\amp, 0.4,
	\lofreq, 100,
	\hifreq, 1000
).play;
)


s.boot;

/*******************************************
TUNING AND TIMBRE
asStream, 11/27/2015
Explores the theory of William Sethares on
the relationship between tuning and timbre.
See http://sethares.engr.wisc.edu/consemi.html
USAGE:
  1. Boot server
  2. Exectute SynthDef block
  3. Execute environment variable block
  4. Execute main block
********************************************/

(
/* SYNTHS
timbreTest has five partials and a simple percussive envelope. The tuningFactor
parameter controls the frequency of the partials. A value of 2 corresponds
to "standard" harmonic partials. Values greater than 2 result in a stretched
spectrum, values less than 2 result in a compressed spectrum. SendReply sends
an OSC message from the server to the client on NoteOn. These messages are
used for the visualization.
kraftySnr and kik taken from hjh's patterns tutorial */

SynthDef(\timbreTest, {|freq=220, amp=0.1, attack=0.03, sustain=0.1, tuningFactor=2, pan=0, id=0, out=0|
	var partials = #[
		0,                     //log2 1
		1,                     //log2 2
		1.5849625007211563,    //log2 3
		2,                     //log2 4
		2.321928094887362,     //log2 5
	];
	var sig = Array.fill(5, { |i|
		SinOsc.ar(tuningFactor ** partials[i] * freq, i*pi/4, 1/(i+1))
	}).sum;
	var env = EnvGen.kr(Env.perc(attack, sustain, amp), doneAction: 2);
	SendReply.kr(Impulse.kr(0), '/tr', [freq, amp, sustain, pan], id);
	Out.ar(out, LPF.ar(Pan2.ar(sig*env, pan), 2000));
}).add;

SynthDef(\kraftySnr, { |amp = 1, freq = 2000, rq = 3, decay = 0.1, pan, out|
    var sig = BrownNoise.ar(amp);
	var env1 = EnvGen.kr(Env.perc(0.002, decay), doneAction: 0);
	var env2 = EnvGen.kr(Env.perc(0.02, decay*2,0.25), doneAction: 2);
    sig = BPF.ar(sig, freq, rq, env1+env2);
    Out.ar(out, Pan2.ar(sig, pan))
}).add;

a = Synth(\kraftySnr);

SynthDef(\kik, { |basefreq = 50, ratio = 7, sweeptime = 0.05, preamp = 1, amp = 1,
        decay1 = 0.3, decay1L = 0.8, decay2 = 0.15, out|
    var    fcurve = EnvGen.kr(Env([basefreq * ratio, basefreq], [sweeptime], \exp)),
        env = EnvGen.kr(Env([1, decay1L, 0], [decay1, decay2], -4), doneAction: 2),
        sig = SinOsc.ar(fcurve, 0.5pi, preamp).distort * env * amp;
    Out.ar(out, sig ! 2)
}).add;

//Simple reverb
SynthDef(\reverber, {|in=16, out=0, wet=0.33|
	var sig = In.ar(in, 2);
	Out.ar(out, FreeVerb2.ar(sig[0], sig[1], wet, room:0.5));
}).add;

//Simple delay
SynthDef(\delay, {|in=18, out=16, delayTime=0.0625, decayTime=0.25, wet=0.5|
	var sig = In.ar(in,2);
	Out.ar(out, AllpassC.ar(sig, delayTime, delayTime, decayTime, add:sig));
}).add;

)

(
~root = 205;
~chord = [1, 1.5, 2.5].collect({|item| item.log2});
~scale = [1, 1.25, 1.5, 2, 2.25, 2.5, 3].collect({|item| item.log2 });
~logHarmonics = [1, 2, 3, 4, 5].collect({|item| item.log2 });
~tuningFactor = 2.001;

~width = 1280;
~height = 720;

~colorValues = (               //Colors from http://www.swisscolors.net/
	background: "e0e5da",
	chord: "00aabb",
	splotch: "f43530",
	harmonics: "46454b"
);

~colors = ~colorValues.collect({|item| Color.fromHexString(item)});
)

(
var p,q,r,t,u;                //patterns
var o;                        //OSCresponder
var w,v,label;                //window, view, text label
var noteEvents, chordEvent;   //event logs for visualization
var tuningFactor = ~tuningFactor;

Ndef(\lfo, {SinOsc.kr(1/75, 0, 0.2, 2)});   //controls tuningFactor

Synth(\reverber, [wet: 0.20]);
Synth(\delay);

/* VISUALIZATION
OSCFunc captures data sent by the \timbreTest synth and stores it in
chordEvent and noteEvents. This data is accessed by the visualization code
contained in v.drawFunc. chordEvent responds to the amplitude of each chord
(pattern p). noteEvents contains information from pattern r and stores it in
a stack where index 0 is the most recent event(s) and index 29 is the least
recent. */

chordEvent = 1;
noteEvents = Array.fill(30, { Bag.new });
o=OSCFunc({|m| switch( m[2],
	1, { chordEvent = chordEvent + m[4].explin(0.04, 0.16, 1, 32) },
	2, { noteEvents[0].add([m[3], m[4], m[5], m[6]])}
)}, '/tr');

w = Window(bounds: Rect(0, 0, ~width, ~height));
v = UserView(w, w.view.bounds);

v.animate = true;
v.background = ~colors['background'];
label = StaticText(v, Rect(40, 15, 400, 50));
label.font = Font("Helvetica", 48, true);
label.stringColor = ~colors['harmonics'];

v.drawFunc = {
	var freqs;

	//Get current value of tuningFactor
	Ndef(\lfo).asBus.get({|value| tuningFactor=value});

	label.string = "A = " ++ ~tuningFactor.asStringPrec(4).padRight(5,"0");

	//Calculate harmonic positions using current value of tuningFactor
	freqs = ~logHarmonics.collect({|item| tuningFactor ** item * ~root});

	//Draw grid lines
	freqs.do({|item,i|
		//Fixed grid lines
		Pen.strokeColor = ~colors['harmonics'];
		Pen.width = 1;
		Pen.moveTo(0@(i+1*~root).explin(180, 1700, ~height, 0));
		Pen.lineTo(~width@(i+1*~root).explin(180, 1700, ~height, 0));
		Pen.stroke;

		//Moving grid lines - line width mapped to chordEvent
		Pen.width = 1;
		Pen.strokeColor = ~colors['chord'];
		Pen.moveTo(0@item.explin(180,1700,~height,0));
		Pen.lineTo(~width@item.explin(180, 1700, ~height, 0));
		Pen.stroke;
		Pen.strokeColor = ~colors['chord'];
		Pen.width = chordEvent;
		4.do({|j|
			Pen.moveTo(2*j+0.5/8 * ~width@item.explin(180,1700,~height,0));
			Pen.lineTo(2*j+1.5/8 * ~width@item.explin(180,1700,~height,0));
			Pen.stroke;
		});
	});

	//Draw splotches - freq --> y, pan --> x, amp --> size; time --> alpha and size
	noteEvents.do{ |item, i|
		Pen.fillColor = ~colors['splotch'];
		Pen.alpha = (30-i).linexp(1,27,0.01,1);
		item.do{ |subItem|
			Pen.fillOval(Rect.aboutPoint(
				subItem[3].linlin(-1,1,0,~width) @ subItem[0].explin(180, 1800, ~height, 0),
				subItem[1].explin(0.002,0.3, 3, 60)*(30-i).linlin(1,27,0.3,1),
				subItem[1].explin(0.002,0.3, 3, 60)*(30-i).linlin(1,27,0.3,1)));
		};
	};

	//Increment chordEvent and noteEvents
	if ( chordEvent <= 2, { chordEvent = 1 }, { chordEvent = chordEvent*0.985 } );
	noteEvents = noteEvents.shift(1, Bag.new);
};
w.front;

/* PATTERNS
Pattern p plays the chords. Use timingOffset to create rhythmic "strum."
Pattern q plays the melody. Notes are played in pairs and through
Pstutter for additional coolness. Patterns t and u are the drum parts.*/
p=Pbind(
	\freq, Pfunc({~tuningFactor ** ~chord * ~root}),
	\sustain, Pseq([8,4],inf),
	\dur, Pseq([2.25,3.75], inf),
	\tuningFactor, Pfunc({~tuningFactor}),
	\instrument, \timbreTest,
	\amp, Pseq([0.10, 0.05], inf)*[2,1,0.5],
	\attack, 0.07,
	\id, 1,
	\out, 16,
	\timingOffset, Ptuple([0,Pseq([1,1.125],inf),1.125],inf)
);

q=Pbind(
	\octave, Pstutter(Pwhite(2,10), Pfunc({ [1,~tuningFactor].choose })),
	\freq, Pfunc({(~tuningFactor ** [~scale.choose,~scale.choose] * ~root)})*Pkey(\octave),
	//\sustain, Pwrand([0.25,0.5,1],[0.5,0.25,0.25], inf),
	\dur, Pwrand([0.25,0.5,1,2,4],[5,4,3,2,1].normalizeSum,inf)*0.25,
	\legato, Prand([1,2],inf),
	\tuningFactor, Pfunc({~tuningFactor}),
	\attack, 0.025,
	\amp, Ptuple([Pexprand(0.002, 0.3), Pwrand([0,Pexprand(0.002, 0.3)],[0.75,0.25],inf)], inf),
	\pan, Ptuple([Pwhite(-0.7,0.7, inf), Pwhite(-0.7,0.7, inf)]),
	\id, 2,
	\timingOffset, Ptuple([0,Pwhite(0,0.02)],inf),
	\out, 16,
	\instrument, \timbreTest,
);

r = Pstutter(Pwrand([1,3,5],[0.9, 0.05, 0.05], inf), q);  //Only stutter 10% of the time

t = Pbind(
	\instrument, \kraftySnr,
	\decay, Pwhite(0.04,0.08, inf),
	\dur, 0.125,
	\rq, Pbrown(0.3, 1, 0.05),
	\freq, Pbrown(6000, 9000, 200),
	\amp, Pseq([0.2, 0.05, 0.03, 0.015, 0.04, 0.02], inf) * 18 * Pexprand(0.5,1.5),
	\pan, Pbrown(-0.3, 0.3, 0.1, inf),
	\out, Pwrand([16,18],[0.67,0.33],inf),
);

u = Pbind(
	\instrument, \kik,
	\dur, Pseq([1, 0.5,0.125,0.875, 0.5],inf),
	\amp, Pseq([0.5, 0.25, 0.5, 0.25, 0.15], inf),
	\baseFreq, [70,75],
);

/* PLAY
We vary tuningFactor sinusoidally and grab a value every six seconds (two
strums). Ptpar starts the patterns. We use a 0.1s delay on all patterns to
make sure tuningFactor is set before the strum. There's probably a more
elegant way to do this. */
Routine({
	~tuningFactor=tuningFactor;
	Ptpar([6.1,p,6.1,r, 0.6, t, 0.1, u]).play(TempoClock.default);
	inf.do({
		6.wait;
		~tuningFactor=tuningFactor;
	});
}).play;
)


(// 1st
SynthDef(\perc1, {
	arg freq=100, dec1 = 2, dec2 = 4, gain = 250, ground = 0;
	var src, rnd, env, free;
	free = EnvGen.ar(Env.sine(dec2),doneAction:2);
	rnd = {arg rt,low,high; LFNoise2.ar(rt).range(low,high)};
	env = {arg dec; Decay.ar(Impulse.ar(0),dec!2,1-ground)+ground};
	src = GrainSin.ar(
		2, Dust.ar(freq*env.(dec1)), // Channels & Trig
		rnd.(2,0.00005,0.0005), // Grain Duration
		rnd.(dec2,freq/4,freq*8), // Grain Freq
		0,-1,1024,0.1 // Pan, Env, MaxGrain, Mul
	);
	src = src*env.(dec2)*gain;
	src = LPF.ar(src.fold(-0.5,0.5),10000,0.25);
	src = HPF.ar(src,100);
	Out.ar(0,src);
}).store
)
(// 2nd
SynthDef(\perc1, {
	arg freq=100, dec1 = 2, dec2 = 4, gain = 250, ground=0, gDur = 0.0005, pitchE = 1;
	var src, rnd, env, free, mod;
	free = EnvGen.ar(Env.sine(dec2),doneAction:2);
	rnd = {arg rt,low,high; LFNoise2.ar(rt!2).range(low,high)};
	env = {arg dec; Decay.ar(Impulse.ar(0),dec!2,1-ground)+ground};
	//mod = Splay.arFill(8, {Pulse.ar(rrand(freq,freq*4)*(env.(dec1)*pitchE))})*env.(dec2);
	//mod = Splay.arFill(8, {Blip.ar(rrand(freq,freq*4)*(env.(dec1)*pitchE),100)})*env.(dec2);
	//mod = Splay.arFill(8, {HenonC.ar(rrand(freq*4,freq*16)*(env.(dec1)*pitchE))})*env.(dec2);
	src = GrainSin.ar(
		2, Dust.ar(freq*(env.(dec1)*pitchE)!2), // Channels & Trig
		rnd.(freq*IRand(-2,2),gDur/2,gDur*2), // Grain Duration
		rnd.(dec2,freq/4,freq), // Grain Freq
		0,-1,1024,0.1 // Pan, Env, MaxGrain, Mul
	);
	src = src*env.(dec2)*gain;
	src = LPF.ar(src.fold(-0.5,0.5),250,0.25);
	src = FreqShift.ar(src,freq*IRand(1,4)*(env.(dec1)*pitchE));
	// src = src ring2: mod;
	src = HPF.ar(src,100).tanh;
	Out.ar(0,src*0.25);
}).store
)
(
Pdef(\seq1,
	Pbind(
		\instrument, \perc1,
		\dec1, Pseq(Array.geom(3,0.125,1.25),inf), // Pitch Env
		\dec2, Pseq(Array.geom(5,0.25,1.25),inf), // Volume doneAction Env
		\gDur, Pseq(Array.geom(9,0.005,2),inf), // Average Grain Duration
		\freq, Pseq(Array.geom(7,250,1.5),inf), // Average Freq
		\gain, Pseq(Array.geom(6,25,2),inf), // Gain for distortion
		\pitchE, Pseq(Array.geom(11,1,0.75),inf), // Pitch Envelope Amount
		// \ground, Pseq([0.25,0.125,0.067,0],inf), // Lowest volume
		\dur, 0.125 // Duration
)).play
)
(
Pdef(\rndSeq,
	Pbind(
		\instrument, \perc1,
		\dur, 0.125,
		\dec2, 0.125,
		\dec1, Pwhite(0.025,1),
		\gDur, Pwhite(0.00005,0.5),
		\freq, Pwhite(5,750),
		\gain, Pwhite(25,500),
		\pitchE, Pwhite(0.5,1),
		\ground, Pwhite(0,0.125)
)).play
)