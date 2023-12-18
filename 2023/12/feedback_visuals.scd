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

(
w=Window.new("", Rect(0,0,900,900)).front;
v=UserView(w, w.view.bounds.insetBy(0,0));
v.resize = 5;
v.animate = true;
);

(
v.drawFunc={|uview|
	var xy = [0.5,0.5];
	var amp = 1;//~busAmp.getSynchronous;
	var sizex = ~sizex * ((v.frame*0.004).sin.abs);
	var sizey = ~sizey * ((v.frame*0.005).cos.abs);
	Pen.drawImage(Point(~zoom.neg/2,~zoom.neg/2), i, operation: 'sourceOver', opacity: 1.3);
	Pen.push;
	Pen.rotateDeg(v.frame*0.3, v.bounds.width/2, v.bounds.height/2);
	Pen.addRect(Rect(v.bounds.width * 0.5 - (sizex/2), v.bounds.height*0.5 - (sizey/2), sizex, sizey));
	Pen.fillColor = Color.hsv((v.frame*0.002).sin.abs+(sin(v.frame*0.04)*0.15), 0.8+((v.frame*0.03).sin.abs*0.2), 0.9);
	Pen.fill;
	Pen.pop;
};
)



