//--supercollider code:
(
var buffersize= 2048;
var buffersize2= buffersize.div(2);
n= NetAddr("127.0.0.1", 47120);
s.waitForBoot {
  c= Bus.control(s, buffersize2);
  b= Buffer.alloc(s, buffersize, 1);
  SynthDef(\avTrk, {
    |in= 0, t_trig= 0, amp= 1, bus|
      var z= Mix(In.ar(in, 2)*amp);
    var chain= FFT(b, z);
    Array.fill(buffersize2, {
      |i|
        var a= Unpack1FFT(chain, buffersize, i);
      var d= Demand.kr(chain>=0, 0, a);
      Out.kr(bus+i, d.min(1));
    }
    );
  }
  ).load;
  s.sync;
  ~trk= Synth(\avTrk, [\in, 0, \amp, 0.3, \bus, c]);
  a= play {
    var a=SinOsc;
    Splay.ar(a.ar(PulseCount.ar(f=InFeedback.ar(0, 2).sum)%999+(60, 63.0005..99)*a.ar(2**f)*2+[3, 4], f>0*f*9)).tanh*MouseX.kr(0, 1)
  };

  Routine.run( {
    inf.do {
      var fftArray= c.getnSynchronous(buffersize2);
      n.sendMsg(\fftArray, *fftArray);  //sending 1024 values
      (1/61).wait;  //a tiny bit faster than framerate
    };
  }
  );
  CmdPeriod.doOnce( {
    b.free;
    c.free
  }
  );
};
)