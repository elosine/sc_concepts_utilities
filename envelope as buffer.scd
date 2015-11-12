(
//MAKE ENVELOPES
~numenv = 3;
~envs = Array.newClear(~numenv);
~envbufs = Array.newClear(~numenv);
~envmakers = {EnvScaleView()}!~numenv;
~envmakers.do{|it| it.view.front};
)
//Store them in an array
~envmakers.do{|it ix| ~envs[ix]=it.env};
//Convert envs to signals and then load into buffers
~envs.do{|it ix| ~envbufs[ix]=Buffer.loadCollection(s, it.asSignal(512))};
//Write to Disk (if you like them!)
~path = "/Users/jyang/Dropbox/supercollider/Concepts and Utilities/Envelope Buffers/";
~envbufs.do{|it ix| it.write(~path++"envbuf"++ix.asString++".aif")};
~envbufs[0].write(~path ++ "backwardsEnv01");
(
SynthDef(\bufenv, {
	arg envbuf, freq=300, dur=1.0;
	var env, envindex, synth, onesecond;
	onesecond = 1.0/(BufRateScale.kr(envbuf)*(BufSampleRate.kr(envbuf)/BufFrames.kr(envbuf)));
	env = PlayBuf.ar(1, envbuf, onesecond/dur, \t_tr.kr(0, 0.001));
	synth = BlitB3Square.ar(freq);
	Out.ar(0, [synth, DelayC.ar(synth, 0.2, 0.05)]*env );
}).add;

)

a = Synth(\bufenv, [\envbuf, ~envbufs[0], \t_tr, 1] );
a.set(\t_tr, 1, \dur, 0.3, \envbuf, ~envbufs[2]);
a.set(\t_tr, 1, \dur, 1.3, \envbuf, ~envbufs[1]);
a.set(\t_tr, 1, \dur, 3, \envbuf, ~envbufs[0]);
a.free;

//Load from saved envelope buffer
b = Buffer.read(s, "/Users/jyang/Dropbox/supercollider/Concepts and Utilities/Envelope Buffers/envbuf1.aif");
~b2 = Buffer.read(s, "/Users/jyang/Dropbox/supercollider/Concepts and Utilities/Envelope Buffers/envbuf0.aif");
~b3 = Buffer.read(s, "/Users/jyang/Dropbox/supercollider/Concepts and Utilities/Envelope Buffers/envbuf2.aif");

c = Synth(\bufenv, [\envbuf, ~b2, \t_tr, 1] );
c.set(\t_tr, 1, \dur, 1.5, \envbuf, b);
c.set(\t_tr, 1, \dur, 1.5, \envbuf, ~b2);
c.set(\t_tr, 1, \dur, 1.5, \envbuf, ~b3);
b.plot;

//CREATE GUI AND LOAD BACK TO PROCESSING

