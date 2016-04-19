(s.options.numAudioBusChannels_(1000);  s.waitForBoot{fork{
	////Groups
	s.sendMsg(\g_new, 900, 1, 1);
	10.do{|ix| s.sendMsg(\g_new, 901+ix, 3, 900+ix)};
	s.sendMsg(\b_allocRead, 0, "/Users/jyang/GitHub/liveprocessing/samples/saxsample.aif");
	s.sendMsg(\b_allocRead, 1, "/Users/jyang/GitHub/liveprocessing/samples/Blackbird.aif");
	s.sendMsg(\b_allocRead, 2, "/Users/jyang/GitHub/liveprocessing/samples/icecreamtruckmf.aif");
	s.sendMsg(\b_allocRead, 3, "/Users/jyang/GitHub/liveprocessing/samples/mirdangamRoll1.aif");
	s.sendMsg(\b_allocRead, 4, "/Users/jyang/GitHub/liveprocessing/samples/tambura.aif");
	s.sendMsg(\b_allocRead, 5, "/Users/jyang/GitHub/liveprocessing/samples/unacorda.aif");


	SynthDef(\playsamp_m, {
		arg obs=0,atk=0.02,rel=0.1,crv= 0,gate=1,buf,loop=1;
		var src, sig, env, amp;
		amp = \amp.kr(0.85,0.01);
		env = EnvGen.ar( Env.asr(atk, 1, rel, crv), gate );
		sig = PlayBuf.ar(1, buf,loop:loop);
		Out.ar(obs, sig*amp*env);
	}).add;
	SynthDef(\playsamp_s, {
		arg ibs,obs=0,atk=0.02,rel=0.1,crv= 0,gate=1,buf,loop=1;
		var src, sig, env, amp;
		amp = \amp.kr(0.85,0.01);
		env = EnvGen.ar( Env.asr(atk, 1, rel, crv), gate );
		sig = PlayBuf.ar(2, buf,loop:loop);
		Out.ar(obs, sig*amp*env);
	}).add;

	SynthDef(\conv, {
		arg ibs1, ibs2, obs;
		var src, i1, i2, sig1, sig2, a1, a2, amp;
		amp = \amp.kr(0.85, 0.01);
		a1 = \a1.kr(0.5, 0.01);
		a2 = \a2.kr(0.5, 0.01);
		src = In.ar(ibs1)*a1;
		i1 = In.ar(ibs2);
		i2 = In.ar(ibs2+1);
		sig1 = Convolution.ar(src, i1*a2, 1024);
		sig2 = Convolution.ar(src, i2*a2, 1024);
		Out.ar(obs, [sig1,sig2]*amp);
	}).add;

	0.5.wait;

	s.sendMsg(\s_new, \playsamp_m, 3000, 0, 901, \buf, 0, \obs, 50); //sax


	s.sendMsg(\s_new, \playsamp_s, 3001, 0, 901, \buf, 1, \obs, 52); //bird
	s.sendMsg(\s_new, \playsamp_s, 3002, 0, 901, \buf, 2, \obs, 54); //icecream
	s.sendMsg(\s_new, \playsamp_s, 3003, 0, 901, \buf, 3, \obs, 56); //mirdungam
	s.sendMsg(\s_new, \playsamp_s, 3004, 0, 901, \buf, 4, \obs, 58); //tambura
	s.sendMsg(\s_new, \playsamp_s, 3005, 0, 901, \buf, 5, \obs, 60); //unacorda



}})


s.sendMsg(\s_new, \conv, 3100, 0, 902, \ibs1, 50, \ibs2, 52, \obs, 0);
s.sendMsg(\n_set, 3100,\a1, 0.3, \a2, 1.0);
s.sendMsg(\n_set, 3100, \ibs2, 54);
s.sendMsg(\n_free, 3100);
s.queryAllNodes



