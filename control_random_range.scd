a = { |lo=0 hi=1 rate=1| TRand.kr( lo, hi, Dust.kr(rate) ).poll; }.play;
a.set(\lo, 1, \hi, 100);
a.set(\lo, 0.1745, \hi, 0.1745);
