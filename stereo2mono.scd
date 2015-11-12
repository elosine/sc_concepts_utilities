~sts = SoundFile.collectIntoBuffers("/Users/jyang/GitHub/DSP_Framework/stereosamples/*");
		~ms = SoundFile.collectIntoBuffers("/Users/jyang/GitHub/DSP_Framework/monosamples/*");
		~sn = Array.newClear(0); //array of all the soundfile names
		0.5.wait;
		//create an array of strings that hold all of the soundfile names incl the converted stereo-to-mono ones
		~ms.do{ |it ix| var nm = it.path.split($/); ~sn = ~sn.add(nm[nm.size-1].asString) };
		~sts.do{ |it ix| var nm = it.path.split($/); ~sn = ~sn.add(nm[nm.size-1].asString) };

		//Convert stereo soundfiles to mono and combine all in ~samps
		~s2mbz = Array.newClear(~sts.size);
		~sts.do{ |it ix|
			it.loadToFloatArray(action: {
				arg array;
				var ar = array;
				~s2mbz[ix] = Buffer.loadCollection(s, ar.unlace(2).sum*0.5);
		})};
		2.wait;
		~samps = ~ms.addAll(~s2mbz);