s.options.memSize = 51200;
s.options.numAudioBusChannels = 200;
s.waitForBoot{ fork{
	var path = "/home/pi/";
	////Main Sample
	s.sendMsg(\b_allocRead, 0, path ++ "samples/LZ_OceanRiff_Mono.aif");
	////Envelope Buffers
		s.sendMsg(\b_allocRead, 100, path ++ "grainEnv/gEnv_3stageLinear.aif");
		s.sendMsg(\b_allocRead, 101, path ++ "grainEnv/gEnv_hanning.aif");
		s.sendMsg(\b_allocRead, 102, path ++ "grainEnv/gEnv_gauss.aif");
		s.sendMsg(\b_allocRead, 103, path ++ "grainEnv/gEnv_blackman.aif");
		s.sendMsg(\b_allocRead, 104, path ++ "grainEnv/gEnv_hamming.aif");
		s.sendMsg(\b_allocRead, 105, path ++ "grainEnv/gEnv_quasiGauss.aif");
		s.sendMsg(\b_allocRead, 106, path ++ "grainEnv/gEnv_blackmanHarris.aif");
		s.sendMsg(\b_allocRead, 107, path ++ "grainEnv/gEnv_tri.aif");
		s.sendMsg(\b_allocRead, 108, path ++ "grainEnv/gEnv_expodec.aif");
		s.sendMsg(\b_allocRead, 109, path ++ "grainEnv/gEnv_rexpodec.aif");
		////Groups
		s.sendMsg(\g_new, 300, 1, 1);
		10.do{|ix| s.sendMsg(\g_new, 301+ix, 3, 300+ix)};
		//SYNTHDEFS///////////////////
		SynthDef(\indexer, {
			arg buf, spd=1, start=0, end=1, abus=99, kbus, t_tr=0, pos=0;
			var index, indexnorm;
			index = Phasor.ar(t_tr, BufRateScale.kr(buf)*spd, start*BufFrames.kr(buf), end*BufFrames.kr(buf), pos*BufFrames.kr(buf));
			indexnorm = index.linlin(0.0, BufFrames.kr(buf), 0.0, 1.0);
			Out.ar(abus, index);
			Out.kr(kbus, indexnorm);
		}).add;
		SynthDef(\sampplay, {
			arg idxbus, obs=0, buf, gate=1, start=0, end=1;
			var index, samp, env;
			index = In.ar(idxbus);
			env = EnvGen.ar(Env.asr(releaseTime:0.01, curve:0),gate);
			samp = BufRd.ar(1, buf, index);
			Out.ar(obs, samp*env);
		}).add;
		SynthDef(\amplify, {
			arg ibs, obs=0, pobs, pobs2, gate=1;
			var src, sig, env, amp, sig2;
			amp = \amp.kr(0.85, 0.03);
			env = EnvGen.ar(Env.asr(releaseTime:0.01),gate,doneAction:2);
			src = In.ar(ibs);
			sig = src;
			sig2 = DelayC.ar(sig, 0.2, 0.05);
			Out.ar(pobs, [sig, sig2]*env*amp); //out to private (stereo) bus
			Out.ar(pobs2, [sig, sig2]*env*amp); //out to private (stereo) bus
			Out.ar(obs, [sig, sig2]*env*amp);
		}).add;


		SynthDef(\greyhole, {
			arg ibs, obs=0, pobs, pobs2, gate=1, rel=1.7, mamp=0.6;
			var del=\del.kr(2, 0.03), damp=\damp.kr(0, 0.03), size=\size.kr(1, 0.03),
			diff=\diff.kr(0.707, 0.03), fb=\fb.kr(0.9, 0.03), moddepth=\moddepth.kr(0.1, 0.03), modfreq=\modfreq.kr(2, 0.03);
			var source, sig, env, amp, sig2;
			amp = \amp.kr(0.8, 0.03)*mamp;
			env = EnvGen.ar(Env.asr(releaseTime:rel), gate, doneAction:2);
			source = In.ar(ibs);
			sig = Greyhole.ar(source, del, damp, size, diff, fb, moddepth, modfreq);
			sig2 = DelayC.ar(sig, 0.2, 0.05);
			Out.ar(obs, [sig, sig2]*env*amp);
			Out.ar(pobs, [sig, sig2]*env*amp);
			Out.ar(pobs2, [sig, sig2]*env*amp);
		}).add;

	10.wait;

	s.sendMsg(\s_new, \indexer, 3000, 0, 303, \buf, 0, \abus, 100, \kbus, 0);
	s.sendMsg(\s_new, \sampplay, 3010, 0, 304, \idxbus, 100, \obs, 104, \buf, 0);

}}
