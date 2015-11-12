
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
	metadata: (
		specs: (
			ibs: ControlSpec(0, Server.default.options.numAudioBusChannels-1, step: 1),
			obs: ControlSpec(0, 49, step: 1),
			kbs: ControlSpec(0, Server.default.options.numControlBusChannels-1, step: 1),
			amp: ControlSpec(-120.0, 18, \lin, default: 0.0, units: "db")
		)
	),
	variants: (one: [amp: 0.1], two: [amp: 1.1])
).add;
SynthDescLib.global.at(\audioOut_mono).def.variants.one
SynthDescLib.global.at(\audioOut_mono).controlDict

//GETTING INFO FROM SYNTHDEFS
SynthDescLib.global.at(\audioOut_mono).name;
SynthDescLib.global.at(\audioOut_mono).outputs;
SynthDescLib.global.at(\audioOut_mono).inputs;
SynthDescLib.global.at(\audioOut_mono).hasGate;
SynthDescLib.global.at(\audioOut_mono).makeWindow;
SynthDescLib.global.at(\audioOut_mono).outputData;
//metadata
SynthDescLib.global.at(\audioOut_mono).metadata;
//variants (presets)
//controls
SynthDescLib.global.at(\audioOut_mono).controls;
SynthDescLib.global.at(\audioOut_mono).controls[0].name;
SynthDescLib.global.at(\audioOut_mono).controls[0].index;
SynthDescLib.global.at(\audioOut_mono).controls[0].rate;
SynthDescLib.global.at(\audioOut_mono).controls[0].defaultValue;
SynthDescLib.global.at(\audioOut_mono).controls[0].numChannels;
//controlDict
SynthDescLib.global.at(\audioOut_mono).controlDict;
SynthDescLib.global.at(\audioOut_mono).controlDict[\amp];
SynthDescLib.global.at(\audioOut_mono).controlDict[\amp].defaultValue;
//etc...



e[\audioOut_mono].metadata;

a = Synth(\audioOut_mono.alpha)

SynthDescLib.global.at(\audioOut_mono).def.variants.one
SynthDescLib.global.at(\audioOut_mono).controlDict

e[\mdDemo].makeWindow;