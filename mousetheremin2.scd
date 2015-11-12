//Implement midi note dictionary in processing range 24-95
//group activity to develop the sounds better
//synthesis exercise to make own mouse theramin but have different sound give some possibilities
//lead class in their own song
//have to play lead with different sound
//make a couple of examples
//way of switching between instruments
//install autogui
//make some sample synths using FM and subtractive synthesis use sos articles
//map x to something
//http://www.soundonsound.com/search?url=%2Fsearch&Keyword=%22synth+secrets%22&Words=All&Summary=Yes
//make a midinote to yaxis map in Processing
//create a repository for all of the student code
//make a welcome video with text like ira glass
//Dragon Dictate install get rode mic

//score sketch
//midi note sketch

//videos:
//synthdef, arguments, mouse.kr, mappingwith linlin, round, envelopes and envgen, lfos

//explainer videos (2nd priority)
//envelopes, lfos, oscillators, ugens, synthdef, classes, variables, arguments, signals vs descreet data

SynthDef(\mousetheremin, {
	arg amp=0.8, midirangelo=24.0, midirangehi=95.0, bendtime=0.001, pitchresolution=0.5;
	var mousepitch, env, osc;
	mousepitch = MouseY.kr(0.0, 1.0, lag:bendtime).linlin(0.0, 1.0, midirangehi, midirangelo);
	env = EnvGen.ar( Env.asr(0.05, releaseTime:0.05), MouseButton.kr(lag:0.001) );
	osc = SinOsc.ar( mousepitch.round(pitchresolution).midicps );
	Out.ar( 0, osc * env );
}).add;

a = Synth(\mousetheremin);
a.set(\midirangelo, 0.05, \midirangehi, 95.0 );
a.free;


84, 83, 79
32, 29, 31, 24
44, 41, 43, 36

