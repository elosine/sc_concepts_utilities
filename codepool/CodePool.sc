CodePool {
	var <name, <>addr, <>port, responder, netadd, localadd, window, codeList, <codeArray, <nameArray, <>codeTextView, envrTextView, sendButton, postWin, postTxt, envKeys, envVals, envList, c, sdButton, <timeArray, xmlSaveName, hist, <>proxyButton, <>clockStartButton;
	
	*new { arg name, addr, port;
	if (GUI.current == SwingGUI,{
			^super.newCopyArgs(name, addr, port).initSwing;
		},{
			^super.newCopyArgs(name, addr, port).initCocoa;
		}
	)
	
	}

	initCocoa {				
		if (name.isNil, {name = "Default"});
		
		if (addr.isNil, {addr = "127.0.0.1"});
		
		if (port.isNil, {port = 57120});
		
		codeArray = [];
		nameArray = [];
		envKeys = [];
		envVals = [];
		timeArray = [];
			
		~proxy = ProxySpace();
		c = this;
		
		netadd = NetAddr(addr, port);
		
		if (port != 57120,{localadd = NetAddr("127.0.0.1",57120)});
			
		~sccode.remove;
		
		~sccode = OSCresponderNode(nil,'/SCCode',{|t,r,msg| msg[1].asString.interpret;}).add;
		
		if (GUI.current != SwingGUI,{
		(
		//second post window for all incoming/outgoing code
		postWin = GUI.window.new("CodePool Post Window", Rect(
			GUI.window.screenBounds.width-500,
			GUI.window.screenBounds.height-250,
			500,
			GUI.window.screenBounds.height-50
		),false)
		.front;
		
		postTxt = GUI.textView.new(postWin,Rect(
			10,
			10,
			480,
			GUI.window.screenBounds.height-70
		))
		.focus(true)
		.editable_(false)
		.enterInterpretsSelection_(false)
		.hasVerticalScroller_(true);
		
		);
		});
		
		responder = OSCresponderNode(nil,'/SCCode',{|t,r,msg|
			{
			if (GUI.current == CocoaGUI,{
				
				hist = postTxt.string;
				
				postTxt.string = //postTxt.string ++ 
				"=============" + msg[2] + "@" + Date.getDate.hourStamp.asString + "=============" ++ 
				"\n";
				
				postTxt.string = postTxt.string ++ 
				msg[1].asString ++ 
				"\n";
				
				postTxt.string = postTxt.string ++ 
				"\n" ++ hist;
			});

			codeArray = codeArray.add(msg[1]);
			nameArray = nameArray.add(msg[2].asString + "@" + Date.getDate.hourStamp.asString);
			codeList.items = nameArray;
			
			//get environment keys
			envKeys = [];
			if( currentEnvironment.asString.contains("Environment") == false,
				{
					forBy(0, currentEnvironment.envir.array.size,2,{arg i;
						if (
							currentEnvironment.envir.array[i] != nil,{
								envKeys = envKeys.add(currentEnvironment.envir.array[i]);
							}
						)
					});
				},
				{
					forBy(0, currentEnvironment.array.size,2,{arg i;
						if (
							currentEnvironment.array[i] != nil,{
								envKeys = envKeys.add(currentEnvironment.array[i]);
							}
						)
					});
				});
			
			//get environment values
			envVals = [];
			if( currentEnvironment.asString.contains("Environment") == false,
				{
					for (0, envKeys.size, {arg i;
						envVals = envVals.add(currentEnvironment.envir.at(envKeys[i]));
					});	
				},
				{
					for (0, envKeys.size, {arg i;
						envVals = envVals.add(currentEnvironment.at(envKeys[i]));
					});
				});
			
			envList.items = envKeys;
			
			timeArray = timeArray.add(t);
			
			window.refresh;
			
			}.defer;

		}).add;
		
		(
		//main window
		window = GUI.window.new("CodePool Coding Window", Rect(
			0,
			GUI.window.screenBounds.height-250,
			GUI.window.screenBounds.width-500,
			400
		),false)
		.front;
		
		/////////////////////////////
		
		// clock
		~clock = DigiClock.new(window, 0.25, Color.white,GUI.window.screenBounds.width-613,350);
		
		// clock buttons
		clockStartButton = Button(window, Rect(
			GUI.window.screenBounds.width-710,
			350,
			95,
			25
			)
		).states_([
			["Start Clock", Color.black, Color.green],
			["Stop Clock", Color.black, Color.cyan]
		])
		.action_({ arg val;
			switch( val.value,
			0, {this.send("{~clock.stop}.defer;")},
			1, {{this.send("{~clock.start}.defer;")}.defer}
			);
		});
		
		Button(window, Rect(
			GUI.window.screenBounds.width-710,
			375,
			95,
			25
			)
		).states_([
			["Reset Clock", Color.black, Color.green]
		])
		.action_({ arg val;
			this.send("{~clock.reset}.defer;");
		});
		
		//lists the name and time of all code executed this session
		codeList = GUI.listView.new(window,Rect(
			GUI.window.screenBounds.width-710,
			30,
			200,
			320
		))
		.enterKeyAction= { 
			this.send(codeTextView.string);
		};
		codeList.items = nameArray;
		codeList.action = { arg q; codeTextView.setString(
			codeArray[ q.value ].asString,
			0,
			codeTextView.string.size;
			)};
		
		//list lable
		GUI.staticText.new(window,Rect(
			GUI.window.screenBounds.width-710,
			10,
			100,
			20
		))
		.string_("Code History");
		
		/////////////////////////////
	 
		//Code input textview
		codeTextView = GUI.textView.new(window,Rect(
			10,
			30,
			(((GUI.window.screenBounds.width-730)/4)*3)-10,
			320
		))
		.focus(true)
		.enterInterpretsSelection_(false)
		.hasVerticalScroller_(true)
		.autohidesScrollers_(true).keyDownAction= { arg view, char, modifiers, unicode, keycode; Ê
		if (keycode == 76, {Ê
			this.send(codeTextView.string);
		});
		};
		
		//Code view lable
		GUI.staticText.new(window,Rect(
			10,
			10,
			200,
			20
		))
		.string_("Code");
		
		/////////////////////////////
		
		//Environment list
		envList = GUI.listView.new(window,Rect(
			(((GUI.window.screenBounds.width-730)/4)*3)+10,
			30,
			((GUI.window.screenBounds.width-730)/4),
			270
		))
		.action_({ arg i; envrTextView.setString(
			envVals[ i.value ].asString,
			0,
			envrTextView.string.size;
			)})
		.enterKeyAction_({ arg i;
			if(envVals[ i.value ].asString.contains("Synth") ,{
				QuickSynthGUI.new(this, envList.item.asString);
				}
			);
		});
		
		//envr list lable
		GUI.staticText.new(window,Rect(
			(((GUI.window.screenBounds.width-730)/4)*3)+10,
			10,
			200,
			20
		))
		.string_("Envir Variables");
		
		//Environmental variable values
		envrTextView = GUI.textView.new(window,Rect(
			(((GUI.window.screenBounds.width-730)/4)*3)+10,
			325,
			((GUI.window.screenBounds.width-730)/4),
			25
		))
		.editable_(false)
		.hasVerticalScroller_(true)
		.autohidesScrollers_(true);
		
		//var list lable
		GUI.staticText.new(window,Rect(
			(((GUI.window.screenBounds.width-730)/4)*3)+10,
			305,
			200,
			20
		))
		.string_("Envir Variable Value");

		// ProxySpace button
		proxyButton = Button(window, Rect(
			(((GUI.window.screenBounds.width-730)/4)*3)+10,
			360,
			((GUI.window.screenBounds.width-730)/4),
			30
			)
		)
		.states_([
			["Environment", Color.black, Color.green],
			["ProxySpace", Color.white, Color.red]
		])
		.action_({ arg state;
			switch(state.value,
			0,{ this.send("currentEnvironment.pop; {c.proxyButton.value = 0}.defer;") },
			1,{ this.send("~proxy.push(s); {c.proxyButton.value = 1}.defer;") }
			);
		});
		
		/////////////////////////////
		
		//Button for sending code
		sendButton = GUI.button.new(window,Rect(
			10,
			370,
			80,
			20
		))
		.states_([
			["Send (Enter)", Color.black, Color.green]
		])
		.action_({arg val;
			this.send(codeTextView.string);
		});

		window.onClose_({
			if (GUI.current == CocoaGUI,{
				postWin.close;
			});
			responder.remove;
			~clock.stop;
			~clock.close;
		});
		);
		
		//Button for browsing SynthDescs
		sdButton = GUI.button.new(window,Rect(
			100,
			370,
			80,
			20
		))
		.states_([
			["SynthDefs", Color.black, Color.green]
		])
		.action_({arg val;
			SynthDefListGUI.new(this);
		});
		
		//Button for saving XML score
		sdButton = GUI.button.new(window,Rect(
			190,
			370,
			80,
			20
		))
		.states_([
			["Save XML", Color.black, Color.green]
		])
		.action_({arg val;
			XMLScore.saveXML(xmlSaveName.string.asString ++".xml", nameArray, timeArray, codeArray);
		});
		
		//file name for xml save
		xmlSaveName = TextField(window, Rect(280,370,160,20));
		xmlSaveName.string = "CodePoolScore";
		
		StaticText.new(window, Rect(442,370,40,20))
		.string_(".xml");
		
	}
	
	initSwing {				
		if (name.isNil, {name = "Default"});
		
		if (addr.isNil, {addr = "127.0.0.1"});
		
		if (port.isNil, {port = 57120});
		
		codeArray = [];
		nameArray = [];
		envKeys = [];
		envVals = [];
			
		
		netadd = NetAddr(addr, port);
		
		if (port != 57120,{localadd = NetAddr("127.0.0.1",57120)});
		
		~sccode.remove;
		
		~sccode = OSCresponderNode(nil,'/SCCode',{|t,r,msg| msg[1].asString.interpret;}).add;
		
		responder = OSCresponderNode(nil,'/SCCode',{|t,r,msg|

			codeArray = codeArray.add(msg[1]);
			nameArray = nameArray.add(msg[2].asString);
			codeList.items = nameArray;
			
			//get environment keys
			envKeys = [];
			forBy(0, currentEnvironment.array.size,2,{arg i;
				if (
					currentEnvironment.array[i] != nil,{
						envKeys = envKeys.add(currentEnvironment.array[i]);
					}
				)
			});
			//get environment values
			envVals = [];
			for (0, envKeys.size, {arg i;
				envVals = envVals.add(currentEnvironment.at(envKeys[i]));
			});
			
			envList.items = envKeys;
			
			window.refresh;

		}).add;
		
		(
		//main window
		window = GUI.window.new("CodePool Coding Window", Rect(
			0,
			50,
			GUI.window.screenBounds.width-500,
			400
		),false)
		.front;
		
		/////////////////////////////
		
		//lists the name and time of all code executed this session
		codeList = GUI.listView.new(window,Rect(
			GUI.window.screenBounds.width-710,
			30,
			200,
			320
		))
		.enterKeyAction= { 
			this.send(codeTextView.string);
		};
		codeList.items = nameArray;
		codeList.action = { arg q; codeTextView.setString(
			codeArray[ q.value ].asString,
			0,
			codeTextView.string.size;
			)};
		
		//list lable
		GUI.staticText.new(window,Rect(
			GUI.window.screenBounds.width-710,
			10,
			100,
			20
		))
		.string_("Code History");
		
		/////////////////////////////
	 
		//Code input textview
		codeTextView = GUI.textView.new(window,Rect(
			10,
			30,
			(((GUI.window.screenBounds.width-730)/4)*3)-10,
			320
		))
		.focus(true)
		.hasVerticalScroller_(true)
		.autohidesScrollers_(true).keyDownAction= { arg view, char, modifiers, unicode, keycode; Ê
		if (keycode == 76, {Ê
			this.send(codeTextView.string);
		});
		};
		
		//Code view lable
		GUI.staticText.new(window,Rect(
			10,
			10,
			200,
			20
		))
		.string_("Code");
		
		/////////////////////////////
		
		//Environment list
		envList = GUI.listView.new(window,Rect(
			(((GUI.window.screenBounds.width-730)/4)*3)+10,
			30,
			((GUI.window.screenBounds.width-730)/4),
			270
		))
		.action_({ arg i; envrTextView.setString(
			envVals[ i.value ].asString,
			0,
			envrTextView.string.size;
			)});
		
		//envr list lable
		GUI.staticText.new(window,Rect(
			(((GUI.window.screenBounds.width-730)/4)*3)+10,
			10,
			200,
			20
		))
		.string_("Environmental Variables");
		
		//Environmental variable values
		envrTextView = GUI.textView.new(window,Rect(
			(((GUI.window.screenBounds.width-730)/4)*3)+10,
			325,
			((GUI.window.screenBounds.width-730)/4),
			25
		))
		.editable_(false)
		.hasVerticalScroller_(true)
		.autohidesScrollers_(true);
		
		//var list lable
		GUI.staticText.new(window,Rect(
			(((GUI.window.screenBounds.width-730)/4)*3)+10,
			305,
			200,
			20
		))
		.string_("Environmental Variable Value");
				
		/////////////////////////////
		
		//Button for sending code
		sendButton = GUI.button.new(window,Rect(
			10,
			370,
			80,
			20
		))
		.states_([
			["Send", Color.black, Color.green]
		])
		.action_({arg val;
			this.send(codeTextView.string);
		});

		window.onClose_({
			responder.remove;
		});
		);
		
		//Button for browsing SynthDescs
		sdButton = GUI.button.new(window,Rect(
			100,
			370,
			80,
			20
		))
		.states_([
			["SynthDescs", Color.black, Color.green]
		])
		.action_({arg val;
			SynthDescLib.global.browse;
		});
		
		
	}
	
	//send code to addr IP
	send { arg code;
		netadd.sendMsg("/SCCode", code.asString, name.asString);
		if (port != 57120,{localadd.sendMsg("/SCCode", code.asString, name.asString)});
	}
	
	//sets the code text view to this code string (not really sure why I did this yet)
	putCode {arg code;
		this.codeTextView.string = codeTextView.string ++ "\n" ++ code.asString;
	}
	
	//returns the content code text view as a String (for if you want do so something with it)
	getCode {
		^this.codeTextView.string;
	}
	
	sendCode {
		this.send(codeTextView.string);
	}
	
	clearWindow {
		codeTextView.string = "";
	}

}

