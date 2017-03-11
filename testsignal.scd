(
s.options.numOutputBusChannels = 8;
s.waitForBoot{fork{
	SynthDef(\testsignal, {
		arg obs=0, amp=1;
		var sig = Decay.ar(Impulse.ar(2), 0.1) * WhiteNoise.ar(0.2);
		Out.ar(obs, sig);
	}).add;
	0.1.wait;
	s.sendMsg(\s_new, \testsignal, 3000, 0, 1, \obs, 0);
	0.1.wait;
	{s.meter}.defer;
}}
)

s.sendMsg(\n_set, 3000, \obs, 7);
s.queryAllNodes