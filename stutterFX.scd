s.sendMsg(\g_new, 1999); s.sendMsg(\g_new, 2000);
10.do{|ix| s.sendMsg(\g_new, 2001+ix, 3, 2000+ix)};
s.sendMsg(\g_new, 2999, 3, 2010);



////JANUS

SynthDef( \janus, {
	arg obs=0, t_tr=0, amp=0.5;
	var imp = T2A.ar(t_tr);
	var o1 = SinOsc.kr(0.311).range(0.0, 0.25);
	var o2 = SinOsc.kr(0.07).range(0.0, 0.25);
	var o3 = SinOsc.kr(0.11).range(0.0, 0.25);
	var o4 = SinOsc.kr(0.085).range(0.0, 0.25);
	var o5 = SinOsc.kr(0.23).range(0.0, 0.25);
	var dur = TRand.kr(3.0, 9.0,imp);
	var p1 = TIRand.kr(40, 80, imp);
	var p2 = p1 + TIRand.kr(1, 10, imp);
	var p3 = p1 + TIRand.kr(1, 10, imp);
	var f1 = p1.midicps;
	var f2 = p2.midicps;
	var f3 = p3.midicps;
	var h = [2,3,4,5,6,7,8,9,10,11,12,13,14];
	var j1 = TIRand.kr(0,10,imp);
	var j2 = TIRand.kr(0,10,imp);
	var j3 = TIRand.kr(0,10,imp);
	var h1 = h.scramble.copyRange(3,5).addFirst(1);
	var h2 = h.scramble.copyRange(7,9).addFirst(1);
	var h3 = h.scramble.copyRange(0,2).addFirst(1);
	var s1 = Ringz.ar( imp, f1*h1, dur,[o5, o1, o2, o3] );
	var s2 = Ringz.ar( imp, f2*h2, dur,[o3, o5, o4, o2]);
	var s3 = Ringz.ar( imp, f3*h3, dur,[o2, o1, o5, o3]);
	var fe = EnvGen.ar(Env.perc(0.002, dur+(dur*0.7), 1, 0),imp,doneAction:2);
	var f1b = (p1+1).midicps;
	var s1b = Ringz.ar( imp, f1b, dur,[o5, o1, o2, o3]);
	var f2b = (p2+1).midicps;
	var s2b = Ringz.ar( imp, f2b, dur,[o3, o5, o4, o2]);
	var f3b = (p3+1).midicps;
	var s3b = Ringz.ar( imp, f3b, dur,[o2, o1, o5, o3]);
	s1 = Mix.ar(s1);
	s2 = Mix.ar(s2);
	s3 = Mix.ar(s3);
	//Out.ar(och, Mix.ar([s1*(1.0/6.0), s2*(1.0/6.0), s3*(1.0/6.0), s1b*(1.0/6.0), s2b*(1.0/6.0), s3b*(1.0/6.0)])*fe);
	Out.ar(obs, (Mix.ar([s1*0.3, s2*0.3, s3*0.3])*fe) * amp);
	//Out.ar(0, Mix.ar([s1*(1.0/6.0), s1b*(1.0/6.0)])*fe);
}).add;




