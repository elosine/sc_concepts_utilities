a = {|out=2| var sig=PinkNoise.ar()*0.2; Out.ar(0, [sig,sig,sig,sig]) }.play;
s.options.numOutputBusChannels = 8;
s.meter;