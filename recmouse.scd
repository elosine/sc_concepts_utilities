s.boot

p = ProxySpace.push(s);
g = Buffer.alloc(s, s.sampleRate*10, 3);

SynthDef(\recmouse, {
	| xlo=0 xhi=1 ylo=0 yhi=1 buf|
	RecordBuf.ar( K2A.ar( [ MouseX.kr(xlo, xhi, lag:0.01), MouseY.kr(ylo, yhi, lag:0.01), MouseButton.kr(lag:0.01).round ] ), buf, loop:0, doneAction:2);
}).add;

SynthDef(\playbuf3, {
	arg buf, out;
	Out.ar( out, PlayBuf.ar(3, buf, loop:1));
}).add

fork{ ~ms0=\recmouse; 0.05.wait; ~ms0.set(\xlo, 0, \xhi, 1, \ylo, 0.999999999, \yhi, 0.1, \buf, g) };

fork{ ~pb = \playbuf3; 0.02.wait; ~pb.set(\buf, g);}

~pb.free


~r = { SinOsc.ar()*In.ar(~pb.bus.index+2)  }
~r.play
s.meter
~r.free