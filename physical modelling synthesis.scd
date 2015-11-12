Physical Modelling Synthesis

Server.default=s=Server.internal;
s.boot;

For a sound synthesis method that truly reflects what goes on in real instruments, you need to take account of the physics of musical instruments. The mathematical equations of acoustics are the basis of physical modelling synthesis. They are tough to build, hard to control, but probably supply the most realistic sounds of the synthesis methods short of the inexpressive method of sampling.

Because they're based on real instrument mechanics, the control parameters for them are familiar to musicians, though perhaps more from an engineer's point of view- lip tension, bore length, string cross sectional area, bow velocity... Controlling physical models in an intuitive musical way is itself a subject of open research.























There are a number of techniques in physical modelling, including

modal synthesis (being a study of the exact modes of vibration of acoustic systems: related to analysis + additive synthesis)

delay line (waveguide) models (building physical models out of combinations of simple units like delays and filters, which model the propagation of sound waves in a medium)

mass-spring models (based on dynamical equations; elementary masses and springs can be combined into larger models of strings, membranes, acoustic chambers, instrument bodies...)



We won't be going too deeply into the engineering- it's a hard topic and an open research area. Good physical models can be very computationally expensive, and easy to use real time models are in many cases still out of reach. There are however an increasing number of successful designs, and certainly bound to be more to come.




















To hear a quick example of working from acoustical equations, here's a physical model of a stiff string I built. Parameters such as the Young's modulus, density and radius of a string lead to calculated mode frequencies and damped decay times.

//adapted from 2.18 Vibrations of a Stiff String, p61, Thomas D. Rossing and Neville H. Fletcher (1995) Principles of Vibration and Sound. New York: Springer-Verlag
(
var modes,modefreqs,modeamps;
var mu,t,e,s,k,f1,l,c,a,beta,beta2,density;
var decaytimefunc;
var material;

material= \nylon; // \steel

//don't know values of E and mu for a nylon/gut string
//so let's try steel

//radius 1 cm
a=0.01;

s=pi*a*a;

//radius of gyration
k=a*0.5;


if (material ==\nylon,{

e=2e+7;

density=2000;

},{//steel

e= 2e+11; // 2e+7; //2e+11 steel;

//density p= 7800 kg m-3
//linear density kg m = p*S

density=7800;
});

mu=density*s;

t=100000;

c= (t/mu).sqrt;	//speed of sound on wave

l=1.8;	//0.3

f1= c/(2*l);

beta= (a*a/l)*((pi*e/t).sqrt);

beta2=beta*beta;

modes=10;

modefreqs= Array.fill(modes,{arg i;
var n,fr;
n=i+1;

fr=n*f1*(1+beta+beta2+(n*n*pi*pi*beta2*0.125));

if(fr>21000, {fr=21000}); //no aliasing

fr
});

decaytimefunc= {arg freq;
var t1,t2,t3;
var m,calc,e1dive2;

//VS p 50 2.13.1 air damping

m=(a*0.5)*((2*pi*freq/(1.5e-5)).sqrt);

calc= 2*m*m/((2*(2.sqrt)*m)+1);

t1= (density/(2*pi*1.2*freq))*calc;

e1dive2=0.01; //a guess!

t2= e1dive2/(pi*freq);

//leave G as 1
t3= 1.0/(8*mu*l*freq*freq*1);

1/((1/t1)+(1/t2)+(1/t3))
};

modeamps=Array.fill(modes,{arg i; decaytimefunc.value(modefreqs.at(i))});

modefreqs.postln;
modeamps.postln;

{
var output;
//EnvGen.ar(Env.new([0.001,1.0,0.9,0.001],[0.001,0.01,0.3],'exponential'),WhiteNoise.ar)
//could slightly vary amps and phases with each strike?

output=EnvGen.ar(
Env.new([0,1,1,0],[0,10,0]),doneAction:2)*
//slight initial shape favouring lower harmonics- 1.0*((modes-i)/modes)
Mix.fill(modes,{arg i; XLine.ar(1.0,modeamps.at(i),10.0)*SinOsc.ar(modefreqs.at(i),0,1.0/modes)});

Pan2.ar(output,0)
}.play;

)
















Most physical models tend to follow a paradigm of a non-linear exciter, and a linear resonantor.

