~sig = Signal.newClear(512);
~sig.waveFill({  arg x, old, i;  x.squared  }, 0, 1);
~buf = Buffer.alloc(s, 512, bufnum:0); //allocate buffer
~buf.loadCollection(~sig); //add signal to buffer
~buf.loadToFloatArray( action:{arg array; ~bufasarray = array.as(Array); "done".postln;} );
f = File("/Users/yangj14/Documents/GitHub/musicmobiles/musicmobileTENOR_001/data/crv001.csv", "w");
~bufasarray.do{ |number| f.write(number.asString); f.write("\n"); };
f.close;

~sig = Signal.newClear(512);
~sig = Signal.sineFill( 512, [1,2,3] ).offset(1).normalize;
~buf = Buffer.alloc(s, 512, bufnum:0); //allocate buffer
~buf.loadCollection(~sig); //add signal to buffer
~buf.loadToFloatArray( action:{arg array; ~bufasarray = array.as(Array); "done".postln;} );
f = File("/Users/yangj14/Documents/GitHub/musicmobiles/musicmobileTENOR_001/data/crv002.csv", "w");
~bufasarray.do{ |number| f.write(number.asString); f.write("\n"); };
f.close;

~sig = Signal.newClear(512);
~sig = Signal.hanningWindow( 512 );
~buf = Buffer.alloc(s, 512, bufnum:0); //allocate buffer
~buf.loadCollection(~sig); //add signal to buffer
~buf.loadToFloatArray( action:{arg array; ~bufasarray = array.as(Array); "done".postln;} );
f = File("/Users/yangj14/Documents/GitHub/musicmobiles/musicmobileTENOR_001/data/crv003.csv", "w");
~bufasarray.do{ |number| f.write(number.asString); f.write("\n"); };
f.close;

~sig = Signal.newClear(512);
~sig = Signal.chebyFill( 512, [0, 1, 0, 0, 0, 1], normalize: true, zeroOffset: true);
~buf = Buffer.alloc(s, 512, bufnum:0); //allocate buffer
~buf.loadCollection(~sig); //add signal to buffer
~buf.loadToFloatArray( action:{arg array; ~bufasarray = array.as(Array); "done".postln;} );
f = File("/Users/yangj14/Documents/GitHub/musicmobiles/musicmobileTENOR_001/data/crv004.csv", "w");
~bufasarray.do{ |number| f.write(number.asString); f.write("\n"); };
f.close;

~sig = Signal.newClear(512);
~sig.waveFill({  arg x, old, i;  x  }, 0, 1); //linear up
~buf = Buffer.alloc(s, 512, bufnum:0); //allocate buffer
~buf.loadCollection(~sig); //add signal to buffer
~buf.loadToFloatArray( action:{arg array; ~bufasarray = array.as(Array); "done".postln;} );
f = File("/Users/yangj14/Documents/GitHub/musicmobiles/musicmobileTENOR_001/data/crv005.csv", "w");
~bufasarray.do{ |number| f.write(number.asString); f.write("\n"); };
f.close;

~sig = Signal.newClear(512);


~sig = Signal.sineFill( 512, [1,3,5,7] ) .offset(1).normalize.plot;
~sig = Signal.chebyFill( 512, [0, 1, 0, 0, 0, 1], normalize: true, zeroOffset: true).plot;
~sig = Signal.sineFill( 512, [1,2,3] ).offset(1).normalize .plot;
~sig = Signal.hanningWindow( 512 ).plot;
~sig = Signal.welchWindow( 512 ).plot;
~sig = Signal.fftCosTable( 512*4 ).plot;

~sig = Signal.newClear(512);
~sig.waveFill({  arg x, old, i;  x  }, 0, 1).plot; //linear up
~sig.waveFill({  arg x, old, i;  1-x  }, 0, 1).plot;
~sig.waveFill({  arg x, old, i;  x.squared  }, 0, 1).plot;
~sig.waveFill({  arg x, old, i;  1-x.squared  }, 0, 1).plot;



d = Document.current.dir;
x = CSVFileReader.read(d++"crvSqrA.csv");
z = x.flatten(1);
z = z.collect{ |it| it.asFloat };
y = z.as(Signal)

~buf2 = Buffer.alloc(s, 512, bufnum:0); //allocate buffer
~buf2.loadCollection(y); //add signal to buffer

{    BufRd.ar(1, ~buf2, Phasor.ar(0, BufRateScale.kr(~buf2) , 0, BufFrames.kr(~buf2) ) ).poll }.play;


~bufasarray.writeArchive("testzzzzzz ")

g = CSVFileWriter("/Users/yangj14/Documents/GitHub/musicmobiles/musicmobileTENOR_001/data/arraytest.csv", w);

b = Object.readArchive("test")

var h, k;
h = File("test2", "wb");
h.write( FloatArray[1.1, 2.2, 3.3, pi, 3.sqrt] );
h.close;

k = File("test2", "rb");
(k.length div: 4).do({ k.getFloat.postln; });
k.close;

Quarks.gui


~sig = Signal.sineFill( 512, [1,3,5,7] ) .offset(1).normalize.plot;
~sig = Signal.chebyFill( 512, [0, 1, 0, 0, 0, 1], normalize: true, zeroOffset: true).plot;
~sig = Signal.sineFill( 512, [1,2,3] ).offset(1).normalize .plot;
~sig = Signal.hanningWindow( 512 ).plot;
~sig = Signal.welchWindow( 512 ).plot;
~sig = Signal.fftCosTable( 512*4 ).plot;

~sig = Signal.newClear(512);
~sig.waveFill({  arg x, old, i;  x  }, 0, 1).plot; //linear up
~sig.waveFill({  arg x, old, i;  1-x  }, 0, 1).plot;
~sig.waveFill({  arg x, old, i;  x.squared  }, 0, 1).plot;
~sig.waveFill({  arg x, old, i;  1-x.squared  }, 0, 1).plot;



~sig.plot;

0, { sig = Signal.sineFill( winw, [1,5] ).offset(1).normalize },
				1, { sig = Signal.chebyFill( winw, [0, 1, 0, 0, 0, 1], normalize: true, zeroOffset: true) },
				2, { ~sig = Signal.sineFill( 512, [1,3,5,7] ) .offset(1).normalize},
				3, { sig = Signal.sineFill( winw, [1,2,3] ).offset(1).normalize },
				4, { sig = Signal.hanningWindow( winw ) },
				5, { sig = Signal.hammingWindow( winw ) },
				6, { sig = Signal.welchWindow( winw ) },
				7, { sig = Signal.fftCosTable( winw*4 ) },
				8, {
					sig = Signal.newClear(winw);
					~sig.waveFill({ arg x, old, i; old * (x % 4) }, 0, 1);
				},
				9, {
					~sig = Signal.newClear(512);
					~sig.waveFill({ arg x, old, i; old * sin(11 * x + 0.3) }, 0, 1);
	~sig.plot;
				},
				10, {
					sig = Signal.newClear(winw);
					sig.waveFill({  arg x, old, i;  x  }, 0, 1);
				},
				11, {
					sig = Signal.newClear(winw);
					sig.waveFill({  arg x, old, i;  1-x  }, 0, 1);
				},
				12, {
					sig = Signal.newClear(winw);
					sig.waveFill({  arg x, old, i;  x.squared  }, 0, 1);
				},
				13, {
					sig = Signal.newClear(winw);
					sig.waveFill({  arg x, old, i;  1-x.squared  }, 0, 1);
				}
