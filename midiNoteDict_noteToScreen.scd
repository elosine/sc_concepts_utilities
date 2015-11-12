( ///////////////////////////////////////////////////////

// 1) //

//MIDI NOTE DICTIONARY
////Allows you to input a symbol and get out the midi note number

////Use only these symbols:
//// \c, \cs, \d, \eb, \e, \f, \fs, \g, \gs, \a, \bb, \b

var currMidiNum, noteNames, octaves;
~mnd = ();
currMidiNum = 0;
noteNames = [\c, \cs, \d, \eb, \e, \f, \fs, \g, \gs, \a, \bb, \b];
octaves = [-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
octaves.do{ |it ix|
	noteNames.do{ |it2 ix2|
		~mnd.put((it2 ++ it).asSymbol, currMidiNum);
		currMidiNum = currMidiNum+1;
	}
};

) ///////////////////////////////////////////////////////////


( ///////////////////////////////////////////////////////

//2//
//FUNCTION TO LOOK UP Y-LOCATION FOR A PITCH

	var screenRes, yres;
	~pitchLo = \a0;
	~pitchHi = \c8;
	screenRes = "system_profiler SPDisplaysDataType | grep Resolution".unixCmdGetStdOut.findRegexp("(?<!@ )[0-9]{3,}").collect({|item| item[1].asInteger}).clump(2);
	yres = screenRes[0][1];

~midiToY = {
	arg midinote;
	~mnd[midinote].linlin(~mnd[~pitchLo], ~mnd[~pitchHi], yres, 0.0);
};

) ///////////////////////////////////////////////////////////


//EXAMPLE OF MIDI NOTE DICTIONARY:
////Use only these symbols:
//// \c, \cs, \d, \eb, \e, \f, \fs, \g, \gs, \a, \bb, \b
~mnd[\bb5];
//Look @ Post Window

//EXAMPLE OF MIDI NOTE TO Y COORDINATE:
////Use only these symbols:
//// \c, \cs, \d, \eb, \e, \f, \fs, \g, \gs, \a, \bb, \b
~midiToY.value(\bb5);
//Look @ Post Window




(
//MAKE A MIDI NOTE DICTIONARY WITH SCREEN COORDINATES FOR MOUSEY
var noteNames, octaves, midiNum, midiRange, yres, incPx, getScreenRes, pinc;

~midiNumLo = 20;
~midiNumHi = 90;

getScreenRes = "system_profiler SPDisplaysDataType | grep Resolution".unixCmdGetStdOut.findRegexp("(?<!@ )[0-9]{3,}").collect({|item| item[1].asInteger}).clump(2);
pinc = 0;

~notedict = ();

midiNum = 0;
midiRange = ~midiNumHi - ~midiNumLo;
yres = getScreenRes[0][1];
incPx = yres/midiRange;

noteNames = [\c, \cs, \d, \eb, \e, \f, \fs, \g, \gs, \a, \bb, \b];
octaves = [-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

octaves.do{ |it ix|
	noteNames.do{ |it2 ix2|
		~notedict.put((it2 ++ it).asSymbol, midiNum);
		midiNum = midiNum+1;
	}
};

~notePx = { |midi| midi.linlin(~midiNumLo, ~midiNumHi, yres, 0.0);

};



SynthDef(\mousetheremin, {
	arg amp=0.8, midirangelo=24.0, midirangehi=95.0, bendtime=0.001, pitchresolution=0.5;
	var mousepitch, env, osc;
	mousepitch = MouseY.kr(0.0, 1.0, lag:bendtime).linlin(0.0, 1.0, midirangehi, midirangelo).poll;
	env = EnvGen.ar( Env.asr(0.05, releaseTime:0.05), MouseButton.kr(lag:0.001) );
	osc = SinOsc.ar( mousepitch.round(pitchresolution).midicps );
	Out.ar( 0, osc * env );
}).add;

)


~mt = Synth(\mousetheremin, [\midirangelo, ~midiNumLo, \midirangehi, ~midiNumHi]);
~mt.free;


84, 83, 79
32, 29, 31, 24
44, 41, 43, 36

~notePx.value(~notedict[\c7]);

