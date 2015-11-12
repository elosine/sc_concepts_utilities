
{
	var phasor= Phasor.ar(0, 0.001, 0, 100).poll;
	var sample= HPZ1.ar(phasor)<0;
	EnvGen.ar(Env.linen(0.1,0.1,0.1,1,\sine),  sample )

}.scope