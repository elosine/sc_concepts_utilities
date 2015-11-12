s.boot;
b = Buffer.alloc(s, s.sampleRate /*1sec of delay buffer*/);
(
{
    MultiTap.ar(`[0.1, 0.2, 0.3, 0.4], `[0.1, 0.2, 0.4, 0.8],
        Decay.ar(Dust.ar(2), 0.1, PinkNoise.ar), bufnum: b.bufnum)
}.play
)