b = Buffer.read(s, "/Users/jyang/GitHub/liveprocessing/samples/saxsample.aif");
c = Buffer.read(s, "/Users/jyang/GitHub/liveprocessing/samples/Blackbird.aif");
d = Buffer.read(s, "/Users/jyang/GitHub/liveprocessing/samples/icecreamtruckmf.aif");
e = Buffer.read(s, "/Users/jyang/GitHub/liveprocessing/samples/mirdangamRoll1.aif");
f = Buffer.read(s, "/Users/jyang/GitHub/liveprocessing/samples/tambura.aif");
g = Buffer.read(s, "/Users/jyang/GitHub/liveprocessing/samples/unacorda.aif");

SynthDef(\pvmorph, {
	arg b1, b2, morph;
	var src, c1, c2, i1, i2, lb1, lb2, sig;
	i1 = PlayBuf.ar(1, b1, BufRateScale.kr(b1), loop: 1);
	i2 = PlayBuf.ar(1, b2, BufRateScale.kr(b2), loop: 1);
	lb1 = LocalBuf.new(2048);
	lb2 = LocalBuf.new(2048);
	c1 = FFT(lb1, i1);
	c2 = FFT(lb2, i2);
	sig = PV_Morph(c1, c2, morph);
	Out.ar(0, IFFT(sig));
}).add;

a = Synth(\pvmorph, [\b1, b, \b2, c]);
a.set(\morph, 0.1, \b2, d);


SynthDef(\pvbinwipe, {
	arg b1, b2, trans;
	var src, c1, c2, i1, i2, lb1, lb2, sig;
	i1 = PlayBuf.ar(1, b1, BufRateScale.kr(b1), loop: 1);
	i2 = PlayBuf.ar(1, b2, BufRateScale.kr(b2), loop: 1);
	lb1 = LocalBuf.new(2048);
	lb2 = LocalBuf.new(2048);
	c1 = FFT(lb1, i1);
	c2 = FFT(lb2, i2);
	sig = PV_BinWipe(c1, c2, trans);
	Out.ar(0, IFFT(sig));
}).add;

a = Synth(\pvbinwipe, [\b1, b, \b2, c]);
a.set(\trans, 0.2, \b2, d);
a.free;

SynthDef(\pvcopyphase, {
	arg b1, b2, trans;
	var src, c1, c2, i1, i2, lb1, lb2, sig;
	i1 = PlayBuf.ar(1, b1, BufRateScale.kr(b1), loop: 1);
	i2 = PlayBuf.ar(1, b2, BufRateScale.kr(b2), loop: 1);
	lb1 = LocalBuf.new(2048);
	lb2 = LocalBuf.new(2048);
	c1 = FFT(lb1, i1);
	c2 = FFT(lb2, i2);
	sig = PV_CopyPhase(c1, c2, trans);
	Out.ar(0, IFFT(sig));
}).add;

a = Synth(\pvcopyphase, [\b1, b, \b2, c]);
a.set(\b1, c, \b2, b);
a.set(\b2, d);
a.free;

SynthDef(\pvcommonmul, {
	arg b1, b2, trans, t2;
	var src, c1, c2, i1, i2, lb1, lb2, sig;
	i1 = PlayBuf.ar(1, b1, BufRateScale.kr(b1), loop: 1);
	i2 = PlayBuf.ar(1, b2, BufRateScale.kr(b2), loop: 1);
	lb1 = LocalBuf.new(2048);
	lb2 = LocalBuf.new(2048);
	c1 = FFT(lb1, i1);
	c2 = FFT(lb2, i2);
	sig = PV_CommonMul(c1, c2, trans, t2);
	Out.ar(0, IFFT(sig));
}).add;

a = Synth(\pvcommonmul, [\b1, b, \b2, c, \trans, 10, \t2, 0.5]);
a.set(\b1, c, \b2, b, \trans, 70, \t2, 4);
a.set(\b1, d);
a.free;

SynthDef(\pvmagsubtract, {
	arg b1, b2, t1, t2;
	var src, c1, c2, i1, i2, lb1, lb2, sig;
	i1 = PlayBuf.ar(1, b1, BufRateScale.kr(b1), loop: 1);
	i2 = PlayBuf.ar(1, b2, BufRateScale.kr(b2), loop: 1);
	lb1 = LocalBuf.new(2048);
	lb2 = LocalBuf.new(2048);
	c1 = FFT(lb1, i1);
	c2 = FFT(lb2, i2);
	sig = PV_MagSubtract(c1, c2);
	Out.ar(0, IFFT(sig));
}).add;

