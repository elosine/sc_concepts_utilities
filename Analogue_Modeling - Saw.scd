( //analogue modeling saw
{
	Mix.fill(4,{
		var freqmult;

		//between 1 +- 0.01
		freqmult= 1+SinOsc.ar( LFNoise1.kr(rrand(0.25,0.5),4,5), pi.rand, 0.01);

		LFSaw.ar(72.midicps*(freqmult),pi.rand,0.2)

	})
}.play
)
