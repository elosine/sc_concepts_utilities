
Analogue Modelling Tips and Tricks


Contents:

Analogue Warmth: avoiding aliasing, chorusing
Filter Comparison: standard filters, BEQ Suite, MoogFF
More Server Side Sequencing: Demand rate UGens




















Simulating Analogue Warmth


Digital systems have the drawback of setting hard contraints on representable frequencies and amplitude levels

Avoiding aliasing; use band limited waveforms (i.e. Saw not LFSaw for higher frequencies)

(
{
[LFSaw.ar(1000),Saw.ar(1000)]
}.plot(0.01)
)

But then, both are perfectly serviceable for low frequencies and the rougher edge to LFSaw can be useful.








Sidenote on aliasing:
Fundamental frequencies at divisors of the sampling rate have harmonics which only alias at harmonic locations!

//These assume 44100Hz output sampling rate
s.sampleRate

//warning; LOUD, awkward on ear
{LFSaw.ar(4410+(MouseX.kr(0,10).round(1)),0,0.5)}.scope

//aliasing if mouse moved left
{LFSaw.ar(1102.5+(MouseX.kr(0,10).round(1)),0,0.5)}.scope

//no aliasing
{Saw.ar(1102.5+(MouseX.kr(0,10).round(1)),0.5)}.scope












Chorusing (detuned oscillators)


{Saw.ar(440,0.2)}.play //plain


Though it increases sensory dissonance (beats and roughness between partials), a thicker sound is possible by mixing multiple copies of a waveform generator with subtle differences


{Mix(Saw.ar(440*[0.99,1.01],0.2))}.play //plain
//if want perceptual (log freq) same difference each side need 0.99 and 0.99.reciprocal, but we'll overlook that for now



//Because the oscillators are deterministic, there is a potential problem of highly rigid beating patterns
(
var numdetune=4;
{ [Mix(Saw.ar(Array.rand(numdetune,0.99,1.01)*8,0.2)), DelayC.ar(Mix(Saw.ar(Array.rand(numdetune,0.99,1.01)*13,0.2)), 0.003)] }.play
)

//to alter phases need LFSaw; but could also just add some subtle frequency modulation
(
{
Mix.fill(4,{
var freqmult;

//between 1 +- 0.01
freqmult= 1+SinOsc.ar(LFNoise1.kr(rrand(0.25,0.5),4,5),pi.rand,0.01);

LFSaw.ar(200*(freqmult),pi.rand,0.2)

})
}.play
)
//question for you; why don't I need to use Rand rather than rrand in this case?


(
{Mix.fill(4,{Saw.ar(440*(1+SinOsc.ar(LFNoise1.kr(rrand(0.25,0.5),4,5),pi.rand,0.02)),0.2)}) }.play
)


//more like an analogue synth though to combine different waveforms in proportion and more overt detunings (ie octaves, octave+fifth)


//make a random mix
{Mix.fill(3,{|i| [LFTri, LFCub, LFPar].choose.ar(200*(2**i),pi.rand,10.rand.neg.dbamp)})}.play





















Now to work on the source+filter model for subtractive synthesis

Comparing Filters

//standard filter
(
z = {
	Resonz.ar(
		Mix(Saw.ar([0.99,1,1.01]*440,0.3)),
		MouseX.kr(100,20000,\exponential), // cutoff freq.
		MouseY.kr(0.1, 1.0, \linear), // rq
		0.5); // mul
}.play
)
z.free;

//The BEQSuite (sc3-plugins pack) has some nice filters, which take less energy away:
(
z = {[
	BLowPass4.ar(
		Mix(Saw.ar([0.99,1,1.01]*7,0.3)),
		// MouseX.kr(100,20000,\exponential), // cutoff freq.
		SinOsc.kr(6).range(100,20000,\exponential), // cutoff freq.

		MouseY.kr(0.1, 1.0, \linear), // rq
		0.5),  // mul
	DelayC.ar(
	BLowPass4.ar(
		Mix(Saw.ar([0.99,1,1.01]*7,0.3)),
		// MouseX.kr(100,20000,\exponential), // cutoff freq.
		SinOsc.kr(8).range(100,20000,\exponential), // cutoff freq.

		MouseY.kr(0.1, 1.0, \linear), // rq
			0.5), 0.2, 0.003) ]  // mul
}.play
)


z.free;

//can distort at high gain
(
z = {
	MoogFF.ar(
		Mix(Saw.ar([0.99,1,1.01]*440,0.3)),
		MouseX.kr(100,20000,\exponential), // cutoff freq.
		MouseY.kr(0.1, 4.0, \linear) //gain
		);
}.play
)

z.free;



















Demand Rate UGens

A bit like the Patterns library, server side!

Triggers are used in the Demand UGen to cue a 'demand' for a new value from the attached specialist demand rate UGens (which all begin with D and have names analogous to patterns)

(
{var sequence = Dseq([-0.3,0.5,0.0,0.4],inf); //Dseq is demand rate

Demand.ar(Impulse.ar(10),0, sequence);
}.plot(1.0)
)


So far, similar functionality might be constructed with Select, Index, EnvGen, IEnvGen et al


But akin to patterns, nesting is possible:


