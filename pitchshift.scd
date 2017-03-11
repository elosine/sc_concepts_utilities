(
// pitch shift input - USE HEADPHONES to prevent feedback.
play({
    PitchShift.ar(
        AudioIn.ar([1,2]),    // stereo audio input
        0.1,             // grain size
        MouseX.kr(0,2),    // mouse x controls pitch shift ratio
        0,                 // pitch dispersion
        0.004            // time dispersion
    )
}))