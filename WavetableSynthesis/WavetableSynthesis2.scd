a = Buffer.read(s, "/Users/jyang/Downloads/Architecture Waveforms 2010 Demo Waveforms/Architecture Waveforms 2010 Wav24/Demo Waveforms/UHF Angels Trumpet.wav");
b = Buffer.read(s, "/Users/jyang/Downloads/Architecture Waveforms 2010 Demo Waveforms/Architecture Waveforms 2010 Wav24/Demo Waveforms/Sydney.wav");
a.loadToFloatArray( action:{|a| s.performList(\sendMsg, \b_gen, 100, \sine1, 7, a)});
b.loadToFloatArray( action:{|a| s.performList(\sendMsg, \b_gen, 101, \sine1, 7, a)});
~wsb[2].loadToFloatArray( action:{|a| s.performList(\sendMsg, \b_gen, 102, \sine1, 7, a)});
~wsb[3].loadToFloatArray( action:{|a| s.performList(\sendMsg, \b_gen, 103, \sine1, 7, a)});
~wsb[4].loadToFloatArray( action:{|a| s.performList(\sendMsg, \b_gen, 104, \sine1, 7, a)});

(

~wsb = SoundFile.collectIntoBuffers("/Users/jyang/GitHub/sc_concepts_utilities/WavetableSynthesis/ArchitectureWaveforms/*",s);//Buffers to hold waveshapesfor shaper
//Convert to wavetable and read into new set of buffers starting at ~ibufnum
~ibufnum = 100;
~wsb.do{ |it ix| it.loadToFloatArray( action:{|a| s.performList(\sendMsg, \b_gen, ~wsb[0]+ix, \sine1, 7, a); ix.postln})};


~wsb2 = {Buffer.alloc(s, 1024)}!32;//Buffers to hold algorithmically generated waves

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
		array = Array.fill(i, 0) ++ [0.5, 1, 0.5];
		s.performList(\sendMsg, \b_gen, ibufnum+i+8, \sine1, 7, array);
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
~genvosc.value(~wsb2[0].bufnum);

//Use Mouse to see which wave you like and put that number into the \wavshp offset
SynthDef(\waveshape_test, {
	arg pitch=60, buf, numbuf=32;
	var sig, freq, offset;
	offset = MouseX.kr(0.0, numbuf).poll;
	freq = pitch.midicps;
	sig = VOsc3.ar(buf+offset, freq+[0,1],freq+[0.37,1.1],freq+[0.43, -0.29], 0.333333);
	Out.ar(0, sig);
}).add;

SynthDef(\wavshp, {
	arg pitch=60, buf, offset;
	var sig, freq;
	freq = pitch.midicps;
	sig = VOsc3.ar(buf+offset, freq+[0,1],freq+[0.37,1.1],freq+[0.43, -0.29], 0.333333);
	Out.ar(0, sig);
}).add;
)

a = Synth(\waveshape_test, [\buf, ~wsb2[0].bufnum]);
b = Synth(\waveshape_test, [\buf, 0, \numbuf, 1]);
c = Synth( \wavshp, [\buf, ~wsb2[0].bufnum, \offset, 11.0744, \pitch, 60] );
c.set(\pitch, 47);
d = Synth(\wavshp, [\buf, ~ibufnum, \offset, ]);