exciter- human lips in brass instruments, a reed in woodwind, the bow/plectrum/quill/hammer/fingers for strings, the beater/stick/brush/mallet/hands for percussion

resonator- the bore of wind instruments, the string of a string instrument, the membrane of a drum.

So the exciter is the energy source of the sound, whilst the resonantor is typically an instrument body that propagates the sound. The resonator is coupled to the air which transmits sound, but in most physical models we imagine a pickup microphone on the body and miss out the voyage in air of the sound (or we add separate reverberation models and the like).

















The following is a piano sound by James McCartney that shows off how a short strike sound can be passed through filters to make a richer emulation of a real acoustic event. First you'll hear the piano hammer sound, then the rich tone.


(
// this shows the building of the piano excitation function used below
{
	var strike, env, noise;
	strike = Impulse.ar(0.01);
	env = Decay2.ar(strike, 0.008, 0.04);
	noise = LFNoise2.ar(3000, env);
	[strike, K2A.ar(env), noise]
}.plot(0.03); //.scope
)


(
// hear the energy impulse alone without any comb resonation
{
	var strike, env, noise;
	strike = Impulse.ar(0.01);
	env = Decay2.ar(strike, 0.008, 0.04);
	noise = LFNoise2.ar(3000, env);
	10*noise
}.scope
)



//single strike with comb resonation

(
{
	var strike, env, noise, pitch, delayTime, detune;
	strike = Impulse.ar(0.01);
	env = Decay2.ar(strike, 0.008, 0.04);

	pitch = (36 + 54.rand);

	Pan2.ar(
			// array of 3 strings per note
			Mix.ar(Array.fill(3, { arg i;
				// detune strings, calculate delay time :
				detune = #[-0.05, 0, 0.04].at(i);
				delayTime = 1 / (pitch + detune).midicps;
				// each string gets own exciter :
				noise = LFNoise2.ar(3000, env); // 3000 Hz was chosen by ear..
				CombL.ar(noise,		// used as a string resonator
					delayTime, 		// max delay time
					delayTime,			// actual delay time
					6) 				// decay time of string
			})),
			(pitch - 36)/27 - 1 // pan position: lo notes left, hi notes right
		)

}.scope
)



(
// synthetic piano patch (James McCartney)
var n;
n = 6;	// number of keys playing
play({
	Mix.ar(Array.fill(n, {	// mix an array of notes
		var delayTime, pitch, detune, strike, hammerEnv, hammer;

		// calculate delay based on a random note
		pitch = (36 + 54.rand);
		strike = Impulse.ar(0.1+0.4.rand, 2pi.rand, 0.1); // random period for each key
		hammerEnv = Decay2.ar(strike, 0.008, 0.04); // excitation envelope
		Pan2.ar(
			// array of 3 strings per note
			Mix.ar(Array.fill(3, { arg i;
				// detune strings, calculate delay time :
				detune = #[-0.05, 0, 0.04].at(i);
				delayTime = 1 / (pitch + detune).midicps;
				// each string gets own exciter :
				hammer = LFNoise2.ar(3000, hammerEnv); // 3000 Hz was chosen by ear..
				CombL.ar(hammer,		// used as a string resonator
					delayTime, 		// max delay time
					delayTime,			// actual delay time
					6) 				// decay time of string
			})),
			(pitch - 36)/27 - 1 // pan position: lo notes left, hi notes right
		)
	}))
})
)


























