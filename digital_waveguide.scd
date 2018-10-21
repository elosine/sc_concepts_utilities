(
SynthDef(\help_dwgbowed, { |out=0, freq=440, amp=0.5,force=1, gate=1,pos=0.07,c1=0.25,c3=31,pan=0|
    var vib = Gendy1.kr(1,1,1,1,0.1, 4,mul:0.003,add:1);
    var son = DWGBowed.ar(freq*vib, amp,force, gate,pos,0.1,c1,c3);
    son = DWGSoundBoard.ar(son);
    son = BPF.ar(son,118,1)+son;
    son = BPF.ar(son,430,1)+son;
    son = BPF.ar(son,490,1)+son;
    son = LPF.ar(son,6000);
    Out.ar(out, Pan2.ar(son * 0.1, pan));
}).add;
)

//Use it.
(

Pbind(
    \instrument, \help_dwgbowed,
    \dur , 0.25,
    \degree, Pseq([1,5,7+3], inf),
    \amp , Pseq([0.9,0.7,0.5],inf),
).play;
)