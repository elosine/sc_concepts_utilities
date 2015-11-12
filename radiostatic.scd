(
SynthDef("radiostatic", {arg out=0;
	var hum, sineSweep, tuning, dustNoise, staticNoise, humFreq, numHarms;

	numHarms = 7;
	humFreq = 100;
	hum = Array.fill(numHarms, {|i| SinOsc.ar( (i+1) * humFreq, 0, 1/numHarms)});
	hum = hum.sum;
	dustNoise = Dust.ar(LFNoise1.ar(0.5).range(1000,8000));
	staticNoise = hum * dustNoise * LFNoise1.ar(1).range(0.5, 2);

	sineSweep = SinOsc.ar(LFNoise2.ar(1).range(20, 11000));
	tuning = SinOsc.ar(10000).ring4(sineSweep) * LFNoise2.ar(1.1).range(0.05, 0.1);

	Out.ar(out,  Pan2.ar(staticNoise + tuning, 0));
}).add;
)

a = Synth("radiostatic");


(
SynthDef("radiostatic", { arg freqs(#[100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200, 1300]), rel=0.7, atk=0.001, dens=50, grel=0.002;
	var hum, dustNoise, dusttrig, trigenv, env, dustNoise2;
	hum = SinOsc.ar(freqs, 0, 1/7);
	hum = hum.sum;
	trigenv = EnvGen.ar( Env.asr(attackTime: atk, releaseTime:rel), \t_tr.kr(1) );
	dusttrig = Dust.kr(dens)*trigenv;
	//env = EnvGen.ar(Env.perc(attackTime: 0.00001, releaseTime:grel), dusttrig);
	env = EnvGen.ar(Env.perc(attackTime: 0.00001, releaseTime:grel), \t_tr2.kr(1), levelBias:3.0);
	dustNoise = Dust.ar(LFNoise1.ar(0.5).range(1000,8000));
	dustNoise = dustNoise*env;
	hum = hum*dustNoise* LFNoise1.ar(1).range(0.5, 2);
	//Out.ar(0, hum*env);
	//Out.ar(0, hum*trigenv);
	Out.ar(0, hum);
}).add;
)
(
a = Synth("radiostatic");
a.set(\t_tr, 1, \rel, 0.5, \dens, 50);
~fund = 300;
~harms = Array.fill(13, { arg i; (i*~fund) + ~fund });
a.setn(\freqs, ~harms);
b = Synth("radiostatic");
~fund = 30;
~harms = Array.fill(13, { arg i; (i*~fund) + ~fund });
b.setn(\freqs, ~harms);
c = Synth("radiostatic");
~fund = 31;
~harms = Array.fill(13, { arg i; (i*~fund) + ~fund });
c.setn(\freqs, ~harms);
)

(
a.set(\t_tr2, 1);
b.set(\t_tr, 1);
c.set(\t_tr, 1);
)


(
a.set(\dens, 30);
b.set(\dens, 10);
c.set(\dens, 20);
)

(
a.set(\rel, 1.2);
b.set(\rel, 1.2);
c.set(\rel, 1.2);
)
(
a.set(\grel, 1.15);
b.set(\grel, 0.15);
c.set(\grel, 0.15);
)


