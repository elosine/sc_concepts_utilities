// ControlSpec-map can also be used to map ugens
(
var spec;
spec = [ 100, 18000, \exp].asSpec;
{
    var freq,osc;
    osc = SinOsc.kr(0.1).range(0,1);
    freq = spec.map( osc );

    freq.dump;// BinaryOpUGen

    SinOsc.ar(
        freq.poll
    )
}.play
)


//USING RANGE
(
SynthDef(\kmap,{
	arg freq=0.2, r1=0.0, r2=1.0;
	SinOsc.ar(freq).range(r1, r2).poll;
}).add;
)
a = Synth(\kmap);
a.set(\r1, 100.0, \r2, 1000.0);
a.free;

b = Bus.control(s);
c = [ 1, 10, \exp].asSpec;
a.c.map(\freq, b);
s.boot;


