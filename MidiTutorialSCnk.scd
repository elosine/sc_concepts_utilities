s.boot;

(
~kbs = {Bus.control(s)}!200;
~mkbs = {Bus.control(s)}!200;
~mkbs_exp = {Bus.control(s)}!200;
~msynths = Array.newClear(0);
~msynths_exp = Array.newClear(0);

~midictl = CCResponder({ |src,chan,num,value|
	[src,chan,num,value].postln;
	value = value.linlin(0.0, 127.0, 0.0, 1.0);
	~kbs[num].set(value);
	},
	nil, // any source
	nil, // any channel
	nil, // CC number 80
);

SynthDef(\mapkb, {
	arg inbus, outbus, lo=0.0, hi=1.0;
	var in = In.kr(inbus).linlin(0.0, 1.0, lo, hi);
	Out.kr(outbus, in);
}).add;

SynthDef(\mapkb_exp, {
	arg inbus, outbus, lo=0.0, hi=1.0;
	var in = In.kr(inbus).linexp(0.0, 1.0, lo, hi);
	Out.kr(outbus, in);
}).add;

SynthDef(\blippy, {
	arg gate=0, dur=1;
	var synth, env;
	env = EnvGen.ar(Env.sine(dur), gate);
	synth = BlitB3Square.ar(\freq.kr(200, 0.07));
	Out.ar( 0, [synth, DelayC.ar(synth, 0.2, 0.05)]*env * \amp.kr(1.0, 0.08) );
}).add;
)

(
~kbs.do{ |it ix|
	~msynths = ~msynths.add( Synth(\mapkb, [\inbus, it, \outbus, ~mkbs[ix]]) );
	~msynths_exp = ~msynths_exp.add( Synth(\mapkb_exp, [\inbus, it, \outbus, ~mkbs_exp[ix]]) );

};
)

//Faders Channels: 2, 3, 4, 5, 6, 8, 9, 12, 13 ...
//Knob Channels: 14-20
//top buttons 23-31; 33-41

~msynths_exp[14].set(\lo, 50.0, \hi, 8000.0);
~sqr1 = Synth(\blippy);
~sqr1.map(\freq, ~mkbs_exp[14]);
~sqr1.map(\amp, ~mkbs[2]);
~sqr1.map(\gate, ~mkbs[23]);
~sqr1.set(\dur, 3.1);

~sqr1.free;
~midictl.remove;