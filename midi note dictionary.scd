(
var md, na, oc;
~nd = ();
md = 0;
na = [\c, \cs, \d, \eb, \e, \f, \fs, \g, \gs, \a, \bb, \b];
oc = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
oc.do{ |it ix|
	na.do{ |it2 ix2|
		~nd.put((it2 ++ it).asSymbol, 12+md);
		md = md+1;
	}
};
)