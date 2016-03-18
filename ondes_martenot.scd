(
SynthDef(\wedSynth,{arg 	midinote=60,
	octave=0,
	dronelvl=0.5,
	mDist = 1,
	rMix = 0.25,
	rRoom = 0.15,
	mButton,
	daBuff;


	var vals, buf,  s, drone, noise, melody, pulse, root;
	root = midinote+(12*octave);
	f = root.midicps;							//Root frequency
	g = (root+19).midicps;						//Compound fifth above root frequency
	x = MouseX.kr(f, g, 1, 1);
	y = MouseY.kr(0.25, 0.05, 'exponential');
	z = Index.kr(daBuff, MouseX.kr(0, 20));
	mButton = MouseButton.kr([x, x*2], [z, z*2] );

	/////////Synths//////////////
	drone = SinOsc.ar([f, f/2], mul:1)*EnvGen.kr(Env.new(
		Array.rand(16, 0, 0.2),  //Random drones
		Array.rand(15, 1, 5),
		'exponential',
		0,
		1));

	noise = Ringz.ar(WhiteNoise.ar(0.005),
		f*2,
		mul:MouseY.kr(0.15,0.25,'exponential')
	);

	melody = Mix.ar([SinOsc.ar(KeyState.kr(
		46,		//m key
		mButton,
		0),
		SinOsc.kr(y*50, 0, 1),  	//Phase modulation controlled by mouse
		mDist).wrap2(1)*y]);		//Amplitude controlled by mouse

	pulse = LFPulse.ar(KeyState.kr(
		46,
		mButton,
		0.8),
		0,
		LFTri.kr(0.2, 0, 0.5, 0.5),
		y/4);

	/////////Output//////////////
	Out.ar(0,
		Mix.new([
			drone*dronelvl,
			FreeVerb.ar(drone*dronelvl,
				0.8,
				0.7),
			FreeVerb.ar(Mix.new([
				melody,
				Latch.ar(pulse, noise)
				]),
				rMix,
				rRoom
			),
			noise
		])
	);
}).send(s)
)