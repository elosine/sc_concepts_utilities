b = SoundFile.collectIntoBuffers("/Users/yangj14/Documents/chucK/grainEnv/*", s);
b.do{|it| it.plot(it.path)};
