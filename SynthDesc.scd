
    ///////////////////////////////////////
   ////                              /////
  ////       \audioOut_mono          /////
 ////                              /////
///////////////////////////////////////
SynthDef( \audioOut_mono, {
		arg ibs, obs, kbs;
		var in, rms;
	in = In.ar(ibs)*\amp.kr(0, 0.01).dbamp;
	rms = Amplitude.kr(in).ampdb.linlin(-80.0, 0.0, 0.0, 1.0);
		Out.kr(kbs, rms); //send rms amplitude measure to a control bus
		Out.ar(obs, in)
	},
	rates:[0, 2],
	variants:(alpha:[amp:0.5]),
	metadata: (
		alpha:([amp:0.5]),
		specs: (
			ibs: ControlSpec(0, Server.default.options.numAudioBusChannels-1, step: 1),
			obs: ControlSpec(0, 49, step: 1),
			kbs: ControlSpec(0, Server.default.options.numControlBusChannels-1, step: 1),
			amp: ControlSpec(-120.0, 18, \lin, default: 0.0, units: "db")
	))
).load.store(mdPlugin:TextArchiveMDPlugin);

e = SynthDesc.read(SynthDef.synthDefDir ++ "audioOut_mono.scsyndef");

e[\audioOut_mono].name;
//Controls is an array of ControlName types
e[\audioOut_mono].controls;
e[\audioOut_mono].controls[3].name;
e[\audioOut_mono].controls[0].index;
e[\audioOut_mono].controls[0].rate;
e[\audioOut_mono].controls[0].defaultValue;
e[\audioOut_mono].controls[0].numChannels;
//controlDict is an Identity Dictionary of the controlnames indexed by name
e[\audioOut_mono].controlDict;
e[\audioOut_mono].controlDict[\amp];
e[\audioOut_mono].controlDict[\amp].name;
e[\audioOut_mono].controlDict[\amp].index;

e[\audioOut_mono].outputs;
e[\audioOut_mono].inputs;
e[\audioOut_mono].hasGate;
e[\audioOut_mono].makeWindow;
e[\audioOut_mono].outputData;

e[\audioOut_mono].metadata;

a = Synth(\audioOut_mono.alpha)

SynthDescLib.global.at(\audioOut_mono).def.variants


e[\mdDemo].makeWindow;