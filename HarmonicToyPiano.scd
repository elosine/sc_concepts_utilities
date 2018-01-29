

(
s.waitForBoot{
	Server.default.makeGui;

	SynthDef(\toypiano, {
		arg obs=0, freq=60, lfospd=0.5, t_tr=0, gate=0;
		var imp = T2A.ar(t_tr);
		var noise = WhiteNoise.ar(0.1);
		var env = EnvGen.ar(Env.linen(0.005, 0, 0.005), t_tr);
		var senv = EnvGen.ar(Env.linen(0.01, 5, 0.01), doneAction:2);
		var sig = DynKlank.ar(
			`[
				[
					1*freq,
					1.0526645678458*freq,
					1.0722177540716*freq,
					1.1173842322068*freq,
					3.2137255202035*freq,
					6.4619017331061*freq,
					6.523014752975*freq,
					10.754460040742*freq,
					10.872643827698*freq,
					22.34655484674*freq
				],
				[
					0.18875469647576,
					0.58145809091593,
					0.69866162462817,
					0.13283592569299,
					1,
					0.88929800059361,
					0.46474200944761,
					0.47717858526362,
					0.44083819263811,
					0.1543129814717
				]*0.1,
				[
					2.7874822816943,
					3.0044616469429,
					3.0818892662019,
					2.7804810119127,
					1.3462578280856,
					2.6210993045158,
					2.3655306128538,
					1.5798209670323,
					2.4811880715523,
					1.4092510528673
				]
			],
			noise*env);
		Out.ar(obs, [sig, DelayC.ar(sig, 0.2, 0.03)]);
	}).add;

	f=32.704;
	w = Window.new("Harmonic Toy Piano");
	w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;
		switch( unicode,
			113, { Synth(\toypiano, [\t_tr, 1, \freq, f*1])},
			119, { Synth(\toypiano, [\t_tr, 1, \freq, f*2])},
			101, { Synth(\toypiano, [\t_tr, 1, \freq, f*3])},
			114, { Synth(\toypiano, [\t_tr, 1, \freq, f*4])},
			116, { Synth(\toypiano, [\t_tr, 1, \freq, f*5])},
			121, { Synth(\toypiano, [\t_tr, 1, \freq, f*6])},
			117, { Synth(\toypiano, [\t_tr, 1, \freq, f*7])},
			105, { Synth(\toypiano, [\t_tr, 1, \freq, f*8])},
			111, { Synth(\toypiano, [\t_tr, 1, \freq, f*9])},
			112, { Synth(\toypiano, [\t_tr, 1, \freq, f*10])},
			97, { Synth(\toypiano, [\t_tr, 1, \freq, f*11])},
			115, { Synth(\toypiano, [\t_tr, 1, \freq, f*12])},
			100, { Synth(\toypiano, [\t_tr, 1, \freq, f*13])},
			102, { Synth(\toypiano, [\t_tr, 1, \freq, f*14])},
			103, { Synth(\toypiano, [\t_tr, 1, \freq, f*15])},
			104, { Synth(\toypiano, [\t_tr, 1, \freq, f*16])},
			106, { Synth(\toypiano, [\t_tr, 1, \freq, f*17])},
			107, { Synth(\toypiano, [\t_tr, 1, \freq, f*18])},
			108, { Synth(\toypiano, [\t_tr, 1, \freq, f*19])},
			122, { Synth(\toypiano, [\t_tr, 1, \freq, f*20])},
			120, { Synth(\toypiano, [\t_tr, 1, \freq, f*21])},
			99, { Synth(\toypiano, [\t_tr, 1, \freq, f*22])},
			118, { Synth(\toypiano, [\t_tr, 1, \freq, f*23])},
			98, { Synth(\toypiano, [\t_tr, 1, \freq, f*24])},
			110, { Synth(\toypiano, [\t_tr, 1, \freq, f*25])},
			109, { Synth(\toypiano, [\t_tr, 1, \freq, f*26])},
		);
	};
	w.front;

};

)


