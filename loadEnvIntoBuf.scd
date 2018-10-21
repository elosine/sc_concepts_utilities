e= Env([0, 0, 0.5, 1, -1, 0], [0, 50, 200, 100, 100].normalize*512/s.sampleRate, \lin)
a= Buffer.loadCollection(s, e.asSignal)
a.plot
{|buf| SinOsc.ar*PlayBuf.ar(1, buf, doneAction:2)!2}.play(args: [\buf, a])