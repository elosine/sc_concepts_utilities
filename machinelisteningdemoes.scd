Some Machine Listening Demoes


SuperCollider comes with an amplitude tracker and pitch tracker for realtime audio 


(
// use audio input's amplitude to control PinkNoise amplitude - use headphones to prevent feedback.
{
	PinkNoise.ar(Amplitude.kr(SoundIn.ar(0)))
}.play
)


You can threshold the input to avoid picking up background noise

(
{
var input,inputAmp,threshhold,gate;
var basefreq;

input = SoundIn.ar(0); 
inputAmp = Amplitude.kr(input);
threshhold = 0.02;	// noise gating threshold
gate = Lag.kr(inputAmp > threshhold, 0.01);

PinkNoise.ar(0.2) * gate		
}.play;
)














The Pitch follower has many input arguments, though you usually take the defaults without worrying. It returns two outputs: the tracked frequency and a signal indicating whether it has locked onto any periodicity or not

(
{
	var amp, freq, hasFreq;
	var input; 
	
	input = SoundIn.ar; 
	
	amp = Amplitude.kr(input); 
	 
	#freq, hasFreq = Pitch.kr(input);  
	
	amp * SinOsc.ar(freq) 
}.play
)



//alternatively, two outputs of the Pitch UGen caught into an array
(
{
	var amp, pitch;
	var input; 
	
	input = SoundIn.ar; 
	
	amp = Amplitude.kr(input); 
	 
	pitch = Pitch.kr(input);  
	//pitch[0], pitch[1] are freq and hasFreq signals in above example, respectively
	 
	
	amp * SinOsc.ar(if(pitch[1],pitch[0],0)) 
}.play
)






Server.internal.boot; //if on a Mac pre SC 3.6 you'll need to swap back to internal server for using .scope: you can have both the internal and localhost server on at once, but you might need to press the -> default button

s = Server.default = Server.internal; 

//showing the outputs - K2A makes sure control rate signals are converted to audio rate, because the final output of a Synth has to be audio rate
(
{
var freq, hasFreq;
# freq, hasFreq = Pitch.kr(SoundIn.ar(1,0.1));
[K2A.ar(freq*0.001), K2A.ar(hasFreq)]
}.scope
)


//detected fundamental frequency used to control some oscillators with allpass reverberation
//Amplitude detector also used to make the control track the input more effectively
(
{
	var in, amp, freq, hasFreq, out;
	in = Mix.ar(SoundIn.ar([0,1]));
	amp = Amplitude.kr(in, mul: 0.4);
	# freq, hasFreq = Pitch.kr(in);
	out = Mix.ar( LFTri.ar(freq * [0.5, 1, 2]) ) * amp;
	6.do({ 
		out = AllpassN.ar(out, 0.040, [0.040.rand,0.040.rand], 2) 
	});
	out
}.play
)






//Also switch waveform based on hasFreq output; try the difference between vowels (pitched) and consonants/noise
(
{
	var in, amp, freq, hasFreq, out;
	
	in = SoundIn.ar(1);
	amp = Amplitude.kr(in, mul: 0.4);
	# freq, hasFreq = Pitch.kr(in);
	
	out=if(hasFreq,Pulse.ar(freq,0.5,0.1),SinOsc.ar(freq,0,0.1));
	
	6.do({ 
		out = AllpassN.ar(out, 0.040, [0.040.rand,0.040.rand], 2) 
	});
	out	
}.play
)






(
a={arg mult1=2;
	var in, amp, freq, hasFreq, out;
	in = SoundIn.ar;
	
	amp = Amplitude.kr(in, 0.05, 0.05);
	
	# freq, hasFreq = Pitch.kr(in, ampThreshold: 0.02, median: 7);
	
	out=Saw.ar(freq*[1,mult1], amp);
	
	Out.ar(0,Pan2.ar(Mix(out)))
}.play;
)

//simple arpeggiator 
(
{

inf.do {|i|
a.set(\mult1,[1,2,4,2,1,0.5,1,4].wrapAt(i));

0.125.wait;
}

}.fork;
)


