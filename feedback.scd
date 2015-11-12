(
var play, imp, initial;
SynthDef("testRes", {

	play = InFeedback.ar(10, 1); // 10 is feedback channel
	imp = SoundIn.ar();

	// feedback
	OffsetOut.ar(10, DelayC.ar(imp + (play * 0.995), 1,
		MouseY.kr(50,2000).reciprocal - ControlRate.ir.reciprocal)); // subtract block size

	OffsetOut.ar([0,1], tanh(play) * 0.9);

}).play(s);
) 