A simple form of physical modelling sound synthesis (related to what we've just heard above) is Karplus-Strong synthesis.

You start with a noise source in a delay line of length based on the pitch of note you would like. Then you successively filter the delay line until all the sound has decayed. You get a periodic sound because the loop (the delayline) is of fixed length.

			------>delay ----------> output
		 				/\						|
						|						\/
						----<--filter---<----


The examples above were a little like this, because a comb filter is a recirculating delay line. The filter acts to dampen the sound down over time, whilst the length of the delay line corresponds to the period of the resulting waveform.


The Pluck UGen is a readymade Karplus-Strong synthesis unit:
(
	{Pluck.ar(WhiteNoise.ar(0.1), Impulse.kr(1), 440.reciprocal, 440.reciprocal, 10,
		coef:MouseX.kr(-0.999, 0.999))
	}.play(s)
)




This can be broken down as individual UGens if you're careful:

(

{
var freq,time, ex, delay, filter, local;

freq= 440;
time= freq.reciprocal;

ex= WhiteNoise.ar(EnvGen.kr(Env([1.0,1.0,0.0,0.0], [time,0,100])));

local= LocalIn.ar(1);

filter= LPZ1.ar(ex+local); //apply filter

delay= DelayN.ar(filter, time, time-ControlDur.ir);

ControlDur.ir.poll;

LocalOut.ar(delay*0.95);

Out.ar(0, Pan2.ar(filter,0.0))
}.play

)


A fundamental limitation of doing it this way is that any feedback (here achieved using a LocalIn and LocalOut pair) acts with a delay of the block size (64 samples by default). This is why I take off the blocksize as a time from the delay time with ControlDur.ir. The maximum frequency this system can cope with is SampleRate.ir/ControlDur.ir, which for standard values is 44100/64, about 690 Hz. So more accurate physical models often have to be built as individual UGens, not out of UGens.










Some further examples:

I can modulate the length of the delay line to make a vibrato:



(

{
var freq,time, ex, delay, filter, local;

freq= 440;
time= freq.reciprocal;

ex= WhiteNoise.ar(EnvGen.kr(Env([1.0,1.0,0.0,0.0], [time,0,100])));

freq= SinOsc.ar(6, 0, 10, freq);
time= freq.reciprocal;

local= LocalIn.ar(1);

filter= LPZ1.ar(ex+local); //apply filter

//maximum delay time is 440-10
delay= DelayN.ar(filter, 430.reciprocal, time-ControlDur.ir);

LocalOut.ar(delay*0.99);

Out.ar(0, Pan2.ar(filter,0.0))
}.play

)





Contributions from Thor Magnusson giving an alternative viewpoint:


// we use a noise ugen to generate a burst
(
{
 var burstEnv, att = 0, dec = 0.001; //Variable declarations
 burstEnv = EnvGen.kr(Env.perc(att, dec), gate: Impulse.kr(1)); //envelope
 PinkNoise.ar(burstEnv); //Noise, amp controlled by burstEnv
}.play
)

// but then we use Comb delay to create the delay line that creates the tone


// let's create a synthdef using Karplus-Strong
SynthDef(\ks_guitar, { arg note, pan, rand, delayTime, noiseType=1;
	var x, y, env;
	env = Env.new(#[1, 1, 0],#[2, 0.001]);
	// A simple exciter x, with some randomness.
	x = Decay.ar(Impulse.ar(0, 0, rand), 0.1+rand, WhiteNoise.ar);
 	x = CombL.ar(x, 0.05, note.reciprocal, delayTime, EnvGen.ar(env, doneAction:2));
	x = Pan2.ar(x, pan);
	Out.ar(0, LeakDC.ar(x));
}).store;

// and play the synthdef
(
{
	20.do({
		Synth(\ks_guitar, [\note, 220+(400.rand),
					\pan, 1.0.rand2,
					\rand, 0.1+0.1.rand,
					\delayTime, 2+1.0.rand]);

	   (1.0.rand + 0.5).wait;
	});
}.fork
)

// here using patterns
a = Pdef(\kspattern,
		Pbind(\instrument, \ks_guitar, // using our sine synthdef
					\note, Pseq.new([60, 61, 63, 66], inf).midicps, // freq arg
					\dur, Pseq.new([0.25, 0.5, 0.25, 1], inf),  // dur arg
					\rand, Prand.new([0.2, 0.15, 0.15, 0.11], inf),  // dur arg
					\pan, 2.0.rand-1,
					\delayTime, 2+1.0.rand;  // envdur arg

		)
).play;

// compare using whitenoise and pinknoise as an exciter:

// whitenoise

(
{
 var burstEnv, att = 0, dec = 0.001;
 var burst, delayTime, delayDecay = 0.5;
 var midiPitch = 69; // A 440
 delayTime = midiPitch.midicps.reciprocal;
 burstEnv = EnvGen.kr(Env.perc(att, dec), gate: Impulse.kr(1/delayDecay));
 burst = WhiteNoise.ar(burstEnv);
 CombL.ar(burst, delayTime, delayTime, delayDecay, add: burst);
}.play
)

// pinknoise
(
{
 var burstEnv, att = 0, dec = 0.001;
 var burst, delayTime, delayDecay = 0.5;
 var midiPitch = 69; // A 440
 delayTime = midiPitch.midicps.reciprocal;
 burstEnv = EnvGen.kr(Env.perc(att, dec), gate: Impulse.kr(1/delayDecay));
 burst = PinkNoise.ar(burstEnv);
 CombL.ar(burst, delayTime, delayTime, delayDecay, add: burst);
}.play
)



// Note that delayTime is controlling the pitch here. The delay time is reciprocal to the pitch. // 1/100th of a sec is 100Hz, 1/400th of a sec is 400Hz.


(
SynthDef(\KSpluck, { arg midiPitch = 69, delayDecay = 1.0;
	var burstEnv, att = 0, dec = 0.001;
	var signalOut, delayTime;

	delayTime = [midiPitch, midiPitch + 12].midicps.reciprocal;
	burstEnv = EnvGen.kr(Env.perc(att, dec));
	signalOut = PinkNoise.ar(burstEnv);
	signalOut = CombL.ar(signalOut, delayTime, delayTime, delayDecay, add: signalOut);
	DetectSilence.ar(signalOut, doneAction:2);
	Out.ar(0, signalOut)
	}
).store;
)

(
//Then run this playback task
r = Task({
	{Synth(\KSpluck,
		[
		\midiPitch, rrand(30, 90), //Choose a pitch
		\delayDecay, rrand(0.1, 3.0) //Choose duration
		]);
		//Choose a wait time before next event
		[0.125, 0.125, 0.25].choose.wait;
	}.loop;
}).play
)


















Further interesting sources:

Some useful filter UGens for modelling instrument bodies and oscillators for sources:
[Klank]
[Ringz]	//single resonating component of a Klank resonator bank
[Resonz]
[Decay]
[Formant]
[Formlet]



Further examples:

[Spring]
[Ball]
[TBall]



STK Library
MdaPiano
MembraneUGens
TwoTube, NTube (in SLUGens)
and more:
http://sourceforge.net/projects/sc3-plugins/

PMSC Library: (great fun!)

http://swiki.hfbk-hamburg.de:8888/MusicTechnology/802





// Paul Lansky ported the STK physical modeling kit by Perry Cook and Gary Scavone
// for SuperCollider. It can be found on his website.
// Here are two examples using a mandolin and a violin bow


// let's try the mandolin
{StkMandolin.ar(mul:3)}.play

(SynthDef(\mando, {arg freq, bodysize, pickposition, stringdamping, stringdetune, aftertouch;
	var signal;
	signal = StkMandolin.ar(freq, bodysize, pickposition, stringdamping, stringdetune, aftertouch);
	Line.kr(1,1,2,doneAction:2); //force deallocation
	Out.ar(0, signal);
}).add
)


(
Synth(\mando, [	\freq, rrand(300, 600),
					\bodysize, rrand(22, 64),
					\pickposition, rrand(22, 88),
					\stringdamping, rrand(44, 80),
					\stringdetune, rrand(1, 10),
					\aftertouch, rrand(44, 80)
					]);
)



(
Task({
	100.do({
		Synth(\mando, [	\freq, rrand(300, 600),
					\bodysize, rrand(22, 64),
					\pickposition, rrand(22, 88),
					\stringdamping, rrand(44, 80),
					\stringdetune, rrand(1, 10),
					\aftertouch, rrand(44, 80)
					]);
		1.wait;
	})
}).start;
)

// and the StkBowed UGen:

(
SynthDef(\bow, {arg freq, bowpressure = 64, bowposition = 64, vibfreq=64, vibgain=64, loudness=64;
	var signal;
	signal = StkBowed.ar(freq, bowpressure, bowposition, vibfreq, vibgain, loudness);
	signal = signal * EnvGen.ar(Env.linen, doneAction:2);
	Out.ar([0,1], signal*10);
}).add
)

(
Task({
	100.do({
		Synth(\bow, [		\freq, rrand(200, 440),
							\bowpressure, rrand(22, 64),
							\bowposition, rrand(22, 64),
							\vibfreq, rrand(22, 44),
							\vibgain, rrand(22, 44)
					]);
		1.wait;
	})
}).start;
)






