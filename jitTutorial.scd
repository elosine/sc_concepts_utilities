// using a Ref as a proxy
// reference example

// create a new Ref object
y = `(nil);

// you can start to calculate with y, even if its value is not yet given:
z = y + 10; // returns a function

// now the source can be set:
y.value = 34;

// the function z can be evaluated now.
z.value


// the same without a reference does not work:

y = nil; // empty y first

z = y + 10; // this fails.

// also an array does not provide this referentiality:

y = [nil]; // array with nil as element

z = y + 10; // this fails.

// an environment without sufficient defaults has the same problem:

currentEnvironment.postln; // anEnvironment
~x; // access the environment: there is nothing stored: nil
~x = 9; // store something
~x;     // now 9 is stored
~x + 100; // calculate with it

currentEnvironment.postln; // the value is stored in the environment

~y + ~x; // cause an error: ~y is nil.
~y = -90; // set ~y

~y + ~x; // this works.



// using a Function as a proxy
// a function can serve the same purpose

y = nil; // empty y first
z = { y } + 10;    // this does not fail, instead it creates a new function, which
        // does not fail when evaluating it after y is set to 34.

y = 34;
z.value;



// NodeProxy, ProxySpace, Ndef
/*For interactive programming it can be useful to be able to use something before it is there - it makes evaluation order more flexible and allows to postpone decisions to a later moment. Some preparations have to be done usually - like above, a reference has to be created. In other situations this sort of preparation is not enough, for example if one wants to apply mathematical operations on signals of running processes on the server.*/

// boot the server
s.boot;

// two proxies on a server. calculation rate is audio rate, number of channels is 2
y = NodeProxy.audio(s, 2);
z = NodeProxy.audio(s, 2);

// use them in calculation
z.play;
z.source = y.sin * 0.2;


// set its source now.
y.source = { Saw.ar([300, 301], 4*pi) };

// the source can be of various type, one of them would be a number:
y.source = 0.0;

// post the source
y.source;

// end them, free their bus number
y.clear;
z.clear;



// In order to provide a simple way of creating node proxies, a proxy space can be used. So the above reads like this:
p = ProxySpace.push(s.boot); // store proxy space in p so it can be accessed easily.
~z.play;


~z = ~y.sin * 0.2;


~y = { Saw.ar([300, 301], 4*pi) };


// clear the space (all proxies)
p.clear;

// move out of the proxyspace.
p.pop;


// Another, very common way to access node proxies is Ndef (this is the same as the above, just written with Ndef):
Ndef(\z).play;

Ndef(\z, Ndef(\y).sin * 0.2);

Ndef(\y, { Saw.ar([300, 301], 4 * pi) });

Ndef.clear;




// jitlib_basic_concepts_02
// proxy space - basic concepts
// See also: JITLib, jitlib_basic_concepts_01, jitlib_basic_concepts_03
// external structure of the node proxy, referencing in proxyspace and environments.
// This document covers:
// a) normal environment lookup
// b) a proxyspace as an environment
// c) using the proxyspace to change processes on the fly
// d) when are the node proxies initialized?
// e) moving out of the proxy space
// f) using ProxySpace together with other Environments
// a) normal environment lookup

currentEnvironment.postln; // anEnvironment (if not, you haven't left it from last helppage..)

~a; // access the environment: there is nothing stored: nil
~a = 9; // store something
~a;     // now 9 is stored
~a + 100; // calculate with it

currentEnvironment.postln; // the value is stored in the environment

~b + ~a; // cause an error: ~b is nil.
~b = -90; // set ~b

~b + ~a; // now this works.

// note that you can always access environments (or ProxySpaces) from outside as well:

x = currentEnvironment;
x[\a] + x[\b] // equivalent to ~b + ~a

// or, if "know" is true, you can access named things with message-like syntax:
x.know = true;
x.a + x.b;



// b) a proxyspace as an environment
// one can replace the current environment with a special type of environment, a ProxySpace. this environment represents processes that play audio on a server.

p = ProxySpace.new(s);    // create a new environment, store it in variable p for now.
p.push;            // push it, so i becomes the current environment.
currentEnvironment.postln;
currentEnvironment === p; // and they are identical.

~x;        // accessing creates a NodeProxy (uninitialized) automatically.
~x + ~y;    // this works immediately, because the lookup does not return nil,
        // but a placeholder (proxy) instead

p.postln;    // now there are two empty placeholders in the environment.



// c) using the proxyspace to change processes on the fly

// boot the server
s.boot;


// as soon as a sound function (or any compatible input) is assigned to a proxy
// this sound plays on its own private bus (so it is not audible yet.)
(
~x = {
    RLPF.ar(Impulse.ar(4) * 20, [850, 950], 0.2)
}
)

// the proxy has been initialized by its first assignment.
// it plays at audio rate (because we have assigned an audio rate ugen function)
// and it has two channels (because the function has stereo output)

~x.index;    // a nodeproxy owns a private bus, so its signal can be used in diverse ways.
        // what is the proxy bus's index? this posts the index to the postwindow
        // before it was .ir(nil), now it is initialized to .ar(2)

~x.bus // what is the proxy's bus?


~x.play;    // now listen to it. a monitor is created (see Monitor) that plays the signal
        // onto a public bus - by default, this is bus 0, the first audio output bus.
        // This monitoring function is independent of the proxy itself.
        // for further info see: jitlib_basic_concepts_03 (part c)



// the sound function can be changed at any time:
(
~x = {
    RLPF.ar(Impulse.ar([5, 7]) * 5, [1450, 1234], 0.2)
}
)

// You can tune a sound function to your liking very easily
// by replacing it with little (or big) variations:

        // filter freqs higher:
~x = {    RLPF.ar(Impulse.ar([5, 7]) * 5, [1800, 2000], 0.2) }

        // same pulse ratio (5/8), different pulse tempo:
~x = {    RLPF.ar(Impulse.ar([5, 8] * 3.2) * 5, [1800, 2000], 0.2) }

        // different filter:
~x = {    Ringz.ar(Impulse.ar([5, 8] * 3.2), [1800, 2000], 0.05) }

// and if you set the proxy's fadeTime, you can create little
// textures by hand:

~x.fadeTime = 3;
        // different filter freqs every time:
~x = {    Ringz.ar(Impulse.ar([5, 8] * rrand(0.5, 1.5)) * 0.5, ({ exprand(200, 4000) } ! 2), 0.05) }



// here is another proxy:
~y = { Pan2.ar(Dust.ar(20), 0) };

~y.bus; // it has two channels, just as the ~x., but it plays on another (private) bus.

// note that ~y is not audible directly,
// but it can be used like a UGen in any other proxy:
(
~x = {
    RLPF.ar(~y.ar * 8, [1450, 1234], 0.2)
}
)

// when the proxy changes, the result changes dynamically:

~y = { Impulse.ar(MouseX.kr(2, 18, 1)) * [1, 1] };

~y = { PinkNoise.ar(MouseX.kr(0, 0.2) * [1, 1]) };

~y = { Impulse.ar([MouseX.kr(2, 18, 1), MouseY.kr(2, 18, 1)]) };



// stop listening. the proxies run in the background.

~x.stop;

~y.bus; // ~y is playing on a different bus ...
~x.bus; // than ~x.

// we can also listen to ~y directly:
~y.play;

// to remove a proxy source, nil can be used:

~y = nil;

// stop listening
~y.stop;



// d) when are the node proxies initialized?
// By default, bus initialization of a node proxy happens as soon as it is used for the first time. Later inputs are adjusted to this bus, as far as it is possible.
~z2 = { LFNoise0.kr([1, 2, 3, 4]) }; // a four channel control rate proxy
~z2.bus.postln;

~z100 = 0.5;    // a constant value creates a single channel control rate proxy.
~z100.bus.postln;

~z34.ar(3)         // the first access (with a numChannels argument) allocates the bus
~z34.bus.postln;    // a 3 channel audio proxy

// these initializations can be removed by using clear:
~z34.clear;
~z34.bus.postln;

// This initialisation happens whenever the proxy is first used. Later, the proxy can be accessed with other rate/numChannels combinations as needed (rates are converted, numChannels are extended by wrapping, sources with too many channels are wrapped).

~u.play(0, 2);    // initialize 2 audio channels (default). 0 is the output bus number.
        // if the proxy is not initialized, play defaults to 2 channels.
        // here it is explicitly given only to make it more clear.
~u = { PinkNoise.ar(0.2) }; // use only one
~u.numChannels;    // 2 channels
~u.clear; // ... or clear it.

// if evaluated the other way round, only one channel is used:

~u = { PinkNoise.ar(0.2) };    // initialize 1 audio channel
~u.play(0, 2);            // play 2 channels: the 1 channel is expanded into 2.
                // numChannels of .play defaults to the proxy's numChannels.
                // here it is explicitly given, so to expand the channels
~u.numChannels;    // 1 channel
~u.clear;

// NOTE: In sc3.7, you can dynamically adjust the rate and numChannels using the NodeProxy: -mold message, and the proxy can also be set to dynamically adjust to the input (NodeProxy: -reshaping).
~u.mold(1); // reshape to mono.
// It can be useful to explicitly initialize proxies that use variable type inputs:
~b.kr(8); ~c.ar;    // explicit initialisation
p.postln;        // post the whole proxy space



// e) moving out of the proxy space

// play the audio:
~x.play;

~x = { PinkNoise.ar(0.5) };

// p is the proxy space:
p.postln;

// to end all processes in p, use end:
p.end(2) // 2 seconds fade out.

// to remove all bus objects and free them from the bus allocato, use clear:
p.clear;

currentEnvironment.postln;

// restore original environment:

p.pop;

currentEnvironment.postln;

~a + ~b; // the old values are still here.

p === currentEnvironment; // this is not the case anymore.

// remove the content, so the garbage collector can release their memory.
p.clear;

// note that if you use this kind of accessing scheme, the objects are not garbage collected
// until the keys are set to nil. This is a common mistake when using normal environments.

// clear all in the normal environment:

currentEnvironment.clear;




// f) using ProxySpace together with other Environments
// using proxy space as an access scheme for node proxies can get in the way of the normal use of environments as pseudo variables. Here are some ways to cope with this.

//////////////    EnvirDocument is currently unavailable ////////////
//// if you want to keep using the current environment as usual, you can restrict the
//// scope of proxyspace to one document (note: this is mac-only currently)
//
EnvirDocument(p, "proxyspace");    // to test this, check for currentEnvironment here
//                    // and in the envir document.

// you can also access the proxy space and the proxies in it indirectly:
p[\x].play;
p[\x] = { SinOsc.ar(450, 0, 0.1) };

// or: when the proxyspace is pushed, you can use a normal environment indirectly:
p.push;
d = ();
d[\buffer1] = Buffer.alloc(s, 1024);
d.use { ~buffer1.postln; ~zz = 81; }; // for more than one access to the environment, use .use


// to access the inner environment of proxy space directly,
// e.g. to check whether a proxy exists, one can use .envir:

p.envir.postln;
p.envir[\x].postln;    // a proxy with this name exists
p.envir[\nono].postln;    // there is no proxy with this name.

// p[\nono].postln;    // this access would have created a new proxy called \nono.



// jitlib_basic_concepts_03
// proxyspace - basic concepts
// See also: JITLib, jitlib_basic_concepts_02, jitlib_basic_concepts_04
// internal structure of the node proxy, node order and the parameter context
// a) slots
// b) fadeTime
// c) play/stop, send/release, pause/resume, clear
// d) the parameter context
// A NodeProxy has two internal contexts in which the objects are inserted: The group, which is on the server, and the nodeMap, which is a client side parameter context. As the group can contain an order of synths, there is a client side representation, in which the source objects are stored (see Order).

// make new space
p = ProxySpace.push(s.boot);
~z.play; ~y.ar; // explicitly initialize proxies

/*a) NodeProxy slots
One node proxy can hold several objects in an execution order. The index can be any positive integer.*/

// the initial slot (0) is used when assigning directly.
// ~y is still unused, we will add it later.

~z = (~y * pi).sin * 0.1 * { LFSaw.kr(LFNoise1.kr(0.1 ! 3).sum * -18).max(0.2) };

// other slot numbers are accessed by positive integers:

~y[1] = { Saw.ar([400, 401.3], 0.4) };
~y[0] = { Saw.ar([300, 301], 0.4) };

// to remove one of them, nil is used:

~y[0] = nil;

// what is to be found at index 1?
~y.objects[1] // a playing interface
~y.objects[1].source.postcs // the function that was put in.
~y.objects.postcs     // this returns objects in the slots.
~y.source.postcs    // this returns the function in slot 0 only.

// multiple assignment
// the function is assigned to the slots from 1 to 4
~z[1..4] = { SinOsc.ar(exprand(300, 600), 0, LFTri.kr({exprand(1, 3)} ! 3).sum.max(0)) * 0.1 };


// the function is assigned to the slots 1, 2 and 3 (subsequent)
~z[1..] = [ {SinOsc.ar(440) * 0.1 }, { SinOsc.ar(870) * 0.08 }, { SinOsc.ar(770) * 0.04 }];

// if no slot is given, all other slots are emptied
~z = { OnePole.ar(Saw.ar([400, 401.3], 0.3), 0.95) };

~z.end;
~y.end;


// b) fade time
// setting the fadeTime will allow cross fades.
// in case of an audio rate proxy the fade is pseudo-gaussian
// in case of a control rate proxy it is linear.

~z.play;

~z.fadeTime = 5.0; // 5 seconds
~z = { max(SinOsc.ar([300, 301]), Saw.ar([304, 304.3])) * 0.1 };
~z = { max(SinOsc.ar(ExpRand(300, 600)), Saw.ar([304, 304.3])) * 0.1 };

// the fadeTime can be set effectively at any time
~z.fadeTime = 0.2;
~z = { max(SinOsc.ar(ExpRand(3, 160)), Saw.ar([304, 304.3])) * 0.1 };
// NOTE: the fadeTime is also used for the operations xset and xmap. (see below)



// c) play/stop, send/free, pause/resume
// there are a couple of messages a NodeProxy understands that are related to play, stop etc. Here is what they do.
// play/stop
// this pair of messages is related to the monitoring function of the proxy. play starts monitoring, stop ends the monitoring. if the proxy group is playing (this can be tested with .isPlaying), play will not affect the proxie's internal behaviour in any way. Only if it is not playing (e.g because one has freed the group by cmd-period) it starts the synths/objects in the proxy. Stop never affects the internal state of the proxy.
// first hit cmd-period.
~z = { max(SinOsc.ar(ExpRand(3, 160)), Saw.ar([304, 304.3])) * 0.1 };
~z.play;        // monitor the proxy
~z.stop;        // note that now the proxy is still playing, but only in private
~z.isPlaying;        // is the group playing? yes.
~z.monitor.isPlaying;    // is the monitor playing? no.
// You can pass a vol argument to play to adjust the monitor volume without affecting the proxy internal bus volume.
~z.play(vol:0.3);
// while playing you can set the volume also:
~z.vol = 0.8;
/*send / release
this pair of messages controls the synths within the proxy. It does not affect the monitoring (see above). send starts a new synth, release releases the synth. send by default releases the last synth. if the synth frees itself (doneAction 2) spawn can be used.*/
// first hit cmd-period.
~z.play; // monitor. this starts also the synth, if the group wasn't playing.

~z = { SinOsc.ar(ExpRand(20, 660) ! 2) * Saw.ar(ExpRand(200, 960) ! 2) * 0.1 };

~z.release; // release the synth. the current fadeTime is used for fade out

~z.send; // send a new synth. the current fadeTime is used for fade in

~z.send; // send another synth, release the old

~z.release;

~z.stop;

~z.play; // monitor. as the group was still playing, this does _not_ start the proxy.
// in order to free the synths and the group together, free is used:
~z.free; // this does also not affect the monitoring.
~z.play; // monitor. as the group was not playing, this starts the proxy.
// in order to free the synths and the group, stop playback, end is used.
~z.end(3); // end in 3 sec
// in order to rebuild the synthdef on the server, use rebuild. this is of course far less efficient than send, but it can make sense; e.g. the synthdef has random elements. UGens like Rand(300, 400) create new random values on every send, while client-side random functions like exprand(1, 1.3) only get built once; to force new decisions with these, one can use rebuild.
(
~z = {
    Splay.ar(
        SinOsc.ar(Rand(300,400) + ({exprand(1, 1.3)} ! rrand(1, 9)))
        * LFCub.ar({exprand(30, 900)} ! rrand(1, 9))
        * LFSaw.kr({exprand(1.0, 8.0)} ! rrand(1, 9)).max(0)
        * 0.1
    )
};
)

~z.play;
~z.rebuild;
~z.send;    // send just creates a new synth - new freq, all else remains the same
~z.rebuild;    // rebuild the synthdef, re-decide numbers of oscs
~z.end;
// pause / resume
// when paused, a node proxy still stays active, but every synth that is started is paused until the proxy is resumed again.
~z.play;

~z.pause; // pause the synth.

~z = { SinOsc.ar({ExpRand(300, 660)} ! 2) * 0.1 };    // you can add a new function,
                            // which is paused.

~z.resume; // resume playing.
// Note that pause/resume causes clicks with audio rate proxies, which do not happen when pauseing control rate proxies.
// clear
// clear removes all synths, the group, the monitor and releases the bus number.
~z.clear;
~z.bus;        // no bus
~z.isNeutral;    // not initialized.
// note that when other processes use the nodeproxy these are not notified. So clearing has to be done with regard to this.



// d) The parameter context
// what happens to function arguments?
~y.play;
~y = { arg freq=500; SinOsc.ar(freq * [1, 1.1]) * 0.1 };
// now the argument 'freq' is a control in the synth (just like in SynthDef) which you can change by the 'set' message.
~y.set(\freq, 440);

// unlike in synths, this context is kept and applied to every new synth:

~y = { arg freq=500; Formant.ar(50, freq * [1, 1.1], 70) * 0.1 };
// the message xset is a variant of set, to crossfade the change using the current fadeTime:
~y.fadeTime = 3;
~y.xset(\freq, 600);

// the same context is applied to all slots:

~y[2] = { arg freq=500; SinOsc.ar(freq * [1, 1.1]) * LFPulse.kr(Rand(1, 3)) * 0.1 };
~y.xset(\freq, 300);
// the parameter context also can keep bus mappings. a control can be mapped to any control proxy :
~c = { MouseX.kr(300, 800, 1) };
~y.map(\freq, ~c);

// also here the context is kept:

~y = { arg freq=500; Formant.ar(4, freq * [1, 1.1], 70) * 0.1 };
// the message xmap is a variant of map, to crossfade the change using the current fadeTime:
~y.set(\freq, 440);
~y.xmap(\freq, ~c);
// to remove a setting or a mapping, use unmap / unset.
~y.unmap;
// also multichannel controls can be mapped to a multichannel proxy using map :
~c2 = { [MouseX.kr(300, 800, 1), MouseY.kr(300, 800, 1)] };
~y = { arg freq=#[440, 550]; SinOsc.ar(freq) * SinOsc.ar(freq + 3) * 0.05 };
~y.map(\freq, ~c2);
the parameter context can be examined:
~y.nodeMap;

// apart from the parameters explicitly set,
// it contains the bus index and the fadeTime

// for more information, see NodeMap


p.clear(8); // clear the whole proxy space, in 8 secs.
previous: jitlib_basic_concepts_02 next: jitlib_basic_concepts_04




// jitlib_basic_concepts_04
// Timing in NodeProxy
// See also: JITLib, jitlib_basic_concepts_03
// Changes that happen to NodeProxy, most importantly setting its source, are normally done whenever the put method is called (or, in ProxySpace, the assignment operation = ). Sometimes it is desirable to time these changes relative to a clock.
// a) clock
// b) quant and offset
// c) client and server tempo
// d) sample accurate output
// a) clock
// generally, every node proxy can have its own time base, usually a tempo clock. the clock is responsible for the timing of insertion of new functions, per default at the next beat of the clock.
p = ProxySpace.push(s.boot);
~x.play; ~y.play;

// these two synths are started at the time when they are inserted:
~x = { Ringz.ar(Impulse.ar(1), 400, 0.05).dup };
~y = { Ringz.ar(Impulse.ar(1), 600, 0.05).dup };

// adding a common clock:
~x.clock = TempoClock.default; ~x.quant = 1.0;
~y.clock = TempoClock.default; ~y.quant = 1.0;

// now they are in sync
~x = { Ringz.ar(Impulse.ar(1), 400, 0.05).dup };
~y = { Ringz.ar(Impulse.ar(1), 600, 0.05).dup };

// for simplicity, one can provide a clock and a quant for a whole proxy space:

p.clock = TempoClock.default; p.quant = 1.0;
~y = { Ringz.ar(Impulse.ar(1), 800, 0.05).dup };

~z.play;
~z = { Ringz.ar(Impulse.ar(1), [500, 514], 0.8).dup * 0.1};
~z = { Ringz.ar(Impulse.ar(1), exprand(300, 400 ! 2), 1.8).dup * 0.1 };
~z = { Ringz.ar(Impulse.ar(2), exprand(300, 3400 ! 2), 0.08).dup * 0.2 };
~z.end;

p.clear; // clear all.
// sequence of events
// When inserting a new function into the proxy, the synthdef is built, sent to the server who sends back a message when it has completed. Then the proxy waits for the next beat to start the synth. When using node proxies with patterns, the patterns are played using the clock as a scheduler.
// b) quant and offset
// In order to be able to control the offset/quant point of insertion, the 'quant' instance variable can be used, which can be either a number or an array of the form [quant, offset], just like in pattern.play(quant).
~z.play; ~y.play;
~z = { Ringz.ar(Impulse.ar(2), exprand(300, 3400 ! 2), 0.08).dup * 0.2 };
~y.quant = [1, 0.3]; // offset of 0.3, quant of 1.0
~y = { Ringz.ar(Impulse.ar(1), 600, 0.05).dup };
~y.quant = [2, 1/3]; // offset of 1/3, quant of 2.0
~y = { Ringz.ar(Impulse.ar(0.5), 600, 0.05).dup };
// quant and offset scheduling is used for the following operations: play, put, removeAt, setNodeMap, wakeUp, rebuild (and the rebuild operations lag, setRates, bus_). For more information about quantisation in SC, see Quant.
// c) connecting client and server tempo
// a ProxySpace has the method ProxySpace: -makeTempoClock, which creates an instance of TempoBusClock together with a node proxy (~tempo) which it keeps in sync.
p.makeTempoClock(2.0); // create a new tempoclock with 2 beats/sec
~y.play; ~x.play;
~y.quant = 1; // set the quant back to 1 and the offset to 0
~y = { Ringz.ar(Impulse.ar(~tempo.kr), 600, 0.05).dup }; // impulse uses tempo
~x = Pbind(\instrument, \default, \freq, Pseq([300, 400], inf)); // pattern uses tempoclock

p.clock.tempo = 1.0; // set the tempo to 1
p.clock.tempo = 2.2; // set the tempo to 2.2

~x.free;
~y.free;
// d) sample accurate output
// for efficiency, NodeProxy uses a normal Out UGen for writing to its bus. If sample accurate playback is needed (OffsetOut), the ProxySynthDef class variable ProxySynthDef: -sampleAccurate can be set to true. Note that for audio through from external sources, this creates a delay for up to one block (e.g. about 1 ms.)
// example

ProxySynthDef.sampleAccurate = false;

~x.play;

// the grain frees itself
~x = { SinOsc.ar(800) * EnvGen.ar(Env.perc(0.001, 0.03, 0.4), doneAction: 2) };


// jittery tone.
(
r = Routine {
    loop {
        200.do { arg i;
            ~x.spawn;
            (0.005).wait;
        };
        1.wait;
    }
}.play;
)

ProxySynthDef.sampleAccurate = true;

// steady tone, because sample accurate.

~x.rebuild;

r.stop;

p.clear; // remove all.








//  JITLib intro
//	f@fredrikolofsson.com
//	_version:			040330
//	_req.classes:
//-----------------------------------------------------------------------------------------------------------------------------------

//jitlib is a 3rd party library distributed with the standard supercollider server release.  beautifully constructed by julian rohrhuber, it adds live coding facilities to sc lang.


//setup.  this will take us into 'jitlib mode'.  good habit to start your jitlib code documents with this line
p= ProxySpace.push(s);


//to get back to normal sc lang we can use
p.pop;


//notice post window feedback.  jitlib is quite verbose and posts a lot of relevant info
p= ProxySpace.push(s);


//here is an empty slot or 'proxy'
~empty;


//and here is another
~empty2;


//in jitlib mode the tilde ~ + anyName indicates a placeholder for something (a NodeProxy).  in this holder you can put ugen functions, static numbers, pbinds, lfos etc.  jitlib makes it easy to connect these proxies together in different ways, patch and swap code around a lot more flexible than in normal sc lang.  these proxies can also be reassign on the fly with or without crossfades.
//let us put something sounding into our empty proxy
~empty= {BrownNoise.ar(0.1)};


//again notice the post window that now tells us what proxies are present, their number of channels and playback rate.  by default proxies are neutral ir(nil) but as soon as you put something into them they will adapt to that rate.  see [the_lazy_proxy] for more.


//evaluate following line whenever to see a list of things you have defined in your proxyspace.  by now we have one 1 channel audiorate proxy called 'empty' and one neutral called 'empty2'
p;


//monitor sound on/off.  this plays whatever is in the proxy
~empty.play(0);	//channel offset 0
~empty.stop;


//assign something to the 'empty2' proxy
~empty2= {Dust.ar(100, 0.2)};


//play both in different channels
~empty.play(0); ~empty2.play(1);
~empty.stop; ~empty2.stop;


//let us recall and do the above again for overview
p= ProxySpace.push(s);			//clears and creates a new proxyspace.  push it onto the server 's'
~empty= {BrownNoise.ar(0.1)};	//put an ugen function into a proxy
~empty2= {Dust.ar(100, 0.2)};	//put another ugen function into another proxy
~empty.play(0);					//monitor the first proxy
~empty.stop;
~empty2.play(1);					//monitor the second proxy in the right channel
~empty2.stop;


//--------------------------------------------------------------------------------
//now we will try reassigning while playing...
~empty.play(0);


//we replace what is currently in the proxy with a different ugen function.  notice how this takes a tiny bit of time as jitlib, beneath the surface, recreates the synthdef for us, sends it to the server and then swap the synths.  see [jitlib_efficiency] for indepth info.
~empty= {WhiteNoise.ar(0.1)};


//and with the following message we can set crossfade times
~empty.fadeTime= 2;				//in seconds

~empty= {PinkNoise.ar(0.1)};
~empty= {BrownNoise.ar(0.1)};


//and fade out to silence is done like this
~empty.release;


//note that the proxy is still being monitored
~empty= {PinkNoise.ar(0.1)};	//fade in again
~empty.stop;						//now brutally stop monitoring


//--------------------------------------------------------------------------------
//one way of organising your code is to have a main audio out and then mix proxies to that output.  this output, which in turn is also a proxy, we explicitly create and initialise here with the .ar message
p= ProxySpace.push(s);		//first let us start anew
~out.ar(2);						//create a 2 channel main audio out proxy (shortcut for NodeProxy.audio(s, 2) )
~out.play;						//and start monitoring


//we set fadeTime for smoother sounds
~out.fadeTime= 2.5;


//put a beating stereo sine ugenFunc into a proxy
~sineLow= {FSinOsc.ar([240, 242], 0, 0.2)};


//and patch the low sines into out to hear it
~out= ~sineLow;


//another proxy
~sineMed= {FSinOsc.ar([400, 404], 0, 0.1)};


//mix them together
~out= ~sineLow+~sineMed;


// a third sine proxy
~sineHigh= {FSinOsc.ar([600, 606], 0, 0.04)};


//and mix them all together
~out= ~sineLow+~sineMed+~sineHigh;


//reassign any of the proxies while playing
~sineMed= {FSinOsc.ar([480, 484], 0, 0.1)};
~sineMed= {FSinOsc.ar([500, 505], 0, 0.1)};
~sineMed= {FSinOsc.ar([400, 404], 0, 0.1)};


//notice that these changes occur instantly while the mixing we just did was done with crossfades.  we need to explicitly set fadeTime for the proxy too
~sineMed.fadeTime= 3;
~sineMed= {FSinOsc.ar([580, 585], 0, 0.1)};
~sineMed= {FSinOsc.ar([400, 404], 0, 0.1)};


//and stop
~out.release;
~out.stop;


//if we investigate current proxyspace we'll see that there are 4 proxies - all stereo audiorate.
p;


//--------------------------------------------------------------------------------
//now ugen functions with arguments
p= ProxySpace.push(s);			//clear and create new
~out.ar(2);							//new main out proxy
~out.play;							//start monitoring


//proxy containing an ugen function with 2 arguments
~sine= {arg freq= 400, amp= 0.1; SinOsc.ar(freq, 0, amp)};


//patch to main output
~out= ~sine;


//change parameters with .set
~sine.set(\freq, 600);
~sine.set(\freq, 800);
~sine.set(\amp, 0.05);


//stop for a little while
~out.stop;


//recreate the proxy - overwrites old - and play again
~sine= {arg freq= 400, amp= 0.1; SinOsc.ar(freq, 0, amp)};
~out= ~sine;
~out.play;


//notice how jitlib remember settings!  get back to defaults with
~sine.unset(\freq);
~sine.unset(\amp);


//also crossfades between settings is possible.  check that you set fadeTime for the right proxy
~sine.fadeTime= 4;
~sine.xset(\freq, 700);					//crossfade
~sine.set(\freq, rrand(400, 900));		//jump to random freq
~sine.xset(\freq, 700);					//crossfade back
~sine.xset(\freq, 500);					//crossfade
~sine.unset(\freq);							//crossfade back to default
~out.stop;


//--------------------------------------------------------------------------------
//create and map controlrate proxies (lfo).  following line puts a controller ugen into a proxy
~freak= {LFNoise2.kr(2, 500, 500)};


//post window tells us that 'freak' is a one channel proxy running in controlrate just as expected
p;


//start monitoring our old sine
~out.play;


//and now this will map (patch) the output of 'freak' to our sine proxy's freq parameter
~sine.map(\freq, ~freak);


//as .unset, .unmap removes the patching
~sine.unmap(\freq);


//of course we can exchange what is inside 'freak' with something else
~freak= {LFNoise0.kr(6, 300, 400)};
~sine.map(\freq, ~freak);


//and yet something different
~freak= {LFNoise0.kr(13, 100, 600).round(66.67)};


//a very cool thing is that controllers like these also can crossfade.  time is set with .fadeTime
~sine.fadeTime= 4;


//so first we create another controller proxy
~freak2= {LFPar.kr(20, 0, 240, 300)};


//and then the crossfade is done like this
~sine.xmap(\freq, ~freak2);
~sine.xmap(\freq, ~freak);
~sine.unmap(\freq);
~sine.release;
~out.stop;


//--------------------------------------------------------------------------------
//quantising
p= ProxySpace.push(s);			//clear and create new
~out.ar(2);							//new main out proxy
~out.play;							//start monitoring


//the .clock message to the current proxyspace will force all proxies to start in sync to a clock
p.clock= TempoClock(1.0);		//60bpm


//this will play a click once a second
~imp1= {Formlet.ar(Impulse.ar(1), 2000, 0.1, 0.2)};
~out= ~imp1;


//run this for another click twice a second
~imp2= {Formlet.ar(Impulse.ar(2), 8000, 0, 0.2)};
~out2.ar(2);
~out2.play;
~out2= ~imp2;


//and finally this three times faster than the first click but still in sync
~imp3= {Formlet.ar(Impulse.ar(3), 12000, 0.3, 0)};
~out3.ar(2);
~out3.play;
~out3= ~imp3;


//stop them all (could also be done with p.free)
~out.stop; ~out2.stop; ~out3.stop;


//--------------------------------------------------------------------------------
//one can also decide which proxies to quantise.  following will mix two synced impulses in right channel and one non-quantised in the left channel
p= ProxySpace.push(s);
c= TempoClock(1.0);
~imp1.clock= c;							//same clock for ~imp1
~imp2.clock= c;							//as for ~imp2.  ~imp3 gets no clock
~imp1= {Formlet.ar(Impulse.ar(1), 2000, 0.1, 0.2)};
~imp2= {Formlet.ar(Impulse.ar(2), 8000, 0, 0.2)};
~imp3= {Formlet.ar(Impulse.ar(1), 600, 0.4, 0)};
~outLeft= ~imp1+~imp2;				//mix the two synced proxies in left channel
~outLeft.play(0);						//start monitoring left channel
~outRight= ~imp3;						//and play the non-synced in right
~outRight.play(1);						//start monitoring right channel


//if we now reassign one of the synced impulses it'll still play in time.  run this a few times
~imp1= {Formlet.ar(Impulse.ar(1), 1000.rrand(3000), 0.1, 0.2)};


//while the right channel impulse won't play in time with the left channel ones
~imp3= {Formlet.ar(Impulse.ar(1), 500.rrand(700), 0.4, 0)};


//stop both channels
~outLeft.stop; ~outRight.stop;


//--------------------------------------------------------------------------------
//using pbinds
SynthDescLib.read;					//init.  a must when working with patterns
p= ProxySpace.push(s);


//let us keep it all in sync
p.clock= TempoClock(1);


//this will start playing right away on a silent bus using the default pbind instrument
~pat= Pbind(\midinote, Pseq([67, 71, 74], inf), \dur, Prand([1/2, 1/4, 1/8], inf));
~pat2= Pbind(\midinote, Pseq([55, 59, 62], inf), \dur, Prand([1, 1/2], inf));
~pat3= Pbind(\midinote, Pseq([43, 47, 48, 50], inf), \dur, Pseq([2], inf));


//to listen we start monitoring
~pat.play;
~pat2.play;
~pat3.play;


//release one pbind and reassign
~pat.release;
~pat= Pbind(\midinote, Pseq([67, 72, 74], inf), \dur, Prand([1/2, 1/4, 1/8], inf));


//release all in turn
~pat.release;
~pat3.release;
~pat2.release;


//and stop monitoring
~pat.stop; ~pat2.stop; ~pat3.stop;

//see [NodeProxy] helpfile under 'using patterns - event streams' and [ProxySpace] for additional examples of pbinds with embedded proxies


//--------------------------------------------------------------------------------
//recording
p= ProxySpace.push(s);			//clear and create new
~out.ar(2);							//new main out proxy
~out.play;							//start monitoring


//start something sounding
~out= {RLPF.ar(WhiteNoise.ar(1), FSinOsc.kr([2, 3], 0, 500, 600))};


//then we create a RecNodeProxy
r= p.record(\out, "filteredNoiseTest.aif");
r.unpause;							//start recording
r.pause;								//pause recording
r.close;								//stop recording
~out.stop;


//--------------------------------------------------------------------------------
//using synthdefs with jitlib
p= ProxySpace.push(s);			//clear and create new
~out.ar(2);							//new main out proxy
~out.play;							//start monitoring


//send a synthdef to the server as normal
(
SynthDef('jitlibtest', {arg out= 0, freq= 400;
	var z;
	z= Formant.ar(freq.dup, LFSaw.kr(1, 0, 100, 200), 0.3, 0.1);
	Out.ar(out, z);
}).send(s);
)


//and access it later in jitlib like this.  just give the name of the synthdef as a symbol
~src = 'jitlibtest';
~out = ~src;
~src.set(\freq, 300);
~src.set(\freq, 200);
~out.stop;


//--------------------------------------------------------------------------------
//effects
p= ProxySpace.push(s);			//clear and create new
~out.ar(2);							//new main out proxy
~out.play;							//start monitoring


//create a mouseX controlled pulse.  stable on the right - more chaotic on the left side
~src= {BrownNoise.ar(Decay.kr(Impulse.kr(FSinOsc.kr(MouseX.kr(0.54, 2.5), 0, 2, 2.5)), 0.7, 0.3))};


//patch to main out
~out= ~src;


//create a mouseY controlled effect.  the src proxy is patched into the inlet of the filter with ~src.ar
~efx= {RLPF.ar(~src.ar, MouseY.kr(200, 8000, 'exponential'))};


//repatch effect to main out
~out= ~efx;


//get rid of effect and stop
~out= ~src;
~out.stop;


//or we could create the effect first just to show with which ease execution order is dealt with
p= ProxySpace.push(s);			//clear and create new
~out.ar(2);							//new main out proxy
~out.play;							//start monitoring


//sets up an effect with two not-yet-defined inputs.  note in post window that jitlib will create reasonable proxies for us right away
~efx= {Resonz.ar(~src.ar, 4000, 0.1, 0.5)};


//patch effect to main out.  i.e. play it but nothing will be heard as no sound comes into the effect
~out= ~efx;


//last create the source sound
~src= {GrayNoise.ar(Decay.kr(Impulse.kr([MouseX.kr(2, 14), MouseY.kr(2, 14)]), 0.4))};


//stop monitoring
~out.stop;


//--------------------------------------------------------------------------------
//careful though.  execution order can't be ignored altogether.  below is a badly designed example with the ampTracker only reading from one channel
p= ProxySpace.push(s);			//clear and create new
~out.ar(2);							//new main out proxy
~out.play;							//start monitoring


//set up the effect.  here's the problem.  ampTracker controller proxy is supposed to be 2 channels
~efx= {Resonz.ar(~src.ar, ~ampTracker.kr, 0.1, 0.5)};


//patch effect to main out
~out= ~efx;


//create the controller.  notice jitlib warning in post window.  ~src.ar defaults to 2 channels
~ampTracker= {Amplitude.kr(~src.ar, mul:5000)};


//last create the source sound.  this won't work as expected only tracking amplitude on 1 channel
~src= {GrayNoise.ar(Decay.kr(Impulse.kr([MouseX.kr(2, 14), MouseY.kr(2, 14)].round(2)), 0.4))};


//to fix it we need to make sure the ampTracker proxy has 2 channels
~out.stop;
p= ProxySpace.push(s);
~out.ar(2);
~out.play;


//force ~ampTracker into 2 channels
~efx= {Resonz.ar(~src.ar, ~ampTracker.kr(2), 0.1, 0.5)};
~out= ~efx;
~ampTracker= {Amplitude.kr(~src.ar, mul:5000)};
~src= {GrayNoise.ar(Decay.kr(Impulse.kr([MouseX.kr(2, 14), MouseY.kr(2, 14)].round(2)), 0.4))};


//examine post window and read more in [the_lazy_proxy]
p;


//stop
~out.stop;


//--------------------------------------------------------------------------------
//synthdefs as effects
p= ProxySpace.push(s);			//clear and create new
~out.ar(2);
~out.play;


//first send a synthdef effect to the server
(
SynthDef('lfoClip', {arg out, in, rate= 4;
	var z;
	z= InFeedback.ar(in, 2)*LFNoise0.kr(rate).min(0);
	Out.ar(out, z);
}).send(s);
)


//the sound that we want to run through the effect
~src= {SinOsc.ar([300, 303], 0, 0.4)};


//put the effect into a proxy
~efx= 'lfoClip';


//patch source sound to main out to hear it
~out= ~src;


//patch effect - still silent
~out= ~efx;


//but now change the effect's out parameter to match the sound's bus number
~efx.set(\out, 0, \in, ~src.bus.index);
~efx.set(\rate, 16);


//to mute the effect either route it to a silent bus or use ~efx.free;
~efx.set(\out, 99);


//and patch source sound back
~out= ~src;


//stop monitoring and clear the whole proxyspace
~out.stop;
p.free;


//--------------------------------------------------------------------------------
//more advanced example muting effects
p= ProxySpace.push(s);			//clear and create new
~out.ar(2);							//new main out proxy
~out.play;							//start monitoring


//creates 4 effects
~dry= {arg mute= 1; ~input.ar*(1-mute)};
~ampmod= {arg mute= 1; ~input.ar*LFSaw.kr(LFNoise0.kr(5).round(0.5), 0, (1-mute)*2).abs};
~dist= {arg mute= 1; (~input.ar*2).clip2(0.4)*(1-mute)};
~dist2= {arg mute= 1; (~input.ar*8).wrap2(0.1)*(1-mute)};


//mix them on the same output
~out= ~ampmod+~dry+~dist+~dist2;


//and create a source sound
~src= {PMOsc.ar(200, [40, 45], LFSaw.kr(0.5, [0, pi], 0.5, 0.75), 0, 0.3)};


//set up a patchbay
~link.ar(2);
~link= {arg in, out= 128; Out.ar(out, InFeedback.ar(in, 2))};
~link.set(\in, ~src.index, \out, ~input.index);


//now mute and unmute
~dry.set(\mute, 0);
~dry.set(\mute, 1);
~ampmod.set(\mute, 0);
~ampmod.set(\mute, 1);
~dist.set(\mute, 0);
~dist.set(\mute, 1);
~dist2.set(\mute, 0);
~dist2.set(\mute, 1);


//--------------------------------------------------------------------------------
//this tutorial is just scratching a little on the surface of jitlib.  find out more in julian's extensive helpfiles [JITLib]






proxy space examples




preparation of the environment

(
s = Server.local;
s.boot;
p = ProxySpace.push(s);
)

playing and monitoring

// play some output to the hardware busses, this could be any audio rate key.
~out.play;

~out = { SinOsc.ar([400, 408]*0.8, 0, 0.2) };


// replacing the node. the crossfade envelope is created internally.
~out = { SinOsc.ar([443, 600-Rand(0,200)], 0, 0.2) };
~out = { Resonz.ar(Saw.ar(40+[0,0.2], 1), [1200, 1600], 0.1) + SinOsc.ar(60*[1,1.1],0,0.2) };
~out = { Pan2.ar(PinkNoise.ar(0.1), LFClipNoise.kr(2)) };

setting the node controls

~out = { arg rate=2; Pan2.ar(PinkNoise.ar(0.1), LFClipNoise.kr(rate)) };
~out.set(\rate, 30);
~out = { arg rate=2; Pan2.ar(Dust.ar(2000, 0.2), LFClipNoise.kr(rate)) };
~out.set(\rate, 2);

referencing between proxies

~lfo = { LFNoise2.kr(30, 300, 500) };
~out = { SinOsc.ar(~lfo.kr, 0, 0.15)  };
~out = { SinOsc.ar(~lfo.kr * [1, 1.2], 0, 0.1) * Pulse.ar(~lfo.kr * [0.1, 0.125], 0.5) };
~lfo = { LFNoise1.kr(30, 40) + SinOsc.kr(0.1, 0, 200, 500) };
~out = { SinOsc.ar(~lfo.kr * [1, 1.2], 0, 0.1)  };
~lfo = 410;

math

// unary operators
~lfo2 = { SinOsc.kr(0.5, 0, 600, 100)  };
~lfo = ~lfo2.abs;
~lfo2 = { SinOsc.kr(1.3, 0, 600, 100)  };


// binary operators
~lfo3 = { LFTri.kr(0.5, 0, 80, 300) };
~lfo = ~lfo2 + ~lfo3;
~lfo = ~lfo3;
~lfo = (~lfo3 / 50).sin * 200 + 500 * { LFTri.kr(~lfo.kr * 0.0015, 0, 0.1 * ~lfo3.kr / 90, 1) };
~lfo3 = { Mix(~lfo2.kr * [1, 1.2]) };

currentEnvironment.free; // free all node proxies
~out.stop; // free the playback synth.


waking up a network of proxies

// hit cmd-. to stop all nodes
// start again
~out.play;

feeding back (one buffer size delay)

~out = { SinOsc.ar([220, 330], ~out.ar(2).reverse * LFNoise2.kr(0.5, 4*pi), 0.4) };

// there is no immediacy: hear the buffer size cycle
~out = { Impulse.ar(1 ! 2) + (~out.ar(2) * 0.99) };



// supercollider 'differential equations'

~out = { SinOsc.ar(Slope.ar(~out.ar) * MouseX.kr(1000, 18000, 1)) * 0.1 + SinOsc.ar(100, 0, 0.1) };

(
~out = { var z, zz;
	z = Slope.ar(~out.ar);
	zz = Slope.ar(z);
	SinOsc.ar(Rand(300,410), z) *
	SinOsc.ar(zz * 410)
	* 0.1 + Decay2.ar(Pan2.ar(Dust.ar(600), MouseX.kr(-1,1)), 0.01, 0.05);
}
)


multiple control

(
~out = { arg freqOffest;
	var ctl;
	ctl = Control.names(\array).kr(Array.rand(8, 400, 1000));
	Pan2.ar(Mix(SinOsc.ar(ctl + freqOffest, 0, 0.1 / 8)), LFNoise0.kr(2))
};
)

~out.setn(\array, Array.exprand(8, 400, 2000));
~out.set(\freqOffest, rrand(300,200));
~out.map(\freqOffest, ~lfo);

// a simpler short form for this is:
(
~out = { arg freqOffest=0, array = #[ 997, 777, 506, 553, 731, 891, 925, 580 ];
	Pan2.ar(Mix(SinOsc.ar(array + freqOffest, 0, 0.1 / 8)), LFNoise0.kr(2))
};
)



mixing


~out1 = { SinOsc.ar(600, 0, 0.1) };
~out2 = { SinOsc.ar(500, 0, 0.1) };
~out3 = { SinOsc.ar(400, 0, 0.1) };
~out = ~out2 + ~out1 + ~out3;

~out = ~out1 + ~out2;
~out = ~out1;

// another way is:
~out = { SinOsc.ar(600, 0, 0.1) };
~out.add({ SinOsc.ar(500, 0, 0.1) });
~out.add({ SinOsc.ar(400, 0, 0.1) });

// or with direct access:
~out[1] = { SinOsc.ar(500 * 1.2, 0, 0.1) };
~out[2] = { SinOsc.ar(400 * 1.2, 0, 0.1) };




restoring / erasing

~out.free; // this frees the group, not the play synth x
~out.send; // resends all synths
~out.free;
~out.send(nil, 1); // this sends at index 1 only
~out.send;

// removing:
~out.removeLast;
~out.removeAt(0);

// cleaning up, freeing the bus:
~out.clear; // this neutralizes the proxy, and frees its bus


for more on the proxy slots see: jitlib_basic_concepts_03



garbage collecting

// often there are proxies playing that are not used anymore - this is good,
// because they might be used again at any time.
// this shows how to free unused proxies, such as ~out1, ~out2.

~out.play;
~out = { Pan2.ar(SinOsc.ar(~lfo.kr, 0, 0.2), sin(~lfo.kr / 10)) }; // ~lfo is kept, as its parents.
~lfo = { LFNoise2.kr(3, 160, 400) };

p.keysValuesDo { arg key, proxy; [key, proxy.isPlaying].postln };
p.reduce; // all monitoring proxies (in this case ~out) are kept. equivalent: p.reduce(to: [~out]);
p.keysValuesDo { arg key, proxy; [key, proxy.isPlaying].postln };

// to remove everything else:
p.postln;
p.clean; // all monitoring proxies (in this case ~out) are kept.
p.postln;

// after ~out is stopped, it is removed, too:
~out.stop; // stop monitor
p.clean;
p.postln; // empty space.


execution order


// you can .play .kr or .ar also a name that is not yet used.
// the rate is guessed as far as possible. on this topic see also: [the_lazy_proxy]

~myOut.play; // play some key (audio rate is assumed)

// the rate is determined from the first access:
// like this ~lfo becomes control rate

~myOut = { SinOsc.ar(~freq.kr * 2, 0, 0.1) };
~freq = 900;
~freq = { SinOsc.kr(115, 0, 70, 220) }

~myOut = { SinOsc.ar(~otherFreq.ar * 2, 0, 0.1) };
~otherFreq = { SinOsc.ar(115, 0, 70, 220) };

currentEnvironment.clear; // clear every  proxy in this environment and remove them. (same: p.clear)




setting the xfade time

~out.play;

~out.fadeTime = 4;
~out = { SinOsc.ar(Rand(800, 300.0)*[1,1.1], 0, 0.1) };
~out = { SinOsc.ar(Rand(800, 300.0)*[1,1.1], 0, 0.1) };
~out.fadeTime = 0.01;
~out = { SinOsc.ar(Rand(800, 300.0)*[1,1.1], 0, 0.1) };
~out = { SinOsc.ar(Rand(800, 300.0)*[1,1.1], 0, 0.1) };

~out.free(3);  // release the synths and the group with a given fadeTime without changing proxy time
~out.stop;	// stop monitor



setting and mapping arguments


~out.play;

~out = { arg freq=500, ffreq=120; SinOsc.ar(freq*[1,1.1], SinOsc.ar(ffreq, 0, pi), 0.2) };
~out.set(\freq, 400+100.rand2);
~out.set(\freq, 400+100.rand2);
~out.set(\ffreq, 30+20.rand2);
~out.unset(\freq, \ffreq);  // remove the setting
~out.set(\ffreq, 30+10.rand2, \freq, 500 + 200.rand2);


// argument settings and mappings are applied to every new function
~out = { arg freq=100, ffreq=20; SinOsc.ar(freq, SinOsc.ar(SinOsc.ar(ffreq)*ffreq, 0, pi), 0.2) };

// mapping to other proxies
~lfo = { SinOsc.kr(0.3, 0, 80, 100) };
~out.map(\ffreq, ~lfo);

~out = { arg freq=300, ffreq=20; Pulse.ar(freq*[1,1.1]+ SinOsc.ar(ffreq, 0, freq), 0.3, 0.1) };
~out = { arg freq=300, ffreq=20; BPF.ar(LFSaw.ar(ffreq*[1,1.1], 0, 1), freq, 0.2) };

~lfo = { FSinOsc.kr(0.3, 0, 30, 200) + FSinOsc.kr(10, 0, 10) };
~out = { arg freq=300, ffreq=20; SinOsc.ar(freq*[1,1.1], SinOsc.ar(ffreq, 0, pi), 0.1) };


// crossfaded setting and mapping: fadeTime is used
~out.fadeTime = 2;
~out.xset(\freq, 9000);
~out.xset(\freq, rrand(400, 700));

~lfo = { FSinOsc.kr(0.1, 0, 30, 100) };
~lfo2 = { LFClipNoise.kr(3, 100, 200) };
~lfo3 = StreamKrDur(Pseq([Prand([530, 600],1), 700, 400, 800, 500].scramble, inf) / 3, 0.2);

~out.xmap(\ffreq, ~lfo2);
~out.xmap(\ffreq, ~lfo);
~out.xmap(\ffreq, ~lfo3);

// argument rates: just like a synthdef has input 'rates' (like \ir or \tr), a nodeproxy control
// can be given a rate. this rate is used for each function passed into the proxy.

// trigger inputs
~out = { arg trig, dt=1; Decay2.kr(trig, 0.01, dt) * Mix(SinOsc.ar(7000*[1.2, 1.3, 0.2])) }
~out.setRates(\trig, \tr);

// set the group, so the node proxy does not store the new value
~out.group.set(\trig, 0.1, \dt, 0.1);
~out.group.set(\trig, 0.4, \dt, 0.31);
~out.group.set(\trig, 0.13, \dt, 2);

// lagging controls:
~out.lag(\xfreq, 1); // equivalent to ~out.setRates(\xfreq, 1);
(
~out = { arg trig, dt=1, xfreq=700;
	Decay2.kr(trig, 0.01, dt) * Mix(SinOsc.ar(xfreq*[1.2, 1.3, 0.2]))
};
)
~out.group.set(\trig, 0.1, \dt, 1, \xfreq, rrand(2000,9000));
~out.group.set(\trig, 0.1, \dt, 0.5, \xfreq, rrand(2000,9000));
~out.group.set(\trig, 0.1, \dt, 1, \xfreq, rrand(2000,9000));

// changing the lag, the synth is reconstructed with the new lag:

~out.lag(\xfreq, 0.01);
~out.group.set(\trig, 0.1, \dt, 1, \xfreq, rrand(2000,9000));
~out.group.set(\trig, 0.1, \dt, 1, \xfreq, rrand(2000,9000));
~out.group.set(\trig, 0.1, \dt, 1, \xfreq, rrand(2000,9000));

// removing the trig rate:
~out.setRates(\trig, nil);

// note that the same works with the i_ and the t_ arguments, just as it does in SynthDef






___________________________________________________________________
other possible inputs


using a synthdef as input


// for a more systematic overview see: [jitlib_fading]

// you have the responsibility for the right number of channels and output rate
// you have to supply an 'out' argument so it can be mapped to the right channel.

~out.play;
~out = SynthDef("w", { arg out=0; Out.ar(out,SinOsc.ar([Rand(430, 600), 600], 0, 0.2)) });
~out = SynthDef("w", { arg out=0; Out.ar(out,SinOsc.ar([Rand(430, 600), 500], 0, 0.2)) });


// if you supply a gate it fades in and out. evaluate this several times
(
~out = SynthDef("w", { arg out=0, gate=1.0;
	Out.ar(out,
		SinOsc.ar([Rand(430, 800), Rand(430, 800)], 0, 0.2) * EnvGen.kr(Env.asr(1,1,1), gate, doneAction:2)
	)
	});
)

// once the SynthDef is sent, it can be assigned by name.
// using this method, a gate argument should be
// provided that releases the synth. (doneAction:2)
// this is very efficient, as the def is on the server already.

// if the synth def is in the synthdesc lib (.store) its gate is detected.

(
SynthDef("staub", { arg out, gate=1;
	Out.ar(out, Ringz.ar(Dust.ar(15), Rand(1, 3) * 3000*[1,1], 0.001) * EnvGen.kr(Env.asr, gate, doneAction:2))
}).send(s);
)

~out = \staub;



// if you supply an envelope that frees itself, no bundle is sent to free it
(
~out = SynthDef("w", { arg out, lfo, f0=430;
	Out.ar(out,
		SinOsc.ar([Rand(f0, 800), Rand(f0, 800)]+lfo, 0, 0.2) * EnvGen.kr(Env.perc(0.01, 0.03), doneAction:2)
	)
	});
)

~out.spawn;
~out.spawn([\f0, 5000]);
fork { 5.do { ~out.spawn([\f0, 5000 + 1000.0.rand]); 0.1.wait; } }


// when the synth description in the SynthDescLib is found for the symbol,
// the proxy can determine whether to release or to free the synth.
// so if there is no 'gate' arg provided and the def has a desc, the synth is
// freed and not released.

(
SynthDef("staub", { arg out;
	Out.ar(out, Ringz.ar(WhiteNoise.ar(0.01), 1000*[1,1], 0.001))
}).store; // store the synth def so it is added to the SynthDescLib
)


~out = \staub;
~out = \staub; // watching the synth count shows that the old synth is freed.
~out = 0;  	// now out plays continuous stream of zero.
~out = nil;	// removes object and stops it.

using patterns

// example

(
SynthDef("who", { arg amp=0.1, freq=440, detune=0, gate=1, out=0, ffreq=800;
	var env;
	env = Env.asr(0.01, amp, 0.5);
	Out.ar(out, Pan2.ar(
		Formant.ar(freq + detune, ffreq, 30, EnvGen.kr(env, gate, doneAction:2)), Rand(-1.0, 1.0))
	)
}).store;

)

~out.play;


~out = Pbind(\instrument, \who, \freq, [600, 601], \ffreq, 800, \legato, 0.02);




// embed a control node proxy into an event pattern:
// this does not work for indirect assignment as \degree, \midinote, etc.,
// because there is calculations in the event! if needed, these can be done in the SynthDef.

~lfo = { SinOsc.kr(2, 0, 400, 700) };
~out = Pbind(\instrument, \who, \freq, 500, \ffreq, ~lfo, \legato, 0.02);

~lfo = { SinOsc.kr(SinOsc.kr(0.2, Rand(0,pi), 10, 10), 0, 400, 700) };

~lfo = { LFNoise1.kr(5, 1300, 1500) };
~lfo = { MouseX.kr(100, 5500, 1) };

(
~out = Pbind(
			\instrument, \who,
			\freq, Pseq([500, 380, 300],inf),
			\legato, 0.1,
			\ffreq, Pseq([~lfo, 100, ~lfo, 100, 300, 550], inf), // use it in a pattern
			\dur, Pseq([1, 0.5, 0.75, 0.125]*0.4, inf)
		);
)

// note that when you use a proxy within a non-event pattern it gets embedded as an object,
// so this functionality is still standard

// works only with control rate proxies. multichannel control rate proxies cause
// multichannel expansion of the events:

~lfoStereo = { LFNoise1.kr([1, 1], 1300, 1500) }; // 2 channel control rate proxy
~out = Pbind(\instrument, \who, \freq, 1500, \detune, ~lfoStereo, \legato, 0.02);
~lfoStereo = { [MouseX.kr(100, 15500, 1), SinOsc.kr(SinOsc.kr(0.2, 0, 10, 10), 0, 400, 700)] }

// btw: setting the clock will cause the pattern to sync:
p.clock = TempoClock.default;
p.clock.tempo = 2.0;
p.clock.tempo = 1.0


// patterns also crossfade, if an \amp arg is defined in the synthdef:
// (evaluate a couple of times)
~out.fadeTime = 3.0;
(
~out = Pbind(
			\instrument, \who,
			\freq, Pshuf([500, 380, 200, 510, 390, 300, 300],inf) * rrand(1.0, 2.0),
			\legato, 0.1,
			\ffreq, Pshuf([~lfo, 100, ~lfo, 100, 300, 550], inf),
			\dur, 0.125 * [1, 2, 3, 2/3].choose
		);
)


using instruments and players

// pause and resume do not work yet.


// store an instrument
(
Instr(\test,
		{ arg dens=520, ffreq=7000; Ringz.ar(Dust.ar(dens, [1,1]*0.1), ffreq, 0.02) }
		);
)

~out = Patch(\test, [10, rrand(5000, 8000)]);
~out.fadeTime = 3;


(
~out = InstrSpawner({ arg freq=1900,env,pan;
	Pan2.ar(SinOsc.ar(freq, 0.5pi, 0.3) * EnvGen.kr(env, doneAction: 2), pan)
},[
	Prand([1500, 700, 800, 3000] + 170.rand2, inf),
	Env.perc(0.002,0.01),
	Prand([-1,1],inf)
],0.125)
)

~out.clear;



// does not work (yet).
//~out.set(\dens, 120);
//~out.xset(\dens, 1030);
//~out.unmap(\ffreq);
//~out.set(\ffreq, 500);


___________________________________________________________________
client side routines

spawning

~out.play;
~out.awake = false; // allow sound object assignment without immediate sending

// putting an synthdef into the node proxy without playing it right away
// the synthdef has an envelope that frees by itself.
(
~out = SynthDef("a", { arg out=0, freq=800, pmf=1.0, pan;
		var env, u;
		env = EnvGen.kr(Env.perc(0.001, 0.04, 0.4),doneAction:2); // envelope
		u = SinOsc.ar(freq * Rand(0.9, 1.1), SinOsc.ar(pmf, 0, pi), env);
		Out.ar(out, Pan2.ar(u, pan))
	})
);


// create a task to repeatedly send grains
(
t = Task.new({
	loop({
		// starts a synth with the current synthdef at index 0
		~out.spawn([\pmf, [1, 20, 300].choose, \pan, [0, -1, 1].choose]);
		[0.1, 0.01, 0.25].choose.wait;
	})
});
)

t.start;
t.stop;
t.start;

// note: if you want to avoid using interpreter variables (single letter, like "t"),
// you can use Tdef for this. (see Tdef.help)

// set some argument
~out.set(\freq, 300);
~out.set(\freq, 600);
~out.map(\freq, ~lfo);
~lfo = { SinOsc.kr(0.1, 0, 3000, 4000) };
~lfo = { SinOsc.kr(0.1, 0, 600, 700) };
~lfo.add({ Trig.kr(Dust.kr(1), 0.1) * 3000 });
~lfo = 300;

// change the definition while going along
(
~out = SynthDef("a", { arg out, freq=800;
		var env;
		env = EnvGen.kr(Env.perc(0.01, 0.1, 0.3),doneAction:2);
		Out.ar(out, Pulse.ar(freq * Rand([0.9,0.9], 1.1), 0.5, env) )
	});
)


t.stop;
~out.awake = true; // don't forget this
//  free all synths in this current ProxySpace
currentEnvironment.clear;




granular synthesis: efficient code

see also [jitlib_efficiency]

~out.play;

(
SynthDef("grain", { arg i_out = 0, pan;
	var env;
	env = EnvGen.kr(Env.perc(0.001, 0.003, 0.2),doneAction:2);
	Out.ar(i_out, Pan2.ar(FSinOsc.ar(Rand(1000,10000)), pan) * env)
}).send(s);
)

// a target for the grains
~someInput.ar(2);  // initialize to 2 channels audio
~out = ~someInput;

(
t = Task({
	loop({
		s.sendMsg("/s_new","grain",-1,0,0,
			\i_out, ~someInput.index, // returns the bus index of the proxy
			\pan, [1, 1, -1].choose * 0.2
		);
		[0.01, 0.02].choose.wait;
	})
});
)
t.play;

// different filters;

~out.fadeTime = 1.0;

~out = { BPF.ar(~someInput.ar, MouseX.kr(100, 18000, 1), 0.1) };

~out = { CombL.ar(~someInput.ar * (LFNoise0.ar(2) > 0), 0.2, 0.2, MouseX.kr(0.1, 5, 1)) };

~out = { RLPF.ar(~someInput.ar, LFNoise1.kr(3, 1000, 1040), 0.05) };


t.stop;



//_________

~out.stop;
currentEnvironment.clear;
ProxySpace.pop; // restore original environment



________________________________________________________________________


using multiple proxyspaces
note that this can be done while the server is not running: with p.wakeUp or p.play
the environment can be played back.

// quit server:

s.quit;


// create two proxyspaces without a running server
(
p = ProxySpace(s);
q = ProxySpace(s);

p.use({
	~out = { Resonz.ar(~in.ar, ~freq.kr, 0.01) };
	~in = { WhiteNoise.ar(0.5) };
	~freq = { LFNoise2.kr(1, 1000, 2000) };
});

q.use({

	~in = { Dust.ar(20, 0.1) };
	~out = { Resonz.ar(~in.ar * 450, ~freq.kr, 0.005) };
	~freq = { LFNoise2.kr(1, 400, 2000) };
});
)

// wait for the booted  server
s.boot;

// play the proxy at \out
p.play(\out);
q.play; // out is the default output


external access


q[\in][1] = { Impulse.ar(2, 0, 0.5) }; // adding a synth at index 1

// equivalent to
q.at(\in).put(1, { Impulse.ar(7, 0, 0.5) });


connecting two spaces (must be on one server)


(
q.use({
	~freq =  100 + p[\freq] / 2;
})
)

recording output (see also: [RecNodeProxy])


r = p.record(\out, "proxySpace.aiff");

// start recording
r.unpause;

// pause recording
r.pause;

// stop recording
r.close;





push/pop


// make x the currentEnvironment
p.push;

~freq = 700;
~freq = 400;
~freq = { p.kr(\freq) + LFNoise1.kr(1, 200, 300) % 400 }; // feedback
~freq = 400;

p.pop; // restore environment


// make y the currentEnvironment
q.push;

~freq = 1000;
~in = { WhiteNoise.ar(0.01) };

q.pop; // restore environment

q.clear;
p.clear;




______________________________________________________________

some more topics

nodeproxy with numbers as input:

p = ProxySpace.push(s.boot);


~out = { SinOsc.ar(~a.kr * Rand(1, 2), 0, 0.1) };
~out.play;

~a = 900;

// these add up:
~a[0] = 440;
~a[1] = 220;
~a[2] = 20;

~a.fadeTime = 2;

~a[0] = 300; // now there is a crossfade.
~a[1] = { SinOsc.kr(5, 0, 20) };
~a[2] = { SinOsc.kr(30, 0, 145) };



// internally a numerical input is approximately replaced by:
// (pseudocode)
SynthDef("name", { arg out, fadeTime;
	 Out.kr(out,
	 	Control.kr(Array.fill(proxy.numChannels, { the number }))
	 		* EnvGate.new(fadeTime:fadeTime)
	 )
});





