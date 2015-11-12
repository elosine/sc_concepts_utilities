s.boot;

(
SynthDef(\decode, { |out = 0, in, amp=1.0|
        var ambi = In.ar(in, 4);
        Out.ar(out, B2Ster.ar(ambi[0], ambi[1], ambi[2])*amp)
}).add;

SynthDef(\noisepan, { |out = 0|
        Out.ar(out, BFEncode1.ar(WhiteNoise.ar, LFTri.kr(0.25, 0, pi), 0, 1, 0.25))
}).add;

SynthDef(\playbuf, { |out = 0, bufnum, amp=4|
	Out.ar(out, PlayBuf.ar(4, bufnum)*amp)
}).add;

~ambibus = Bus.audio(s, 4);
~abuf = Buffer.read(s, "/Volumes/Untitled 1/Unhome/unhome/Country Kitchen Bounces/CountryKitchen_4ch.aiff");
)

// decoder...
~decode = Synth(\decode, [\in, ~ambibus.index], s, \addToTail);

// then source
~source = Synth(\playbuf, [\out, ~ambibus.index, \bufnum, ~abuf], s, \addToHead);

~source.set(\amp, 6);
~decode.set(\amp, 20);


~source.free;
~decode.free;

s.meter;
