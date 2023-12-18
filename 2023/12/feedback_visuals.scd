

(
w=Window.new("", Rect(0,0,900,900)).front;
v=UserView(w, w.view.bounds);
v.resize = 5;
v.animate = true;
);

(
v.drawFunc={|uview|
	var xy = [0.5,0.5];
	var amp = 1;//~busAmp.getSynchronous;
	var sizex = ~sizex * ((v.frame*0.004).sin.abs);
	var sizey = ~sizey * ((v.frame*0.005).cos.abs);
	if (i.notNil){
		Pen.drawImage(Point(~zoom.neg/2,~zoom.neg/2), i, operation: 'sourceOver', opacity: 1);
	};
	Pen.push;
	Pen.rotateDeg(v.frame*0.3, v.bounds.width/2, v.bounds.height/2);
	Pen.addRect(Rect(v.bounds.width * 0.5 - (sizex/2), v.bounds.height*0.5 - (sizey/2), sizex, sizey));
	Pen.fillColor = Color.hsv((v.frame*0.002).sin.abs+(sin(v.frame*0.04)*0.15), 0.8+((v.frame*0.03).sin.abs*0.2), 0.9);
	Pen.fill;
	Pen.pop;
};
)

(
~zoom = 30;
~sizex = 60;
~sizey = 60;
Tdef(\updt, { loop {
	if (w.isNil.not) {
		defer {
			i = Image.fromWindow(w);
			i.scalesWhenResized_(true);
			i.setSize((i.width+~zoom).asInteger, (i.height+~zoom).asInteger)
		};
		(1/20).wait;
	}
}
}).play
)




// Visuals with sound

s.waitForBoot { ~busp = Bus.control(s, 4); };

(
z=Window.new("", Rect(0,0,900,900)).front;
u=UserView(z, z.view.bounds);
u.resize = 5;
u.animate = true;
);

(
u.drawFunc={|uview|
	var amp = 1;//~busAmp.getSynchronous;
	var sizex = ~sizex * ~busp.getnSynchronous(2)[0];
	var sizey = ~sizey * ~busp.getnSynchronous(2)[1];
	if (j.notNil){
		Pen.drawImage(Point(~zoom.neg/2,~zoom.neg/2), j, operation: 'sourceOver', opacity: 1);
	};
	Pen.push;
	Pen.rotateDeg(u.frame*~busp.getnSynchronous(3)[2], u.bounds.width/2, u.bounds.height/2);
	Pen.addRect(Rect(u.bounds.width * 0.5 - (sizex/2), u.bounds.height*0.5 - (sizey/2), sizex, sizey));
	Pen.fillColor = Color.hsv((u.frame*0.002).sin.abs+(sin(u.frame*0.04)*0.15), 0.8+((u.frame*0.03).sin.abs*0.2), 0.9);
	Pen.fill;
	Pen.pop;
};
)


(
~zoom = ~busp.getnSynchronous(4)[3];
~sizex = 160;
~sizey = 160;
Tdef(\updt2, { loop {
	if (z.isNil.not) {
		~zoom = ~busp.getnSynchronous(4)[3];
		defer {
			j = Image.fromWindow(z);
			j.scalesWhenResized_(true);
			j.setSize((j.width+~zoom).asInteger, (j.height+~zoom).asInteger)
		};
		(1/20).wait;
	}
}
}).play
)

(
Ndef(\sins, {
	var fb = LocalIn.ar(2).tanh;
	var dens = \dens.kr(10);
	var snd = CombC.ar(PitchShift.ar(fb*\fb.kr(1), 0.2, \pitch.kr(0.8)) + SoundIn.ar([0,1], 0.03) + Dust.ar(dens, 0.4), 0.2, LFNoise1.ar(0.1).range(0.03,0.03));
	LocalOut.ar(LeakDC.ar(snd));
	Out.kr(~busp, [Amplitude.ar(snd, 0.01, 0.7), \pitch.kr, \dens.kr].flatten);
	snd.tanh
}).gui;
)