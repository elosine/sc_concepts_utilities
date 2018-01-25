SynthDef(\hratio, {
	arg fund=50, r1=2, r2=3;
	var sig1 = SinOsc.ar(fund*r1);
	var sig2 = SinOsc.ar(fund*r2);
	Out.ar(0, [sig1, sig2]);
}).add;

a = Synth(\hratio);
a.set(\fund, 60, \r1, 13, \r2, 14);