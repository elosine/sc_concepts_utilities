p = Server(\pi, NetAddr("192.168.0.11",    57110));

p.sendMsg(\n_set, 4000, \obs, 104);

p.sendMsg(\s_new, \greyhole, 3020, 0, 305, \ibs, 104, \obs, 0);

p.sendMsg(\n_set, 3020, \obs, 110);


p.sendMsg(\n_free, 4000);

p.sendMsg(\s_new, \ts, 3033, 0, 305);


	p.sendMsg(\s_new, \playsamp, 4000, 0, 301, \buf, 4);



