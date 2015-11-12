10.1.round(0.5);

-96.0.dbamp

{MouseX.kr(1.0, 0.0, \exponential).poll}.play
{
~sp = \amp.asSpec;
	~num = MouseX.kr();
	~amp = ~sp.map(~num);
	~amp.dump;
	~amp.poll;
}.play
(
var spec;
spec = \amp.asSpec;
{
    var freq, osc;
    osc = SinOsc.kr(0.1).range(0,1);
    freq = spec.map( osc );

    freq.dump;// BinaryOpUGen

    SinOsc.ar(
        freq.poll
    )
}.play
)