
a = {Latch.ar(Phasor.ar(0, 1, 0.000001, 1.0), \t_tr.kr(0, 0) ).poll}.play

a.set(\t_tr, 1);