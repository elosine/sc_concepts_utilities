(
SynthDef(\dt, {
	arg freq1=1440, freq2=1000, amp=0.35;
	Out.ar(0, [ SinOsc.ar(freq1), SinOsc.ar(freq2)]*amp);
}).add;

)

a = Synth(\dt);
a.set(\freq1, 10000, \freq2, 10400);
a.free;

