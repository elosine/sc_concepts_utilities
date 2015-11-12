// Same SynthDef, but adding metadata
// \freq and \amp exist in the global ControlSpec collection -- Spec.specs
// They are converted to real ControlSpecs using .asSpec

d = SynthDef(\mdDemo, { |out, freq, cutoff, volume, gate = 1|
    var    sig = LPF.ar(Saw.ar(freq, volume), cutoff),
        env = EnvGen.kr(Env.adsr, gate, doneAction: 2);
    Out.ar(out, (sig * env) ! 2)
}, metadata: (specs: (cutoff: ControlSpec(100, 1000, \exp, units: "Hz"), volume: \amp))).add;

SynthDescLib.global[\mdDemo].makeWindow;

// Now cutoff has a slider for frequency and volume has amplitude scaling


// Store the SynthDef along with metadata
d.store(mdPlugin: TextArchiveMDPlugin);

"ls %mdDemo.*".format(SynthDef.synthDefDir.escapeChar($ )).unixCmd;

// In addition to .scsyndef, there's also .txarcmeta - "text archive metadata"

// Load a fresh SynthDesc from disk for it
// The SynthDesc.read interface is a bit weird - e will be a dictionary holding the SynthDesc
e = SynthDesc.read(SynthDef.synthDefDir ++ "mdDemo.scsyndef");

// Metadata have been successfully read from disk!
// You could even do the above after recompiling and the MD would be there
e[\mdDemo].metadata

e[\mdDemo].makeWindow;