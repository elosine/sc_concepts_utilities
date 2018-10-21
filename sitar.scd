/*
Based on a model by David Ronan (http://issta.ie/wp-content/uploads/The-Physical-Modelling-of-a-Sitar.pdf).
Requires sc3-plugins.

Lacks shimmer. Sounds more like a banjo than a sitar. I don't know whether
this is just a matter of tuning parameters or whether the model itself needs
fixing.
*/

(
s.waitForBoot({
	// Single string of a sitar.
	SynthDef(\tar, {
		|
		out = 0, in = 0, inscale = 1.0, freq = 440, bw = 1.03, amp = 0.5
		pos = 0.1,
		hc1 = 1, hc3 = 30, hfreq = 3000,
		vc1 = 1, vc3 = 30, vfreq = 3000
		|
		var inp, jawari, snd;
		// Input audio -- may be a pluck impulse (chikari) or audio (tarafdar)
		inp = In.ar(in, 1) * inscale;
		// Jawari (bridge) simulation. This is the heart of Ronan's model.
		// Violins and guitars have vertical bridges. The jawari is flat, and this causes the tar to buzz against the jawari.
		// Physically, end of the string coming in contact the bridge causes the string to shorten.
		// We assume that the audio output is a reasonable approximation of how much contact the string has with the bridge.
		// So we shorten the DWG (by adjusting its frequency) according to its own audio output.
		jawari = LocalIn.ar(1);
		// Make the jawari control rate
		jawari = A2K.kr(jawari);
		// Make the jawari affect the freq exponentially
		jawari = jawari.linexp(-1, 1, bw.reciprocal, bw);
		// The string itself has horizontal and vertical planes, which we simulate with two different DWGPlucked instances
		snd = [
			DWGPlucked.ar(freq * jawari, pos: pos, c1: hc1, c3: hc3, inp: LPF.ar(inp, hfreq)),
			DWGPlucked.ar(freq * jawari, pos: pos, c1: vc1, c3: vc3, inp: LPF.ar(inp, vfreq))
		].sum;
		LocalOut.ar(snd);
		Out.ar(out, snd * amp);
	}).add;

	SynthDef(\pluckImpulse, {
		|out = 0, t_trig = 0, amp = 0.3|
		Out.ar(out, PinkNoise.ar * EnvGen.kr(Env.perc(0.01, 0.02), t_trig) * amp);
	}).add;

	// Useful for testing. For programmatic usage use \pluckImpulse
	SynthDef(\mousePluck, {
		|out = 0, num = 0, amp = 0.3|
		var m = MouseY.kr(0, 8);
		var trig = (num <= m) & (m < (num + 1)) * MouseButton.kr(0, 1, 0);
		Out.ar(out, HPF.ar(WhiteNoise.ar, 400) * EnvGen.kr(Env.perc(0.001, 0.03, 0.5), trig) * amp);
	}).add;

	SynthDef(\sitar, {
		|out = 0, chikari = 0, tarafdar = 0, dry = 0.5, wet = 0.5, amp = 0.5|
		var snd = In.ar(chikari, 1) * dry;
		var lfo;
		snd = snd + (In.ar(tarafdar, 1) * wet);
		// Dumb gourd model. I randomly picked lope only transitions to the release node when released. Examples are below. Tfreqs/bws/amps.
		// Please let me know if you have some estimates of the resonances of a real sitar gourd.
		snd = snd + BPF.ar(snd, [90, 132, 280], [1.3, 0.9, 1.4], [0.9, 0.6, 0.7]).sum;
		snd = Pan2.ar(GVerb.ar(0.3*snd, roomsize:1, damping:0.7), 0, amp);
		Out.ar(out, snd);
	}).add;

	s.sync;

	// Don't take this example tuning seriously.
	// I know next to nothing about ragas and sitar tuning.
	~chikariFreqs = 48.midicps * [1, 16/15, 5/4, 4/3, 3/2, 8/5, 15/8, 2];
	~numChikari = ~chikariFreqs.size;
	~tarafdarFreqs = 48.midicps * [1, 16/15, 5/4, 4/3, 3/2, 8/5, 15/8, 2, 2*16/15, 2*5/4, 2*4/3, 2*3/2];
	~numTarafdar = ~tarafdarFreqs.size;

	// Pluck impulse busses, one per chikari
	~pluckBus = Bus.audio(s, ~numChikari);
	// Summed output of all chikari (plucked strings)
	~chikariBus = Bus.audio(s, 1);
	// Summed output of all tarafdar (sympathetic strings)
	~tarafdarBus = Bus.audio(s, 1);

	~pluckGroup = Group();
	~chikariGroup = Group.after(~pluckGroup);
	~tarafdarGroup = Group.after(~chikariGroup);

	~pluck = ~numChikari.collect { |i|
		Synth(\mousePluck, [
			\out, ~pluckBus.index + i,
			\num, i,
		], ~pluckGroup);
	};
	~chikari = ~numChikari.collect { |i|
		Synth(\tar, [
			\in, ~pluckBus.index + i,
			\out, ~chikariBus,
			\freq, ~chikariFreqs[i],
			\bw, 1.08,
			\hc1, 4, \hc2, 50,
			\vc1, 3, \vc3, 30,
			\amp, 0.1
		], ~chikariGroup);
	};
	~tarafdar = ~numTarafdar.collect { |i|
		Synth(\tar, [
			\in, ~chikariBus,
			\inscale, 0.1,
			\out, ~tarafdarBus,
			\freq, ~tarafdarFreqs[i] * 1.0.rand.linexp(0, 1, 0.99, 1.01),
			\pos, 0.4,
			\bw, 1.08,
			\hc1, 4, \hc2, 50,
			\vc1, 3, \vc3, 30,
			\amp, 0.1
		], ~tarafdarGroup);
	};
	~sitar = Synth.after(~tarafdarGroup, \sitar, [
		\chikari, ~chikariBus,
		\tarafdar, ~tarafdarBus,
		\dry, 1,
		\wet, 0.5,
		\amp, 0.8
	]);
});
)