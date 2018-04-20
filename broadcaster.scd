~broadcastList = ();
(
OSCdef(\joinBroadcast, { |msg time addr recvPort|
	var id = msg[1].asSymbol;
	var ip = addr;
	var dArray;
	msg.postln;
	time.postln;
	addr.postln;
	recvPort.postln;
	//see if id is already used
	if( ~broadcastList.includesKey(id), { NetAddr(ip.ip, 12321).sendMsg("/reply", "Sorry, that ID is taken. Please choose another") },
		{ //if not id is not already used
			~broadcastList.put(id, ip);
			//post complete list
			dArray = ~broadcastList.asSortedArray;
			dArray.do({|it ix| it[0].post; " : ".post; it[1].postln});
	});
}, "/id");
)

NetAddr(~broadcastList[\jyang].ip, 12321).sendMsg("/bounce", 17.0, 0.171);

