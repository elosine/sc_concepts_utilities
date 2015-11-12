//IMPULSE MAKER ///////////////////////
(
Server.default = Server.internal;
s = Server.default;
s.options.sampleRate = 44100;
s.options.memSize = 32768;
s.reboot;
~fftsize = 4096;
d = 1;
~irPath = "/Users/justin/Dropbox/Impulse_Response/ImpulseResponses/SARC/44k/dpa4006_ph1_t1-01.wav"
s.waitForBoot {
	{
	var ir, irbuffer, bufsize;
		irbuffer = Buffer.read(s, ~irPath);
		s.sync;
		bufsize = PartConv.calcBufSize(~fftsize, irbuffer);
		~irspectrum= Buffer.alloc(s, bufsize, 1);
		~irspectrum.preparePartConv(irbuffer, ~fftsize);
		s.sync;
		irbuffer.free;
	}.fork;
};

~iLen = 1000000;
b = Buffer.read(s,"/Users/justin/Dropbox/Supercollider/Impulse Response/44k_pup_t1_131072/dpa4006_pup_t1-30.wav" );
c = Buffer.alloc(s, ~iLen, 1);
)

x = Synth("IASIARimpulseMaker", [\bufnum, b, \recBuf, c, \amp, -3.dbamp, \fftsize, ~fftsize, \spectrumBufnum, ~irspectrum.bufnum]);

(
c.write("/Users/justin/Desktop/Impulses/Ch30/impulse" ++ d.asString ++ ".aif", "AIFF", "float", ~iLen, 0);
c.free;
c = Buffer.alloc(s, ~iLen, 1);
b.free;
b = Buffer.read(s, "/Users/justin/Desktop/Impulses/Ch30/impulse"++d.asString++".aif");
d = d+1;
)
d=19