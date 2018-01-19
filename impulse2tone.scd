SynthDef(\impulse2tone,{
	var sig = Impulse.ar(MouseY.kr(0, 100).poll);
	var dsig = DelayC.ar(sig,0.2,0.03);
	Out.ar(0,[sig, dsig]);
}).add

a = Synth(\impulse2tone);