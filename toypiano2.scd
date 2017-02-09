(
SynthDef(\toypiano, {
	arg obs=0, pitch=60, lfospd=0.5, t_tr=0;
	var imp = T2A.ar(t_tr);
	var freq = pitch.midicps;
	var sig = DynKlank.ar(
		`[
			[
				1*freq,
				1.0526645678458*freq,
				1.0722177540716*freq,
				1.1173842322068*freq,
				3.2137255202035*freq,
				6.4619017331061*freq,
				( (6.523014752975*freq).cpsmidi + SinOsc.kr(0.05*lfospd) ).midicps,
				10.754460040742*freq,
				( (10.872643827698*freq).cpsmidi + SinOsc.kr(0.03*lfospd) ).midicps,
				22.34655484674*freq
			],
			[
				0.18875469647576,
				0.58145809091593,
				0.69866162462817,
				0.13283592569299,
				1,
				0.88929800059361+LFTri.kr(0.05*lfospd).range(-0.2, 0.2),
				0.46474200944761+LFTri.kr(0.03*lfospd).range(-0.2, 0.2),
				0.4771785852636+LFTri.kr(0.08*lfospd).range(-0.2, 0.2),
				0.44083819263811+LFTri.kr(0.1*lfospd).range(-0.2, 0.2),
				0.1543129814717+LFTri.kr(0.04*lfospd).range(-0.05, 0.05)
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
		imp);
	Out.ar(obs, sig);
}).add;
)

//GROUPS
s.sendMsg(\g_new, 2000); 9.do{|ix| s.sendMsg(\g_new, 2001+ix, 3, 2000+ix)};
//Make Synth
(
~cf=60;
s.sendMsg(\s_new, \toypiano, 3000, 0, 2002, \t_tr, 1, \pitch, ~cf, \lfospd, 0.3);
s.sendMsg(\s_new, \toypiano, 3001, 0, 2002, \t_tr, 1, \pitch, ~cf+3, \lfospd, 0.32);
s.sendMsg(\s_new, \toypiano, 3002, 0, 2002, \t_tr, 1, \pitch, ~cf+5, \lfospd, 0.38);
s.sendMsg(\s_new, \toypiano, 3003, 0, 2002, \t_tr, 1, \pitch, ~cf+11, \lfospd, 0.4);
s.sendMsg(\s_new, \toypiano, 3004, 0, 2002, \t_tr, 1, \pitch, ~cf+1, \lfospd, 0.5);
)

(
~cf=57;
s.sendMsg(\n_set, 3000, \t_tr, 1, \pitch, ~cf);
s.sendMsg(\n_set, 3001, \t_tr, 1, \pitch, ~cf+11);
)
(
~cf=63;
s.sendMsg(\n_set, 3000, \t_tr, 1, \pitch, ~cf);
s.sendMsg(\n_set, 3002, \t_tr, 1, \pitch, ~cf+3);
)
(
~cf=69;
s.sendMsg(\n_set, 3000, \t_tr, 1, \pitch, ~cf);
s.sendMsg(\n_set, 3003, \t_tr, 1, \pitch, ~cf+5);
)
(
~cf=60;
s.sendMsg(\n_set, 3000, \t_tr, 1, \pitch, ~cf);
s.sendMsg(\n_set, 3004, \t_tr, 1, \pitch, ~cf+1);
)

s.queryAllNodes