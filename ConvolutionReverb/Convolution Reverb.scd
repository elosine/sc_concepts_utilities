s.options.memSize = 245760;
s.boot; s.meter;

//SET UP SOURCE
~s1 = Buffer.read(s, "/Users/jyang/Dropbox/supercollider/Concepts and Utilities/ConvolutionReverb/breakingglass.wav");
//or from folder:
~samps = SoundFile.collectIntoBuffers("/Users/jyang/Dropbox/supercollider/Concepts and Utilities/ConvolutionReverb/Samples/*");
//have to call using index: ~samps[0]


//SET UP IMPULSE RESPONSE
//http://www.openairlib.net/auralizationdb/map
(
//IR PATH
~irpath = "/Users/jyang/Dropbox/supercollider/Concepts and Utilities/ConvolutionReverb/SonicLab_PanelsUp_Ground_1and2.aiff";
~cr = EZConv(~irpath);
)
(
//INSPECT
~cr.numChannels;
~cr.irSpectrum;
)
(
//USE IN SYNTH DEF
SynthDef(\convRev, {
	arg sourcebuf, sourcegain=1, gain=0.5, spd=1, start=0.0, end=1.0;
	var source, bufindexer, convolve;
	bufindexer = Phasor.ar( 0, BufRateScale.kr(sourcebuf)*spd, start*BufFrames.kr(sourcebuf), end*BufFrames.kr(sourcebuf) );
	source = BufRd.ar(2, sourcebuf, bufindexer);
	convolve = ~cr.ar(source*sourcegain, leak: 0.1, mul:gain);
	Out.ar(0, convolve);
}).add;
)

//PLAY
a = Synth(\convRev, [\sourcebuf, ~s1] );
a.set(\gain, 1.0, \sourcegain, 2, \spd, -0.1);
a.free;

//RESET YOUR IMPULSE
~cr.free; ~cr=nil;
(
//IR PATH
~irpath = "/Users/jyang/Dropbox/supercollider/Concepts and Utilities/ConvolutionReverb/HamiltonMausoleum_stereo.wav";
~cr = EZConv(~irpath);
)
(
//INSPECT
~cr.numChannels;
~cr.irSpectrum;
)

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

(
//LIVE IN SYNTH DEF (USE HEADPHONES)
SynthDef(\convRevLive, {
	arg inbus=0, sourcegain=1, gain=0.5;
	var source, convolve;
	source = SoundIn.ar(inbus);
	convolve = ~cr.ar(source*sourcegain, leak: 0.1, mul:gain);
	Out.ar(0, convolve);
}).add;
)

c = Synth(\convRevLive);
c.set(\sourcegain, 0.2, \gain, 0.5);
c.free;