SynthDefListGUI {
	var parent, synthNames;
	var win, list, listView;
	
	*new { arg parent;
		^super.newCopyArgs(parent).init;
	}
	
	makeList {
		list = Array.fill(SynthDescLib.global.synthDescs.keys.size,0);
		
		SynthDescLib.global.synthDescs.keys.do({ arg item, i;
			list[i] = item;
		});
	}
	
	init {
		this.makeList;
		
		win = Window("SynthDefs", Rect(
			100,
			50,
			200,
			180
			)
		, false)
		.front;
		
		listView = ListView(win, Rect(
			10,
			10,
			180,
			130
			)
		)
		.items_(list)
		.enterKeyAction_({ arg i;
			list[i.value].postln;
			QuickSynthGUI.new(parent,nil,list[i.value].asSymbol);
		});
		
		Button(win, Rect(
			10,
			150,
			160,
			20
			)
		)
		.states_([
			["Refresh List", Color.black, Color.white]
		])
		.action_({
			this.makeList;
			listView.items_(list);
		});
		
	}
}

QuickSynthGUI {
	var parent, envVar, synthName;
	var win, varName, synthLabel, releaseTime, modeMenu, toCodeButton, scrollView, argVal;
	var synthArgs, codeBlock, tmpCtr, clrBut, initialType;
	
	*new {arg parent, envVar, synthName;
		^super.newCopyArgs(parent,envVar,synthName).init;
	}
	
	init {
		
		if(envVar.isNil,{
			initialType = 0;
		},{
			synthName = currentEnvironment.at(envVar.asSymbol).defName.asSymbol;
			initialType = 1;
		});
		synthArgs = SynthDescLib.global.synthDescs.at(synthName).controlNames;
		if(envVar.isNil,{envVar = "quick" ++ parent.name});
		tmpCtr = Array.new(synthArgs.size);
		SynthDescLib.global.synthDescs.at(synthName).controls.do { |ctl|
			tmpCtr.add( [\name, 0, \defaultValue, ctl.defaultValue] );
		};
		
		argVal = Array.series(synthArgs.size,0,0);
		
		//Window
		win = Window("QuickSynth", Rect(
			300,
			20,
			400,
			300
		),
		false)
		.front;
		
		// variable name textfield
		varName = TextField(win, Rect(
				10,
				10,
				180,
				20
			)
		).string_("~"++envVar.asString);
		
		// synth name label
		synthLabel = StaticText(win, Rect(
			200,
			10,
			180,
			20
			)
		).string_("Synth:" + synthName.asString);
		
		// action list
		modeMenu = PopUpMenu(win, Rect(
			10,
			40,
			100,
			20
			)
		).items = [
			"new",
			"set",
			"release"
		];
		
		//default value is "set" when used from variable, otherwise "new"
		modeMenu.value_(initialType);
		
		// release time label
		StaticText(win, Rect(
			120,
			40,
			100,
			20
			)
		).string_("release time:");
		
		// release time number box
		releaseTime = NumberBox(win, Rect(
			200,
			40,
			100,
			20
			)
		).value_(1);
		
		this.showScrollView;
		
				
		// generate code
		toCodeButton = Button(win, Rect(
			10,
			270,
			180,
			20
			)
		)
		.states_([
			["Send to CodePool Window", Color.black, Color.green]
		])
		.action_({
			switch(modeMenu.value,
				0, {
					codeBlock = "(\n";
					codeBlock = codeBlock ++ varName.string ++ "= Synth(\"" ++ synthName.asString ++ "\",[\n";
					synthArgs.size.do({ arg i;
						codeBlock = codeBlock ++ "\\" ++ synthArgs[i].asString ++ "," ++ argVal[i].value.asString;
						if(i < (synthArgs.size-1),
						{codeBlock = codeBlock ++",\n"},{codeBlock = codeBlock ++ "\n"});
					});
					codeBlock = codeBlock ++ "]);\n";
					codeBlock = codeBlock ++ ");\n";
					
					parent.codeTextView.string = parent.codeTextView.string ++ "\n" ++ codeBlock;
				},
				1, {
					codeBlock = "(\n";
					codeBlock = codeBlock ++ varName.string ++ ".set(\n";
					synthArgs.size.do({ arg i;
						codeBlock = codeBlock ++ "\\" ++ synthArgs[i].asString ++ "," ++ argVal[i].value.asString;
						if(i < (synthArgs.size-1),
						{codeBlock = codeBlock ++",\n"},{codeBlock = codeBlock ++ "\n"});
					});
					codeBlock = codeBlock ++ ")\n";
					codeBlock = codeBlock ++ ");\n";
					
					parent.codeTextView.string = parent.codeTextView.string ++ "\n" ++ codeBlock;
				},
				2, {
					codeBlock = "(\n";
					codeBlock = codeBlock ++ varName.string ++ ".release(" ++ releaseTime.value ++ ")\n";
					codeBlock = codeBlock ++ ");\n";
					
					parent.codeTextView.string = parent.codeTextView.string ++ "\n" ++ codeBlock;
				}
			)
		});
		
		// clear CodePool window
		clrBut = Button(win, Rect(
			200,
			270,
			180,
			20
			)
		)
		.states_([
			["Cear CodePool Window", Color.black, Color.green]
		])
		.action_({
			parent.codeTextView.string = "";
		});
		
	}
	
	showScrollView {
		// scroll view
		scrollView = ScrollView(win, Rect(
			10,
			80,
			380,
			180
			)
		);
		
		// param editors
		synthArgs.size.do({ arg i;
			// labels
			StaticText(scrollView, Rect(
				0,
				(i*20)+10,
				200,
				20
				)
			).string_(synthArgs[i].asString);
			
			// number boxes
			argVal[i] = NumberBox(scrollView, Rect(
				200,
				(i*20)+10,
				160,
				20
				)
			).value_(tmpCtr[i][3]);
		
		});

	}
}

