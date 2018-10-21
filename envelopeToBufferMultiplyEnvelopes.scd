e = Env( [0, 0, 1, 1, 0], [0, 512.0/3.0, 512.0/3.0, 512.0/3.0], \lin);
f = e.asSignal.resamp1(512);
a = Buffer.loadCollection(s, f);
// a = Buffer.loadCollection(s, e.asSignal);
e.plot

a.write("/Users/yangj14/Documents/GitHub/grainBufs/gEnv_threeStageLinear.aif");

b = Env.sine(512/41000).asSignal;
c = Signal.sineFill(512, [1, 0, 0.8], [ pi*1.5, pi*1.5, pi*1.5 ]).exp.scale(0.42).offset(0.15.neg);

d = b*c;
d.plot

