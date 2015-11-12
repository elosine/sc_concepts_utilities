Spec.add(\helpExp, ControlSpec( 0.01, 1.0, \exp) );

// the array will be converted to a control spec
Spec.add(\helpLin, [0, 1, \lin, 0.011, 0.01]);

// a symbol will be looked up converteuse the existing \freq spec for \helpLin2
Spec.add(\helpLin2, \freq);

// existing spec:
Spec.add(\helpLin, ControlSpec(0.ampdb, 1.ampdb, \db, units: " dB"));


// List of default specs:

\unipolar -> ControlSpec(0, 1),
\bipolar -> ControlSpec(-1, 1, default: 0),

\freq -> ControlSpec(20, 20000, \exp, 0, 440, units: " Hz"),
\lofreq -> ControlSpec(0.1, 100, \exp, 0, 6, units: " Hz"),
\midfreq -> ControlSpec(25, 4200, \exp, 0, 440, units: " Hz"),
\widefreq -> ControlSpec(0.1, 20000, \exp, 0, 440, units: " Hz"),
\phase -> ControlSpec(0, 2pi),
\rq -> ControlSpec(0.001, 2, \exp, 0, 0.707),

\audiobus -> ControlSpec(0, Server.default.options.numAudioBusChannels-1, step: 1),
\controlbus -> ControlSpec(0, Server.default.options.numControlBusChannels-1, step: 1),

\midi -> ControlSpec(0, 127, default: 64),
\midinote -> ControlSpec(0, 127, default: 60),
\midivelocity -> ControlSpec(1, 127, default: 64),

\db -> ControlSpec(0.ampdb, 1.ampdb, \db, units: " dB"),
\amp -> ControlSpec(0, 1, \amp, 0, 0),
\boostcut -> ControlSpec(-20, 20, units: " dB",default: 0),

\pan -> ControlSpec(-1, 1, default: 0),
\detune -> ControlSpec(-20, 20, default: 0, units: " Hz"),
\rate -> ControlSpec(0.125, 8, \exp, 0, 1),
\beats -> ControlSpec(0, 20, units: " Hz"),

\delay -> ControlSpec(0.0001, 1, \exp, 0, 0.3, units: " secs")