(
{var sequence = Dseq([-0.3,Drand([-1,1],1),0.0,0.4],inf); //Dseq is demand rate

Demand.ar(Impulse.ar(100),0, sequence);
}.plot(1.0)
)





Musical use:

(
{var freq, sequence = Dseq([60,Drand([48,72],1),63,62.8],inf); //Dseq is demand rate

freq= Demand.kr(Impulse.kr(MouseX.kr(1,100)),0, sequence).midicps; //only need k-rate; used a-rate in last examples because final output in UGen graph needs to be audio rate

Saw.ar(freq, 0.1)
}.play
)


//multichannel use 1 (multichannel expansion gives independent sequences)
(
{var freq, sequence = Dseq([60,Drand([47,73],1),63,61.5],inf); //Dseq is demand rate

freq= Demand.kr(Impulse.kr([5,5.1]),0, sequence).midicps; //output is two channels, since Dseq has two output values

SyncSaw.ar(freq, 300,0.1);
}.play
)


//multichannel use 2 (multichannel sequence itself)
(
{var freq, sequence = Dseq([[60,48],Drand([48,72],1),63,[61,62.8],[55,62.5],[63,62.1]],inf); //Dseq is demand rate

freq= Demand.kr(Impulse.kr(5),0, sequence).midicps; //output is two channels, since Dseq has two output values

[
SyncSaw.ar(freq[0], LFNoise0.kr(7,100,230),0.1),
SyncSaw.ar(freq[1], LFNoise2.kr(17,400,630),0.1)
]
}.play
)




More demanding: Duty allows you to specify a duration sequence for controlling when the next value is demanded

//interaction of durations for holding current value and output value sequence
{Duty.ar(Dseq([0.025,0.05],inf),0,Dseq([-0.5,0.5,0,-1,1],inf))}.plot(0.6)






The next three examples are provided as more involved patches; you might want to try to work out what is going on!


//putting various things together: rhythmic synthesis
(
{var freq, filterfreq, source, filtered;
var tempo;

tempo= 0.5; //seconds per beat

freq= Duty.kr(Dseq([0.25,0.25,0.5,0.75,0.75,0.75,0.25,0.25,0.25]*tempo,inf),0,Dseq([60,62,63,65,67,55,53,Drand([51,49,58,70],1),70,Drand([70, 48,72,36],1)],inf)).midicps;

filterfreq= Duty.kr(Dseq([0.25,0.25,0.25,0.25,1.0]*tempo,inf),0,Dseq(Array.fill(16,{exprand(300,5000)}),inf));

source= Mix(SyncSaw.ar([1,0.5,0.25,1.01, 1.25]*(freq.lag(0.05)),LFNoise2.kr([0.25,0.5,1,2,4]*(tempo*2),200,300), 0.1));

filtered= BLowPass4.ar(source,filterfreq.lag(0.0625),0.5);

Pan2.ar(filtered, LFNoise1.kr(tempo,0.25))
}.play
)
//note that if you make the Duty's .ar you'll see a substantial increase in CPU usage!








(
{
var source, filter, env;
var trig, freq, freq2;

trig= Impulse.kr(8,[0,0.1]); //stereo here forces stereo throughout the graph, including generating different notes
//trig= Impulse.kr(8);

//sequencer via Demand UGens
freq= Demand.kr(trig,0,Drand([60,63,60,63,65,63,70,67, 60,62,60,63,65,63,70,67, 67,72,75,72,67,70,63,55],inf)).midicps;

//portamento via lag
source= Mix.fill(4,{|i| LFSaw.ar((freq*[0.25*1.5,0.125]).lag(MouseY.kr(0.0,0.15))*((2**(i))+SinOsc.ar(LFNoise1.kr(rrand(0.25,0.5),4,5),pi.rand,0.01)),pi.rand,0.2)});

//if using Saw instead
//source= Mix.fill(4,{|i| Saw.ar((freq*[0.25*1.5,0.125]).lag(MouseY.kr(0.0,0.15))*((2**(i))+SinOsc.ar(LFNoise1.kr(rrand(0.25,0.5),4,5),pi.rand,0.01)),0.2)});

//envelope is restarted by trigger MouseX.kr(0.25,0.125)
env= EnvGen.ar(Env([0,1,0],[0.01,0.25]),trig);

filter= BLowPass.ar(0.5*source,300+(MouseX.kr(100,20000,'exponential')*env),0.2, env);

//Pan2.ar(filter,0.0);
 }.play
)










//using InterplEnv
(
{
var source, filter;
var freq;

freq= IEnvGen.kr(InterplEnv([60,62,63,67,70,67,70,72,48].scramble,0.125.dup(8)),Phasor.ar(LFNoise0.kr(1)>0,0.5*(1.0/SampleRate.ir),0.0,1.0).round(1/8)).midicps;

source= Mix.fill(5,{|i| Saw.ar(freq*(0.25*(2**(i))+SinOsc.ar(LFNoise1.kr([0.125,0.25,0.5].choose,7,8),pi.rand,0.01)),0.2)});

filter= BLowPass.ar(0.5*source,1000+(2000*EnvGen.ar(Env([0,1,0],[0.01,0.25]),Impulse.kr(2))),0.2);

Limiter.ar(GVerb.ar(filter*0.25) + Pan2.ar(filter))
 }.play
)









