(
x = {OteyPiano.ar(50,0.5)}.play;
)
x.free;

//Define piano synthdef
(
SynthDef(\help_oteypiano, { |out=0, freq=440,gate=1, amp=0.5,rho=1|
    var son =

	OteyPiano.ar(
		freq: freq,
		vel: 1,
		t_gate: 0,
		rmin: 0.35,
		rmax: 2,
		rampl: 4,
		rampr: 8,
		rcore: 1, lmin: 0.07, lmax: 1.4, lampl: -4, lampr: 4, rho: 1, e: 1, zb: 1, zh: 0, mh: 1, k: 0.2, alpha: 1, p: 1, hpos: 0.142, loss: 1, detune: 0.0003, hammer_type: 1)


	OteyPiano.ar(freq, amp, rho:rho)*EnvGen.ar(Env.asr(0,1,0.1),gate,doneAction:2);
    Out.ar(out, Pan2.ar(son * 0.1, LinLin.kr(freq,36.midicps,90.midicps,-0.75,0.75)));
}).add;
)

//Use it.
(
Pbind(
    \instrument, \help_oteypiano,
    \delta, 1,
    \dur, 3,
    \degree, Pseq([1,3,5], inf),
    \rho, Pwhite(0.1,3) //comment this line to get standard sound
).play;
)