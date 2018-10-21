e = ((1/Signal.sineFill(512, [1], [pi*1.5]).exp.normalize.scale(6.45).invert) + 1.148);
e.resamp1(512);
a = Buffer.loadCollection(s, e);
a.write("/Users/yangj14/Documents/GitHub/grainBufs/gEnv_quasiGauss.aif");

b= Buffer.read(s, "/Users/yangj14/Documents/GitHub/grainBufs/gEnv_quasiGauss.aif");
b.plot(b.path);
