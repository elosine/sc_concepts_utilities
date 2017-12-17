

b = Buffer.alloc(s, s.sampleRate*9, 1);

SynthDef(\recMs, {
	arg bufx, bufy;
	RecordBuf.ar( K2A.ar(MouseX.kr() ), bufx, loop:0, doneAction:2);
	RecordBuf.ar( K2A.ar(MouseY.kr() ), bufy, loop:0, doneAction:2);
}).add;

a = Synth(\recMY, [\buf, b, \dur, 9]);
b.plot;
s.queryAllNodes

b.getToFloatArray(wait:0.01,action:{arg array; ~bufarray = array});

~b2 = ~bufarray.resamp1(1000);

~bufarray.plot

~b2.plot

~b2.normalize;

~b2.writeArchive("/Users/yangj14/Documents/GitHub/musicmobiles/curveArrays/crv001.dat".standardizePath);

f = Object.readArchive("/Users/yangj14/Documents/GitHub/musicmobiles/curveArrays/crv001.dat".standardizePath);

f.normalize