/* An approach to try to reproduce the 'famous' bassline of "Der Mussolini" by D.A.F. */

// very bad simulated analogue distorted bass synth
// too distorted compared to the original...

SynthDef(\daf_bass,{ |out, freq=440, sustain=1, gate=1, amp=0.1|
	var snd, env, fenv, harm;
	harm = [1,1.01,2,2.02,3.5,4.01,5.501];
	harm = harm ++ (harm*2);
	snd = SinOsc.ar(freq*harm).sum.distort * 2;
	snd = snd + SinOsc.ar(freq / [1, 2]).sum!2;
	env = EnvGen.kr(Env.adsr(0.001,0.2,0.9,0.25), gate, amp, doneAction:2);
	snd = snd * env;
	OffsetOut.ar(out, (snd!2));
}).add;

// approx 63 bpm
TempoClock.default.tempo = 63/60;

// approx bass pattern + modulation of Mussolini bassline
Pdef(\daf_bass,
	Pbind(
		\instrument, \daf_bass,
		\scale, Scale.minor,
		\octave, [3], // try out [2,3] or [3,4] for octave bass leetness
		\ctranspose,Pseq([
			Pn(-1,16*4),
			Pn(1,16*2)
		], inf),
		// -1 for thinking in musical degrees...
		\degree, Pseq([1, 4, 1, 10, 1, 8, 1, 1, 8, 1, 8, 1, 8, 7, 1, 8]-1,inf),
		\legato, Pwhite(0.75, 0.8),
		\dur, 0.2
	)
).play;

// link: http://www.youtube.com/watch?v=15ScQivK5DY



/*
Waveshaper

References : Posted by Partice Tarrabia and Bram de Jong

Notes :
amount should be in [-1..1[ Plot it and stand back in astonishment! ;)

Code :
x = input in [-1..1]
y = output
k = 2*amount/(1-amount);

f(x) = (1+k)*x/(1+k*abs(x))
http://www.musicdsp.org/archive.php?classid=4#203
*/

(
{
	var x = SinOsc.ar(220, 0, 0.8);
	var amount = MouseX.kr(-1, 1);
	var k = 2 * amount / (1 - amount);
	(1 + k) * x / (1 + (k * x.abs));
}.scope

)

//a bit of filtering and tweaking, you get a decent guitar amp...

(
{
	var in, amount, amCoef;
	in = HPF.ar(SoundIn.ar(0), 400)*5;
	amount = 0.99;
	amCoef= 2*amount/(1-amount);
	MidEQ.ar(LPF.ar((1+amCoef)*in/(1+(amCoef*in.abs)), [3800, 3900])*0.5, 120, 0.7, 8);
}.play;
)
