DigiClock { 
	var window,font,timenum,numbus,timeroutine,num,view;
	
	*new {	arg argWindow=nil,scale=1,displayColor=nil,moveX=0,moveY=0,fontname="DS-Digital";
			^super.new.init(argWindow,scale,displayColor,moveX,moveY,fontname);
	}
	
	init {	arg argWindow=nil,scale=1,displayColor=nil,moveX=0,moveY=0,fontname="DS-Digital";
			font = Font(fontname,185*scale);
			if(argWindow!=nil,{
				window = argWindow;
				},{
				window = SCWindow.new(
							"DigiClock Timer",
							Rect(0,1000, 411*scale, 275*scale)).front;
				});
			view = FlowView.new(window,Rect(moveX,moveY,411*scale, 275*scale),margin:0@0);
			timenum = SCStaticText.new(view,Rect(0,0,410*scale,195*scale))
				.action_({ arg numb; numb.value.postln })
				.font_(font)
				.string_(0.asTimeString.asArray.copyRange(3,7));
			
			if(displayColor==nil,{
					timenum.background_(Color.new255(0,206,209));
				},{
					timenum.background_(displayColor);
				});
			
			num = 0;
			this.makeTimeRoutine;
			this.makeButtons(view,scale);
	}
	
	start { 
		timeroutine.play(AppClock);	
	}
	
	stop { 
		timeroutine.stop;
		this.makeTimeRoutine;
	}
	reset {
		timeroutine.stop;
		this.makeTimeRoutine;
		num = 0;
		timenum.string_(0.asTimeString.asArray.copyRange(3,7));
	}
	
	close {
		timeroutine.stop; 
		window.close;
	}
	
	makeButtons { arg view,scale;
		var toggle,play;
		toggle = 0;
		play = SCButton.new(view,Rect(0,0,270*scale,70*scale))
				.states_([
					["Start",Color.new255(35,35,35),Color.new255(100,100,100)],
					["Stop",Color.new255(100,100,100),Color.new255(35,35,35)]
					
					])
				.action_({ 
					if(toggle==0,{
							this.start;
							toggle = 1;
						},{
							this.stop;
							toggle = 0;
						}); 
					});
		SCButton.new(view,Rect(0,0,125*scale,70*scale))
			.states_([
				["Reset",Color.new255(150,150,150),Color.new255(0,0,0)]
				])
			.action_({ 
				this.reset;
				toggle = 0;
				play.value_(0);
				});
	}
	
	makeTimeRoutine {
		timeroutine = Routine({
				inf.do({
					|i|
					num = num+1;
					timenum.string_(num.asTimeString.asArray.copyRange(3,7));
					1.wait; });
				});
	}
	
}