a = {Bus.audio(s)}!3;
e = Group.new();
f = Group.new(e, 'addAfter');
s.queryAllNodes;

b = {Out.ar(a[0], SinOsc.ar(330))}.play(e);
c = { Out.ar( a[1], Crackle.ar(1.9) ) }.play(e);
d = { Out.ar( a[2], Formant.ar(200, SinOsc.kr(0.3).range(100, 8000), 200, 0.125) ) }.play(e);

SynthDef(\mixer3, {
	arg ibus1, ibus2, ibus3, a1=0.3, a2=0.3, a3=0.3;
	var mix;
	mix = Mix.ar( [In.ar(ibus1)*a1, In.ar(ibus2)*a2, In.ar(ibus3)*a3] );
	Out.ar(0, mix);
}).load;


g = Synth(\mixer3, [\ibus1, a[0]], f);
g.set(\ibus1, a[0], \a1, 0.1);
g.set(\ibus2, a[1], \a2, 0.2);
g.set(\ibus3, a[2], \a3, 0.1);

s.meter;