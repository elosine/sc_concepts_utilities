s.options.numOutputBusChannels=8;
ServerOptions

(
SynthDef(\panaztest, {
	arg pos, t_tr=0;
	var src = Decay.ar(T2A.ar(t_tr), 0.334) * WhiteNoise.ar(0.2);
	src = PanAz.ar(8, src, pos);
	Out.ar(0, src);
}).add;
)

a = Synth(\panaztest);
a.set(\t_tr, 1, \pos, 1.875);
s.meter