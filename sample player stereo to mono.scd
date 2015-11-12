
	SynthDef(\sampS2M, {
		arg obs=0, atk=0.01, rel=0.1, crv= -3, gate=1, sbuf, mbuf, amp = 1,
		rate=1, start=0, loop=0;
		var env, in,sig, tr;
		tr = \t_tr.kr(1,0)
		env = EnvGen.ar(Env.asr(atk, 1, rel, crv), gate);
		sig = PlayBuf.ar( 2, sbuf,rate, tr, start, loop);
		RecordBuf.ar( sig.sum, mbuf, loop:loop, trigger:tr);
		in = PlayBuf.ar(1, mbuf, rate, tr, start, loop);
		Out.ar(obs, in*env*amp);
	}).add;