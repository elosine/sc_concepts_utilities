-18.dbamp

SynthDef(\sindb, {
	arg freq=300, db= -18;
	var amp = db.dbamp;
	Out.ar(0, SinOsc.ar(freq)*amp);
}).add;

a = Synth(\sindb, [\freq, 300, \db, -6]);
a.set(\freq, 1000, \db, -16);
a.set(\freq, 3000, \db, -21);
a.set(\freq, 300, \db, -6);