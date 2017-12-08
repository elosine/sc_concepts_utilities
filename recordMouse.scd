

~buffer = Buffer.alloc(s, s.sampleRate * 4, 1);

SynthDef(\recMY, {
	arg buf, dur=4;
	Line.ar(dur:dur, doneAction:2);
	RecordBuf.ar( K2A.ar(MouseX.kr() ), buf, loop:0, doneAction:2);
}).add;

a = Synth(\recMY, [\buf, ~buffer]);
~buffer.plot;
s.queryAllNodes