ProxyQuickSynthGUI {
	var parent, envVar;
	var win, varName, synthLabel, releaseTime, modeMenu, toCodeButton, scrollView, argVal;
	var synthName, synthArgs, codeBlock, tmpCtr, clrBut;
	
	*new {arg parent;
		^super.newCopyArgs(parent).init;
	}
	
	init {
		
		synthName = currentEnvironment.at(envVar.asSymbol).defName.asSymbol;
		synthArgs = SynthDescLib.global.synthDescs.at(synthName).controlNames;
		tmpCtr = Array.new(synthArgs.size);
		SynthDescLib.global.synthDescs.at(synthName).controls.do { |ctl|
			tmpCtr.add( [\name, 0, \defaultValue, ctl.defaultValue] );
		};
		
		argVal = Array.series(synthArgs.size,0,0);
		
		//Window
		win = Window("ProxyQuickSynth", Rect(
			300,
			20,
			400,
			300
		),
		false)
		.front;
		
		// variable name textfield
		varName = TextField(win, Rect(
				10,
				10,
				180,
				20
			)
		).string_("~"++envVar.asString);
		
		// synth name label
		synthLabel = StaticText(win, Rect(
			200,
			10,
			180,
			20
			)
		).string_("Synth:" + synthName.asString);
		
		// action list
		modeMenu = PopUpMenu(win, Rect(
			10,
			40,
			100,
			20
			)
		).items = [
			"new",
			"set",
			"release"
		];
		
		// release time label
		StaticText(win, Rect(
			120,
			40,
			100,
			20
			)
		).string_("release time:");
		
		// release time number box
		releaseTime = NumberBox(win, Rect(
			200,
			40,
			100,
			20
			)
		).value_(1);
		
		this.showScrollView;
		
				
		// generate code
		toCodeButton = Button(win, Rect(
			10,
			270,
			180,
			20
			)
		)
		.states_([
			["Send to CodePool Window", Color.black, Color.green]
		])
		.action_({
			switch(modeMenu.value,
				0, {
					codeBlock = "(\n";
					codeBlock = codeBlock ++ varName.string ++ "= Synth(\"" ++ synthName.asString ++ "\",[\n";
					synthArgs.size.do({ arg i;
						codeBlock = codeBlock ++ "\\" ++ synthArgs[i].asString ++ "," ++ argVal[i].value.asString;
						if(i < (synthArgs.size-1),
						{codeBlock = codeBlock ++",\n"},{codeBlock = codeBlock ++ "\n"});
					});
					codeBlock = codeBlock ++ "]);\n";
					codeBlock = codeBlock ++ ");\n";
					
					parent.codeTextView.string = parent.codeTextView.string ++ "\n" ++ codeBlock;
				},
				1, {
					codeBlock = "(\n";
					codeBlock = codeBlock ++ varName.string ++ ".set(\n";
					synthArgs.size.do({ arg i;
						codeBlock = codeBlock ++ "\\" ++ synthArgs[i].asString ++ "," ++ argVal[i].value.asString;
						if(i < (synthArgs.size-1),
						{codeBlock = codeBlock ++",\n"},{codeBlock = codeBlock ++ "\n"});
					});
					codeBlock = codeBlock ++ ")\n";
					codeBlock = codeBlock ++ ");\n";
					
					parent.codeTextView.string = parent.codeTextView.string ++ "\n" ++ codeBlock;
				},
				2, {
					codeBlock = "(\n";
					codeBlock = codeBlock ++ varName.string ++ ".release(" ++ releaseTime.value ++ ")\n";
					codeBlock = codeBlock ++ ");\n";
					
					parent.codeTextView.string = parent.codeTextView.string ++ "\n" ++ codeBlock;
				}
			)
		});
		
		// clear CodePool window
		clrBut = Button(win, Rect(
			200,
			270,
			180,
			20
			)
		)
		.states_([
			["Cear CodePool Window", Color.black, Color.green]
		])
		.action_({
			parent.codeTextView.string = "";
		});
		
	}
	
	showScrollView {
		// scroll view
		scrollView = ScrollView(win, Rect(
			10,
			80,
			380,
			180
			)
		);
		
		// param editors
		synthArgs.size.do({ arg i;
			// labels
			StaticText(scrollView, Rect(
				0,
				(i*20)+10,
				200,
				20
				)
			).string_(synthArgs[i].asString);
			
			// number boxes
			argVal[i] = NumberBox(scrollView, Rect(
				200,
				(i*20)+10,
				160,
				20
				)
			).value_(tmpCtr[i][3]);
		
		});

	}
}


//XML Score Saving Class

XMLScore {
	var <>path, <>nameList, <>timeList, <>codeList;
	
	*new {arg path;
		^super.newCopyArgs(path).init;
	}
	
	init {
	
	}
	
	*saveXML {arg path, nameList, timeList, codeList;
		var root, doc, file, event, events;
		
		doc = DOMDocument.new;
		root = doc.createElement("Score");
		doc.appendChild(root);

		events = doc.createElement("Events");
		root.appendChild(events);

		nameList.do({ arg code,i;
			var temp;
			event = doc.createElement("Event");
			event.setAttribute( "Sender" , nameList[i].asString );
			event.setAttribute( "Time" , timeList[i].asString );
			temp = doc.createTextNode(codeList[i].asString);
			event.appendChild(temp);
			events.appendChild(event);
		});
		
		file = File(path, "w");
		doc.write(file);
		file.close;
	
	}
	
	
}