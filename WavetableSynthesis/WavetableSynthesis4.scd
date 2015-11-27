

(
~wsb = SoundFile.collectIntoBuffers("/Users/jyang/GitHub/synthesisrecipies/WavetableSynthesis/ArchitectureWaveforms/*",s,);//Buffers to hold waveshapesfor shaper

//~wsb = SoundFile.collectIntoBuffers("/Users/jyang/GitHub/synthesisrecipies/WavetableSynthesis/AdventureKid/AKWF_epiano/SET_1/*",s);//Buffers to hold waveshapesfor shaper
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



a = Synth(\waveshape_test, [\buf, ~wsb2[0].bufnum, \numbuf, 32]);
b = Synth(\waveshape_test, [\buf, ~wsb[0].bufnum, \numbuf, ~wsb.size-1]);
c = Synth( \wavshp, [\buf, ~wsb2[0].bufnum, \offset, 11.0744, \pitch, 60] );
c.set(\pitch, 47);
d = Synth(\wavshp, [\buf, 0, \offset, 8.84]);
d.set(\offset, 25.9311, \pitch, 30);
d.set(\offset, 30.1239, \pitch, 48);
d.set(\offset, 30.8461, \pitch, 79);
b.free
a.free;