/*
 * kick drum synthesis with a bit of FM.
 */
(
var w,specs,synthNode;

s.waitForBoot({

	SynthDef(\kick,{ arg out=0,bodyAttTa=0,bodyDecTa=0.5,bodyAttCa=0,bodyDecCa=4.neg,pitchDeviation=200,pitchOffset=50,decTp=0.1,decCp=6.neg,amp=1,bpm=2,doneAct=0,bodyRatio=1,bodyIndex=1,klickModRatio=9,klickModIndex=20,klickRatio=0.1,klickAttT=0,klickDecT=0.005,klickAttC=0,klickDecC=6.neg,bodyAmp=1,klickAmp=0.5,noiseAttT=0,noiseDecT=0.005,noiseAttC=0,noiseDecC=2.neg,noiseAmp=0.7,noiseCutoff=8000,noiseRq=0.8,filterFreq=120,res=0.6,inputGain=1,filteredAmp=1;
		var trig,body,klickMod,klick,bodyAmpEnv,pitchEnv,klickAmpEnv,noiseAmpEnv,noise,filtered;

		trig = Impulse.ar(bpm);
		bodyAmpEnv = EnvGen.ar(Env([0,1,0],[bodyAttTa,bodyDecTa],[bodyAttCa,bodyDecCa]),trig,doneAction:doneAct);
		pitchEnv = EnvGen.ar(Env([0,1,0],[0,decTp],decCp),trig,pitchDeviation,pitchOffset);
		klickAmpEnv = EnvGen.ar(Env([0,1,0],[klickAttT,klickDecT],[klickAttC,klickDecC]),trig);
		noiseAmpEnv = EnvGen.ar(Env([0,1,0],[noiseAttT,noiseDecT],[noiseAttC,noiseDecC]),trig,noiseAmp);

		body = SinOsc.ar(pitchEnv,SinOsc.ar(pitchEnv*bodyRatio,0,bodyIndex*bodyAmpEnv,0.25pi),bodyAmpEnv);
		klickMod = SinOsc.ar(pitchEnv*klickModRatio,0,klickModIndex,0.25pi);
		klick = (SinOsc.ar(pitchEnv*klickRatio,klickMod,klickAmpEnv) + SinOsc.ar(pitchEnv*klickRatio*8,klickMod,klickAmpEnv*0.125));
		noise = BLowPass.ar(WhiteNoise.ar,noiseCutoff,noiseRq,noiseAmpEnv);
		filtered = DFM1.ar(body + klick,filterFreq,res,inputGain,0,0.0003,filteredAmp);

		Out.ar(out,(body*bodyAmp + (klick*klickAmp) + noise + filtered)*amp!2)
	}).add;

	{ s.scope(2) }.defer

});

specs = [
	(name:\bodyAttTa,spec:ControlSpec(0,1,2,0.001,0)),
	(name:\bodyDecTa,spec:ControlSpec(0,2,2,0.001,0.5)),
	(name:\bodyAttCa,spec:ControlSpec(-12,12,\lin,0.01,0)),
	(name:\bodyDecCa,spec:ControlSpec(-12,12,\lin,0.01,-4)),
	(name:\pitchDeviation,spec:ControlSpec(0,500,2,1,200)),
	(name:\pitchOffset,spec:ControlSpec(30,300,2,1,50)),
	(name:\decTp,spec:ControlSpec(0,2,2,0.001,0.1)),
	(name:\decCp,spec:ControlSpec(-12,12,\lin,0.01,-6)),
	(name:\bodyRatio,spec:ControlSpec(0,20,\lin,0.01,1)),
	(name:\bodyIndex,spec:ControlSpec(0,15,2,0.01,1)),
	(name:\bodyAmp,spec:ControlSpec(0,1,2,0.001,1)),
	(name:\klickAttT,spec:ControlSpec(0,0.1,2,0.001,0)),
	(name:\klickDecT,spec:ControlSpec(0.001,0.1,2,0.001,0.005)),
	(name:\klickAttC,spec:ControlSpec(-12,12,\lin,0.01,0)),
	(name:\klickDecC,spec:ControlSpec(-12,12,\lin,0.01,-6)),
	(name:\klickRatio,spec:ControlSpec(0,20,\lin,0.01,0.1)),
	(name:\klickModRatio,spec:ControlSpec(0,20,\lin,0.01,9)),
	(name:\klickModIndex,spec:ControlSpec(0,50,2,0.01,20)),
	(name:\klickAmp,spec:ControlSpec(0,1,2,0.001,0.5)),
	(name:\noiseAttT,spec:ControlSpec(0,0.2,2,0.001,0)),
	(name:\noiseDecT,spec:ControlSpec(0,0.4,2,0.001,0.005)),
	(name:\noiseAttC,spec:ControlSpec(-12,12,\lin,0.01,0)),
	(name:\noiseDecC,spec:ControlSpec(-12,12,\lin,0.01,-2)),
	(name:\noiseCutoff,spec:ControlSpec(20,12000,\exp,1,8000)),
	(name:\noiseRq,spec:ControlSpec(0.001,1,\lin,0.001,0.8)),
	(name:\noiseAmp,spec:ControlSpec(0,1,2,0.001,0.7)),
	(name:\filterFreq,spec:ControlSpec(40,14000,\exp,1,120)),
	(name:\res,spec:ControlSpec(0,15,2,0.01,0.6)),
	(name:\inputGain,spec:ControlSpec(1,100,\lin,0.01,1)),
	(name:\filteredAmp,spec:ControlSpec(0,1,2,0.001,1)),
	(name:\amp,spec:ControlSpec(0,1,\lin,0.001,1))
];

w = Window(\kick,Rect(0,0,400,200)).layout_(
	VLayout(
		HLayout(
			[NumberBox().value_(0).maxWidth_(40).align_(\right).clipLo_(0).decimals_(0).scroll_step_(1).action_({ arg numb;
				synthNode.isNil.not.if { s.sendMsg('/n_set',synthNode,\out,numb.value) }
			}),a:\left],
			[StaticText().maxWidth_(40).string_("out"),a:\left],
			nil
		),

		Button().states_([["start",Color.black,Color.green],["stop",Color.black,Color.red]]).maxWidth_(80).action_({ arg butt;
			(butt.value == 0).if {
				s.sendMsg('/n_free',synthNode);
				synthNode = nil
			} {
				synthNode = s.nextNodeID;
				s.sendBundle(nil,
					['/s_new',\kick,synthNode,0,1] ++ (specs collect: { |spec| [spec.name,spec.spec.default] }).flatten
				)
			}
		}),

		GridLayout.rows(
			*(specs collect: { |spec|
				var slider,numbox,c = spec.spec.step;
				slider = Slider().orientation_(\horizontal).value_(spec.spec.unmap(spec.spec.default)).action_({ arg slider;
					synthNode.isNil.not.if { s.sendMsg('/n_set',synthNode,spec.name,spec.spec.map(slider.value)) };
					numbox.value_(spec.spec.map(slider.value));
					spec.spec.default_(spec.spec.map(slider.value))
				});
				numbox = NumberBox().value_(spec.spec.default).maxWidth_(50).action_({ arg numb;
					synthNode.isNil.not.if { s.sendMsg('/n_set',synthNode,spec.name,numb.value) };
					slider.value_(spec.spec.unmap(numb.value));
				}).minDecimals_((c < 0).if { c.abs + 1 } { 0 }).scroll_step_(spec.spec.step).clipLo_(spec.spec.minval).clipHi_(spec.spec.maxval);
				[
					StaticText().string_(spec.name).font_(Font("Monaco",12)),
					slider,
					numbox
				]
			})
		).vSpacing_(2)
	)
).onClose_({
	synthNode.isNil.not.if { s.sendMsg('/n_free',synthNode) }
}).front
)