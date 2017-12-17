
s.sendMsg(\g_new, 2000);
s.sendMsg(\g_new, 2001, 3, 2000);
s.sendMsg(\g_new, 2002, 3, 2001);
s.sendMsg(\g_new, 2003, 3, 2002);
~proc = NetAddr("127.0.0.1", 12321);

//Audio Rate Phasor-Driven Clock Object
SynthDef(\phasorclock, {
	arg abus, kbus, stbpm=60.0, endbpm=120.0, dur=60.0, bpc=4.0, t_tr=1;
	var tempo = ( EnvGen.ar(Env.new([1.0, 0.0, 1.0], [0.0, dur]), t_tr).linexp(0.0, 1.0, stbpm, endbpm) / 60.0) / (SampleRate.ir*bpc);
	var clk = Phasor.ar(0, tempo);
	Out.ar(abus, clk);
	Out.kr(kbus, clk);
}).add;

//Object to create signal-rate triggers
SynthDef(\timedtrig, {
	arg ibs, obs, phase=0.5;
	var clk = In.ar(ibs);
	//var tr = (clk>phase) * (clk<(phase+0.0001));
	var tr = (clk>phase) * (clk<(phase+0.004));
	//var rp = SendReply( tr, '/test', [100,200], "ds", 3300);
	SendReply.kr( A2K.kr(tr), "/test", [40, 41, 42, 43] + MouseX.kr, 1905);
	Out.ar(obs, tr);
}).add;


//--supercollider code
s.boot

s.options.maxLogins = 5;
(
SynthDef(\osctest, {
        SendReply.kr(Impulse.kr(1), '/test', SinOsc.kr(0.11));
}).add;
)
Synth(\osctest)

o= OSCresponder(s.addr, '/test', {|t, r, m| m.postln}).add
o.remove




s.options.maxLogins = 10



s.sendMsg(\s_new, \phasorclock, 5000, 0, 2001, \abus, 100, \kbus, 0, \bpc, 16, \stbpm, 60, \endbpm, 60, \dur, 0.1, \t_tr, 1);
s.sendMsg(\s_new, \timedtrig, 10000, 0, 2002, \ibs, 100, \obs, 200, \phase, 0.33);
o = OSCFunc({ |msg| msg.postln }, "/test");

s.sendMsg(\n_free,10000);