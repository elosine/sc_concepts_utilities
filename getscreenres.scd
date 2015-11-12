a = "system_profiler SPDisplaysDataType | grep Resolution".unixCmdGetStdOut.findRegexp("(?<!@ )[0-9]{3,}").collect({|item| item[1].asInteger}).clump(2);

a[0][0];


q = ();

q.put(\wh, [10, 124]);
