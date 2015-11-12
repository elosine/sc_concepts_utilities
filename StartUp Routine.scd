(

//Initialization Sequence
~init = {
	s.waitForBoot{
	fork{
		1.postln;
		//Add SynthDefs
		//Make Busses
		//Load Buffers
		//Make Groups
		0.1.wait;

		2.postln;
		//Functions
		//OSC Defs
		0.1.wait;

		3.postln;
		//Routines
		0.1.wait;

		4.postln;
		//GUI
		{

		}.defer
	}
}};

//Exit Sequence
~exit = {
	fork{
		1.postln;

		0.1.wait;

		2.postln;

		0.1.wait;

		3.postln;

		0.1.wait;
}};

//Initialization OSCified
//// Using this, you can initialize remotely
OSCdef( \init, {~init.value}, "/init" );
//Exit OSCified
//// Using this, you can exit remotely
OSCdef( \exit, {~exit.value}, "/exit" );
)

a = NetAddr("localhost", 57120);
a.sendMsg("/init");
a.sendMsg("/exit");