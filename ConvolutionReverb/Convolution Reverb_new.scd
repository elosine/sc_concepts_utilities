(
fork{
	s.options.memSize = 245760;
	s.waitForBoot{
		//IMPULSES
		~impulses = SoundFile.collectIntoBuffers("/Users/jyang/GitHub/sc_concepts_utilities/ConvolutionReverb/impulses/*");
		//SET UP SOURCE
		~s1 = Buffer.read(s, "/Users/jyang/Dropbox/supercollider/Concepts and Utilities/ConvolutionReverb/breakingglass.wav");
		//or from folder:
		~samps = SoundFile.collectIntoBuffers("/Users/jyang/Dropbox/supercollider/Concepts and Utilities/ConvolutionReverb/Samples/*");

		//NEW IMPULSE FUNCTION

		~newimpulse = { |inum|
			fork{
				~cr.free; ~cr=nil;

				0.3.wait;

				~cr = EZConv(~impulses[inum].path);

				0.3.wait;

				//INSPECT
				~cr.numChannels;
				~cr.irSpectrum;
				0.3.wait;
				//USE IN SYNTH DEF
				SynthDef(\convRev, {
					arg sourcebuf, sourcegain=1, gain=0.5, spd=1, start=0.0, end=1.0;
					var source, bufindexer, convolve;
					bufindexer = Phasor.ar( 0, BufRateScale.kr(sourcebuf)*spd, start*BufFrames.kr(sourcebuf), end*BufFrames.kr(sourcebuf) );
					source = BufRd.ar(2, sourcebuf, bufindexer);
					convolve = ~cr.ar(source*sourcegain, leak: 0.1, mul:gain);
					Out.ar(0, convolve);
				}).add;

				//LIVE IN SYNTH DEF (USE HEADPHONES)
				SynthDef(\convRevLive, {
					arg inbus=0, sourcegain=1, gain=0.5;
					var source, convolve;
					source = SoundIn.ar(inbus);
					convolve = ~cr.ar(source*sourcegain, leak: 0.1, mul:gain);
					Out.ar(0, convolve);
				}).add;
			}//end fork
		};//end ~newimpulse function


		//SET UP IMPULSE RESPONSE
		//http://www.openairlib.net/auralizationdb/map
		~cr = EZConv(~impulses[4].path);

		0.3.wait;

		//INSPECT
		~cr.numChannels;
		~cr.irSpectrum;

		0.3.wait;

		//USE IN SYNTH DEF
		SynthDef(\convRev, {
			arg sourcebuf, sourcegain=1, gain=0.5, spd=1, start=0.0, end=1.0;
			var source, bufindexer, convolve;
			bufindexer = Phasor.ar( 0, BufRateScale.kr(sourcebuf)*spd, start*BufFrames.kr(sourcebuf), end*BufFrames.kr(sourcebuf) );
			source = BufRd.ar(2, sourcebuf, bufindexer);
			convolve = ~cr.ar(source*sourcegain, leak: 0.1, mul:gain);
			Out.ar(0, convolve);
		}).add;

		//LIVE IN SYNTH DEF (USE HEADPHONES)
		SynthDef(\convRevLive, {
			arg inbus=0, sourcegain=1, gain=0.5;
			var source, convolve;
			source = SoundIn.ar(inbus);
			convolve = ~cr.ar(source*sourcegain, leak: 0.1, mul:gain);
			Out.ar(0, convolve);
		}).add;
	} //end s.waitForBoot
}// end fork
)

//PLAY
a = Synth(\convRev, [\sourcebuf, ~s1] );
a.set(\gain, 1.0, \sourcegain, 2, \spd, -0.1);
a.free;

c = Synth(\convRevLive);
c.set(\sourcegain, 0.2, \gain, 0.5);
c.free;

//Kill synth before setting a new impulse
(
c.free;
g = ~impulses.size.rand.round;
~newimpulse.value(g);
~impulses[g];
)
c = Synth(\convRevLive);


// A TEST IMPULSE
v = {PinkNoise.ar(0.5 ! 2) * Decay2.ar(Impulse.ar(0.2), 0.15, 0.75)}.play //Dry
v.free;
(
	x = {
		var source = PinkNoise.ar(0.5 ! 2) * Decay2.ar(Impulse.ar(0.2), 0.15, 0.75); // stereo source
		~cr.ar(source, leak: 0.1, mul: 1.5); // watch out for gain buildup when convolving.
	}.play;
)
x.free;

~impulses[0].path