//Tartini can be substituted straight in for Pitch in these patches; the only difference is that hasFreq is a continuous value between 0 and 1 for Tartini, for a degree of voicing







//basic use of Onsets UGen; requies an FFT. LocalBuf used to avoid running extra code to assign a Buffer first

(
{
var soundin, trig;
soundin= SoundIn.ar; 

trig= Onsets.kr(FFT(LocalBuf(512),soundin));

//retrigger envelope, and choose new random frequency for sine tone, on detected onset
EnvGen.ar(Env.perc,trig)*SinOsc.ar(TRand.kr(400,800,trig));
}.play
)





//This time using a preallocated buffer for the FFT. A lot of feature extractors use at least a 1024 point FFT; the Onsets UGen wants to react more quickly, so a 512 size window works better here
// Prepare the buffers
(
b = Buffer.alloc(s, 512);

// a11wlk01 is not the most percussive source: try a drum beat from your hard drive? 
d = Buffer.read(s, "sounds/a11wlk01.wav");

)

// Move the mouse to vary the threshold
(
{
var sig, chain, onsets, noise;

sig = PlayBuf.ar(1,d,loop:1);

chain = FFT(b, sig);

//mouse control is for sensitivity (threshold of detector) 
onsets = Onsets.kr(chain, MouseX.kr(0,1), \rcomplex);

// You'll hear percussive "ticks" whenever an onset is detected
noise = WhiteNoise.ar(EnvGen.kr(Env.perc(0.001, 0.1, 0.2), onsets));
Out.ar(0, Pan2.ar(sig, -0.75, 0.2) + Pan2.ar(noise, 0.75, 1));
}.play;
)





//sequence stepping by onsets detected
(
{
	var sig, chain, onsets, demand, sound;
	
	sig = SoundIn.ar(0);
	
	chain = FFT(b, sig);
	
	onsets = Onsets.kr(chain, MouseX.kr(0,1), \rcomplex);

	//move sequence along when onset detected
	//demand = Demand.kr(Trig1.kr(onsets,0.01), 0, Dseq([60,62,64,67].midicps,inf));
	demand = Stepper.kr(onsets,0,1,8)*200;
	//demand.poll;
	
	sound= Saw.ar(demand,0.2);
	
	Out.ar(0,sig!2);
}.play;
)




//combination with TGrains
//uses buffer d from before
(
{
var source, detect;
	
	source= SoundIn.ar(0); 
	
	detect= Onsets.kr(FFT(LocalBuf(512),source),0.1); //second argument is detection threshold
	//detect= PV_HainsworthFoote.ar(FFT(LocalBuf(2048),source), 1.0, 0.0, 0.7, 0.01);
	
	TGrains.ar(2, detect, d, LFNoise0.kr(10,0.2,1.0), MouseX.kr(0,BufDur.kr(d)), MouseY.kr(0.1,0.5), LFNoise0.kr(10,1.0), 0.5, 2);
}.play
)













//comparing Coyote onset detector from BatUGens: defaults inferior at lower volumes and for fast repetition rates
//The Onsets UGen is a result of proper evaluation in an academic paper, Coyote is more intuitively constructed...
{PinkNoise.ar(Decay.kr(Coyote.kr(SoundIn.ar),0.2))}.play

{PinkNoise.ar(Decay.kr(Onsets.kr(FFT(LocalBuf(512),SoundIn.ar)),0.2))}.play
















//Another feature extractor:  Spectral Centroid, an important timbral cue
(
{
var in, spectrum, centroid; 	
	
in = SoundIn.ar; 
	
spectrum = FFT(LocalBuf(1024), in);

centroid = SpecCentroid.kr(spectrum);

centroid.poll;

SinOsc.ar(centroid/8)*0.1; 
 
}.play
)



//using SendTrig to get single values back to language from server
(
{
var in, spectrum, centroid; 	
	
in = SoundIn.ar; 
	
spectrum = FFT(LocalBuf(1024), in);

centroid = SpecCentroid.kr(spectrum);

SendTrig.kr(spectrum,0,centroid); 
}.play
)

