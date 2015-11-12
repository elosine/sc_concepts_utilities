(
s.sendMsg(\b_allocRead, 0,"/Users/jyang/Downloads/50830__scriptique__tis-but-thy-name-that-is-my-enemey.wav" , 0, -1);

SynthDef(\warpoverlap, {arg buffer = 0, stretch = 1, windowsize = 0.05, mul = 1, gate = 1;
	var out, env, overlaps, harm, wwinsize, wwinoverlap, wwinran;
	overlaps = 8;
	harm = [3, 7, 5, -12].midiratio.asRef;
	wwinsize = `[0.11, 0.11, 0.11, 0.2];
	wwinsize = 0.11;
	wwinoverlap = 8;
	wwinran = 0.1;
	env = EnvGen.kr(Env([0.01, 1, 0.01], [0.1, 0.1], 'exp', 1), gate, doneAction: 2);
	out = WarpOverlap.ar(1, buffer, overlaps, 0, stretch, harm, windowsize, wwinsize, wwinoverlap, wwinran, mul);
	Out.ar(0, out * env);
}).send(s);

)


s.boot;

(
var winenv;
// a custom envelope
winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

SynthDef(\in_grain_test, {arg gate = 1, amp = 1, envbuf;
    var pan, env;
    // use mouse x to control panning
    pan = MouseX.kr(-1, 1);
    env = EnvGen.kr(
        Env([0, 1, 0], [1, 1], \sin, 1),
        gate,
        levelScale: amp,
        doneAction: 2);
    Out.ar(0,
		        GrainIn.ar(2, Impulse.kr(3), 1, SoundIn.ar(1), pan, envbuf) * env)
    }).send(s);

)

// use built-in env
x = Synth(\in_grain_test, [\envbuf, -1])

// switch to the custom env
x.set(\envbuf, z)
x.set(\envbuf, -1);

x.set(\gate, 1);

LiveGrain

s.sendMsg(\s_new, \warpoverlap, a=s.nextNodeID, 0, 1, \buffer, 0, \stretch, 30, \mul, 0.1)

s.sendMsg(\n_free, a);

Warp1



b = Buffer.read(s,"/Users/jyang/Downloads/50830__scriptique__tis-but-thy-name-that-is-my-enemey.wav");
(
SynthDef(\icy, {
	arg buf, step=0.1;
	var sig;
	sig = WarpOverlap.ar(buffer:buf, overlaps:8, step:step);
	Out.ar(0, sig);
}).add;
)

a=Synth(\icy, [\buf, b]);
a.set(\step, 0.001);
