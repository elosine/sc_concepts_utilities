MIDIdef.noteOn(\noteon, { arg vel, nn, chan, src; ~notes[nn] = Synth.new( \chariots, [ \pitch, nn, \amp, vel.linexp(1,127,0.1, 1), \gate, 1 ] )});

MIDIdef.noteOn(\noteon, { arg vel, nn, chan, src; ~notes[nn] = Synth.new( \wonder, [ \pitch, nn, \amp, vel.linexp(1,127,0.1, 1), \gate, 1 ] )});

MIDIdef.noteOn(\noteon, { arg vel, nn, chan, src; ~notes[nn] = Synth.new( \synthbass, [ \pitch, nn, \amp, vel.linexp(1,127,0.1, 1), \gate, 1 ] )});

(
s.options.memSize = 81920;
s.waitForBoot{
	MIDIClient.init;
	MIDIIn.connectAll;

	~notes = Array.newClear(128);

	MIDIdef.noteOn(\noteon, {
		arg vel, nn, chan, src;
		~notes[nn] = Synth.new( \chariots, [ \pitch, nn, \amp, vel.linexp(1,127,0.1, 1), \gate, 1 ] );
	});

	MIDIdef.noteOff(\noteoff, {
		arg vel, nn;
		~notes[nn].set(\gate, 0);
		~notes[nn] = nil;
	});

	SynthDef( \wonder, {
		arg pitch=60, gate=1,
		predelay=0.01, speed= 0.005, depth=0.03, ph_diff=0.5, //0.03
		amp=0.5, och=0,
		atk=0.001, sus=0.4, rel=0.03, pluckamp=4;
		var sig, env, modulators, numDelays = 12, sigd, pluck, coef;
		var freq = pitch.midicps;
		var s2del = TRand.kr(0.05, 0.07, gate); //0.07
		var hpf = TRand.kr(1650, 1750, gate); //1700
		var lpf = TRand.kr(3500, 4500, gate); //4000
		var decay = TRand.kr(0.08, 0.11, gate);//0.1
		env = EnvGen.ar( Env.adsr(atk,decay, sus, rel), gate, doneAction:2);
		sig = Pulse.ar( freq, 0.29);
		sig = RHPF.ar(sig, hpf, 0.8);
		sig = RLPF.ar(sig, lpf, 0.8);
		// pluck = Pluck.ar( WhiteNoise.ar(0.2), gate, (freq*2).reciprocal, (freq*2).reciprocal, rel*24, 0.1);
		coef = TRand.kr(0.01, 0.06, gate);
		pluck = Pluck.ar( WhiteNoise.ar(0.1)+sig, gate, freq.reciprocal, freq.reciprocal, rel*24, coef);
		sigd = DelayC.ar(sig, 0.2, s2del);

		sig = sig*numDelays.reciprocal;
		modulators = Array.fill( numDelays, { arg i;
			LFPar.kr( speed * rrand(0.94, 1.06), ph_diff * i, depth, predelay )
		});
		sig = DelayC.ar(sig, 0.5, modulators);
		sig = sig.sum;

		sig = Decimator.ar( (sig+sigd), 44100, 6 );
		sig = (pluck*pluckamp)+sig;
		// Out.ar(och, sig*env*amp);
		Out.ar(0, [ sig , DelayC.ar( sig, 0.2, 0.02)]*env*amp);
		// Out.ar(0, [ pluck , DelayC.ar( pluck, 0.2, 0.02)]*env*amp);
	}).add;
}

SynthDef( \synthbass,{
	arg gate=1, atk=0.01, rel=0.07, crv= -6,
	fatk=0.01, fdky=0.14, fsus=0.1, frel=0.07, fcrv= 0,
	ffrq1=1800, rq1=0.6, dky=0, sus=1;
	var freq1, osc1, vol, amp, env,
	osc2, osc3, freq2, freq3,
	sig, pitch, fenv, sigR;
	pitch = \pitch.kr(60, 0.017);
	freq1 = pitch.midicps;
	freq2 = (pitch+0.06).midicps;
	freq3 = (pitch-12).midicps;
	amp = \amp.kr(0.85, 0.040);
	env = EnvGen.ar( Env.adsr(atk, dky, sus, rel, curve:crv), gate, doneAction:2);
	fenv = EnvGen.ar( Env.adsr(fatk, fdky, fsus, frel, curve:fcrv), gate);
	osc1 = SawDPW.ar(freq1);
	osc2 = SawDPW.ar(freq2);
	osc3 = SinOsc.ar(freq3);
	sig = Mix.ar([osc1, osc2, osc3]);
	sig = RLPF.ar( sig, (ffrq1*fenv)+80, rq1 );
	sig = sig.softclip;
	sigR = DelayC.ar(sig, 0.2, 0.03);
	Out.ar(0, [sig, sigR]*env*amp);
}).add;

SynthDef(\kick,{
		arg out=0, bodyAttTa=0, bodyDecTa=0.1, bodyAttCa=0, bodyDecCa=2.neg, pitchDeviation=200, pitchOffset=50, decTp=0.06, decCp=6.neg, amp=1, bpm=6, doneAct=2, bodyRatio=0.8, bodyIndex=0.8, klickModRatio=9, klickModIndex=20, klickRatio=0.1, klickAttT=0, klickDecT=0.01, klickAttC=0, klickDecC=6.neg, bodyAmp=1, klickAmp=0.2, noiseAttT=0, noiseDecT=0.01, noiseAttC=0, noiseDecC=2.neg, noiseAmp=0.7, noiseCutoff=8000, noiseRq=0.8, filterFreq=120, res=0.6, inputGain=1, filteredAmp=1, gate=1;
		var trig, body, klickMod, klick, bodyAmpEnv, pitchEnv, klickAmpEnv, noiseAmpEnv, noise,filtered;

		bodyAmpEnv = EnvGen.ar(Env([0,1,0],[bodyAttTa,bodyDecTa],[bodyAttCa,bodyDecCa]),gate,doneAction:doneAct);
		pitchEnv = EnvGen.ar(Env([0,1,0],[0,decTp],decCp),gate,pitchDeviation,pitchOffset);
		klickAmpEnv = EnvGen.ar(Env([0,1,0],[klickAttT,klickDecT],[klickAttC,klickDecC]),gate);
		noiseAmpEnv = EnvGen.ar(Env([0,1,0],[noiseAttT,noiseDecT],[noiseAttC,noiseDecC]),gate,noiseAmp);

		body = SinOsc.ar(pitchEnv,SinOsc.ar(pitchEnv*bodyRatio,0,bodyIndex*bodyAmpEnv,0.25pi),bodyAmpEnv);
		klickMod = SinOsc.ar(pitchEnv*klickModRatio,0,klickModIndex,0.25pi);
		klick = (SinOsc.ar(pitchEnv*klickRatio,klickMod,klickAmpEnv) + SinOsc.ar(pitchEnv*klickRatio*8,klickMod,klickAmpEnv*0.125));
		noise = BLowPass.ar(WhiteNoise.ar,noiseCutoff,noiseRq,noiseAmpEnv);
		filtered = DFM1.ar(body + klick,filterFreq,res,inputGain,0,0.0003,filteredAmp);

		Out.ar(out,(body*bodyAmp + (klick*klickAmp) + noise + filtered)*amp!2)
	}).add;

SynthDef(\pad, {
	arg atk=0.3, dur=3, rel=0.5,gate=1, crv = -2,
	lffreq1=2, lffreq2=2, lf1lo=0.14, lf1hi=0.20,
	lf2lo=0.74, lf2hi=0.8, detune1= -0.06, detune2 = 0.06, detune3 = -12.06,
	ffreq = 2500;
	var osc1,osc2, osc3;
	var freq1, freq2, freq3;
	var env, sus, sig, amp, pitch, sig2;
	var lfo1, lfo2;
	pitch = \pitch.kr(64, 0.03);
	amp = \amp.kr(0.75, 0.03);
	lfo1 = SinOsc.kr(lffreq1).range(lf1lo, lf1hi);
	lfo2 = SinOsc.kr(lffreq2).range(lf2lo, lf2hi);
	sus = dur-atk;
	env = EnvGen.ar(Env.adsr(atk, sus, rel, curve: crv),gate, doneAction:2);
	freq1 = (pitch+detune1).midicps;
	freq2 = (pitch+detune2).midicps;
	freq3 = (pitch+detune3).midicps;
	osc1 = Pulse.ar(freq1, lfo1);
	osc2 = Pulse.ar(freq2, lfo2);
	osc3 = Pulse.ar(freq3, lfo1);
	sig = Mix.ar([osc1*0.33333, osc2*0.33333, osc3*0.33333]);
	sig = DFM1.ar(sig, ffreq, type:0);
	sig2 = DelayC.ar(sig, 0.2, 0.05);

	Out.ar(0, [sig, sig2]*env*amp);
}).add;

SynthDef( \chariots, {
	arg atk=0.1, rel=2, crv = 0, gate=1, lffreq=0.06, detune = 0.06,
	lpfreq=6000, fatk=1.6, frel=7.7, fcrv=0,
	mix=0.7, rm=0.9, dmp=0.07;
	var osc1, osc2, freq1, freq2, env, pitch, amp, sig, lfo1, pitch2,
	fenv;
	fenv = EnvGen.ar( Env.asr(fatk, 1, frel, fcrv), gate );
	lfo1 = SinOsc.kr(lffreq);
	pitch = \pitch.kr(60, 0.017);
	pitch2 = pitch + (lfo1*detune) ;
	amp = \amp.kr(0.85, 0.017);
	env = EnvGen.ar( Env.asr(atk, 1, rel, crv), gate , doneAction:2);
	freq1 = pitch.midicps;
	freq2 = pitch2.midicps;
	osc1 = Saw.ar(freq1);
	osc2 = Saw.ar(freq2);
	sig = Mix.ar( [osc1, osc2] );
	sig = RLPF.ar(sig, (lpfreq*fenv)+100 );
	//sig = FreeVerb2.ar(sig, sig, mix, rm, dmp);
	sig = JPverb.ar(sig, 4, 0, 4);
	Out.ar(0, sig*amp*env);
}).add;
)

