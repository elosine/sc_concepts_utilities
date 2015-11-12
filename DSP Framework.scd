//In synth Dictionary
//Creates an audio bus
//creates Monitoring to control bus
//creates control bus
//pull model processing or other will send an osc msg and get a response with controlbus val
//control amp
//add ringmod
//add to archive and make standalone
//easy way to add effects
//easy way to add controllers
//how to kill everything
//add all old effects
//kill synths and everything in an operator
//stereo dsp def
//way to map args to control busses and controlers
//more signals
//custom glitch noise ones
//adapt funky level meter
//make an impulse signal with the pink noise from convolution

//DO THIS WITH petals of resonance
//MAKE A FUNCTION THAT WILL STORE A SYNTHDEF WITH ITS ARGUMENTS AND RANGES AND SPEC
//////Add Specs when adding synth def as meta data with control spec
//Get arg names and specs and default value and store in dictionary


//CLEAN UP AND ADD SYNTHDEFS ONE AT A TIME, MAKE THIS DOCUMENT AN ARCHIVE OF SYNTHDEFS
//MAKE A TEST GUI

//set up control busses for each arg of each synth when instanciting them
//make dictionary of all oscdef addresses and their args and any callbacks

s.meter;


(
//Add everything to a dictionary
q = ();

//Create 3 Groups: ins from soundcard, DSP,  and outs to soundcard
q[\insgrp] = Group.new(s);
q[\dspgrp1] = Group.after(q[\insgrp]);
q[\dspgrp2] = Group.after(q[\insgrp]);
q[\dspgrp3] = Group.after(q[\insgrp]);
q[\dspgrp4] = Group.after(q[\insgrp]);
q[\dspgrp5] = Group.after(q[\insgrp]);
q[\dspgrp6] = Group.after(q[\insgrp]);
q[\dspgrp7] = Group.after(q[\insgrp]);
q[\dspgrp8] = Group.after(q[\insgrp]);
q[\dspgrp9] = Group.after(q[\insgrp]);
q[\dspgrp10] = Group.after(q[\insgrp]);
q[\outsgrp] = Group.after(q[\dspgrp]);
/////////////////////////////////////////////////////////
////  AUDIO IN ////
/////////////////////////////////////////////////////////

//OSCdef: \mkaudioindef
//msg[1]= Dictonary name for Sound-In conglomerate
//msg[2] = Sound in Channel
//1) Adds an array to dictionary under the name in msg[1]
//2) Create a private audio bus to send the audio in to in slot [0]
//3) Create a control bus to send the amplitude measurement/metering to in slot [1]
//4) Create a audio-in synth in slot [2]
q[\mkaudioindef] = OSCdef(\mkaudioin,{ |msg|
	var obs, kbs;
	obs = Bus.audio(s, 1); //private audio bus for sound in
	kbs = Bus.control(s, 1); //control bus for amplitude measurement/metering
	q[msg[1].asSymbol] = [
		obs,
		kbs,
		Synth(\audioin_mono, [\ibs, msg[2].asInteger, \obs, obs, \kbs, kbs], q[\insgrp]), //synth to take audio in and route to private audio bus
	]
}, "/mkaudioin");
/////////////////////////////////////////////////////////
////  AUDIO OUT ////
/////////////////////////////////////////////////////////
//SynthDefs to handle Sound-Out to soundcard
q[\outdef_m] = SynthDef( \audioOut_mono, {
	arg ibs, obs, kbs, amp=1;
	var in, rms;
	in = In.ar(ibs)*amp;
	rms = Amplitude.kr(in).ampdb.linlin(-40.0, 0.0, 0.0, 1.0);
	Out.kr(kbs, rms); //send rms amplitude measure to a control bus
	Out.ar(obs, in)
}).add;
q[\outdef_s] = SynthDef( \audioOut_stereo, {
	arg ibs, obs, kbs, amp=1;
	var in, rms;
	in = In.ar([ibs, ibs+1])*amp;
	rms = Amplitude.kr(in).ampdb.linlin(-40.0, 0.0, 0.0, 1.0);
	Out.kr(kbs, rms); //send rms amplitude measure to a control bus
	Out.ar(obs, in)
}).add;
//OSCdef: \mkaudioOutdef
//msg[1]= Dictonary name for Sound-Out conglomerate
//msg[2] = Sound Out Channel
//1) Adds an array to dictionary under the name in msg[1]
//3) Create a control bus to send the amplitude measurement/metering to in slot [0]
//4) Create a Audio-Out synth in slot [2]
//Def for mono out
q[\mkaudioOutdef_m] = OSCdef(\mkaudioOut_m,{ |msg|
	var kbs;
	kbs = Bus.control(s, 1); //control bus for amplitude measurement/metering
	q[msg[1].asSymbol] = [
		kbs,
		"placeholder",
		Synth(\audioOut_mono, [\obs, msg[2].asInteger, \kbs, kbs], q[\outsgrp]),
	]
}, "/mkaudioOut_m");
//Def for stereo out
q[\mkaudioOutdef_s] = OSCdef(\mkaudioOut_s,{ |msg|
	var kbs;
	kbs = Bus.control(s, 2); //control bus for amplitude measurement/metering
	q[msg[1].asSymbol] = [
		kbs,
		"placeholder",
		Synth(\audioOut_stereo, [\obs, msg[2].asInteger, \kbs, kbs], q[\outsgrp]),
	]
}, "/mkaudioOut_s");
//OSCdef: /routeout - to choose a private audio bus to route out to soundcard
//msg[1] = name of in conglermate to send out
//msg[2] = name of out conglermate
//msg[3] = out channel number
q[\routeoutdef] = OSCdef(\routeout, { |msg| q[msg[2].asSymbol][2].set(\ibs, q[msg[1].asSymbol][0], \obs, msg[3].asInteger)}, "/routeout");
/////////////////////////////////////////////////////////
////  SET AMP ////
/////////////////////////////////////////////////////////
//msg[1] = dictionary name to set
//msg[2] = amp value
//synth should always be [2] in dictionary array
q[\setampdef] = OSCdef(\setamp, {|msg| q[msg[1].asSymbol][2].set(\amp, msg[2].asFloat)}, "/setamp");
/////////////////////////////////////////////////////////
////  SIGNALS & DSP ////
/////////////////////////////////////////////////////////
//For Each synthdef make dictionary entry under synthdef name
//an array with slot [0]: synthdef
//and slot [1] an array with:
//[names of all arguments...]
q[\sineWlfo] = [
	SynthDef(\sineWlfo, {
		arg obs, rate, freqlo=100, freqhi=400, amp=1;
		var sig, lfo;
		lfo = SinOsc.kr(rate).range(freqlo, freqhi);
		sig = SinOsc.ar(lfo);
		Out.ar(obs, sig*amp);
	}).add,
	[ \obs, \rate, \freqlo, \freqhi, \amp ]
];
q[\ringmod] = [
	SynthDef(\ringmod, {
		arg obs, kbs, carbus, modbus, amp=1;
		var rm, rms;
		rm = DiodeRingMod.ar(In.ar(carbus), In.ar(modbus));
		rms = Amplitude.kr(rm).ampdb.linlin(-40.0, 0.0, 0.0, 1.0);
		Out.kr(kbs, rms); //send rms amplitude measure to a control bus
		Out.ar(obs, rm*amp);
	}).add,
	[ \obs, \carbus, \modbus, \amp ]
];
//MAKE SIGNAL
//Add array to dictionary under name msg[1]:
//0) audio out bus
//1) place holder (no inbus)
//2) synth
//msg[1] dictionary name
//msg[2] synth name
//msg[3].. list of args-value pairs
q[\mksigdef] = OSCdef(\mksig, {|msg|
	var argsvals = msg.copyRange(3, msg.size);
	var obs = Bus.audio(s);
	argsvals.do{|it, ix| if(ix.even, {argsvals[ix]=it.asSymbol}, {argsvals[ix]=it.asFloat})};
	argsvals = argsvals++[\obs, obs];
	q[msg[1].asSymbol] = [
		obs,
		"placeholder",
		Synth(msg[2].asSymbol, argsvals, q[\insgroup]);
	];
}, "/mksig");
//MAKE DSP
//Add array to dictionary under name msg[1]:
//0) audio out bus
//1) control bus
//2) synth
//msg[1] dictionary name
//msg[2] synth name
//msg[3] group name
//msg[4].. list of args-value pairs
q[\mkdspdef_m] = OSCdef(\mkdsp_m, {|msg|
	var argsvals = msg.copyRange(4, msg.size);
	var obs = Bus.audio(s);
	var kbs = Bus.control(s);
	argsvals.do{|it, ix| if(ix.even, {argsvals[ix]=it.asSymbol}, {argsvals[ix]=it.asFloat})};
	argsvals = argsvals++[\obs, obs, \kbs, kbs];
	q[msg[1].asSymbol] = [
		obs,
		kbs,
		Synth(msg[2].asSymbol, argsvals, q[msg[3].asSymbol]);
	];
}, "/mkdsp_m");
//Set Synth Def
//msg[1] = dictionary name
//msg[2...] = arg-val pairs
q[\setsynthdef] = OSCdef(\setsynth, {|msg|
	var argsvals = msg.copyRange(2, msg.size);
	argsvals.do{|it, ix| if(ix>0, {q[msg[1].asSymbol][2].set(argsvals[ix-1].asSymbol, it.asFloat) })};
}, "/setsynth");
//Set RingMod Def
//msg[1] = dictionary name
//msg[2] = dict name for carrier synth
//msg[3] = dict name for mod synth
q[\setrmdef] = OSCdef(\setrm, {|msg|
	q[msg[1].asSymbol][2].set(\carbus, q[msg[2].asSymbol][0], \modbus, q[msg[3].asSymbol][0])
}, "/setrm");

)
/////////////////////////////////////////
//////  SYNTHDEFS ////////////////
/////////////////////////////////////////

