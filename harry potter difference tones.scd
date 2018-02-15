SynthDef(\diffalea, { arg freq = 220, gate = 1, amp = 1, lowFreq = 1000, hiFreq = 1500;
	var freq1 = Rand(lowFreq, hiFreq);
	var freq2 = freq1 - freq;
	var env = EnvGen.kr(Env.asr(0.01, 1, 0.01, 1, 'linear'), gate, doneAction: 2);
	Out.ar(0, Mix(SinOsc.ar([freq1, freq2], 0.5pi.rand, mul:amp*env))!2);
}).send;

~freqs = [47, 52, 55, 54, 52, 59, 57, 54, 52, 55, 54, 50, 52, 47, 47, 52, 55, 54, 52, 59, 62, 61, 60, 57, 60, 59, 55, 47, 55, 52].midicps;

~duras = [0.5, 0.75, 0.25, 0.5, 1, 0.5, 1.5, 1.5, 0.75, 0.25, 0.5, 1, 0.5, 2.5, 0.5, 0.75, 0.25, 0.5, 1, 0.5, 1, 0.5, 1, 0.5, 0.75, 0.25, 0.5, 1, 0.5, 2.5];

s.prepareForRecord;

s.bind({
Pbind( \instrument, \diffalea, \lowFreq, [2200, 1200, 3200], \hiFreq, [2400, 1400, 3400], \freq, Pseq(~freqs+[0, 0, 0], inf), \dur, Pseq(~duras+[0, 0, 0], inf), \legato, 1, \strum, 8 ).play(TempoClock(1.3));
	s.record;
});

s.stopRecording;



