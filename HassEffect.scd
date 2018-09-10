SynthDef(\hass, { |del=0.0|
	var sig = Impulse.ar(4);
	var dsig = DelayC.ar(sig, 0.02, del);
	Out.ar(0, [sig, dsig]*0.4);
}).add;

a = Synth(\hass);
a.set(\del, 0.003);
a.set(\del, 0.01);
a.set(\del, 0.02);
a.set(\del, 0.000);