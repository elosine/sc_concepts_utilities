/*
it uses 4 oscillators tuned almost to unison (the trumpet only uses 2). 3 are sawtooths and one is pulse with a slow LFO modulating pulsewidth. 2 oscillators go into one 440 LPF and 2 go into another 440 LPF (they run in parallel). Using two 440's may not be too important but it allows for more complex breath control of timbre by allowing different breath control intensity and timbre for different parts of the sound (you'll note that in the brass MP3 I can go from full mellow sounding french horn to piercing trumpet just using breath). From there they go into an MOTM 410 Triple resonance filter. I use that like a fixed filter bank or parametric EQ to get a more realistic brass sound by tuning the three filters and using the mix knob to add that to the sound. From there it goes through a 420 LPF under breath control. This allows final tone shaping and at times a greather than 24db rolloff because it's in series with the other filters. Then from there the sound goes through a VCA under breath control and that's it. I also went through an MXR Stereo Chorus to turn a mono sound into a stereo one, and then through the crappy reverb built into my Yamaha mixer.
*/
//Trombone

//3 oscillators & an envelope
SynthDef( \tbone, {
	arg obs=0, pitch=60, amp=0.87, dur=3, t_tr=1;
	var osc1, osc2, osc3, osc4;
	var sig, env;
	env = EnvGen.ar(Env.perc(0.01, dur), t_tr);
	osc1 = Saw.ar(pitch.midicps);
	osc2 = Saw.ar( ( pitch + LFTri.kr(0.05).range(-0.05, 0.05) ).midicps );
	osc3 = Saw.ar( ( pitch + LFTri.kr(0.08).range(-0.04, 0.04) ).midicps );
	osc4 = Pulse.ar( pitch.midicps, LFTri.kr(0.03).range(0.334, 0.667) );
	sig = Mix.ar([osc1,osc2,osc3,osc4]*0.25);
	Out.ar(obs,sig*amp*env);
}).add;

s.sendMsg(\g_new, 2000);
s.sendMsg(\s_new, \tbone, 3000, 0, 2000, \pitch, 60, \dur, 3.0, \t_tr, 1);
s.sendMsg(\n_set, 3000, \t_tr, 1);



//Add 2 LPFs
SynthDef( \tbone, {
	arg obs=0, pitch=60, amp=0.87, dur=3, t_tr=1, ffreq1=440, ffreq2=440, q1=0.5, q2=0.5;
	var osc1, osc2, osc3, osc4;
	var sig, sig1, sig2, env;
	env = EnvGen.ar(Env.perc(0.01, dur), t_tr);
	osc1 = Saw.ar(pitch.midicps);
	osc2 = Saw.ar( ( pitch + LFTri.kr(0.01).range(-0.05, 0.05) ).midicps );
	osc3 = Saw.ar( ( pitch + LFTri.kr(0.024).range(-0.04, 0.04) ).midicps );
	osc4 = Pulse.ar( pitch.midicps, LFTri.kr(0.03).range(0.334, 0.667) );
	sig1 = Mix.ar([osc1,osc2]*0.5);
	sig1 = RLPF.ar(sig1, ffreq1, q1);
	sig2 = Mix.ar([osc3,osc4]*0.5);
	sig2 = RLPF.ar(sig2, ffreq2, q2);
	sig = Mix.ar([sig1, sig2]*0.5);
	Out.ar(obs,sig*amp*env);
}).add;

s.sendMsg(\g_new, 2000);
s.sendMsg(\s_new, \tbone, 3000, 0, 2000, \pitch, 60, \dur, 3.0, \t_tr, 1, \ffreq1, 500, \ffreq2, 5000, \q1, 0.1, \q2, 0.7);
s.sendMsg(\n_set, 3000, \t_tr, 1, \ffreq1, 500, \ffreq2, 5000, \q1, 0.1, \q2, 0.7, \pitch, 52);