q = ();
q[\synthdefs] = ();
//function to pull control names and add to dictionary
q[\addsyndef] = {
	arg syndefname;
	var get, ctlnames;
	syndefname = syndefname.asSymbol;
	get = SynthDesc.read(SynthDef.synthDefDir ++ syndefname++".scsyndef");
	ctlnames = get.[syndefname.asSymbol].controlNames;
	ctlnames.do{|it, ix|
		q[\synthdefs][syndefname][1][it] = Array.newClear(3);
	};
};
//Function: to add spec to args
q[\addsynthdefargsSpec] = {
	arg syndefname, argname, lo, hi, warp;
	q[\synthdefs][syndefname][1][argname][0] = lo;
	q[\synthdefs][syndefname][1][argname][1] = hi;
	q[\synthdefs][syndefname][1][argname][2] = warp;
};
//OSCdefs to poll and set and get synthdef arg specs:
//Poll synthdef args
//Send me: name of synthdef as msg[1]
q[\pollsyndefargs] = OSCdef(\pollsyndefargs,{
	arg msg, time, addr;
	var mailtoadr, args, argsStr="";
	mailtoadr = addr;
	args = q[\synthdefs][msg[1].asSymbol][1].keys.asArray;
	args.do{|it, ix| argsStr = if(ix==0,{argsStr=it},{argsStr=argsStr++"#"++it})};
	argsStr.postln;
	mailtoadr.sendMsg("/sdargs", argsStr);
}, "/getsdargs");
//Set SynthDef arg spec
//Send me: name of synthdef as msg[1]
//arg name as msg[2]
//lo, hi, warp as msg[3-5]
q[\setsdargspec] = OSCdef(\setsdargspec,{|msg|
	q[\addsynthdefargsSpec].value(msg[1].asSymbol, msg[2].asSymbol, msg[3].asFloat, msg[3].asFloat, msg[5])
}, "/setsdargspec");
//Get SynthDef arg spec
//Send me: name of synthdef as msg[1]
//arg name as msg[2]
q[\getsdargspec] = OSCdef(\getsdargspec,{
	arg msg, time, addr;
	var mailtoadr, args, argsStr="";
	mailtoadr = addr;
	args = q[\synthdefs][msg[1].asSymbol][1][msg[2].asSymbol];
	args.postln;
	args.do{|it, ix| argsStr = if(ix==0,{argsStr=it.asString},{argsStr=argsStr++"#"++it.asString})};
	argsStr.postln;
	mailtoadr.sendMsg("/sdargs", argsStr)
}, "/getsdargspec");

  //////////////////////
 //////SYNTHDEFS://////
