
{ SendTrig.ar( Trig1.ar(EnvGen.ar(Env.perc()) ), 333, 838 )}.play

OSCdef(\trigtest, {|msg| msg.postln}, "/tr");