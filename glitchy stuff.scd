({var
	  rf = 7
	, rt = Impulse.kr(rf)
	, bs = 8.collect({|i| PulseDivider.kr(rt, 16, i*2)})
	, bt = bs[0] + bs[2] + Dust.kr(SinOsc.kr(0.01, 0, 0.25, 0.25))
	, be = Decay.kr(bt, 0.2)
	, se = Decay.kr(bs[5]+bs[6], 0.01)
	, bass = be*SinOsc.ar(SinOsc.ar([5,6], 0, 20,
		Demand.kr(bt, 0, Drand((30..48), inf)).midicps
	))
	, snar = se*SinOsc.ar(2000+[0, 5])
	, off = (LPF.kr(BrownNoise.kr([1,1]), 10)**(1/3))>0
	, hat = DelayL.kr(Decay.kr(Mix.kr(bs), 0.01), 20, rf.reciprocal*off)*PinkNoise.ar
	, line = Saw.ar(50)*0.1*(LFNoise0.kr(50)>0)*SinOsc.kr(0.1, 0, 0.4, 0.45)
	;
	Out.ar(0, FreeVerb.ar(bass+snar + hat + line,
		SinOsc.kr(0.01, 0, 0.4, 0.5),
		0.8, 0.5))
}.play
)

play{p=LFPulse;cos(p.ar(p.kr(2)+p.kr(3)*[50,51]).lag(2e-3)+mean({|n|(p.ar(n*1e2+50*p.kr(4-n/[2,7,4]).sum+3e2)*p.kr(n+1*2,0,0.8))}!3));



	// this was going to be drum and bass but I got carried away


	s.options.memSize = 81920;
(
fork{
	// this is going to be a convoluted step seq
	var i = 0;

	loop{
		var tempo, step;
		tempo = [
			(3,5..21).reciprocal.choose,
			1/11,
			1/7,
			1/5,
			1
		].wchoose([0.1,17,0.4,0.3,0.25].normalizeSum);

		i = i + 1;
		step = i % 16;

		play{
			// not sure I used all of these.
			var scale, bdm, hh, sd, bd, bda, sda, hha, bdseq, sdseq, hhseq, reva, revb, rev,
				mix;

			scale = Scale.harmonicMinor.degrees+26;

			// bd sequence
			bdseq =[ {2.rand}.dup(16),
				[1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0]
			].choose;

			// bd amp env
			bda = EnvGen.kr(Env.perc(0.01,tempo*6.0.rand,bdseq[step]), doneAction: 2);

			// bass freq modulation
			bdm = {LFNoise2.kr(tempo.rand,0.25,1)}.dup;

			// bd
			bd = LPF.ar(Pulse.ar(scale.choose.midicps,0.5).distort*bdm,1e4.rand).sum * bda;
			bd = bd.tanh;
			5.do{bd = CombC.ar(bd, 0.5, 0.1.rand, 5.0.rand)+bd};
			5.do{bd = AllpassC.ar(bd, 0.5, 0.1.rand, 5.0.rand)+bd};

			// sd seq
			sdseq = [ [0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0],
				{2.rand}.dup(16)
			].choose;

			// sd amp env
			sda = EnvGen.kr(Env.perc(0.01,0.1,sdseq[step]));

			// sd
			sd = PinkNoise.ar(2).distort * sda.lag(0.1.rand);
			5.do{sd = AllpassC.ar(sd, 0.5, [0.25.rand,0.05.rand].choose, 1.5.rand)+sd};

			// hh seq
			hhseq = [{2.rand}.dup(16),
				[0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1]
			].choose;

			// hh amp env
			hha = EnvGen.kr(Env.perc(0.01,0.01,hhseq[step]));

			// hh
			hh = HPF.ar(WhiteNoise.ar(0.7),8000) * hha;

			// drums together
			mix = bd + sd + hh;

			// rev
			reva = GVerb.ar(mix,1.0.rand.max(0.1),1.0.rand).sum;
			revb = GVerb.ar(mix,1.0.rand.max(1),3.0.rand).sum;
			rev = XFade2.ar(reva,revb,LFNoise0.kr(tempo));

			// pannnn
			mix = PanAz.ar(5,rev,LFNoise0.kr(tempo*2));
			mix = Limiter.ar(mix);

			// raussssss
			Out.ar(0,mix.clip);
		};
	tempo.wait;
	};
}
)



	//code that utilizes the glitch.
//warning!  extremely loud.
//note: might not sound the same on all soundcards
(
{ GlitchHPF.ar( BrownNoise.ar(1.dup), freq:0.5, mul:Saw.kr(1, 10) ) * 0.001 }.play;
)

	//mouse controls lfo volume in the x axis and band pass filter cut off in y, bit of randomness on the cutoffs and mucho glitchiness results
{BPF.ar(WhiteNoise.ar(mul: SinOsc.ar(MouseX.kr(0,8),phase:Rand (0,pi), mul:Rand( 0.1,1) )),MouseY.kr(0,20000) * Rand(0,400)  ) +

BPF.ar(WhiteNoise.ar(mul: SinOsc.ar(MouseX.kr(0,8),phase:Rand (0,pi), mul:Rand( 0.1,1) )),MouseY.kr(0,20000) * Rand(0,400) )  +

BPF.ar(WhiteNoise.ar(mul: SinOsc.ar(MouseX.kr(0,8),phase:Rand (0,pi), mul:Rand( 0.1,1) )),MouseY.kr(0,20000) * Rand(0,400)  )     }.scope;