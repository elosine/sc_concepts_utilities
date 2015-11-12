b = Buffer.read(s, "/Volumes/Ute/DDMI/Samplistic/snare8.wav");
~cbus = Bus.audio(s);
(
SynthDef(\playbufidx,{
	arg buf, spd=0.5, ctlbus;
	var player, indexer, indexnorm;
	indexer = Phasor.ar(trig:0, rate:BufRateScale.kr(buf)*spd, start:0, end:BufFrames.kr(buf));
	indexnorm = indexer.linlin(0.0, BufFrames.kr(buf), 0.0, 1.0);
	Out.kr(ctlbus, indexnorm);
	player = BufRd.ar(1, buf, indexer);
	Out.ar(0, player);
}).add;
)

a = Synth(\playbufidx, [\buf, b, \ctlbus, ~cbus]);


~bufidxRout = Routine.run({
	inf.do{

	}

});
~cbus.get;

 Routine.run({
    inf.do{
      var fftArray= c.getnSynchronous(buffersize2);
      n.sendMsg(\fftArray, *fftArray);  //sending 1024 values
      (1/61).wait;  //a tiny bit faster than framerate
    };
  });