s.waitForBoot{ fork{

	s.sendMsg(\b_allocRead, 0, "/home/pi/perfectday.aif");
	SynthDef(\playbuf, {|buf=0 amp=1 loop=1 obs=0| Out.ar(obs, PlayBuf.ar(2, buf, loop:loop)*amp }).add;
		0.1.wait;
		s.sendMsg(\s_new, \playbuf, 3000, 0, 1, \buf, 0);

	}};