//////////////////////

    ///////////////////////////////////////
   ////                              /////
  ////         \audioin_mono        /////
 ////                              /////
///////////////////////////////////////
//SynthDef to handle sound in and put it to a audio bus
//put in dictionary
q[\synthdefs][\audioin_mono] = [
	SynthDef( \audioin_mono, {
		arg ibs, obs, kbs, amp=1;
		var in, rms;
		in = SoundIn.ar(ibs)*amp;
		rms = Amplitude.kr(in).ampdb.linlin(-40.0, 0.0, 0.0, 1.0);
		Out.kr(kbs, rms); //send rms amplitude measure to a control bus
		Out.ar(obs, in)
	}).add,
	()
];
//run function to add control names
q[\addsyndef].value(\audioin_mono);
//Run function(s) to add any specs to arguments
q[\addsynthdefargsSpec].value(\audioin_mono, \amp, 0.0, 1.0, \lin);
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

//NEXT:
// Clean up Pedals of resonance
//// Add
// Add impulse signal
// Prototype in Processing

a = NetAddr("localhost", 57120);
a.sendMsg("/mkaudioin", "mic1", 0);
a.sendMsg("/mkaudioOut_m", "out1", 0);
a.sendMsg("/routeout", "mic1", "out1", 1);
a.sendMsg("/setamp", "out1", 0);
a.sendMsg("/mksig", "sine1", "sineWlfo", "rate", 0.1, "freqlo", 200, "freqhi", 1000);
a.sendMsg("/setsynth", "sine1", "amp", 0);
a.sendMsg("/routeout", "sine1", "out1", 1);
a.sendMsg("/setsynth", "sine1", "rate", 0.1, "freqhi", 350);
a.sendMsg("/mkdsp_m", "rm1", "ringmod", "dspgrp4");
a.sendMsg("/setrm", "rm1", "mic1", "sine1");
a.sendMsg("/routeout", "rm1", "out1", 1);
a.sendMsg("/setsynth", "sine1", "rate", 3.3, "freqlo", 10, "freqhi", 30);


