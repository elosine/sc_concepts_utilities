SynthDescLib.global.at(\test1).def.asCompileString.postcs;

SynthDef(\test1, {
	Out.ar(0, SinOsc.ar());
}).load;


f = { SynthDef(\test, { |freq| Out.ar(0, SinOsc.ar(freq)) }).add };
f.value;
SynthDescLib.global[\test].def.asCompileString.postcs


f = {SinOsc.ar()}.play;
f.postcs;
f.value.postcs;
f.asCompileString.postcs

a = {SinOsc.ar()};
a.asCompileString.postcs;
a.postcs;

"{SinOsc.ar()}.play;".asString.interpret;




