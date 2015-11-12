//add number boxes for freq & amplitude
// fine tuners
//way to save presets
//way to interpolate between presets
//controlers
//arduino resistance setup
//record impuses for Martin

(
SynthDef("49Sines", {
	arg freqs=#[100, 200, 300, 100, 200, 300, 200, 300, 100, 200, 300, 200, 300, 100, 200, 300, 200, 300, 100, 200, 300, 200, 300, 100, 200, 300, 200, 300, 100, 200, 300, 200, 300, 100, 200, 300, 200, 300, 100, 200, 300, 200, 300, 100, 200, 300, 100, 200, 300], amps=#[0.1, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3 ];
	var output;
	output = Mix.new(FSinOsc.ar(freqs, 0, amps/(2*freqs.size)));
	Out.ar(0, [output, output]);
}).load(s)
)


(
~lsi = Synth("49Sines");
~win = Window.new("Long String", Rect(10, 10, 1000, 570)).front;
~win.view.background = Color(0);
~ms = MultiSliderView(~win,Rect(0, 0, 1000, 270));
~ms.value = Array.fill(49, {|v| rrand(0.1, 1)});
//~ms.background = Color.new255(143, 188, 143);
~ms.fillColor = Color.new255(110, 139, 61);
~ms.isFilled = true;
~ms.elasticMode = 0;
~ms.xOffset = 5;
~ms.indexThumbSize = 16;
~ms.action = { arg freqs; ~lsi.set(\freqs, ((freqs.value*106)+7).midicps);
	((freqs.value*106)+7).midicps.postln;
};

~msA = MultiSliderView(~win,Rect(0, 300, 1000, 270));
~msA.value = Array.fill(49, {|v| rrand(0.1, 1)});
//~msA.background = Color.new255(143, 188, 143);
~msA.fillColor = Color.red;
~msA.isFilled = true;
~msA.elasticMode = 0;
~msA.xOffset = 5;
~msA.indexThumbSize = 16;
~msA.action = { arg amps; ~lsi.set(\amps, ((amps.value*90)-60).dbamp);
	((amps.value*90)-70).dbamp.postln;
};


)


-40.

113.midicps



(
SynthDef(\drumline, {
	arg rate1=11.0, rate2=10.0, rate3=12.0, gdur=0.03, ffreq=5000, frez=0.5, fr1=300, fr2=12000, amp=0.8, gate=0, dur=0.01, crv=0, pan=0;
	var noise, grainrate1, grainrate2, grainrate3, grainenv1, grainenv2, grainenv3, filterednoise1, filterednoise2, filterednoise3, freqchgrate1, freqchgrate2, freqchgrate3, s1, s2, s3, output, oenv, envtrig, atk;
	atk = PinkNoise.ar()*EnvGen.ar(Env.perc(attackTime:0.005, releaseTime:0.01));
	envtrig = \t_tr.kr(0,0);
	oenv = EnvGen.ar( Env.perc(attackTime:0.005, releaseTime:dur, curve:crv), envtrig, doneAction:2);
	grainrate1 = Impulse.kr(rate1);
	grainrate2 = Impulse.kr(rate2);
	grainrate3 = Impulse.kr(rate3);
	freqchgrate1 = Impulse.kr(rate1*2);
	freqchgrate2 = Impulse.kr(rate2*3);
	freqchgrate3 = Impulse.kr(rate3*4);
	grainenv1 = EnvGen.ar( Env.perc(attackTime:0.003, releaseTime:gdur), gate:grainrate1 );
	grainenv2 = EnvGen.ar( Env.perc(attackTime:0.003, releaseTime:gdur), gate:grainrate2 );
	grainenv3 = EnvGen.ar( Env.perc(attackTime:0.003, releaseTime:gdur), gate:grainrate3 );
	noise = Crackle.ar(chaosParam:1.95);
	filterednoise1 = MoogLadder.ar( in:noise, ffreq:TRand.kr(fr1, fr2, freqchgrate1), res:frez, mul:3 );
	filterednoise2 = MoogLadder.ar( in:noise, ffreq:TRand.kr(fr1, fr2, freqchgrate2), res:frez, mul:3 );
	filterednoise3 = MoogLadder.ar( in:noise, ffreq:TRand.kr(fr1, fr2, freqchgrate3), res:frez, mul:3 );
	s1 = filterednoise1*grainenv1;
	s2 = filterednoise2*grainenv2;
	s3 = filterednoise3*grainenv3;
	output = Mix.ar( [s1, s2, s3, atk] );
	output = Pan2.ar(output, pan);
	Out.ar(0, output*amp*oenv);
}).load;
)
// frez from 0.1 - 5.0

a = Synth(\drumline);
a.set(\rate1, 9.21, \rate2, 11.73, \rate3, 13.11, \gdur, 0.032, \frez, 0.05, \fr1, 150, \fr2, 20000, \amp, 7.7);
a.set(\rate1, 7.24, \rate2, 8.73, \rate3, 10.13, \gdur, 0.032, \frez, 0.05, \fr1, 150, \fr2, 20000, \amp, 5.7);
a.set(\rate1, 13.21, \rate2, 7.73, \rate3, 10.11, \gdur, 0.032, \frez, 0.12, \fr1, 1000, \fr2, 20000, \amp, 7.7);

a.set(\t_tr, 1, \dur, 4.63, \crv, -6);
a.set(\gate, 0);
a.free;