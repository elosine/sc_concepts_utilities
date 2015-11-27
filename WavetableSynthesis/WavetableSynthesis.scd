

~wsb = SoundFile.collectIntoBuffers("/Users/jyang/GitHub/sc_concepts_utilities/WavetableSynthesis/ArchitectureWaveforms/*",s);//Buffers to hold waveshapesfor shaper

~vosc3bufs = {Buffer.alloc(s, 1024)}!32;//Buffers to hold waveshapesfor vosc3
b = Buffer.read(s, "/Users/jyang/Downloads/Architecture Waveforms 2010 Demo Waveforms/Architecture Waveforms 2010 Wav32/Demo Waveforms/Fractal Staircase 01 0007.wav");
b.numFrames

f = SoundFile.openRead("/Users/jyang/Downloads/Architecture Waveforms 2010 Demo Waveforms/Architecture Waveforms 2010 Wav24/Demo Waveforms/Pulse Bi Square 1-4th.wav");
f = SoundFile.openRead("/Users/jyang/Downloads/Architecture Waveforms 2010 Demo Waveforms/Architecture Waveforms 2010 Wav24/Demo Waveforms/UHF Angels Trumpet.wav");
f = SoundFile.openRead("/Users/jyang/Downloads/Architecture Waveforms 2010 Demo Waveforms/Architecture Waveforms 2010 Wav32/Demo Waveforms/Fractal Staircase 01 0007.wav");

f.seek(0);
f.readData(d = Signal.newClear(2048));  // e.g., 16384, 32768 ...
f.close;

d = d.asWavetable;

b = Buffer.sendCollection(s, d, wait: -1, action: { "all dun kthxbai".postln });
c = Buffer.sendCollection(s, d, wait: -1, action: { "all dun kthxbai".postln });


		s.performList(\sendMsg, \b_gen, ibufnum+i+16, \sine1, 7, a);
~wsb[1].loadToFloatArray( action:{|a| s.performList(\sendMsg, \b_gen, 102, \sine1, 7, a);});


SynthDef(\waveshape, {
	arg pitch;
	var sig, freq;
	freq = pitch.midicps;
	sig = SinOsc.ar(freq);
	sig = Shaper.ar(b.bufnum, sig);
	Out.ar(0, sig);
}).add;

SynthDef(\vosc, {
	arg pitch=60, buf; //offset
	var sig, freq, offset;
	offset = MouseX.kr(buf, buf+10);
	freq = pitch.midicps;
	sig = VOsc3.ar(buf+offset, freq+[0,1],freq+[0.37,1.1],freq+[0.43, -0.29], 0.333333);
	Out.ar(0, sig);
}).add;

a = Synth(\vosc, [\buf, 0]);
//use this synth to listen and choose your wave
(
SynthDef("help-VOsc",{
	arg out=0, bufoffset=0, freq=240;
	var x;
	// mouse x controls the wavetable position
	x = MouseX.kr(0,48).poll;
	Out.ar( out, VOsc3.ar(bufoffset, freq+[0,1],freq+[0.37,1.1],freq+[0.43, -0.29], 0.3) );
}).play(s,[\out, 0, \bufoffset, b.bufnum]);
)

//// FOR WAVESHAPEING WITH VOSC3
//Clunky Function that will generate waveforms from the help file and load them into bufs
~genvosc = {|ibufnum|
	var ar1, ar2;
	8.do{|i|
		var part, array;
		part = (i+1)**2;
		array = Array.fill(part, { arg j; ((part-j)/part).squared.round(0.001) });
		s.performList(\sendMsg, \b_gen, ibufnum+i, \sine1, 7, array);
	};

	8.do{|i|
		var array;
		~array = Array.fill(i, 0) ++ [0.5, 1, 0.5];
		s.performList(\sendMsg, \b_gen, i+8, \sine1, 7, array);
	};

	8.do{|i|
		var a, n;
		n = (i+1)*8;
		a = Array.fill(n,0);
		(n>>1).do({ arg i; a.put(n.rand, 1) });
		s.performList(\sendMsg, \b_gen, ibufnum+i+16, \sine1, 7, a);
	};

	8.do{ |i|
		var a;
		n = (i+1)**2;
		a = Array.fill(n, { arg j; 1.0.rand2 });
		// fill table
		s.performList(\sendMsg, \b_gen, ibufnum+i+24, \sine1, 7, a);
	};
};

//Run function
~genvosc.value(~vosc3bufs[0].bufnum);



//grab x value from the mouse poll and stick this into your synth def
VOsc3.ar(~vosc3bufs[0].bufnum+(x value from mouse poll), freq+[0,1],freq+[0.37,1.1],freq+[0.43, -0.29], 0.3)

