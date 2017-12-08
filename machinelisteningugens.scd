//Machine Listening Resources: SuperCollider UGens

Built-in UGens: 

Pitch
Amplitude
Loudness
RunningSum //use .rms method

//onset:
Onsets
PV_JensenAndersen
PV_HainsworthFoote

//timbre:
MFCC
ZeroCrossing
SpecFlatness
SpecPcile
SpecCentroid
any filter //(extract energy in a certain channel)


//key detection: 
KeyTrack

//beat tracking:
BeatTrack		//autocorrelation beat tracker, takes longer to react but more stable estimates
BeatTrack2  //crosscorrelation beat tracker, more experimental but quicker reactions


Third Party feature extraction UGens are available in the sc3-plugins project (http://sourceforge.net/projects/sc3-plugins/)

//In PitchDetection
Qitch	//constant Q frequency domain pattern matching frequency detector
Tartini //improved autocorrelation pitch detector, better for low frequencies, better peak picking

//In ConcatUGens:

Concat //feature matching granulation
Concat2 //feature matching granulation with built-in amplitude control


//BBCut2UGens:
AnalyseEvents2 //event detection and extraction
AutoTrack			 //same as BeatTrack which is now in the main sc distribution


//Dan Stowell's MCLD UGens also contain some extra feature extractors such as:
FFTSpread //approximate spectral bandwidth of signal
FFTSlope //shape of falloff of spectral energy
FFTCrest //peakiness of the spectrum in a given band
FFTRumble //energy below the fundamental frequency (assuming one is present)


//BatUGens contains some machine listening facilities including:
Coyote //time domain onset detector
FrameCompare //frame by frame distance measure between two changing spectral inputs


//Some from my website: http://www.sussex.ac.uk/Users/nc81/code.html#SC

//In the SCMIR Library: 
Chromagram //energy at pitch class positions in an n-Tone Equal Temperament
SensoryDissonance //psychoacoustic 'roughness' measure

//Wavelets:
WT_Transient //transient detector

//PolyPitch:
PolyPitch //polyphonic pitch tracker (heavy CPU cost to run)


In the Quarks:
DissonanceLib //Juan Sebasti‡n Lach: A  library of psychoacoustic dissonance curves together with harmonic analysis functions.
//also:
TuningLib //Charles CŽleste Hutchins, Jascha Narveson: can also calculate dissonance functions for a given scale


Freesound2 //Gerard Roma: Client for the Freesound 2 beta API, also allows access to some feature data from the sound files on the sites



Tom Stoll's concatenative synthesis implementation is available on github: 
Corpus-based Processing for SuperCollider: https://github.com/kitefishlabs/cbpsc


