(
//var kbusraw;
~idx = 0;
~sidx = 0;
~kbraw = {Bus.control(s)}!200; //holds raw values
~kbmap = {Bus.control(s)}!200; //holds mapped values
~mapdict = (); //an array named for an argument-synth with[rawbus, mappedbus, mapped synth]
~syndict = ();

SynthDef(\kmap_lin, {
	arg inbus, outbus, inlo=0.0, inhi=1.0, outlo=0.0, outhi=1.0;
	Out.kr( outbus, In.kr(inbus).linlin(inlo, inhi, outlo, outhi) );
}).add;
SynthDef(\kmap_exp, {
	arg inbus, outbus, inlo=0.0, inhi=1.0, outlo=0.0, outhi=1.0;
	Out.kr( outbus, In.kr(inbus).linexp(inlo, inhi, outlo, outhi) );
}).add;
SynthDef(\kmap_crv, {
	arg inbus, outbus, inlo=0.0, inhi=1.0, outlo=0.0, outhi=1.0, crv = -2;
	Out.kr( outbus, In.kr(inbus).lincurve(inlo, inhi, outlo, outhi, crv) );
	Lag
}).add;

OSCdef( \mapbusdef, { |msg|
	var crv;
	if(crv.isNil, {crv = "lin"},{crv = msg[6].asString});
	if(crv == "lin", {
		~mapdict[msg[1]] = [
			~kbraw[~idx],
			~kbmap[~idx],
			Synth( \kmap_lin, [
				\inbus, ~kbraw[~idx],
				\outbus, ~kbmap[~idx],
				\inlo, msg[2],
				\inhi, msg[3],
				\outlo, msg[4],
				\outhi, msg[5]
			] )
		];
	});
	if(crv == "exp", {
		~mapdict[msg[1]] = [
			~kbraw[~idx],
			~kbmap[~idx],
			Synth( \kmap_exp, [
				\inbus, ~kbraw[~idx],
				\outbus, ~kbmap[~idx],
				\inlo, msg[2],
				\inhi, msg[3],
				\outlo, msg[4],
				\outhi, msg[5]
			] )
		];
	});
	if(crv == "crv", {
		~mapdict[msg[1]] = [
			~kbraw[~idx],
			~kbmap[~idx],
			Synth( \kmap_crv, [
				\inbus, ~kbraw[~idx],
				\outbus, ~kbmap[~idx],
				\inlo, msg[2],
				\inhi, msg[3],
				\outlo, msg[4],
				\outhi, msg[5],
				\crv, msg[7]
			] )
		];
	});
	~idx = ~idx + 1;
}, "/mkmap");

OSCdef(\mksyn, {|msg|
	s.makeBundle(0.0, {
		~syndict[msg[1].asSymbol] = Synth(msg[2].asSymbol);
		msg.do{|it, ix| if(ix>3 && ix.even,{it.postln;~syndict[msg[1].asSymbol].map( msg[ix-1].asSymbol, ~mapdict[it.asSymbol][1] )})};
		//msg.do{|it, ix| if(ix>3 && ix.even,{ it.postln;})};
	})
}, "/mksyn");

OSCdef(\remap, {|msg|
	~mapdict[ msg[1].asSymbol][2].set(\inlo, msg[2],\inhi, msg[3],\outlo, msg[4],\outhi, msg[5]);//name of arg-syn
}, "/remap");

)


//Tester
a = NetAddr("localhost", 57120);

//Set up arg maps:
// /mkmap, Name of mappedarg, inlo, inhi, outlo, outhi, warp: lin, exp, crv, if crv: crv value
a.sendMsg("/mkmap", "sawpitch", 0.0, 1.0, 10.0, 90, "lin");
a.sendMsg("/mkmap", "sawlr", 0.0, 1.0, 0.0, 3);

SynthDef(\ts, {|pitch=60, lr=3| Out.ar(0, BlitB3Saw.ar( (pitch + (SinOsc.kr(lr)*0.5)).midicps ))}).add;
{Out.kr(~mapdict[\sawpitch][0], MouseX.kr())}.play;
{Out.kr(~mapdict[\sawlr][0], MouseY.kr())}.play;

// Play Synth:
// /mksyn, unique string for this instance of synth, synthdef name, pairs: list of args to map/name in mapdict
a.sendMsg("/mksyn", "testy", \ts, "pitch", "sawpitch", "lr", "sawlr");
a.sendMsg("/remap", "sawlr", 0.0, 1.0, 1, 60);
a.sendMsg("/remap", "sawpitch", 0.0, 1.0, 40, 70);

~syndict[\testy].free;

//free synth
//make real synth example and go from there
/////Denid
//make synths
//make CV camera/projector-screen live drawing instrument

/*
//STANDALONE NOTES
//Open processing patch from supercollider standalone
String.scDir refers to this directory: /SuperCollider.app/Contents/Resources

("open" + String.scDir +/+ "TextEdit.app").unixCmd


// some folder paths that should point inside the app's Contents folder
SynthDef.synthDefDir = String.scDir +/+ "synthdefs/";
Archive.archiveDir = String.scDir;
Platform.classLibraryDir
Platform.systemExtensionDir
Platform.helpDir
thisProcess.platform.startupFiles

// make a storage place for various objects:
q = (); // Event

q[\a_long_array] = Array.rand(128, 0.0, 1.0);
q[\pi_squared] = pi * pi;
q[\favourite_sound] = { { SinOsc.ar([300, 330]).sum * LFPulse.kr(2 + [0, 0.01]) * 0.1 }.play };
q[\same_long_array] = q[\a_long_array]; // same objects may appear several times

Archive.global.put(\myData, q);

Archive.global.at(\myData).postcs;

// after a recompile:
s.boot;

q = Archive.global.at(\myData);
q.postcs;
q[\favourite_sound].value;
q[\favourite_sound].value.free;

*/
