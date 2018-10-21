e = Signal.sineFill(512, [1, 0, 0.8], [ pi*1.5, pi*1.5, pi*1.5 ]).exp.scale(0.42).offset(0.15.neg);
e.resamp1(512);
a = Buffer.loadCollection(s, e);
a.write("/Users/yangj14/Documents/GitHub/grainBufs/gEnv_Pulse.aif");

b= Buffer.read(s, "/Users/yangj14/Documents/GitHub/grainBufs/gEnv_Pulse.aif");
b.plot
