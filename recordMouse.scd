

~buffer = Buffer.alloc(s, 1000, 1);

SynthDef(\recMY, {
	arg buf, dur=9;
	Line.ar(dur:dur, doneAction:2);
	BufWr.ar( K2A.ar(MouseX.kr() ), buf, Phasor.ar(1, //figure out control rate
	//RecordBuf.ar( K2A.ar(MouseX.kr() ), buf, loop:0, doneAction:2);
	// Out.ar(0, WhiteNoise.ar( MouseY.kr(lag:0.03) )!2 );
}).add;

a = Synth(\recMY, [\buf, ~buffer, \dur, 13]);
~buffer.plot;
s.queryAllNodes

	resample to 1000 