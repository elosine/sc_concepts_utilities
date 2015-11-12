//AUDIO BUFFER AS FLOAT ARRAY

s.boot;
//READ SOUNDFILE INTO BUFFER
//b = Buffer.read(s, "/Volumes/Ute/DDMI/Samplistic/heartbeat_L.aif");
b = Buffer.read(s, "/Volumes/Ute/DDMI/Samplistic/breakingwindie.wav");
//b = Buffer.read(s, "/Volumes/Ute/DDMI/Samplistic/snare8.wav");
//CONVERT BUFFER TO FLOAT ARRAY
b.loadToFloatArray( action:{arg array; ~bufArray1 = array; "done".postln;} );

(
//RESAMPLE TO MANAGEABLE SIZE
~sampsize = 800;
~resamp = (~bufArray1.size/~sampsize).round;
~resampArray = Array.newClear(~sampsize+1); //This is the new resampled array
~ct = 0; //A counter for the resampled array
//RESAMPLE THE BUFFER ARRAY AND PUT THE VALUES INTO A NEW ARRAY AS FLOATS
~bufArray1.do{ |it, ix| if( ix%~resamp == 0, {~resampArray[~ct]=it.asFloat; ~ct = ~ct+1} ) };
//ADD OSC ADDRESS
~resampArray = ~resampArray.insert(0, "/sbuf");
//SEND TO PROCESSING
~proc = NetAddr("127.0.0.1", 12321); //Processing address
)

~proc.sendBundle(0.0, ~resampArray);


//make a scrubber that corresponds to play buf
~cbus = Bus.audio(s);
(
SynthDef(\playbufidx,{
	arg buf, spd=0.5, ctlbus, start=0.0, end=1.0;
	var player, indexer, indexnorm;
	indexer = Phasor.ar(trig:0, rate:BufRateScale.kr(buf)*spd, start:start*BufFrames.kr(buf), end:end*BufFrames.kr(buf));
	indexnorm = indexer.linlin(0.0, BufFrames.kr(buf), 0.0, 1.0);
	Out.kr(ctlbus, indexnorm);
	player = BufRd.ar(2, buf, indexer);
	Out.ar(0, player);
}).add;
)

a = Synth(\playbufidx, [\buf, b, \ctlbus, ~cbus]);
a.set(\spd, 1);
a.set(\start, 0.5, \end, 0.8);
a.set(\spd, 0.2);
a.free;

(
var pos = 0.0;
~bufidxRout = Routine.run({
	inf.do{
		~cbus.get( { |val| if(val != nil, {pos=val}) } );
		~proc.sendMsg("/scrubpos", pos);
		(1/61).wait;
	}
});
)
b.get({arg value; a = value; ("after the server responds a is set to:" + a).postln;});

~bufidxRout.stop;
~cbus.get;

 Routine.run({
    inf.do{
      var fftArray= c.getnSynchronous(buffersize2);
      ~proc.sendMsg("/b1scrub", *fftArray);  //sending 1024 values
      (1/61).wait;
    };
  });