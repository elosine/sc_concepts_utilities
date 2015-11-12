/ SuperOctaver + Frequency-Shifting on MouseY
//   MouseX = amplitude
//   MouseY = frequency shift
//   MouseButton = clear frequency shift

//f = "sounds/a11wlk01-44_1.aiff";  // may need an absolute path here
f = "/Volumes/13-14/Justin/immlibaudio/breathing.aif";  // may need an absolute path here
b = Buffer.read(s,f);
(
x = {
         var in, amp, fftSize=8192, winLen=2048, hopFrac=0.25,
             chain1, chain2, chain3, mexp, fScaled, df, binShift;
         amp = MouseX.kr(-60,10).dbamp;
         in = amp * PlayBuf.ar(1,b.bufnum,BufRateScale.kr(b.bufnum),loop:1);
         // in = amp * SoundIn.ar(0); // for Mic input (f-shift inhibits feedback)
         df = MouseY.kr(-500.0,500.0); // frequency-shift in Hz
         df = df*(1-MouseButton.kr); // press mouse to cancel frequency shift
         binShift = fftSize * (df / s.sampleRate);

         chain1 = FFT(LocalBuf(fftSize), in, hopFrac, 0, 1, winLen);
         chain2 = PV_Copy(chain1,LocalBuf(fftSize)); // -> octave up
         chain3 = PV_Copy(chain1,LocalBuf(fftSize)); // -> octave down

         chain1 = PV_BinShift(chain1, stretch:0.5, shift:binShift, interp:1);
         chain2 = PV_BinShift(chain2, stretch:1.0, shift:binShift, interp:1);
         chain3 = PV_BinShift(chain3, stretch:0.25, shift:binShift, interp:1);

         chain2 = PV_Add(chain2,chain1);
         chain3 = PV_Add(chain3,chain2);
         Out.ar(0, IFFT(chain3,0,winLen).dup);
}.play;
) 