//Add a 3 band resonant filter on 3rd, 5th, and 7th harmonic
SynthDef( \tbone, {
	arg obs=0, pitch=60, amp=0.87, dur=3, t_tr=1, ffreq1=440, ffreq2=440, q1=0.5, q2=0.5, sigamp=0.7, filtersigamp=0.3;
	var freq = pitch.midicps;
	var osc1, osc2, osc3, osc4;
	var sig, filtersig, sig1, sig2, env;
	env = EnvGen.ar(Env.perc(0.01, dur), t_tr);
	osc1 = Saw.ar(pitch.midicps);
	osc2 = Saw.ar( ( pitch + LFTri.kr(0.01).range(-0.05, 0.05) ).midicps );
	osc3 = Saw.ar( ( pitch + LFTri.kr(0.024).range(-0.04, 0.04) ).midicps );
	osc4 = Pulse.ar( pitch.midicps, LFTri.kr(0.03).range(0.334, 0.667) );
	sig1 = Mix.ar([osc1,osc2]*0.5);
	sig1 = RLPF.ar(sig1, ffreq1, q1);
	sig2 = Mix.ar([osc3,osc4]*0.5);
	sig2 = RLPF.ar(sig2, ffreq2, q2);
	sig = Mix.ar([sig1, sig2]*0.5);
	filtersig = DynKlank.ar(`[ [(3*freq), (5*freq), (7*freq)], [0.002, 0.003, 0.005], [ (0.5*dur), (0.7*dur), (0.9*dur) ] ], sig);
	sig = Mix.ar([sig*sigamp, filtersig*filtersigamp]);
	Out.ar(obs,sig*amp*env);
}).add;

s.sendMsg(\g_new, 2000);
s.sendMsg(\s_new, \tbone, 3000, 0, 2000, \pitch, 60, \dur, 3.0, \t_tr, 1, \ffreq1, 500, \ffreq2, 5000, \q1, 0.1, \q2, 0.7);
s.sendMsg(\n_set, 3000, \t_tr, 1, \ffreq1, 500, \ffreq2, 5000, \q1, 0.1, \q2, 0.7, \pitch, 54, \filtersigamp, 0.15, \dur, 1.8, \sigamp, 0.85);

(
//Add a final lpf
SynthDef( \tbone, {
	arg obs=0, pitch=60, amp=0.87, dur=3, t_tr=1, ffreq1=440, ffreq2=440, q1=0.5, q2=0.5, sigamp=0.7, filtersigamp=0.3, fatk=0.2, fsus=0.5, frel=0.3, mq=0.5, mflo=500, mfhi=10000, t60=1, damp=0.5, sz=1;
	var freq = pitch.midicps;
	var osc1, osc2, osc3, osc4;
	var sig, filtersig, sig1, sig2, env, fenv;
	env = EnvGen.ar(Env.perc(0.01, dur), t_tr);
	osc1 = Saw.ar(pitch.midicps);
	osc2 = Saw.ar( ( pitch + LFTri.kr(0.01).range(-0.05, 0.05) ).midicps );
	osc3 = Saw.ar( ( pitch + LFTri.kr(0.024).range(-0.04, 0.04) ).midicps );
	osc4 = Pulse.ar( pitch.midicps, LFTri.kr(0.03).range(0.334, 0.667) );
	sig1 = Mix.ar([osc1,osc2]*0.5);
	sig1 = RLPF.ar(sig1, ffreq1, q1);
	sig2 = Mix.ar([osc3,osc4]*0.5);
	sig2 = RLPF.ar(sig2, ffreq2, q2);
	sig = Mix.ar([sig1, sig2]*0.5);
	filtersig = DynKlank.ar(`[ [(3*freq), (5*freq), (7*freq)], [0.002, 0.003, 0.005], [ (0.5*dur), (0.7*dur), (0.9*dur) ] ], sig);
	sig = Mix.ar([sig*sigamp, filtersig*filtersigamp]);
	fenv =   (EnvGen.kr(Env.linen(fatk*dur, fsus*dur, frel*dur,), t_tr)*mfhi)+mflo   ;
	sig = RLPF.ar(sig, fenv, mq);
	//sig = JPverb.ar(sig, t60, damp, sz);
	sig = FreeVerb.ar(sig);
	Out.ar(obs,sig*amp*env);
}).add;

s.sendMsg(\g_new, 2000);
)
s.sendMsg(\s_new, \tbone, 3000, 0, 2000, \pitch, 60, \dur, 3.0, \t_tr, 1, \ffreq1, 500, \ffreq2, 5000, \q1, 0.1, \q2, 0.7);
s.sendMsg(\n_set, 3000, \t_tr, 1, \ffreq1, 500, \ffreq2, 5000, \q1, 0.1, \q2, 0.7, \pitch, 30, \filtersigamp, 0.25, \dur, 3, \sigamp, 0.75, \mq, 0.7, \fatk, 0.3, \fsus, 0.3, \frel, 0.4, \mflo, 500, \mfhi, 11000);

s.sendMsg(\s_new, \tbone, 3001, 0, 2000, \pitch, 60, \dur, 3.0, \t_tr, 1, \ffreq1, 500, \ffreq2, 5000, \q1, 0.1, \q2, 0.7);



s.sendMsg(\s_new, \tbone, 3002, 0, 2000, \pitch, 60, \dur, 3.0, \t_tr, 1, \ffreq1, 500, \ffreq2, 5000, \q1, 0.1, \q2, 0.7);

(
s.sendMsg(\n_set, 3000, \t_tr, 1, \ffreq1, 500, \ffreq2, 5000, \q1, 0.1, \q2, 0.7, \pitch, 33, \filtersigamp, 0.25, \dur, 3, \sigamp, 0.75, \mq, 0.8, \fatk, 0.3, \fsus, 0.3, \frel, 0.4, \mflo, 500, \mfhi, 11000, \amp, 1);

s.sendMsg(\n_set, 3001, \t_tr, 1, \ffreq1, 500, \ffreq2, 5000, \q1, 0.1, \q2, 0.7, \pitch, 63, \filtersigamp, 0.25, \dur, 3, \sigamp, 0.75, \mq, 0.8, \fatk, 0.3, \fsus, 0.3, \frel, 0.4, \mflo, 500, \mfhi, 11000, \amp, 1.4);

s.sendMsg(\n_set, 3002, \t_tr, 1, \ffreq1, 500, \ffreq2, 5000, \q1, 0.1, \q2, 0.7, \pitch, 67, \filtersigamp, 0.25, \dur, 3, \sigamp, 0.75, \mq, 0.8, \fatk, 0.3, \fsus, 0.3, \frel, 0.4, \mflo, 500, \mfhi, 11000, \amp, 1.4);
)

//add a bunch of lfos

	