// =====================================================
// SYNTHDEFs - 'billbird' and 'billbigbird'
// =====================================================

(
SynthDef("billbird", { arg dur, freq, freqskew, amp, t_gate;
         var freqenv, ampenv, freqenvctl, ampenvctl, sig;
         // make an empty 10 segment envelope
         freqenv = Env.newClear(10);
         ampenv = Env.newClear(10);
         // create a control argument array
         freqenvctl = NamedControl.kr(\freqenv, freqenv.asArray);
         ampenvctl = NamedControl.kr(\ampenv, ampenv.asArray);
         sig = SinOsc.ar(
             EnvGen.kr(freqenvctl, t_gate, freqskew, freq, dur), // freq
             0, // phase
             //    amp);
             EnvGen.kr(ampenvctl, t_gate, amp, timeScale: dur,
doneAction: 2)); // amplitude
         Out.ar(0, sig);
}).add;

SynthDef("billbigbird", { arg dur, freq, freqskew, amp, t_gate;
     var howmany = 20; // hard wire max number of partials
     var pnum = Array.fill(howmany, 0).postln; // partial numbers (zero= 'silent' partials as default);
     var pamp = Array.fill(howmany, 1).normalizeSum.postln; // partial amps
     var pnumctl = NamedControl.kr(\partialNumbers, pnum.asArray);
     var pampctl = NamedControl.kr(\partialAmps, pamp.asArray);
     var freqenv = Env.newClear(51);
     var ampenv = Env.newClear(51);
     var freqenvctl = NamedControl.kr(\freqenv, freqenv.asArray);
     var ampenvctl = NamedControl.kr(\ampenv, ampenv.asArray);

     var sig = DynKlang.ar(`[pnumctl, pampctl, nil], // KLANG: partials,amplitudes, phases
                            EnvGen.kr(freqenvctl, t_gate, freqskew,freq, dur), // KLANG: fundamental frequency
	0) // KLANG: offset
                         * EnvGen.kr(ampenvctl, t_gate, amp, timeScale:dur, doneAction: 2); // amplitude envelope

     Out.ar(0, sig);
  }).add;
)

// Example 1:
(
x = Synth("billbird", [
     \t_gate, 1,
     \amp, 0.35,
     \freqenv, Env([0.8, 1, 0.3, 0], [0.15, 0.6, 0.25], 'sine'),
     \freqskew, 2400,
     \freq, 4000,
     \dur, 0.05,
     \ampenv, Env([0, 1, 0.7, 1, 0], [0.25, 0.35, 0.15, 0.25], 'sine')
]);
)

// Example 2:
(
x = Synth("billbigbird", [
     \dur, 0.2,
     \freq, 2000,
     \freqskew, 800,
     \amp, 0.2,
     \freqenv, Env([1, 0.8, 0.3, 0], [0.15, 0.6, 0.25], 'sine'),
     \ampenv, Env([0, 1, 0.1, 1, 0], [0.25, 0.25, 0.25, 0.25], 'sine'),
     \partialNumbers, [1,2,3],
     \partialAmps, [1,0.2,0.05],
     \t_gate, 1,
]);
)

// =====================================================
// GLOBAL VARIABLES
// =====================================================
(
~main_amp = Env([0, 1, 0.7, 1, 0], [0.25, 0.35, 0.15, 0.25], 'sine');
~main_amp.plot
)
/*
(define main-amp '(.00 .00 .25 1.00 .60 .70 .75 1.00 1.00 .0))
(define bird-tap '(.00 .00 .01 1.00 .99 1.00 1.00 .0))
(define bird-amp '(.00 .00 .25 1.00 .75 1.00 1.00 .0))
*/

// =====================================================
// FUNCTIONS getLevels & getTimes
// =====================================================

// Rearrange breakpoint envelops from Bill
(
~getLevels = {arg array; array.clump(2).flop.at(1)};
~getTimes = {arg array; array.clump(2).flop.at(0).differentiate.drop(1)};
~getPartials = {arg array; array.clump(2).flop.at(0)}; // same as ~getLevels
~getPartialAmps = {arg array; array.clump(2).flop.at(1)};
)

// Example
a = [0, 0.8, 0.15, 1, 0.75, 0.3, 1, 0] // original chip-up freq-envelopefrom bill
~getLevels.value(a);
~getTimes.value(a);


// ============================
// ===== CHIPPING SPARROW =====
// ============================
(
var chipup = [0, 0.8, 0.15, 1, 0.75, 0.3, 1, 0]; // original chip-upfreq-envelope from bill
var freqenv = Env(~getLevels.value(chipup), ~getTimes.value(chipup), 'sine');
~chipping_sparrow = Task({
     17.do({ // do this 17 times
         x = Synth("billbird", [
             \t_gate, 1,
             \amp, 0.05,
             \freqenv, freqenv,
             \freqskew, 2400,
             \freq, 4000,
             \dur, 0.05,
             \ampenv, ~main_amp,
         ]);
         0.01.wait;
     })});
)
~chipping_sparrow.start; // play it!

// ============================
// ===== YELLOW WARBLER =======
// ============================

(
var yellow_up, yellow_up_bill = [0, 0, 0.6, 1, 1, 0.5];
var yellow_swirl, yellow_swirl_bill = [0, 1, 0.05, 1, 0.6, 0, 0.8, 0.3,
1, 0.1];
var yellow_down, yellow_down_bill = [0, 1, 1, 0];
var yellow_last, yellow_last_bill = [0, 0, 0.3, 0.2, 0.8, 0.7, 1, 1];
var swirl_amp, swirl_amp_bill = [0, 0, 0.9, 1, 1, 0];
var main_amp = ~main_amp;
var times_bill = [0, 0.23, 0.45, 0.62, 0.85, 1.05, 1.15, 1.25, 1.4];
var yel_t = times_bill.differentiate;
yellow_up = Env(~getLevels.value(yellow_up_bill),
~getTimes.value(yellow_up_bill), 'sine');
yellow_swirl = Env(~getLevels.value(yellow_swirl_bill),
~getTimes.value(yellow_swirl_bill), 'sine');
yellow_down = Env(~getLevels.value(yellow_down_bill),
~getTimes.value(yellow_down_bill), 'sine');
yellow_last = Env(~getLevels.value(yellow_last_bill),
~getTimes.value(yellow_last_bill), 'sine');
swirl_amp = Env(~getLevels.value(swirl_amp_bill),
~getTimes.value(swirl_amp_bill), 'sine');

~yellow_warbler = Task({
             Synth("billbird", [\dur, 0.05, \freq, 5600, \freqskew, 400,
\amp, 0.05, \freqenv, yellow_up, \ampenv, main_amp, \t_gate, 1]);
yel_t[1].wait;  Synth("billbird", [\dur, 0.12, \freq, 5000, \freqskew,
1500, \amp, 0.15, \freqenv, yellow_swirl, \ampenv, swirl_amp, \t_gate, 1]);
yel_t[2].wait;    Synth("billbird", [\dur, 0.13, \freq, 5000, \freqskew,
1700, \amp, 0.17, \freqenv, yellow_swirl, \ampenv, swirl_amp, \t_gate, 1]);
yel_t[3].wait;    Synth("billbird", [\dur, 0.16, \freq, 5000, \freqskew,
2000, \amp, 0.20, \freqenv, yellow_swirl, \ampenv, swirl_amp, \t_gate, 1]);
yel_t[4].wait;    Synth("billbird", [\dur, 0.15, \freq, 5000, \freqskew,
2000, \amp, 0.20, \freqenv, yellow_swirl, \ampenv, swirl_amp, \t_gate, 1]);
yel_t[5].wait;    Synth("billbird", [\dur, 0.075, \freq, 3700,
\freqskew, 1000, \amp, 0.20, \freqenv, yellow_down, \ampenv, main_amp,
\t_gate, 1]);
yel_t[6].wait;    Synth("billbird", [\dur, 0.075, \freq, 3700,
\freqskew, 800, \amp, 0.15, \freqenv, yellow_down, \ampenv, main_amp,
\t_gate, 1]);
yel_t[7].wait;    Synth("billbird", [\dur, 0.075, \freq, 3700,
\freqskew, 800, \amp, 0.15, \freqenv, yellow_down, \ampenv, main_amp,
\t_gate, 1]);
yel_t[8].wait;    Synth("billbird", [\dur, 0.2, \freq, 3700, \freqskew,
2000, \amp, 0.2, \freqenv, yellow_last, \ampenv, swirl_amp, \t_gate, 1]);
});

// This was my first try; I got the timing wrong (simply copied X time
points, instead of Diff-X)
~yellow_warbler_wrong = Task({
             Synth("billbird", [\dur, 0.05, \freq, 5600, \freqskew, 400,
\amp, 0.05, \freqenv, yellow_up, \ampenv, main_amp, \t_gate, 1]);
0.23.wait;  Synth("billbird", [\dur, 0.12, \freq, 5000, \freqskew, 1500,
\amp, 0.15, \freqenv, yellow_swirl, \ampenv, swirl_amp, \t_gate, 1]);
0.45.wait;    Synth("billbird", [\dur, 0.13, \freq, 5000, \freqskew,
1700, \amp, 0.17, \freqenv, yellow_swirl, \ampenv, swirl_amp, \t_gate, 1]);
0.62.wait;    Synth("billbird", [\dur, 0.16, \freq, 5000, \freqskew,
2000, \amp, 0.20, \freqenv, yellow_swirl, \ampenv, swirl_amp, \t_gate, 1]);
0.85.wait;    Synth("billbird", [\dur, 0.15, \freq, 5000, \freqskew,
2000, \amp, 0.20, \freqenv, yellow_swirl, \ampenv, swirl_amp, \t_gate, 1]);
1.05.wait;    Synth("billbird", [\dur, 0.075, \freq, 3700, \freqskew,
1000, \amp, 0.20, \freqenv, yellow_down, \ampenv, main_amp, \t_gate, 1]);
1.15.wait;    Synth("billbird", [\dur, 0.075, \freq, 3700, \freqskew,
800, \amp, 0.15, \freqenv, yellow_down, \ampenv, main_amp, \t_gate, 1]);
1.25.wait;    Synth("billbird", [\dur, 0.075, \freq, 3700, \freqskew,
800, \amp, 0.15, \freqenv, yellow_down, \ampenv, main_amp, \t_gate, 1]);
1.40.wait;    Synth("billbird", [\dur, 0.2, \freq, 3700, \freqskew,
2000, \amp, 0.2, \freqenv, yellow_last, \ampenv, swirl_amp, \t_gate, 1]);
});
)

~yellow_warbler.start;

~yellow_warbler_wrong.start; // this one does a nice rallentado


// ============================
// ===== ORCHARD ORIOLE =======
// ============================

(
var oriup, oriup_bill = [0, 0, 1, 1,];
var oridwn, oridwn_bill = [0, 1, 1, 0];
var oriupdwna, oriupdwna_bill = [0, 0, 0.6, 1, 1, 0.6];
var oriupdwnb, oriupdwnb_bill = [0, 0.5, 0.3, 1, 1, 0];
var oribiga, oribiga_bill = [0, 0.9, 0.15, 1, 0.4, 0.3, 0.6, 0.6, 0.85,
0, 1, 0];
var orimid, orimid_bill = [0, 1.00, 0.05, 0.50, 0.10, 1.00, 0.25, 0.00,
0.85, 0.50, 1.00, 0.0];
var oridwnup, oridwnup_bill = [0.00, 0.30, 0.25, 0.00, 1.00, 1.0];
var oriamp, oriamp_bill = [0.00, 0.00, 0.10, 1.00, 1.00, 0.0];
var main_amp = ~main_amp;
var times_bill = [0.38, 0.41, 0.50, 0.65, 0.70, 1, 1.1, 1.3, 1.48, 1.65,
1.7, 1.8, 1.92, 2.2, 2.28, 2.4] - 0.38; // from bill
var ori_t = times_bill.differentiate; // get array of durations in
between events

oriup = Env(~getLevels.value(oriup_bill), ~getTimes.value(oriup_bill),
'sine');
oridwn = Env(~getLevels.value(oridwn_bill),
~getTimes.value(oridwn_bill), 'sine');
oriupdwna = Env(~getLevels.value(oriupdwna_bill),
~getTimes.value(oriupdwna_bill), 'sine');
oriupdwnb = Env(~getLevels.value(oriupdwnb_bill),
~getTimes.value(oriupdwnb_bill), 'sine');
oribiga = Env(~getLevels.value(oribiga_bill),
~getTimes.value(oribiga_bill), 'sine');
orimid = Env(~getLevels.value(orimid_bill),
~getTimes.value(orimid_bill), 'sine');
oridwnup = Env(~getLevels.value(oridwnup_bill),
~getTimes.value(oridwnup_bill), 'sine');
oriamp = Env(~getLevels.value(oriamp_bill),
~getTimes.value(oriamp_bill), 'sine');

~orchard_oriole = Task({
             Synth("billbird", [\dur, 0.03, \freq, 3700, \freqskew, 100,
\amp, 0.5, \freqenv, oridwn, \ampenv, main_amp, \t_gate, 1]);
ori_t[1].wait;  Synth("billbird", [\dur, 0.05, \freq, 2500, \freqskew,
1000, \amp, 0.1, \freqenv, oriup, \ampenv, main_amp, \t_gate, 1]);
ori_t[2].wait;  Synth("billbigbird", [\dur, 0.1, \freq, 2000, \freqskew,
800, \amp, 0.2, \freqenv, oriupdwna, \ampenv, main_amp,
                                   \partialNumbers, [1, 2, 3],
\partialAmps, [1, 0.2, 0.5], \t_gate, 1]);
ori_t[3].wait;  Synth("billbird", [\dur, 0.3, \freq, 3900, \freqskew,
1200, \amp, 0.1, \freqenv, oridwn, \ampenv, main_amp, \t_gate, 1]);
ori_t[4].wait;  Synth("billbigbird", [\dur, 0.21, \freq, 2000,
\freqskew, 1200, \amp, 0.15, \freqenv, oribiga, \ampenv, main_amp,
                                   \partialNumbers, [1, 2],
\partialAmps, [1, 0.05], \t_gate, 1]);
ori_t[5].wait;  Synth("billbird", [\dur, 0.05, \freq, 4200, \freqskew,
1000, \amp, 0.1, \freqenv, oridwn, \ampenv, main_amp, \t_gate, 1]);
ori_t[6].wait;  Synth("billbigbird", [\dur, 0.1, \freq, 2000, \freqskew,
1000, \amp, 0.25, \freqenv, orimid, \ampenv, main_amp,
                                   \partialNumbers, [1, 2],
\partialAmps, [1, 0.05], \t_gate, 1]);
ori_t[7].wait;  Synth("billbigbird", [\dur, 0.1, \freq, 2000, \freqskew,
1000, \amp, 0.25, \freqenv, orimid, \ampenv, main_amp,
                                   \partialNumbers, [1, 2],
\partialAmps, [1, 0.05], \t_gate, 1]);
ori_t[8].wait;  Synth("billbird", [\dur, 0.1, \freq, 2300, \freqskew,
3200, \amp, 0.1, \freqenv, oriupdwnb, \ampenv, oriamp, \t_gate, 1]);
ori_t[9].wait;  Synth("billbird", [\dur, 0.03, \freq, 1800, \freqskew,
300, \amp, 0.05, \freqenv, oriup, \ampenv, main_amp, \t_gate, 1]);
ori_t[10].wait;  Synth("billbird", [\dur, 0.03, \freq, 2200, \freqskew,
100, \amp, 0.4, \freqenv, oridwn, \ampenv, main_amp, \t_gate, 1]);
ori_t[11].wait;  Synth("billbird", [\dur, 0.07, \freq, 2500, \freqskew,
2000, \amp, 0.15, \freqenv, oriupdwnb, \ampenv, oriamp, \t_gate, 1]);
ori_t[12].wait;  Synth("billbigbird", [\dur, 0.2, \freq, 2400,
\freqskew, 1200, \amp, 0.25, \freqenv, oridwnup, \ampenv, main_amp,
                                   \partialNumbers, [1, 2],
\partialAmps, [1, 0.04], \t_gate, 1]);
ori_t[13].wait;  Synth("billbird", [\dur, 0.02, \freq, 2200, \freqskew,
3000, \amp, 0.4, \freqenv, oriup, \ampenv, main_amp, \t_gate, 1]);
ori_t[14].wait;  Synth("billbird", [\dur, 0.02, \freq, 2200, \freqskew,
3000, \amp, 0.4, \freqenv, oriup, \ampenv, main_amp, \t_gate, 1]);
ori_t[15].wait;  Synth("billbigbird", [\dur, 0.17, \freq, 2000,
\freqskew, 1000, \amp, 0.2, \freqenv, oriupdwna, \ampenv, main_amp,
                                   \partialNumbers, [1, 2],
\partialAmps, [1, 0.04], \t_gate, 1]);
});
)

~orchard_oriole.start;


// ============================
// ==== CASSINS KINGBIRD ======
// ============================

(
var kingfirst_bill = [0.00, 0.30, 0.45, 1.00, 0.90, 0.10, 1.00, 0.0];
var kingsecond_bill = [0.00, 0.00, 0.02, 0.50, 0.04, 0.00, 0.06, 0.55,
0.08, 0.05, 0.10, 0.60, 0.12, 0.05, 0.14, 0.65, 0.16, 0.10, 0.18, 0.70,
0.20, 0.10, 0.22, 0.75, 0.24, 0.15, 0.26, 0.80, 0.28, 0.20, 0.30, 0.85,
0.32, 0.25, 0.34, 0.90, 0.36, 0.30, 0.38, 0.95, 0.40, 0.40, 0.42, 1.00,
0.44, 0.50, 0.46, 1.00, 0.48, 0.45, 0.50, 1.00, 0.52, 0.50, 0.54, 1.00,
0.56, 0.40, 0.58, 0.95, 0.60, 0.40, 0.62, 0.90, 0.64, 0.40, 0.66, 0.85,
0.68, 0.35, 0.70, 0.80, 0.72, 0.30, 0.74, 0.75, 0.76, 0.25, 0.78, 0.70,
0.80, 0.20, 0.82, 0.65, 0.84, 0.10, 0.86, 0.60, 0.88, 0.00, 0.90, 0.55,
0.92, 0.00, 0.94, 0.50, 0.96, 0.00, 1.00, 0.40];
var main_amp = ~main_amp;
var times_bill = [0.3, 0.12];
var king_t = times_bill.differentiate; // get array of durations in
between events

var kingfirst = Env(~getLevels.value(kingfirst_bill),
~getTimes.value(kingfirst_bill), 'sine');
var kingsecond = Env(~getLevels.value(kingsecond_bill),
~getTimes.value(kingsecond_bill), 'sine');

~cassis_kingbird = Task({
                 Synth("billbigbird", [\dur, 0.04, \freq, 1700,
\freqskew, 1200, \amp, 0.15, \freqenv, kingfirst, \ampenv, main_amp,
                                       \partialNumbers, [1, 2, 3, 4],
\partialAmps, [1, 0.5, 0, 0.2], \t_gate, 1]);
king_t[1].wait;    Synth("billbigbird", [\dur, 0.18, \freq, 1700,
\freqskew, 900, \amp, 0.25, \freqenv, kingsecond, \ampenv, main_amp,
                                       \partialNumbers, [1, 2, 3, 4],
\partialAmps, [1, 0.01, 0, 0.1], \t_gate, 1]);
});

//kingsecond.plot;
)

~cassis_kingbird.start; 