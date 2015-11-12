//a bit of filtering and tweaking, you get a decent guitar amp...

(
{
	var in, amount, amCoef;
	in = HPF.ar(SoundIn.ar(0), 400)*5;
	amount = 0.99;
	amCoef= 2*amount/(1-amount);
	MidEQ.ar(LPF.ar((1+amCoef)*in/(1+(amCoef*in.abs)), [3800, 3900])*0.5, 120, 0.7, 8);
}.play;
)