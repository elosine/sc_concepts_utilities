SerialPort.listDevices
(
//Adjust Server Options before boot
s.options.numAudioBusChannels = 1000;
s.options.memSize = 163840;
s.waitForBoot{ fork{

	// GLOBAL VARIABLES

	//// Cursor routine array
	var csrroutines = Array.newClear(99);

	//// Arduino gate
	var inoOn = 0;

	//// Phasorclocks
	var clkbpm = Array.newClear(0);
	var clkbpc = Array.newClear(0);

	//// Windows
	var winwidths = Array.newClear(0);

	//// Curves
	var winw = 0;
	var crvbufs = Array.newClear(0);

	//FUNCTIONS
	////  look up func
	var lookupfunc = { |array num | var return; array.do{|it ix| if(it[0] == num, { return=it[1] }) }; return; };
	////  look up ix func
	var lookupixfunc = { |array num | var return; array.do{|it ix| if(it[0] == num, { return=ix }) }; return; };

	//MISC Variables
	var bthdrs, btaction, triggernum;

	// GROUPS ///////////////////////////////////////////////
	s.sendMsg(\g_new, 1999); s.sendMsg(\g_new, 2000);
	10.do{|ix| s.sendMsg(\g_new, 2001+ix, 3, 2000+ix)};
	s.sendMsg(\g_new, 2999, 3, 2010);

	// OSC Clients ///////////////////////////////
	~proc = NetAddr("192.168.1.3", 12321);
	~proc = NetAddr("127.0.0.1", 12321);
	~sclang = NetAddr("127.0.0.1", 57120); //SClang address


	// Curves ///////////////////////////////

	~folderpath = Document.current.dir;

	~crv001 = CSVFileReader.read(~folderpath++"/crv001.csv");
	~crv001= ~crv001.flatten(1);
	~crv001 = ~crv001.collect{ |it| it.asFloat };
	~crv001 = ~crv001.as(Signal);
	~crv001buf = Buffer.alloc(s, 512, bufnum:0); //allocate buffer
	~crv001buf.loadCollection(~crv001); //add signal to buffer

	~crv002 = CSVFileReader.read(~folderpath++"/crv002.csv");
	~crv002= ~crv002.flatten(1);
	~crv002 = ~crv002.collect{ |it| it.asFloat };
	~crv002 = ~crv002.as(Signal);
	~crv002buf = Buffer.alloc(s, 512, bufnum:2); //allocate buffer
	~crv002buf.loadCollection(~crv002); //add signal to buffer

	~crv003 = CSVFileReader.read(~folderpath++"/crv003.csv");
	~crv003= ~crv003.flatten(1);
	~crv003 = ~crv003.collect{ |it| it.asFloat };
	~crv003 = ~crv003.as(Signal);
	~crv003buf = Buffer.alloc(s, 512, bufnum:3); //allocate buffer
	~crv003buf.loadCollection(~crv003); //add signal to buffer

	~crv004 = CSVFileReader.read(~folderpath++"/crv004.csv");
	~crv004= ~crv004.flatten(1);
	~crv004 = ~crv004.collect{ |it| it.asFloat };
	~crv004 = ~crv004.as(Signal);
	~crv004buf = Buffer.alloc(s, 512, bufnum:4); //allocate buffer
	~crv004buf.loadCollection(~crv004); //add signal to buffer

	~crv005 = CSVFileReader.read(~folderpath++"/crv005.csv");
	~crv005= ~crv005.flatten(1);
	~crv005 = ~crv005.collect{ |it| it.asFloat };
	~crv005 = ~crv005.as(Signal);
	~crv005buf = Buffer.alloc(s, 512, bufnum:5); //allocate buffer
	~crv005buf.loadCollection(~crv005); //add signal to buffer

	// ~ips = [NetAddr("192.168.1.2", 12321), NetAddr("192.168.1.3", 12321), NetAddr("192.168.1.4", 12321), NetAddr("192.168.1.5", 12321), NetAddr("192.168.1.6", 12321), NetAddr("192.168.1.7", 12321), NetAddr("192.168.1.8", 12321), NetAddr("192.168.1.9", 12321)];

	~ips = [NetAddr("127.0.0.1", 12321)];



	// ARDUINO /////////////////////////////////////////////////////////////////////////////////

	if(inoOn == 1, {
		~ino = ArduinoSMS("/dev/tty.wchusbserial1d160",9600);

		//////Button Headers
		bthdrs = ["b0","b1","b2","b3","b4","b5","b6","b7"];

		//////Button Actions
		btaction = [

			//0
			//control the tactus number in triggernum
			{ |val|
				if( val==1, { ~sclang.sendMsg("/mvtactus", triggernum[0], 1) }, { ~sclang.sendMsg("/mvtactus", triggernum[0], 0) } );
			}

		];

		//////Button Actions
		triggernum = [0];

		//////Arduino Action /////////////////////
		~ino.action = {
			arg msg;
			var sm = msg.split($:);
			var header = sm[0];
			var val = sm[1].asFloat;

			//Switches
			bthdrs.do{ |it ix|
				if( it==sm[0], {
					var val = sm[1].asInteger;
					btaction[ix].value(val);
				} ) //end if
			}; //end sh.do

		}; //end ino.action

	}); //end if inoOn


	// PHASOR CLOCKS /////////////////////////////////////////////////////////////////////////////////

	//// phasorclock synthdef ////////////////////////////////////////////////////////////////////////
	SynthDef(\phasorclock, {
		arg abus, kbus, trigbus, stbpm=60.0, endbpm=60.0, rampdur=0.05, bpc=16.0, t_tr=1, dir=1;
		var temporamp = EnvGen.ar( Env.new( [1.0, 0.0, 1.0], [0.0, rampdur] ), t_tr ).linexp(0.0, 1.0, stbpm, endbpm);
		var tempo = (temporamp/60.0) / (SampleRate.ir*bpc);
		var clk = Phasor.ar( In.kr(trigbus), tempo*dir);
		Out.ar(abus, clk);
		Out.kr(kbus, clk);
	}).add;

	////////////////////////////////////////////////////////////////////////////////////////////////////////
	// MAKE CURSOR / PHASORCLOCK
	/////////////////////////////////////////////////////////////////////////////////////////////////////////

	OSCdef(\mkcsr, {|msg|
		var ix = msg[1].asInteger;
		var winix = msg[2].asInteger;
		var bpm = msg[3].asFloat;
		var bpc = msg[4].asFloat;
		var wt = msg[5].asInteger;
		var clr = msg[6].asString;

		// 1) Make phasorclock
		//phasorclocks at nodes 3000-3999, group 2002, audio busses 100-199 and control busses 100-199
		//optional trigbus @ kbusses 350-399, which are tactuses
		s.sendMsg(\s_new, \phasorclock, 3000+ix, 0, 2002, \abus, 100+ix, \kbus, 100+ix, \trigbus, 350+ix, \stbpm, bpm, \endbpm, bpm, \bpc, bpc);

		// 2) Store BPM & BPC info for reading signal buffer
		clkbpm = clkbpm.add( [ix, bpm] );
		clkbpc = clkbpc.add( [ix, bpc] );

		// 2) Make Cursor
		//// "/mkcursor", ix, winix, weight, color name
		~proc.sendMsg("/mkcursor", ix, winix, ix, wt, clr);

		// 2) Make Routine to send cursor data
		csrroutines[ix] = Routine{ inf.do{
			~sclang.sendMsg( "/getkdata", ix+100);
			0.03.wait;
		}}.play;

	}, "/mkcsr");

	OSCdef(\csrSync, {|msg|
		var ix = msg[1].asInteger;
		var winix = msg[2].asInteger;
		var clkix = msg[3].asInteger;
		var wt = msg[5].asInteger;
		var clr = msg[6].asString;


		// 2) Make Cursor
		//// "/mkcursor", ix, winix, weight, color name
		~proc.sendMsg("/mkcursor", ix, winix, clkix, wt, clr);

	}, "/csrSync");

	OSCdef(\rmvcsr, {|msg|
		var ix = msg[1].asInteger;
		//1) Remove Cursor
		~proc.sendMsg("/rmvcursor", ix);
		// 2) Free phasorclock
		s.sendMsg(\n_free, 3000+ix);
	}, "/rmvcsr");

	OSCdef( \chgcsr, {|msg|
		var clkix = msg[1].asInteger;
		var newbpm = msg[2].asFloat;
		var newdir = msg[3].asInteger;
		var chgdur = msg[4].asFloat;

		//look up current bpm
		var currbpm;
		currbpm={var cbpm; clkbpm.do{ |it|  if(it[0]==clkix, {cbpm=it[1]}); };cbpm}.value;

		fork{
			0.05.wait;

			//phasorclocks at nodes 3000+
			s.sendMsg(\n_set, clkix+3000, \stbpm, currbpm, \endbpm, newbpm, \rampdur, chgdur, \dir, newdir, \t_tr, 1);

			//store new bpm
			clkbpm.do{ |it ixx|  if(it[0]==clkix, { clkbpm[ixx][1]=newbpm }); };

		}; //end fork


	}, "/chgcsr");


	////////////////////////////////////////////////////////////////////////////////////////////////////////
	// OSCdefs for Sending Control Data from Control Busses to Processing
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	OSCdef( \getkdata, {
		arg msg;
		var kbus = msg[1].asInteger;
		s.sendMsg(\c_get, kbus);
	}, "/getkdata");

	OSCdef( \kdat, {
		arg msg;
		var bnum=msg[1].asInteger;
		var val=msg[2].asFloat;
		// ~proc.sendMsg("/kdat", bnum, val);
		~ips.do{|it ix| it.sendMsg("/kdat", bnum, val)};
	}, \c_set);

	0.1.wait;

	/////////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////////
	// CURVES
	/////////////////////////////////////////////////////////////////////////////////////////////////////////

	//// Get window width
	OSCdef(\winw, {|msg|
		var winix = msg[1].asInteger;
		var winw = msg[2].asInteger;
		winwidths = winwidths.add([winix, winw]);
		winwidths.postln;
	}, "/winw");

	//// CURVE MAKER ///////////////////////////////////////////////////////////////////////////////////////
	OSCdef(\mkcrv,{ |msg|
		var ix = msg[1].asInteger;
		var winix = msg[2].asInteger;
		var crvtype = msg[3].asInteger;
		var crvwt = msg[4].asInteger;
		var crvclr = msg[5].asString;
		var winw, sig, buf, bufasarray;


		fork{

			//1) Get Winlet Width
			~proc.sendMsg("/winw", winix);

			0.3.wait;

			//1b) Look up winwidth in array and store in local variable
			winw = lookupfunc.value(winwidths, winix);
			0.3.wait;

			//2) Make Empty Curve
			~proc.sendMsg("/mkcrv", ix, winix, crvwt, crvclr);

			//3) Make Signal based on crvtype
			switch( crvtype,
				0, { sig = Signal.sineFill( winw, [1,5] ).offset(1).normalize },
				1, { sig = Signal.chebyFill( winw, [0, 1, 0, 0, 0, 1], normalize: true, zeroOffset: true) },
				2, { sig = Signal.sineFill( winw, [1,3,5,7] ) .offset(1).normalize},
				3, { sig = Signal.sineFill( winw, [1,2,3] ).offset(1).normalize },
				4, { sig = Signal.hanningWindow( winw ) },
				5, { sig = Signal.hammingWindow( winw ) },
				6, { sig = Signal.welchWindow( winw ) },
				7, { sig = Signal.fftCosTable( winw*4 ) },
				8, {
					sig = Signal.newClear(winw);
					sig.waveFill({ arg x, old, i; old * (x % 4) }, 0, 1);
				},
				9, {
					sig = Signal.newClear(winw);
					sig.waveFill({ arg x, old, i; old * sin(11 * x + 0.3) }, 0, 1);
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

			);

			0.3.wait;

			//4) Add Signal to Buffer and Buffer to Buffer Array & convert buffer to float array
			buf = Buffer.alloc(s, winw, bufnum:ix); //allocate buffer

			0.3.wait;

			buf.loadCollection(sig); //add signal to buffer
			//Add Buffer to buffer array indexed by curve number
			0.3.wait;

			//CONVERT BUFFER TO FLOAT ARRAY
			buf.loadToFloatArray( action:{arg array; bufasarray = array.as(Array); "done".postln;} );

			0.3.wait;


			//Insert osc name and curve index
			bufasarray.insert(0, ix);
			bufasarray.insert(0, "/crvcoord");

			//bufasarray.postln;

			0.3.wait;

			//5) Send Curve Coordinates to Processing
			~proc.sendBundle(0.0, bufasarray);

			1.85.wait;

			//6) Render Curve
			~proc.sendMsg("/rendercrv", ix);


		}; //end fork

	}, "/mkcrv");

	~mkCrvFromArray =  {
		arg array, ix, winix, crvwt, crvclr;
		fork{
			// Make Empty Curve
			~proc.sendMsg("/mkcrv", ix, winix, crvwt, crvclr);

			//Insert osc name and curve index
			array.insert(0, ix);
			array.insert(0, "/crvcoord");

			0.3.wait;

			// Send Curve Coordinates to Processing
			~proc.sendBundle(0.0, array);

			0.85.wait;

			// Render Curve
			~proc.sendMsg("/rendercrv", ix);

		}; //end fork
	};


	//// Remove curve
	OSCdef(\rmvcrv, {|msg|
		var ix = msg[1].asInteger;
		~proc.sendMsg("/rmvcrv", ix);
		s.sendMsg(\b_free, ix);
	}, "/rmvcrv");

	0.1.wait;
	/////////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////////
	// CURVE SIGNALS
	/////////////////////////////////////////////////////////////////////////////////////////////////////////

	//// Buffer Read SynthDef for reading Curve Signals
	SynthDef(\crvsig, {
		arg clkibs, sigbuf, kobs, obs, bufsize;
		var clk = In.ar(clkibs);
		var sig = BufRd.ar(1, sigbuf, clk*bufsize , 1);
		Out.kr(kobs, sig);
		Out.ar(obs, sig);
	}).add;

	//// CURVE FOLLOWER MAKER //////////////////////////////////////////////////////////////////////////

	OSCdef(\mkcrvfollow, { |msg|
		var ix = msg[1].asInteger;
		var clkix = msg[2].asInteger;
		var crvix = msg[3].asInteger;
		var winix = msg[4].asInteger;
		var sigbuf, winw;

		fork{

			//2) Look Up Window Width
			// winw = lookupfunc.value(winwidths,winix);
			winw = 512;
			0.3.wait;

			//3) //// Make Curve Signal Synth - nodes: 4000-4999, group:2003, aobs:200-299, kobs:200-299
			//// clock's audio sigs at audio busses 100-199
			s.sendMsg(\s_new, \crvsig, 4000+ix, 0, 2003, \clkibs, 100+clkix, \sigbuf, crvix, \kobs, 200+ix, \obs, 200+ix, \bufsize, winw);

			//4) Make Curve Follower in Processing
			// "mkcrvfollow", ix, clkix, crvix
			~proc.sendMsg("/mkcrvfollow", ix, clkix, crvix);

		}; //end fork

	}, "/mkcrvfollow");

	OSCdef(\rmvcrvfollow, { |msg|
		var ix = msg[1].asInteger;
		~proc.sendMsg("/rmvcrvfollow", ix);
		s.sendMsg(\n_free, 4000+ix);
	}, "/rmvcrvfollow");

	//////////////////////////////////////////////////////////////////////////////////////////////////




	////////////////////////////////////////////////////////////////////////////////////////////////////////
	// TACTUS
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	SynthDef(\tactus, {
		arg obs,kobs, tobs, atk=0.1, rel=0.25, crv= -4, gate=0;
		var sig = EnvGen.ar(Env.asr(atk,1.0,rel,crv),gate);
		var gatesig = (1-sig).floor ;
		gatesig.poll;
		Out.ar(obs,sig);
		Out.kr(kobs,sig);
		Out.kr(tobs,gatesig);
	}).add;

	// MAKE A TACTUS
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	OSCdef(\mktactus, {|msg|
		var ix = msg[1].asInteger;
		var winnum = msg[2].asInteger;
		var sz = msg[3].asInteger;
		var clr = msg[4].asString;

		//1) Make a Synth using audio/kbusses 300-349, trigobs 350-399, nodes 5000-5999, group 2003
		s.sendMsg( \s_new, \tactus, 5000+ix, 0, 2003, \obs, 300+ix, \kobs, 300+ix, \tobs, 350+ix, \atk, 0.05, \rel, 0.25, \crv, 6);

		//2) Make a Graphic
		// "/mktactus", int ix, int winix, int sz, String tclr
		~proc.sendMsg( "/mktactus", ix, winnum, sz, clr);

	}, "/mktactus");

	// Activate Tactus
	OSCdef(\mvtactus, {|msg|
		var ix = msg[1].asInteger;
		var trig = msg[2].asInteger;

		s.sendMsg(\n_set, 5000+ix, \gate, trig);
	}, "/mvtactus");

	//Make SC side Cursors

	0.1.wait;

	s.sendMsg(\s_new, \phasorclock, 3000, 0, 2002, \abus, 100, \kbus, 100, \trigbus, 350, \stbpm, 30, \endbpm, 30, \bpc, 8);
	clkbpm = clkbpm.add( [0, 30] );
	clkbpc = clkbpc.add( [0, 8] );
	csrroutines[0] = Routine{ inf.do{ ~sclang.sendMsg( "/getkdata", 100); 0.03.wait; }}.play;

	s.sendMsg(\s_new, \phasorclock, 3001, 0, 2002, \abus, 101, \kbus, 101, \trigbus, 351, \stbpm, 11, \endbpm, 11, \bpc, 8);
	clkbpm = clkbpm.add( [1, 11] );
	clkbpc = clkbpc.add( [1, 8] );
	csrroutines[1] = Routine{ inf.do{ ~sclang.sendMsg( "/getkdata", 101); 0.03.wait; }}.play;

	s.sendMsg(\s_new, \phasorclock, 3002, 0, 2002, \abus, 102, \kbus, 102, \trigbus, 352, \stbpm, 42, \endbpm, 42, \bpc, 8);
	clkbpm = clkbpm.add( [2, 42] );
	clkbpc = clkbpc.add( [2, 8] );
	csrroutines[2] = Routine{ inf.do{ ~sclang.sendMsg( "/getkdata", 102); 0.03.wait; }}.play;

	s.sendMsg(\s_new, \phasorclock, 3003, 0, 2003, \abus, 103, \kbus, 103, \trigbus, 353, \stbpm, 7, \endbpm, 7, \bpc, 8);
	clkbpm = clkbpm.add( [3, 7] );
	clkbpc = clkbpc.add( [3, 8] );
	csrroutines[3] = Routine{ inf.do{ ~sclang.sendMsg( "/getkdata", 103); 0.03.wait; }}.play;

	{
		w = Window.new("Musicmobiles Control", Rect(750, 400, 300, 200), border:false)
		.background_(Color.new255(25, 33, 47))
		.layout_(
			VLayout(
				HLayout(
					VLayout(
						StaticText().string_("Trill")
						.stringColor_(Color.white),
						CheckBox()
						.action_({|val|
							var act = val.value;
							if(act, {~ips.do{|it ix| it.sendMsg("/showsVG", 0, 1)}},
								{~ips.do{|it ix| it.sendMsg("/showsVG", 0, 0)}}
							);
						})
					),
					VLayout(
						StaticText().string_("Cresc")
						.stringColor_(Color.white),
						CheckBox()
						.action_({|val|
							var act = val.value;
							if(act, {~ips.do{|it ix| it.sendMsg("/showcrescendo", 0, 1)}},
								{~ips.do{|it ix| it.sendMsg("/showcrescendo", 0, 0)}}
							);
						})
					),
					VLayout(
						StaticText().string_("Accel")
						.stringColor_(Color.white),
					CheckBox( )
					.action_({|val|
						var act = val.value;
						if(act, {~ips.do{|it ix| it.sendMsg("/showfeatheredBeams", 0, 1)}},
							{~ips.do{|it ix| it.sendMsg("/showfeatheredBeams", 0, 0)}}
						);
					})
					),
					VLayout(
						StaticText().string_("Noise")
						.stringColor_(Color.white),
					CheckBox( )
					.action_({|val|
						var act = val.value;
						if(act, {~ips.do{|it ix| it.sendMsg("/showimg", 0, 1)}},
							{~ips.do{|it ix| it.sendMsg("/showimg", 0, 0)}}
						);
					}),
				)
				),
				HLayout(
					VLayout(
						StaticText().string_("Crv1")
						.stringColor_(Color.white),
					CheckBox( )
					.action_({|val|
						var act = val.value;
						if(act, {~ips.do{|it ix| it.sendMsg("/showcrv", 0, 1)}},
							{~ips.do{|it ix| it.sendMsg("/showcrv", 0, 0)}}
						);
					})
						),
					VLayout(
						StaticText().string_("Crv2")
						.stringColor_(Color.white),
					CheckBox( )
					.action_({|val|
						var act = val.value;
						if(act, {~ips.do{|it ix| it.sendMsg("/showcrv", 1, 1)}},
							{~ips.do{|it ix| it.sendMsg("/showcrv", 1, 0)}}
						);
					})
						),
					VLayout(
						StaticText().string_("Crv3")
						.stringColor_(Color.white),
					CheckBox( )
					.action_({|val|
						var act = val.value;
						if(act, {~ips.do{|it ix| it.sendMsg("/showcrv", 2, 1)}},
							{~ips.do{|it ix| it.sendMsg("/showcrv", 2, 0)}}
						);
					})
						),
					VLayout(
						StaticText().string_("Crv4")
						.stringColor_(Color.white),
					CheckBox( )
					.action_({|val|
						var act = val.value;
						if(act, {~ips.do{|it ix| it.sendMsg("/showcrv", 3, 1)}},
							{~ips.do{|it ix| it.sendMsg("/showcrv", 3, 0)}}
						);
					})
							),
					VLayout(
						StaticText().string_("Crv5")
						.stringColor_(Color.white),
					CheckBox( )
					.action_({|val|
						var act = val.value;
						if(act, {~ips.do{|it ix| it.sendMsg("/showcrv", 4, 1)}},
							{~ips.do{|it ix| it.sendMsg("/showcrv", 4, 0)}}
						);
					}),
				)
						),

				HLayout(
					VLayout(
						StaticText().string_("Csr1")
						.stringColor_(Color.white),
					CheckBox( )
					.action_({|val|
						var act = val.value;
						if(act, {~ips.do{|it ix| it.sendMsg("/showcsr", 0, 1)}},
							{~ips.do{|it ix| it.sendMsg("/showcsr", 0, 0)}}
						);
					})
								),
					VLayout(
						StaticText().string_("Csr2")
						.stringColor_(Color.white),
					CheckBox( )
					.action_({|val|
						var act = val.value;
						if(act, {~ips.do{|it ix| it.sendMsg("/showcsr", 1, 1)}},
							{~ips.do{|it ix| it.sendMsg("/showcsr", 1, 0)}}
						);
					})
								),
					VLayout(
						StaticText().string_("Csr3")
						.stringColor_(Color.white),
					CheckBox( )
					.action_({|val|
						var act = val.value;
						if(act, {~ips.do{|it ix| it.sendMsg("/showcsr", 2, 1)}},
							{~ips.do{|it ix| it.sendMsg("/showcsr", 2, 0)}}
						);
					})
								),
					VLayout(
						StaticText().string_("Csr4")
						.stringColor_(Color.white),
					CheckBox( )
					.action_({|val|
						var act = val.value;
						if(act, {~ips.do{|it ix| it.sendMsg("/showcsr", 3, 1)}},
							{~ips.do{|it ix| it.sendMsg("/showcsr", 3, 0)}}
						);
					}),
				)
				),
				HLayout(
					StaticText().string_("Csr")
					.stringColor_(Color.white),
					NumberBox()
					.action_( { |val|
						~csr = val.value;
					}),
					StaticText().string_("BPM")
					.stringColor_(Color.white),
					NumberBox()
					.action_( { |val|
						~bpm = val.value;
					}),
					StaticText().string_("Dir")
					.stringColor_(Color.white),
					NumberBox()
					.action_( { |val|
						~dir = val.value;
					}),
					StaticText().string_("Dur")
					.stringColor_(Color.white),
					NumberBox()
					.action_( { |val|
						~dur = val.value;
					}),
					Button().action_({~sclang.sendMsg("/chgcsr", ~csr, ~bpm, ~dir, ~dur)})
				)

			)
		).front;
	}.defer;

	//////////////////////////////////////////////////////////////////////////////////////////////////

}} //end waitforboot/fork
)





