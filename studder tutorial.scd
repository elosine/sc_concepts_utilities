// Source audio: simple sweep
{ Pulse.ar(XLine.kr(100, 1000, 5)) * 0.1!2 }.play;

// All you need is a varying delay.
// In this example, an 0.2s delay is switched on every other 0.2s. So every 0.2s of audio is repeated once.
(
{
    var snd = Pulse.ar(XLine.kr(100, 1000, 5));
    snd = DelayC.ar(snd, 0.2, LFPulse.ar((0.2 * 2).reciprocal) * 0.2);
    snd * 0.1!2;
}.play;
)

// More general version using Stepper instead of LFPulse. You can control the length of the repeat and the number of repeats.
(
{ |fragmentlength = 0.2, numrepeats = 3|
    var trig, reset, del, snd;
    snd = Pulse.ar(XLine.kr(100, 1000, 5));
    trig = Impulse.ar(fragmentlength.reciprocal);
    reset = Impulse.ar(0); // if we don't do this the stepper will start at 1...
    del = Stepper.ar(trig, reset, 0, numrepeats - 1) * fragmentlength;
    snd = DelayC.ar(snd, 10, del);
    snd * 0.1!2;
}.play(args: [\fragmentlength, 0.1, \numrepeats, 4]);
)

// With some enhancements, we can allow the reset counter to be out of sync.
(
{ |holdlength = 0.5, fragmentlength = 0.2|
    var reset, phase, fragment, del, snd;
    snd = Pulse.ar(XLine.kr(100, 1000, 5));

    reset = Impulse.ar(holdlength.reciprocal);
    phase = Sweep.ar(reset);
    // this is the easiest way to make an Impulse resettable? seriously?
    fragment = { |ph| (ph - Delay1.ar(ph)) < 0 + Impulse.ar(0) }.value(phase / fragmentlength % 1);
    del = Latch.ar(phase, fragment);
    snd = DelayC.ar(snd, 10, del);
    snd * 0.1!2;
}.play;
)

// Many stutter plugins let you play back the audio at a different rate.
// This is a little trickier. Speeding up 2x not as easy as adding a Sweep.ar(fragment) because otherwise you get negative delays.
// So you have to add in an extra delay equal to fragmentlength.
(
{ |holdlength = 0.5, fragmentlength = 0.2, rate = 1.5|
    var reset, phase, fragment, del, snd;
    snd = Pulse.ar(XLine.kr(100, 1000, 5));
    reset = Impulse.ar(holdlength.reciprocal);
    phase = Sweep.ar(reset);
    fragment = { |ph| (ph - Delay1.ar(ph)) < 0 + Impulse.ar(0) }.value(phase / fragmentlength % 1);
    del = Latch.ar(phase, fragment) + ((fragmentlength - Sweep.ar(fragment)) * (rate - 1));
    snd = DelayC.ar(snd, 10, del);
    snd * 0.1!2;
}.play;
)

(
~stutter = { |snd, reset, fragmentlength, rate = 1.0, maxdelay = 10|
    var phase, fragment, del;
    phase = Sweep.ar(reset);
    fragment = { |ph| (ph - Delay1.ar(ph)) < 0 + Impulse.ar(0) }.value(phase / fragmentlength % 1);
    del = Latch.ar(phase, fragment) + ((fragmentlength - Sweep.ar(fragment)) * (rate - 1));
    DelayC.ar(snd, maxdelay, del);
};
)

/*
// put this into your extensions dir to install as a pseudo-ugen
Stutter {
    *ar { |in, reset, length, rate = 1.0, maxdelay = 10|
        var phase, fragment, del;
        phase = Sweep.ar(reset);
        fragment = { |ph| (ph - Delay1.ar(ph)) < 0 + Impulse.ar(0) }.value(phase / length % 1);
        del = Latch.ar(phase, fragment) + ((length - Sweep.ar(fragment)) * (rate - 1));
        ^DelayC.ar(in, maxdelay, del);
    }
}
*/




// Next examples use this buffer
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");


// audio-rate stutter inspired by DestroyFX
(
{
    var snd, holdperiod, multiplier;
    snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop: 1);
    holdperiod = MouseY.kr(0.01, 1.0, 1);
    multiplier = MouseX.kr(1, 20);
    snd = ~stutter.(snd, Impulse.ar(holdperiod.reciprocal), holdperiod / multiplier);
    snd * 0.3!2;
}.play;
)

// feedback loop inspired by Glitchmachines
(
{
    var in, loop, out;
    in = PlayBuf.ar(1, b, BufRateScale.kr(b), loop: 1);
	out = (in!2*0.6) + DelayC.ar(LocalIn.ar(2), 0.3, [0.11, 0.13], 0.95);
    loop = out;
    loop = ~stutter.(loop, Impulse.kr([3.4, 5.5]), [0.1, 0.03], [0.8, 1.3]);
    loop = LPF.ar(loop, 5000);
	LocalOut.ar(loop.reverse);
    out * 0.3;
}.play;
)
)

// sequencing with Pmono
(
SynthDef(\stuttertest, {
    |out = 0, buf, t_reset = 0, fragmentlength = 0.1, amp = 0.1|
    var snd;
    snd = PlayBuf.ar(1, buf, BufRateScale.kr(buf), loop: 1);
    snd = ~stutter.(snd, t_reset, fragmentlength);
    Out.ar(out, snd * amp!2);
}).add;
)
(
Pmono(\stuttertest,
    \buf, b,
    \amp, 0.3,
    \reset, 1,
    \dur, 0.1,
    \fragmentlength, Pseq([0.01, 0.03, 0.07, 0.05, 0.06], inf)
).play;
)

// grab audio on onsets
// live performers like this because they can control the effect easily
(
{
    var snd, reset;
    snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop: 1);
    reset = Onsets.kr(FFT(LocalBuf(512), snd), 0.5);
    snd = ~stutter.(snd, reset, 0.05);
    snd = DelayC.ar(snd, 0.2, 0.2);
    snd!2 * 0.3;
}.play;
)

// "scrambler" -- randomly samples from recent audio
// even simpler than stutter, a favorite effect of mine
(
{
    var snd;
    snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop: 1);
    snd = DelayC.ar(snd, 1.0, LFNoise0.ar(13).range(0.0, 1.0));
    snd!2 * 0.3;
}.play;
)

/*
Some other options to try out:
Breakcore ugen in sc3-plugins
BBCut quark (see CutStream* classes for real-time stutter)
*/