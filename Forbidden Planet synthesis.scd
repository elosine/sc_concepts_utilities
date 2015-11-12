//From supercollider book

1.3 Forbidden Planet

(
play(
	{
		CombN.ar(
			SinOsc.ar(
				midicps(
					LFNoise1.ar(1, 24,
						LFSaw.ar([1, 5.123], 0, 3, 80)
					)
				),
				0, 0.4),
			1, 0.3, 2)
	}
)
)


//"http://ellejohara.com/blog/category/music/"  ellejohara  Astrid Lydia Johannsen
(
{
	var a = LFNoise0.kr(12).exprange(110, 880);
	Resonz.ar(
		LPF.ar(
			in:CombN.ar(
		in:SinOsc.ar( [a, a], 0, 0.2 ),
		maxdelaytime:2,
		delaytime:0.2,
		decaytime:10),
		freq:48, mul:16 ),
		freq:880,
		bwr:0.5,
		mul:8 )
}.play;

)

//Forbidden planet deconstruction

//comb filtered sine wave
{CombN.ar( in:SinOsc.ar( freq:LFNoise0.kr( MouseX.kr(2, 17, lag:0.01 )).exprange(MouseY.kr(100, 400), MouseY.kr(400, 800)), mul:0.2 ), maxdelaytime:0.2, delaytime:0.2, decaytime:10 ) }.play;




(
{
	var modulator, carrier;
	modulator = SinOsc.ar(MouseX.kr(2, 200, 1));
	carrier = SinOsc.ar(333, 0, modulator);
	carrier!2; // the output
}.play
)




(
play{Splay.ar(x=sin(CombL.ar(LPF.ar(InFeedback.ar(20,99),2e3),1,LFNoise1.kr(1e-3!99)+1/99,0.05)+Dust2.ar(0.01!99)))++(0!18)++(x-x.rotate/2)}
)

play{Splay.ar(a={|i|RLPF.ar(Trig.ar(InFeedback.ar(i+[-1,1]%6+2).sum.abs.lag(1e-3)<1e-4,8e-3),{2**10.rand*20}!4,1e-3,0s).mean.sin}!6,0.5)++a}

// 12-tone feedback ring
// Each "string" resonates itself and one adjacent string

s = Server.internal;
s.options.memSize=1572864;
s.options.numWireBufs=128;
Server.default = s.boot;
{
	{
		var beat, note, pan, durseq, maxdur, durindex, dur, section, sectionamp, n, restime, res, dynamic, dynamicsequence, rotated, envmode, env, attack, gate, envbalance, envlag, pluck, filtersweep, out;

		beat=0.09;
		"bpm=".post;
		(60/beat/4).postln;
		note=[0,8,3,12,2,13,23,15,17,14,20];
		pan=(note % 2 * 2 - 1) * note / 24;
		durseq=[1,1,1,1,2,2,2,2,3,3,3,3,1,1,1,1,1,1,1,1,4,4,4,4,6,2,6,2,6,2,6,2,16] * beat;
		maxdur=durseq.maxItem.postln;

		// each string toggles on and off after a different number of beats
		section=(note%3).nthPrime * (2**(note%7+5)) * beat;
		n=note.size;

		restime=(30+note).midicps.reciprocal - ControlRate.ir.reciprocal;
		res=DelayN.ar(LocalIn.ar(n),restime,restime);

		sectionamp=Amplitude.kr(DelayN.ar(res,section,section));
		dur=Demand.kr(Impulse.kr(0)+PulseCount.kr(sectionamp>0.2, sectionamp<0.1), 0, Dseq(durseq, inf));

		dynamic=Lag.kr(sectionamp,section/16);
		dynamic=PulseCount.kr(dynamic<0.1,dynamic>0.2);

		dynamicsequence=[0,1,0.9,0.8,0.7,0.8,2.5,0.5,2.5];
		dynamic=Select.kr(dynamic,dynamicsequence);
		dynamic=Lag.kr(dynamic,dur*2);

		rotated=DelayN.ar(res.rotate(1),maxdur,Slew.kr(dur,1+(3/4),1+(2/3)));

		attack=0.003;
		env=Amplitude.ar(DelayC.ar(res,maxdur,dur))<0.01;
		gate=min(1,PulseCount.ar(env, TDelay.ar(env, dur-attack)));
		pluck=TDelay.ar(gate, attack) * (dynamic) / 2;
		envbalance = min(0.9,dynamic);
		env=Lag.ar(SelectX.ar(dynamic,[K2A.ar(1),env]),attack,envbalance,1-envbalance);

		filtersweep=5**(Amplitude.ar(rotated) * min(2,dynamic+1) + 0.43);
		LocalOut.ar(BPF.ar(
			(env * (res + rotated) * dynamic +
				Impulse.ar( 1/section, 0, LFNoise0.kr(1/section)) +
				pluck
			).softclip,
			filtersweep/restime,
			2));

		out=Compander.ar(res,res,0.2,1,0.5);
		Mix(Pan2.ar(out,pan))/n.sqrt;
}.scope} 