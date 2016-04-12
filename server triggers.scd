SynthDef(\test,
	{
		arg carF=380, modR, modD;
		var car, mod, modF;
		modF = carF*modR;
		mod = SinOsc.ar(modF*modD);
		car = SinOsc.ar(carF+mod);
		Out.ar(0, car);
}).add;

~mySynth = Synth(\test);
~mySynth.set(\modR, 3.7);
~mySynth.set(\modD, 200);

(
SynthDef(\trigtest, {
	var lfo = SinOsc.kr(0.1).range(0.0, 1.0);
	var trig = Impulse.kr(20);
	SendReply.kr(trig, '/slsin', lfo, 1905);
}).add;


SynthDef(\rmstest, {
	var sig = SoundIn.ar(0);
	SendPeakRMS.kr(sig, 20, 3, '/peak1', 1906);
}).add;
)

a= Synth(\trigtest);
b= Synth(\rmstest);
(
OSCFunc({|msg|
	{
		p.value_(msg[3]);
		//~proc.sendMsg(...

	}.defer
},'/slsin');


OSCFunc({|msg|
	{
		m.value_(msg[3])
	}.defer
},'/peak1');
)

(//draw all GUI elements////////////
w = Window.new("A bunch of sliders",
	//draw main window
	Rect(Window.screenBounds.width-1500, Window.screenBounds.height-200, 700, 500)).front;
//place a number box
~num1 = NumberBox(w, Rect(42, 362, 60, 20));
//place text below it
~txt1 = StaticText(w, Rect(55, 380, 100, 20)).string_("freq");
//place slider above it
~sld1 = Slider(w, Rect(50, 60, 40, 300))//take action from slider value
.action_({
	a = ~sld1.value.linexp(0, 1, 80, 1200);//remap slider value 0-1 to n-n
	~num1.value_(a);//number box value = remapped slider value
	~mySynth.set(\carF, a);

});

d = Slider(w, Rect(130, 60, 40, 300));
g = Slider(w, Rect(210, 60, 40, 300));
j = Slider(w, Rect(290, 60, 40, 300));
m = Slider(w, Rect(370, 60, 40, 300));
p = Slider(w, Rect(450, 60, 40, 300));
)

w.close

p.value_(1);
