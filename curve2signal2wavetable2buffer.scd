( // Wavetable-lookup using an editable Plotter
Server.default.waitForBoot({
        var buffer = Buffer.alloc(Server.default, 512); // allocate Buffer
        var plotter = Plotter.new("Wavetable", 800@300) // create the Plotter
        .value_(0!256).editMode_(true).editFunc_({ arg plotter;
                var signal = plotter.value.as(Signal); // convert Array to Signal
                var wavetable = signal.asWavetable; // convert signal to a wavetable
                buffer.sendCollection(wavetable,0); // send to Buffer
        });
        {Out.ar(0,Osc.ar(buffer,250))}.scope(zoom:1.8);  // wavetable lookup synthesis
})
)

a = p.as(Signal);
b = a.asWavetable;
c = Buffer.alloc(Server.default, 1024);
c.sendCollection(p,0);
c.plot

{|dur=10.0| BufRd.ar(1, c, Phasor.ar(0, (BufFrames.kr(c)/SampleRate.ir)*(1.0/dur), 0, BufFrames.kr(c)), 1).poll}.play

p.size