~myBuffs = SoundFile.collectIntoBuffers("/Users/admin/STUDIO/SCfold/Spec/*");

s.options.memSize = 81920;
b = Buffer.read(s, "/Users/yangj14/Documents/GitHub/opensource/sc/sitar.wav");
g = Group.new(s);
h = Group.after(g);
i = Group.after(h);
j = Group.after(i);
k = Group.after(j);
l = Group.after(k);
v = { |och=0 buf rate|  PlayBuf.ar(2, buf, rate, loop:1) };
w = {|ich rate=1 atk=0.01 dur=1 rel=0.1| In.ar(ich)*EnvGen.ar(Env.linen(atk, dur, rel), Dust.kr(rate) )};
a = v.play(g,20,args:[\rate, 0.1]);
b = w.play(h, 30, args:[\ich, 20, \dur, 0.03]);
b.set(\rate, 0.4);
b.free
b.set(\rate, 2, \dur, 0.03, \rel, 0.01);
c = { ReplaceOut.ar(0, Greyhole.ar(In.ar(0),) )}.play(i);
b.set(\och, 30); x = {|del dif ich fb| Greyhole.ar(In.ar(ich), del,feedback:fb, diff:dif) }; f=x.play(i,0, args:[\del, 0.1, \diff, 0.5, \ich, 30, \fb, 0.2]);
f.free; f = x.play(i,0, [\del, 0.1, \diff, 0.5, \ich, 30, \fb, 0.1]);

d = { ReplaceOut.ar( 0, Pan2.ar( In.ar(0), SinOsc.kr(0.4).range(-1, 1) )) }.play(k);
e = {|rate=1| Out.kr(0, SinOsc.kr(rate).range(0.01, 10))}.play(g);
e.set(\rate, 0.1);
e.set(\rate, 0.05);
a.map(\rate, 0);
e.free;

b.free
c.free;

x = { arg freq=900; Resonz.ar(PinkNoise.ar([1,1]), freq, 0.01) }.play(s, 0);
x.set(\freq, 1400);
x.free;

a.value(0, b).play;
a.play
a.stop
a.free;


play{SinOsc.ar([a=[1,8,2]]*96,0,Decay.kr(Demand.kr([b=Impulse.kr(a,[0,1,0.5])],0,Dseq([1,9,0,0],16))*b,0.1)).fold2(0.1)!2}

play{Splay.ar(BPF.ar(PinkNoise.ar(1!12),LFNoise0.kr({((1..32)*1e-2).choose}!12).exprange(99,600).round(50),2e-3))*25}