// register to receive this message
(
OSCresponder(s.addr,'/tr',{ arg time,responder,msg;
	
	[time,responder,msg].postln;
	
	c = msg[3];
	
}).add
);


//remember last 3 values
(
var memory = {1000}!3; 
var memoryposition =0; 

//only one OSCresponder at a time, will replace previous 
OSCresponder(s.addr,'/tr',{ arg time,responder,msg;
	
	//[time,responder,msg].postln;
	
	
	memory[memoryposition] = msg[3]; 
	
	memoryposition = (memoryposition+1)%3; 
	
	//store latest in global variable
	//c = msg[3];
	//could pass to a global environment variable to access outside this scope
	//~memory = memory; 
	
	memory.postln;
	
}).add
);










//MFCCs demo

b.free;
b = Buffer.alloc(s,1024,1); 

//try different vowel sounds at input (aaaa, eeee, uuuu...) and see how the patch changes to follow
(
{
var in, fft, array, stat1, stat2, sound, freq;

in = SoundIn.ar(0); 
fft = FFT(b, in);
array=MFCC.kr(fft, 5); //5 MFCCS

stat1 = array[1..4].sum;	//create two statistics from the values
stat2 = (array[1] - array[4]);
//rather than instantaneous value, could get further functions over time using RunningSum, Median etc

freq= (stat1*500)+100;

//statistic two used as condition to choose between output signals
sound = if(stat2>0, LFPulse.ar(freq,0.5), LFTri.ar(freq)); 

Out.ar(0,Pan2.ar(sound*0.2)); 
}.play
)







//Using SendReply with mixed multiple feature detectors

//demo of audio->features->synthesis and audio->features->language side decisions

b.free;
b=Buffer.alloc(s, 1024, 1);

(
SynthDef(\audioims,{
var input, fft, mfcc, freq, hasFreq, synthesis, features; 

input= SoundIn.ar; 

fft= FFT(b, input); 

#freq, hasFreq= Pitch.kr(input);

mfcc= MFCC.kr(fft,3);

features= [freq]++mfcc;	//array of four features

//trigger from FFT
SendReply.kr(fft,'myfeaturemessage', features);

//could use the values in synthesis directly
//synthesis= Resonz.ar(Saw.ar(freq),100+(2000*mfcc[0]), 0.01+(0.5*mfcc[1])); 
//
//Out.ar(0,Pan2.ar(synthesis))

}).add;

)

Synth(\audioims)




(
OSCresponder(s.addr,'myfeaturemessage',{ arg time,responder,msg;
	var features;
	
	//[time,responder,msg].postln;
	
	features= msg[3..6]; 
	
	//should be the four features passed across
	features.postln;
	
}).add;

)





//harmonizer (more complicated logic could be done language side, all server side here)
(
{
var temp; 
var pitchclass; 

temp = Tartini.kr(SoundIn.ar); 
pitchclass = ((temp[0].cpsmidi.round(1.0))%12); 
	
SinOsc.ar((72 + Index.kr(LocalBuf.newFrom([4,4,5,6,7,9,10,11,11,0,1,2]),pitchclass)).midicps.poll,0,0.3) 	
+
SinOsc.ar(261.626,0,0.5)	//basic drone; sing a diatonic scale over this root and hear computer harmonize
}.play
)




//chromatic autotune
(

{var soundin, amp, freq, hasFreq, pitchclass, pitch, pitcherror; 
var localbuf, britney; 

localbuf=LocalBuf.newFrom(([60,62,64,65,67,69,71,72]-12).midicps); 

soundin= SoundIn.ar; 
amp= Amplitude.kr(soundin);
#freq, hasFreq= Tartini.kr(soundin); 

pitch = freq.cpsmidi;
pitchclass = freq.cpsmidi.round(1.0); 

pitcherror = pitchclass - pitch; //correction in MIDI note space; midiratio will turn this difference back into a frequency correction ratio

britney= PitchShift.ar(soundin,0.01,if(hasFreq>0.5,pitcherror.midiratio,1.0)); 

britney + Saw.ar(pitchclass.midicps,0.1)
}.play
)








