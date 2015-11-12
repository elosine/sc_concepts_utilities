//In synth Dictionary
//Creates an audio bus
//creates Monitoring to control bus
//creates control bus
//pull model processing or other will send an osc msg and get a response with controlbus val


//Add everything to a dictionary
q = ();
//Create 3 Groups: ins from soundcard, DSP,  and outs to soundcard
q[\insgrp] = Group.new(s);
q[\dspgrp] = Group.after(q[\insgrp]);
q[\outsgrp] = Group.after(q[\dspgrp]);
//SynthDef to handle sound in and put it to a audio bus
q[\indef_m] = SynthDef( \audioin_mono, {
	arg ibs, obs, kbs, amp=1;
	var in, rms;
	in = SoundIn.ar(ibs)*amp;
	rms = Amplitude.kr(in).ampdb.linlin(-40.0, 0.0, 0.0, 1.0);
	Out.kr(kbs, rms); //send rms amplitude measure to a control bus
	Out.ar(obs, in)
}).add;
q[\indef_s] = SynthDef( \audioin_stereo, {
	arg ibs, obs, kbs, amp=1;
	var in, rms;
	in = SoundIn.ar([ibs, ibs+1])*amp;
	rms = Amplitude.kr(in).ampdb.linlin(-40.0, 0.0, 0.0, 1.0);
	Out.kr(kbs, rms); //send rms amplitude measure to a control bus
	Out.ar(obs, in)
}).add;
//OSCdef: \mkaudioindef
//msg[1]= Dictonary name for Sound-In conglomerate
//msg[2] = Mono or Stereo
//msg[3] = Sound in Channel
//1) Adds an array to dictionary under the name in msg[1]
//2) Create a private audio bus to send the audio in to in slot [0]
//3) Create a control bus to send the amplitude measurement/metering to in slot [1]
//4) Create a audio-in synth in slot [2]
q[\mkaudioindef] = OSCdef(\mkaudioin,{ |msg|
	//msg[2] 1=mono, 2=stereo
	switch(msg[2].asInteger,
		1, { //mono
			var obs, kbs;
			obs = Bus.audio(s, 1), //private audio bus for sound in
			kbs = Bus.control(s, 1), //control bus for amplitude measurement/metering
			q[msg[1]].asSymbol = [
				obs,
				kbs,
				Synth(\audioin_mono, [\ibs, msg[3].asInteger, \obs, obs, \kbs, kbs], q[\insgrp]), //synth to take audio in and route to private audio bus
			]
		},
		2, { //stereo
			q[msg[1]].asSymbol = [
				Bus.audio(s, 2), //private audio bus for sound in
			]
		}
	)
}, "/mkaudioin");
