SynthDef("Distortion_FX", {|outputChannels=0,inputChannels=4, drive=0.3, type=0,outAmp=1|
   var out;
   out = SoundIn.ar(0, 2)*(((drive**2)+0.02)*50);
   out= SelectX.ar(type,[out.softclip,out.distort,out.clip(-1,1),out.fold(-1,1)]);
   out = out * ((outAmp**2)*(1-(drive/2.6)));
   Out.ar(outputChannels,out);
}).add;

a = Synth(\Distortion_FX);
a.set(\type, 3);