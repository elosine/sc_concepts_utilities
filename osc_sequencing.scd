(
SynthDef(\osctest, {
	arg trig=0;
	SendReply.kr( trig, '/osctest', [1, 2, 3, 4], 1000);
}).add;

OSCdef(\osctest, {|msg| msg.postln}, "/osctest");


t = TempoClock(60/60);
)
a = Synth(\osctest, [\trig, 1]);

(
Pbind(
	\instrument, \osctest,
	\t_tr, Pseq( [1], 16),
).play(t);

)

(
q = Pbind(
	\instrument, \osctest,
	\trig, Pseq( [1], 16),
	\dur, Pseq( [1, 0.1, 0.5, 0.1, 1], 16 ),
).play(t);

)
q.stop;
q.start;
q.reset;
