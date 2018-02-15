(
SynthDef(\binural, {
	arg pitch=67;
	var p2add = MouseY.kr(0, 1, lag:0.03);
	Out.ar(0, [SinOsc.ar(pitch.midicps), SinOsc.ar( (pitch+p2add).midicps)]*0.35);
}).add;

)

a = Synth(\binural);
a.free;

