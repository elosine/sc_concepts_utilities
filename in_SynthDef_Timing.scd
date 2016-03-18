If you can't branch, what good is a comparison in the server?
Comparisons have a lot of uses, actually.
Choosing one of two signals: This is the closest we can get to if-then-else in the server. Both then and else must be running continuously. That's a requirement of how the server works: the number and arrangement of unit generators within a single Synth cannot change. Instead, you can choose which of those signals makes it downstream. One will be used and the other ignored.

Since true is 1 and false is 0, you can use a conditional to index into an array using Select.
Select.kr(aKrSignal > anotherKrSignal, [false_signal, true_signal]);
Generating triggers: A trigger occurs whenever a signal is <= 0, and then becomes > 0. Extending this to comparisons, it means that a trigger occurs when a comparison is false for a while, and then becomes true. Comparing a signal to a threshold may then be used anywhere that a trigger is valid. For a simple example, take the case of sending a message to the language when the microphone input's amplitude crosses a threshold.
var mic = In.ar(8, 1),
amplitude = Amplitude.kr(mic);
SendTrig.kr(amplitude > 0.2, 0, amplitude);
Passing or suppressing triggers: You might need to generate triggers continuously, but permit the triggers to take effect only when a condition is met. Multiplication handles this nicely: condition * trigger. Since the condition evaluates as 0 when false, the trigger will be replaced by 0 and nothing happens, as desired.

For a simple case, let's refine the mic amplitude example by suppressing triggers that occur within 1/4 second after the previous.
var mic = In.ar(8, 1),
amplitude = Amplitude.kr(mic),
trig = amplitude > 0.2,
timer = Timer.kr(trig),  // how long since the last trigger?
filteredTrig = (timer > 0.25) * trig;
SendTrig.kr(filteredTrig, 0, amplitude);

//Examples
//Single Trigger
{
	var a=SinOsc.kr(0.5);
	var env=EnvGen.ar(Env.perc(),a>0.5);
	var sig=SinOsc.ar();
	Out.ar(0, sig*env)
}.play

//Timer Trigger
(//AND is multiplication OR is addition
{
	var master, t0, e0, s0, t1, e1, s1;
	master = Phasor.ar(0, (1.0/(44100.0*2.0)) );
	t0 = master>0.25;

	e0=EnvGen.ar(Env.perc(),t0);
	s0=SinOsc.ar();
	//  ((x > 0) + (y > 0)) > 0
	t1 = ( ((master>0.5) * (master<0.51)) + (master>0.75) ).poll;
	e1=EnvGen.ar(Env.perc(),t1);
	s1=SinOsc.ar(660);
	Out.ar(0, [s1*e1, s0*e0])

}.play
)

//Another Example using Impulse & Env
(//AND is multiplication OR is addition
{
	var master, t0, e0, s0, t1, e1, s1, i1, ie1;
	master = Phasor.ar(0, (1.0/(44100.0*2.0)) );
	t0 = master>0.25;

	e0=EnvGen.ar(Env.perc(),t0);
	s0=SinOsc.ar();
	//  ((x > 0) + (y > 0)) > 0
	t1 = master>0.75;
	ie1=EnvGen.ar(Env.asr(0.01, 1, 0.01, 0),t1);
	i1 = Impulse.ar(4)*ie1;
	e1=EnvGen.ar(Env.perc(),i1);
	s1=SinOsc.ar(660);
	Out.ar(0, [s1*e1, s0*e0])

}.play
)