SynthDef(\bufRoll, { |time = 7, bufnum, rate = 1, amp = 1, density = 18,
	attack = 0.002, decay = 0.01,	// attack and decay of individual stroke
	out=0, ibs=0 |
	var	sig, envDefault, in, env,
	trig = Dust.ar(LFTri.kr(0.1).range(9.0, 33.0)),
	trigs = PulseDivider.ar(trig, 2, (0..1)),
	strokeEnv = EnvGen.ar(Env.linen(attack, density.reciprocal - attack - decay, decay), trigs);
	// time of this env must add up to 1.0 sec
	envDefault = Env(#[0, 1, 0], #[0.001, 0.999], -4);
	// 40 == 10 possible envelope segments (which is a lot, really)
	env = Control.names(\env).kr((0 ! 40).overWrite(envDefault.asArray, 0));
	in = In.ar(ibs);
	sig = (in * strokeEnv).sum * EnvGen.ar(env, timeScale: time, doneAction:2);
	Out.ar(out, sig * amp);
}).add;


(
s.sendMsg(\s_new, \bufRoll, 3000, 0, 2003, \time, 7, \density, 33, \amp, 1.5);
s.sendMsg(\s_new, \janus, 3001, 0, 2001, \t_tr, 1, \obs, 0 );
)




SynthDef( \crush, {
	arg ibs=0, obs=0, gate;
	var in, sig;
	var amp = \amp.kr(0.85, 0.01);
	//var rate = \samprate.kr(44100, 0.01);
	//var bits = \bitrate.kr(24,0.01);
	var rate = LFTri.kr(0.005).range(1000.0, 10000.0);
	var bits = LFTri.kr(0.003).range(1.0, 6.0);
	var env = EnvGen.ar(Env.asr(0.03,1,0.03,0),gate, doneAction:2);
	in = In.ar(ibs);
	sig = Decimator.ar(in, rate, bits);
	ReplaceOut.ar(obs, sig*amp*env);
}).add;


s.sendMsg(\s_new, \crush, 3002, 0, 2003, \ibs, 0, \gate, 1, \samprate, 3000, \bitrate, 2);
s.sendMsg(\s_new, \janus, 3001, 0, 2001, \t_tr, 1, \obs, 0 );
s.sendMsg(\n_set, 3002, \samprate, 1000, \bitrate, 1, \gate, 0);


SynthDef(\bufRollPan, { |start, time = 1, bufnum, rate = 1, amp = 1, strokesPerSec = 18, pan = 0,
	attack = 0.002, decay = 0.01,	// attack and decay of individual stroke
	out|
	var	sig, envDefault, env,
	trig = Impulse.ar(strokesPerSec),
	trigs = PulseDivider.ar(trig, 2, (0..1)),
	strokeEnv = EnvGen.ar(Env.linen(attack, strokesPerSec.reciprocal - attack - decay, decay), trigs);
	// time of this env must add up to 1.0 sec
	envDefault = Env(#[0, 1, 0], #[0.001, 0.999], -4);
	// 40 == 10 possible envelope segments (which is a lot, really)
	env = Control.names(\env).kr((0 ! 40).overWrite(envDefault.asArray, 0));
	sig = (PlayBuf.ar(1, bufnum, rate * BufRateScale.kr(bufnum), trigs, start, 1) * strokeEnv).sum
	* EnvGen.ar(env, timeScale: time, doneAction:2);
	Out.ar(out, Pan2.ar(sig, pan, amp));
}).memStore(\ddwSynths);

SynthDef(\bufRollPanMove, { |start, time = 1, bufnum, rate = 1, amp = 1, strokesPerSec = 18,
	attack = 0.002, decay = 0.01,	// attack and decay of individual stroke
	panStart = 0, panEnd = 0,	out|
	var	sig, envDefault, env,
	trig = Impulse.ar(strokesPerSec),
	trigs = PulseDivider.ar(trig, 2, (0..1)),
	strokeEnv = EnvGen.ar(Env.linen(attack, strokesPerSec.reciprocal - attack - decay, decay), trigs);
	// time of this env must add up to 1.0 sec
	envDefault = Env(#[0, 1, 0], #[0.001, 0.999], -4);
	// 40 == 10 possible envelope segments (which is a lot, really)
	env = Control.names(\env).kr((0 ! 40).overWrite(envDefault.asArray, 0));
	sig = (PlayBuf.ar(1, bufnum, rate * BufRateScale.kr(bufnum), trigs, start, 1) * strokeEnv).sum
	* EnvGen.ar(env, timeScale: time, doneAction:2);
	Out.ar(out, Pan2.ar(sig, Line.kr(panStart, panEnd, time), amp));
}).memStore(\ddwSynths);

SynthDef(\bufRollPanChangeRate, { |start, time = 1, bufnum, rate = 1, amp = 1,
	strokeRateStart = 18, strokeRateEnd = 18,
	attack = 0.002, decay = 0.01,	// attack and decay of individual stroke
	panStart = 0, panEnd = 0,	out|
	var	sig, envDefault, env,
	strokesPerSec = XLine.kr(strokeRateStart, strokeRateEnd, time),
	trig = Impulse.ar(strokesPerSec),
	trigs = PulseDivider.ar(trig, 2, (0..1)),
	strokeEnv = EnvGen.ar(Env.linen(attack, strokesPerSec.reciprocal - attack - decay, decay), trigs);
	// time of this env must add up to 1.0 sec
	envDefault = Env(#[0, 1, 0], #[0.001, 0.999], -4);
	// 40 == 10 possible envelope segments (which is a lot, really)
	env = Control.names(\env).kr((0 ! 40).overWrite(envDefault.asArray, 0));
	sig = (PlayBuf.ar(1, bufnum, rate * BufRateScale.kr(bufnum), trigs, start, 1) * strokeEnv).sum
	* EnvGen.ar(env, timeScale: time, doneAction:2);
	Out.ar(out, Pan2.ar(sig, Line.kr(panStart, panEnd, time), amp));
}).memStore(\ddwSynths);

