k=s.sampleRate/s.options.blockSize;
b = Buffer.alloc(s, k*60);
a = {SinOsc.ar(300)*SinOsc.kr( MouseX.kr(0, 27) ).range(0, 1); }.play;
c = {RecordBuf.kr(MouseX.kr(lag:0.01).poll, b, loop:0, doneAction:2)}.play;

	c.free

d = {SinOsc.kr( (PlayBuf.kr(1, b, loop:1)*27).poll ).range(0, 1)*SinOsc.ar(300)}.play