a = Synth(\pvmagsubtract, [\b1, b, \b2, c]);
a.set(\b1, b, \b2, c);
a.set(\b1, d);
a.free;

SynthDef(\pvrandwipe, {
	arg b1, b2, t1, t2, dens=1;
	var src, c1, c2, i1, i2, lb1, lb2, sig, trig;
	trig = Dust.kr(dens);
	i1 = PlayBuf.ar(1, b1, BufRateScale.kr(b1), loop: 1);
	i2 = PlayBuf.ar(1, b2, BufRateScale.kr(b2), loop: 1);
	lb1 = LocalBuf.new(2048);
	lb2 = LocalBuf.new(2048);
	c1 = FFT(lb1, i1);
	c2 = FFT(lb2, i2);
	sig = PV_RandWipe(c1, c2, t1, trig);
	Out.ar(0, IFFT(sig));
}).add;

a = Synth(\pvrandwipe, [\b1, b, \b2, c]);
a.set( \t1, 0.7);
a.set(\b1, c, \b2, b, \t1, 0.4);
a.set(\b1, d);
a.free;

SynthDef(\pvsoftwipe, {
	arg b1, b2, t1, rate=0.1, lo=0.01, hi=0.2;
	var src, c1, c2, i1, i2, lb1, lb2, sig, lfo, trig;
	lfo = SinOsc.kr(rate).range(lo, hi);
	trig = Dust.kr(rate);
	//lfo = TRand.kr(lo, hi, trig);
	i1 = PlayBuf.ar(1, b1, BufRateScale.kr(b1), loop: 1);
	i2 = PlayBuf.ar(1, b2, BufRateScale.kr(b2), loop: 1);
	lb1 = LocalBuf.new(2048);
	lb2 = LocalBuf.new(2048);
	c1 = FFT(lb1, i1);
	c2 = FFT(lb2, i2);
	sig = PV_SoftWipe(c1, c2, lfo);
	Out.ar(0, IFFT(sig));
}).add;

a = Synth(\pvsoftwipe, [\b1, b, \b2, c]);
a.set( \rate, 0.08, \lo, - 0.01, \hi, 0.15);
a.set(\b2, g);
a.set(\b1, g, \b2, b);
a.free;



SynthDef(\pvxfade, {
	arg b1, b2, t1, rate=0.1, lo=0.0, hi=1.0;
	var src, c1, c2, i1, i2, lb1, lb2, sig, lfo, trig;
	lfo = SinOsc.kr(rate).range(lo, hi);
	trig = Dust.kr(rate);
	//lfo = TRand.kr(lo, hi, trig);
	i1 = PlayBuf.ar(1, b1, BufRateScale.kr(b1), loop: 1);
	i2 = PlayBuf.ar(1, b2, BufRateScale.kr(b2), loop: 1);
	lb1 = LocalBuf.new(2048);
	lb2 = LocalBuf.new(2048);
	c1 = FFT(lb1, i1);
	c2 = FFT(lb2, i2);
	sig = PV_XFade(c1, c2, lfo);
	Out.ar(0, IFFT(sig));
}).add;

a = Synth(\pvxfade, [\b1, b, \b2, c]);
a.set( \rate, 0.08, \lo, - 0.01, \hi, 0.15);
a.set(\b2, g);
a.set(\b1, g, \b2, b);
a.free;

SynthDef(\conv, {
	arg b1, b2;
	var src, i1, i2, sig, a1, a2, amp;
	amp = \amp.kr(0.85, 0.01);
	a1 = \a1.kr(0.5, 0.01);
	a2 = \a2.kr(0.5, 0.01);
	i1a = PlayBuf.ar(1, b1, BufRateScale.kr(b1), loop: 1);
	i2b = PlayBuf.ar(1, b2, BufRateScale.kr(b2), loop: 1);
	sig = Convolution.ar(i1*a1, i2*a2, 1024);
	Out.ar(0, sig*amp);
}).add;

a = Synth(\conv, [\b1, b, \b2, c]);
a.set(\a1, 0.5, \a2, 0.5, \amp, 0.85);
a.set(\b2, c);
a.free;
