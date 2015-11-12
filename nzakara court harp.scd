(
SynthDef(\horp, {|out=0, amp=0.1, dur=0.5, freq=440|
        var sound, env, freqr;

        freqr= (freq).reciprocal;

        //sound = SinOsc.ar(freq); //
        sound= Pluck.ar(WhiteNoise.ar,Impulse.kr(0.1),freqr,freqr,1.5,Rand(0.0,0.2));

        env = EnvGen.ar(Env([0.0,1.0,1.0,0.0],[0.01,dur,0.01]),doneAction:2);

        Out.ar(out, Pan2.ar(amp*env*sound, 0.0) );
}).add

)


//Synth(\horp)


(

var createscale, createpattern;


//create tuning of a stringed instrument, with available inter-string ratios from near a major third to near a perfect fifth
createscale = {
        var n = rrand(4,10); //4 to 10 'strings'
        var availableratios = Array.rand(3,1.25,1.55);
        var ratio = 1.0;
        var freq = rrand(50,400-((n-4)*50));

        Array.fill(n,{ freq = freq*ratio; ratio = availableratios.choose; freq});

};

//creating indexing patterns for accessing the strings
createpattern = {|poly, scalenow|
        var chords;
        var n, n2;
        var stretches;
        var temp;
        var indices;

        n = scalenow.size;

        chords = nil!2;

        chords[0] = [0]++((1..(n-1)).scramble.copyRange(0,poly-1).sort);
        chords[1] = chords[0].copy;

        //find some point in first chord to stretch for a variant, where there is a suitable gap;
        stretches = List[];

        //chords[0][i]
        chords[0].differentiate.do{|val,i|  if((i>0) and: (val>1)) {stretches.add(i)}; };

        if ( (chords[0][poly-1])<(n-1)) {stretches.add(poly)};

        //stretches.postln; //sometimes empty?

        temp= stretches.choose-1; //index safe to shift

        chords[1][temp] =  chords[1][temp]+1; //do shift

        //[\stretches, temp, stretches].postln;
        //chords.postln;

        //create all transpositions (some may be repeats due to transposition equivalence classes)
        //would usually only allow shifts of top element up to n-1
        temp= List[];
        (1..(n-1)).do{|val| temp.add((chords[0]+val)%n); temp.add((chords[1]+val)%n);  };

        //make skeleton
        chords = temp.asSet.asArray;

        //chords.postln;

        n2= chords.size;

        //create melody pattern as set of indices; rarely, melody pattern could itself be based on basic skeleton

        indices = Array.fill(rrand(4,10),{n2.rand;});

        //[\indices,indices].postln;

        temp = Array.fill(n2,{|j|  (indices+j)%n2; }).flatten;

        //[\temp, temp].postln;

        chords.at(temp);

};


{
        var scalenow, patternnow;
        var polyphony;
        var rate, strum, duration, repeats;

        inf.do{

                "retuning horp to new scale and creating plucking patterns".postln;

                scalenow = createscale.value;

                polyphony = rrand(2,scalenow.size-2);

                patternnow = createpattern.value(polyphony, scalenow);

                //patternnow.postln;

                rate= [0.0625,0.125,0.25,1.0].wchoose([0.25,0.4,0.3,0.05]);

                strum= ({exprand(0.01,0.04)-0.01}!2).sort;

                duration = rrand(0.5,1.5);

                repeats = [1,2].wchoose([0.8,0.2]);

                if(rate>0.2) {repeats=1;};

                repeats.do{

                        patternnow.do{|val|

                                //scalenow.at(val).postln;

                                {
                                        scalenow.at(val).do{|freq|

                                                Synth(\horp,[\freq, freq, \dur, duration, \amp, rrand(0.05,0.1)]);

                                                rrand(strum[0],strum[1]).wait;
                                        };
                                }.fork;

                                (rate+rrand(0.01,0.03)).wait;
                        }

                };


                1.0.wait;

        };

}.fork;

) 