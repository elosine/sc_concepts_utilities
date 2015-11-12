(
b = Buffer.read(s,"/Users/jyang/Downloads/204497__holadios__short-giggle.wav");
c = Buffer.alloc(s, s.sampleRate*1.0);
d = SoundFile.collectIntoBuffers("/Users/jyang/Dropbox/grainEnv/"   ++ "*");
e = Buffer.read(s, "/Volumes/Ute/Freeze/acjourney.aif");

SynthDef(\icy, {
	arg buf=0, envbuf = -1, pitchshift=1, rate=1, winsz=0.8, overlaps=40, resettrig=0, startpos=0.0, endpos=1.0, rand=0.1;
	var sig, ix;
	ix = Phasor.kr(resettrig, (1.0/ControlRate.ir)*rate, startpos, endpos);
	sig = Warp1.ar(1, buf, ix, pitchshift, winsz, envbuf, overlaps,rand);
	Out.ar(0, sig);
}).add;

SynthDef(\icylive, {
	arg ibs=0, buf, envbuf = -1, pitchshift=1, rate=0.05, winsz=0.8, overlaps=33, resettrig=0, startpos=0.0, endpos=1.0;
	var sig, ix, source;
	source = SoundIn.ar(ibs);
	BufWr.ar(source, buf, Phasor.ar(0, BufRateScale.kr(buf), BufFrames.kr(buf)*startpos, BufFrames.kr(buf)*endpos));
	ix = Phasor.kr(resettrig, (1.0/ControlRate.ir)*rate, startpos, endpos).poll;
	sig = Delay1.ar(Warp1.ar(1, buf, ix, pitchshift, winsz, envbuf, overlaps));
	Out.ar(0, sig);
}).add;
)
a = Synth(\icylive, [\buf, c]);
a.set(\winsz, 0.4, \overlaps, 30, \rate, 0.07,\startpos, 0.0, \endpos, 0.5)

x = Synth(\icy, [\buf, e, \envbuf, -1])

x.set(\winsz, 0.4, \overlaps, 33, \rate, 0.002, \startpos, 0.37, \endpos, 0.785, \rand, 0.1)
x.set(\envbuf, d[0]);
x.set(\envbuf, -1);
d

x.free;

{Phasor.kr(0, ).poll}.play

