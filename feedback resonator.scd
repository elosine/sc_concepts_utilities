// Resonator, must subtract blockSize for correct tuning
(
SynthDef("testRes", {

var freq = 300, localIn, input, limitLevel = 0.2, output;
var feedbackAmt = 0.999;

freq = MouseY.kr(20, 678, \exponential).poll;
feedbackAmt = MouseX.kr(0.2, 0.99999).poll;
localIn = LocalIn.ar(1);
input = LFNoise1.ar(freq * 16, 0.2);
input = input + Dust2.ar(freq);


LocalOut.ar(
	HPF.ar(LPF.ar(DelayC.ar(input + (localIn * feedbackAmt), 2, freq.reciprocal - ControlRate.ir.reciprocal), freq * 8), freq * 0.125)
);

output = Limiter.ar(localIn, limitLevel, 0.01) * limitLevel.reciprocal;
OffsetOut.ar(0, output ! 2);

}).play(s);

)