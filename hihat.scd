(
SynthDef(\hihat1, {
arg rel = 0.5;

var env1 = EnvGen.ar(Env.perc(0.001,rel,1,-16),doneAction:2);
var env2 = EnvGen.ar(Env.perc(0.001,rel/2,1,-16));
var src1 = PinkNoise.ar(1)+WhiteNoise.ar(0.5*env2);
src1 = RHPF.ar(src1, Rand(5000,10000));
src1 = LPF.ar(src1, 15000);

Out.ar([0,1],src1*env1);
}).store;
SynthDef(\hihat2, {
arg rel=0.5, a=1.5, b=0.25, wid=0.25;

var env1 = EnvGen.ar(Env.perc(0.001,rel,1,-16),doneAction:2);
var src1 = HenonC.ar(15000,a,b);
src1 = src1*src1*Pulse.ar([Rand(10,250),Rand(10,250)],wid);
src1 = RHPF.ar(src1, Rand(5000,10000));
src1 = LPF.ar(src1, 12500);

Out.ar([0,1],src1*env1);
}).store;
SynthDef(\hihat3, {
arg rel=0.5, a=1.5, b=0.25, wid=0.25;

var env1 = EnvGen.ar(Env.perc(0.001,rel,1,-16),doneAction:2);
var src1 = CuspL.ar(25000,a,b);
src1 = src1*src1*Pulse.ar([Rand(10,250),Rand(10,250)],wid);
src1 = RHPF.ar(src1, Rand(5000,10000));
src1 = LPF.ar(src1, 12500);

Out.ar([0,1],src1*env1);
}).store;
SynthDef(\hihat4, {
arg rel=0.5, a=1.5, b=0.25, wid=0.25;

var env1 = EnvGen.ar(Env.perc(0.001,rel,1,-16),doneAction:2);
var src1 = LatoocarfianC.ar(25000,a,b);
src1 = src1*src1*Pulse.ar([Rand(10,250),Rand(10,250)],wid);
src1 = RHPF.ar(src1, Rand(5000,10000));
src1 = LPF.ar(src1, 12500);

Out.ar([0,1],src1*env1);
}).store;
)

(
Pdef(\seq1,
Pbind(\instrument, Pseq([\hihat1,\hihat2,\hihat3,\hihat4],inf),
\rel, Pwhite(0.125,1),
\a, Pwhite(0.25,2),
\b, Pwhite(0.25,2),
\wid, Pwhite(0.05,0.5),
\dur, 0.125
)).play
)