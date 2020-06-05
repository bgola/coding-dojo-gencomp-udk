(

// Function to create a new object representing the
// DMX configuration of the mhx25 moving head.
~mhx25 = {
	(
		internal_values: [0,0,0,0,0,0,0,1,0,0,0,0],

		colorDict:(
			white: 0,
			yellow: 5,
			pink: 10,
			green: 15,
			violet: 20,
			lightBlue: 25,
			yellowGreen: 30,
			red: 35,
			darkBlue: 40,
		),

		goboDict:(
			redDot: 8,
			crystal: 16,
			storm: 24,
			chain: 32,
			hazard: 40,
			david: 48,
			milky: 56,
			milkyShake: 64, // missing: shakes
		),

		// Angle for X axis (panning) from 0 to 540
		rotX: {|self, angle|
			self.internal_values[0] = angle.linlin(0, 540, 0, 1);
		},

		// Angle for Y axis (tilt) from 0 to 270
		rotY: {|self, angle|
			self.internal_values[1] = angle.linlin(0, 270, 0, 1);
		},

		rotSpeed: {|self, speed|
			self.internal_values[4] = speed.linlin(0, 100, 1, 0);
		},


		fineX: {|self, value|
			self.internal_values[2] = value.linlin(0, 100, 0, 1);
		},

		fineY: {|self, value|
			self.internal_values[3] = value.linlin(0, 100, 0, 1);
		},

		color: {|self, colorName|
			self.internal_values[5] = self.colorDict[colorName].linlin(0, 255, 0, 1);
		},


		shutterOpen: {|self|
			self.internal_values[6] = 5.linlin(0, 255, 0, 1);
		},

		shutterClose: {|self|
			"turning off".postln;
			self.internal_values[6] = 0.linlin(0, 255, 0, 1);
		},
		dim: {|self, value|
			self.internal_values[7] = value.linlin(0, 100, 0, 1);
		},
		// speed between 0-100, strobe effect
		shutter: {|self, speed|
			var sspeed = speed.linlin(0, 100, 15, 182);
			self.internal_values[6] = sspeed.linlin(8, 215, 0, 1);
		},


		gobo: {|self, goboName|
			self.internal_values[8] = self.goboDict[goboName].linlin(0, 255, 0, 1);
		},

		goboOff: {|self|
			self.internal_values[8] = 0;
		},

		goboRot: {|self, value|
			self.internal_values[9] = value.linlin(0, 255, 0, 1);
		},

		rainbow: {|self, speed|
			// 128-191
			var sspeed = speed.linlin(0, 100, 128, 191);
			self.internal_values[5] = sspeed.linlin(0, 255, 0, 1);
		},
	)
};

// Function to create a new object representing the
// DMX configuration of a par64 LED Light
~par64 ={
	(
		internal_values: [0, 0, 0, 0, 0, 0, 1],

		red: {|self,dimRed|
			self.internal_values[0] = dimRed.linlin(0, 255, 0, 1);
		},
		green: {|self,dimGreen|
			self.internal_values[1] = dimGreen.linlin(0, 255, 0, 1);
		},
		blue: {|self,dimBlue|
			self.internal_values[2] = dimBlue.linlin(0, 255, 0, 1);
		},
		color: {|self, red, green, blue|
			self.red(red);
			self.green(green);
			self.blue(blue);
		},
		macro: {|self,dimMacro|
			self.internal_values[3] = dimMacro.linlin(0, 15, 0, 1);
		},
		strobe: {|self,sStrobe|
			var sspeed = sStrobe.linlin(0, 255, 15, 255);
			self.internal_values[4] = sspeed.linlin(0, 255, 0, 1);
		},
		dim: {|self,dimMaster|
			self.internal_values[6] = dimMaster.linlin(0, 255, 0, 1);
		},
)};

~fog = {
	(
		internal_values: [0],
		fog: {|self, value| self.internal_values[0] = value};
	);
};

// Creates two mhx25 objects
~mhx25_1 = ~mhx25.value();
~mhx25_2 = ~mhx25.value();
~globalHue = 0.4;
/*~mhx25_2.rotX = {|self, angle|
	self.internal_values[0] = angle.linlin(0, 540, 1, 0);
};

~mhx25_2.rotY= {|self, angle|
	self.internal_values[1] = angle.linlin(0, 270, 1, 0);
};*/

// Creates five par64 objects
~par64_1 = ~par64.value();
~par64_2 = ~par64.value();
~par64_3 = ~par64.value();
~par64_4 = ~par64.value();
~par64_5 = ~par64.value();
~par64_6 = ~par64.value();
~par64_7 = ~par64.value();
~par64_8 = ~par64.value();
~pars = [~par64_1,~par64_2,~par64_4,~par64_5,~par64_3,~par64_6,~par64_7,~par64_8];
~pars8 = [~par64_1,~par64_2,~par64_3,~par64_4,~par64_5,~par64_6, ~par64_4];

~mhxs = [~mhx25_1,~mhx25_2];

~parg1 = [~par64_1,~par64_2,~par64_3];
~parg2 = [~par64_4,~par64_5,~par64_6];
~fog1 = ~fog.value;

// This function creates an object that represents the Enttec DMX USB Pro
// device, it keeps track of all DMX devices connected.
//
// To use it you only need to instantiate once the controller passing
// all DMX devices (as defined above, or simply implementing the internal_values
// attribute), and call the .send method when you want to update the values.
~dmx_controller = { |port, devs|
	var channels = devs.collect {|dev| dev.internal_values.size}.sum;
	"Number of channels: ".post; channels.postln;
	(
		dmx: EnttecDMX.new(port, channels),
		objs: devs,

		send: {|self|
			var values = [];
			self.objs.do {|obj|
				values = values ++ obj.internal_values;
			};
			self.dmx.sendDMX(*values)
		},
	)
};

// On mac os X this is the port usually:

~port1 = "/dev/tty.usbserial-EN225291";
~port2 = "/dev/ttyUSB0";
~port = "";
if(File.exists(~port1), {~port = ~port1; 1.postln;},{~port = ~port2; 2.postln;});

// Here we create a controller with the objects instantiated in the block above.
//~controller = ~dmx_controller.value(~port, [~mhx25_1, ~mhx25_2, ~par64_1, ~par64_2, ~par64_3, ~par64_4, ~par64_5, ~par64_6]);
//~controller = ~dmx_controller.value(~port, [~mhx25_1, ~mhx25_2]);
//~controller = ~dmx_controller.value(~port, [~mhx25_1, ~mhx25_2, ~par64_1,~par64_2,~par64_3,~par64_4,~par64_5, ~par64_6]);
~controller = ~dmx_controller.value(~port, [~par64_1,~par64_2,~par64_3,~par64_4,~par64_5, ~par64_6, ~mhx25_1, ~mhx25_2,~par64_7,~par64_8, ~fog1]);


// OOOOSSSSSSCCCCCC receive values via touchosc
OSCFunc.trace(false);

~globalXoffset = 0;
~globalYoffset = 0;

OSCdef(\speedReceiver,
{|msg, time, addr, recvPort|
		~mhx25_1.rotSpeed(msg[1]*100);
		~mhx25_2.rotSpeed(msg[1]*100);
		~controller.send;
}, '/1/speedFader');


OSCdef(\Dy,
{|msg, time, addr, recvPort|
		var ox = rrand(~globalXoffset.neg, ~globalXoffset);
		var oy = rrand(~globalYoffset.neg, ~globalYoffset);
		~mhx25_1.rotY(msg[1]*270);
		~mhx25_2.rotY(msg[1]*270 + oy);
		~controller.send;
}, '/oscControl/slider2Dy');

OSCdef(\Dx,
{|msg, time, addr, recvPort|
		var ox = rrand(~globalXoffset.neg, ~globalXoffset);
		var oy = rrand(~globalYoffset.neg, ~globalYoffset);
		~mhx25_1.rotX(msg[1]*540);
		~mhx25_2.rotX(msg[1]*540 + oy);
		~controller.send;
}, '/oscControl/slider2Dx');

OSCdef(\onoff,
{|msg, time, addr, recvPort|
		if (msg[1] == 1, {
			~mhx25_1.shutterOpen;
			~mhx25_2.shutterOpen;
		}, {
			~mhx25_1.shutterClose;
			~mhx25_2.shutterClose;
		});
		~controller.send;
}, '/oscControl/toggle1');

OSCdef(\dim,
{|msg, time, addr, recvPort|
		~mhx25_1.dim(msg[1]*100);
		~mhx25_2.dim(msg[1]*100);
		~controller.send;
}, '/oscControl/slider1');

OSCdef(\hue,
{|msg, time, addr, recvPort|
		var hue, colors;
		colors = [\red, \yellow, \yellowGreen, \green, \lightBlue, \darkBlue, \violet, \pink];
		~globalHue = msg[1];
		hue = (~globalHue*8).abs;
		~mhxs.do {|m| m.color(colors[hue])};
}, '/oscControl/slider2');

OSCdef(\strobe,
{|msg, time, addr, recvPort|
		~pars.do{|par|par.strobe(msg[1]*255)};
		~controller.send;
}, '/oscControl/slider3');

OSCdef(\blue,
{|msg, time, addr, recvPort|
		~mhx25_1.blue(msg[1]*255);
		~mhx25_2.blue(msg[1]*255);
		~controller.send;
}, '/oscControl/slider4');

OSCdef(\xyReceiver,
{|msg, time, addr, recvPort|
		var ox = rrand(~globalXoffset.neg, ~globalXoffset);
		var oy = rrand(~globalYoffset.neg, ~globalYoffset);
		~mhx25_1.rotX(msg[1]*360);
		~mhx25_1.rotY(msg[2]*270);
		~mhx25_2.rotX(msg[1]*360 + ox);
		~mhx25_2.rotY(msg[2]*270 + oy);
		~controller.send;
}, '/1/xy1');

OSCdef(\toggleSequence1,
{|msg, time, addr, recvPort|
		if(msg[1] == 1.0, {Tdef(\explorer).play;}, {Tdef(\explorer).stop;});
		if(msg[1] == 1.0, {Tdef(\parmove).play;}, {Tdef(\parmove).stop;});
}, '/1/toggle3');

OSCdef(\onOff,
{|msg, time, addr, recvPort|
		if(msg[1] == 1.0, {~mhx25_1.shutterOpen;}, {~mhx25_1.shutterClose;});
		if(msg[1] == 1.0, {~mhx25_2.shutterOpen;}, {~mhx25_2.shutterClose;});
		~controller.send;
}, '/1/toggle1');

OSCdef(\shutter,
{|msg, time, addr, recvPort|
		if(msg[1] == 1.0, {~mhx25_1.shutter(100);}, {~mhx25_1.shutter(50);});
		if(msg[1] == 1.0, {~mhx25_2.shutter(100);}, {~mhx25_2.shutter(50);});
		~controller.send;
}, '/1/toggle2');

OSCdef(\whiteButton,
{|msg, time, addr, recvPort|
		~mhx25_1.color(\white);
		~mhx25_2.color(\white);
		~controller.send;
}, '/1/push1');

OSCdef(\pinkButton,
{|msg, time, addr, recvPort|
		~mhx25_1.color(\pink);
		~mhx25_2.color(\pink);
		~controller.send;
}, '/1/push2');

OSCdef(\xoffsetslider,
{|msg, time, addr, recvPort|
		~globalXoffset = msg[1] + 90;
}, '/1/xoffset');

OSCdef(\yoffsetslider,
{|msg, time, addr, recvPort|
		~globalYoffset = msg[1] + 90;
}, '/1/yoffset');
);

~globalDim = 5;

(
Tdef(\parmove, {
	var delay = 5.0;
	loop {

		~pars8.do {|par,i|
			//par.dim(~globalDim);
			//par.green(255.rand); par.red(255.rand); par.blue(255.rand);
			par.green(255); par.red(0); par.blue(0);
			~controller.send;
			delay.wait;
			par.green(0); par.red(0); par.blue(0);
			delay = delay - 0.3;
			if(delay < 0.05, {delay = 0.05;},{});
		}
	};
});
);


Tdef(\rgb, {
	~parg1[0].color(255, 0, 0);
	~parg2[0].color(255, 0, 0);

	~parg1[1].color(0, 255, 0);
	~parg2[1].color(0, 255, 0);

	~parg1[2].color(0, 0, 255);
	~parg2[2].color(0, 0, 255);

	~controller.send;
});

Tdef(\rgbStrobe, {
	~parg1[0].color(255, 0, 0);
	~parg2[0].color(255, 0, 0);

	~parg1[1].color(0, 255, 0);
	~parg2[1].color(0, 255, 0);

	~parg1[2].color(0, 0, 255);
	~parg2[2].color(0, 0, 255);

	~pars.do { |p| p.strobe(rrand(93,98)) };
	~controller.send;
}).stop;

Tdef(\rgbRotate, {
	inf.do {|i|
 		~parg1[i%3].color(255, 0, 0);
		~parg2[i%3].color(255, 0, 0);

		~parg1[(i+1)%3].color(0, 255, 0);
		~parg2[(i+1)%3].color(0, 255, 0);

		~parg1[(i+2)%3].color(0, 0, 255);
		~parg2[(i+2)%3].color(0, 0, 255);

		~controller.send;
		1.wait;
	}
}).stop;

Tdef(\rgbFadeGroups, {
	inf.do {|i|
		var c;
		c = Color.hsv((i%40).linlin(0, 39, 0, 1), 1, 1);
		~parg1[0].color(
			c.red.linlin(0,1,0,255),
			c.green.linlin(0,1,0,255),
			c.blue.linlin(0,1,0,255));
		~parg2[0].color(
			c.red.linlin(0,1,0,255),
			c.green.linlin(0,1,0,255),
			c.blue.linlin(0,1,0,255));

		c = Color.hsv(((i+2)/40.0) % 1, 1, 1);
		~parg1[1].color(
			c.red.linlin(0,1,0,255),
			c.green.linlin(0,1,0,255),
			c.blue.linlin(0,1,0,255));
		~parg2[1].color(
			c.red.linlin(0,1,0,255),
			c.green.linlin(0,1,0,255),
			c.blue.linlin(0,1,0,255));

		c = Color.hsv(((i+4)/40.0) % 1, 1, 1);
 		~parg1[2].color(c.red.linlin(0,1,0,255), c.green.linlin(0,1,0,255), c.blue.linlin(0,1,0,255));
		~parg2[2].color(c.red.linlin(0,1,0,255), c.green.linlin(0,1,0,255), c.blue.linlin(0,1,0,255));

		~controller.send;
		0.1.wait;
	}
});

Tdef(\rgbFadeColor, {
	inf.do {|i|
		var c;
		~pars.do {|par, j|
			c = Color.hsv(((i+(j*2))/40.0) % 1, 1, 0.5, 1);

			par.color(
				c.red.linlin(0,1,0,255),
				c.green.linlin(0,1,0,255),
				c.blue.linlin(0,1,0,255));
		};
		~controller.send;
		0.05.wait;
	}
});


Tdef(\rgbHueOscillate, {
	loop {
		~globalHue = (~globalHue + 0.0005) % 0.999;
		~globalHue.postln;
		0.05.wait;
	};
}).stop;

(
Tdef(\rgbFade8, {
	var sp = rrand(60, 100);
	//Tdef(\rgbHueOscillate).play;
	inf.do {|i|
		var c1 = Color.hsv(
			~globalHue, 1, 1 - ((i%sp)/(sp-1)));
		var c2 = Color.hsv(
			~globalHue, 1, ((i%sp)/(sp-1)));

		~pars8[(i/sp)%7].color(
			c1.red*255, c1.green*255, c1.blue*255);
		~pars8[((i/sp)+1)%7].color(
			c2.red*255, c2.green*255, c2.blue*255);
		~controller.send;
		0.01.wait;
	}
}).stop;
);

(
Tdef(\rgbFade111, {
	var sp = rrand(500, 100);
	//Tdef(\rgbHueOscillate).play;
	inf.do {|i|
		var c1 = Color.hsv(
			~globalHue, 1, 1 - ((i%sp)/(sp-1)));
		var c2 = Color.hsv(
			~globalHue, 1, ((i%sp)/(sp-1)));

		~pars[(i/sp)%8].color(
			c1.red*255, c1.green*255, c1.blue*255);
		~pars[((i/sp)+1)%8].color(
			c2.red*255, c2.green*255, c2.blue*255);
		~controller.send;
		0.01.wait;
	}
}).stop;
);

(
Tdef(\rgbFadeSametime111, {
	var sp = rrand(30, 10);
	loop {
		127.do { |j|
			var shade = j * 2;
			~pars.do {|par,i|
				var c1 = Color.hsv(
					~globalHue, 1, 1 - (shade/255));
				par.color(c1.red*255, c1.green*255, c1.blue*255);
			};
			~controller.send;
			0.01.wait;
		};
		127.do { |j|
			var shade = 255 - (j * 2);
			~pars.do {|par,i|
				var c1 = Color.hsv(
					~globalHue, 1, 1 - (shade/255));
				par.color(c1.red*255, c1.green*255, c1.blue*255);
			};
			~controller.send;
			0.01.wait;
		}
	};

}).stop;
);

~possibleHues = [ 0.96, 0.4, 0, 0.666, 1 ];

(
Tdef(\rgbPickOneFollow111, {
	var leader_color = ~possibleHues.choose;
	loop {
		var leader = ~pars.choose;
		var others = ~pars.reject {|par| par == leader };
		var others_color = leader_color;
		leader_color = ~possibleHues.choose;
		127.do { |j|
			var shade = j * 2;
			var cl = Color.hsv(leader_color, 1, 1-(shade/255));
			others.do {|par,i|
				var c1 = Color.hsv(
					others_color, 1, 1 - (shade/255));
				par.color(c1.red*255, c1.green*255, c1.blue*255);
			};
			leader.color(cl.red*255, cl.green*255, cl.blue*255);
			~controller.send;
			0.05.wait;
		};
	};
}).stop;
);


(
Tdef(\rgbChange111Color, {
	~possibleHues = [ 0.96, 0.4, 0, 0.666, 1 ];
	inf.do {
		~globalHue = ~possibleHues.choose;
		rrand(100.0, 240.0).wait;
	};
}).stop;
);

~globalHue=0.96;





// 1000.collect{|i|120-((i*0.01 + ((2*5)*0.1)).sin.abs*120)}.plot

Tdef(\rgbFadeGreen, {
	inf.do {|i|
		var c;
		~pars.do {|par,j|
			par.color(0, 120-((i*0.01 + ((j)*0.1)).sin.abs*120), 0);
		};
		~controller.send;
		0.05.wait;
	}
});

~globalHue = 0.5;
Tdef(\rgbFadeColors, {
	inf.do {|i|
		var c;
		~pars.do {|par,j|
			c = Color.hsv(~globalHue, 1.0, (1-((i*0.01 + ((j)*0.3)).sin).abs));
			par.color(c.red * 255, c.green * 255, c.blue * 255);
		};
		~controller.send;
		0.05.wait;
	}
}).stop;

Tdef(\dialog, {
	loop {
		~mhx25_1.dim(5);
		~mhx25_2.dim(5);
		10.do {
			~mhx25_1.rotX([rrand(0, 200), rrand(340, 540)].choose);
			~mhx25_1.rotY([rrand(0, 100), rrand(170, 270)].choose);
			~mhx25_1.shutter(10.rand);
			~mhx25_2.rotX(540.rand);
			~mhx25_2.rotY(270.rand);
			~mhx25_2.shutter(10.rand);
			~controller.send;
			rrand(0.2,3.0).wait;
		};

		/*~mhx25_1.rotX(270);
		~mhx25_1.rotY(135);
		~mhx25_2.rotX(270);
		~mhx25_2.rotY(135);
		*/

		~controller.send;
		1.wait;
		~mhx25_1.shutter(rrand(89, 95));
		~mhx25_2.shutter(rrand(89, 95));
		~controller.send;
		rrand(1,6).wait;
		~mhx25_1.shutterClose.value;
		~mhx25_2.shutterClose.value;
		~controller.send;
		rrand(10, 60).wait;
	};
}).stop;


Tdef(\pargroups, {
	100.do {|i|
		~parg1.do {|par|
			par.color(0, 255, 0);
		};
		~controller.send;
		((100-i)/140.0).wait;
		~parg1.do {|par|
			par.color(0, 0, 0);
		};
		~parg2.do {|par|
			par.color(0, 255, 0);
		};
		~controller.send;
		((100-i)/140.0).wait;
		~parg2.do {|par|
			par.color(0, 0, 0);
		};
		~controller.send;
	}
});


(
Tdef(\explorer, {
	i = 0;
	while ( { i < 27 },
	{
			var z;
			z = if ((i % 2) == 0, { 0 },{ 540 });
			if (i > 10, { ~mhx25_1.shutterOpen; },{});
			if (i > 20, { ~mhx25_1.shutterClose; },{});
			if (i > 10, { ~mhx25_2.shutterOpen; },{});
			if (i > 20, { ~mhx25_2.shutterClose; },{});
			~mhx25_1.rotSpeed(i * 4);
			~mhx25_1.rotX(z);
			~mhx25_1.rotY(i * 10);
			~mhx25_2.rotSpeed(i * 4);
			~mhx25_2.rotX(z);
			~mhx25_2.rotY(i * 10);
			~controller.send;
			2.5.wait;
			i = i+1;
	});

}).stop;
);

(
Tdef(\mhxdance, {
	// a couple of sequences, independent and independent after each other
	var delay = 10;
	loop {
		~mhxs.do {|mhx|
			mhx.rotX(0);
			mhx.rotY(0);
			mhx.rotSpeed(100);
			~controller.send;
		};
		delay.wait;
		~mhxs.do {|mhx|
			mhx.rotX(360);
			~controller.send;
		};
		delay.wait;
		~mhxs.do {|mhx|
			mhx.rotY(270);
			~controller.send;
		};
		delay.wait;

		i = 0;
		while({i < 5},
			{
				~mhxs.do {|mhx|
					mhx.rotX(540.rand);
					mhx.rotY(270.rand);
				};

				~controller.send;
				delay.wait;
				i = i+1;
			};
		);
		i = 0;
		while({i < 5},
			{
				var randx = 540.rand;
				var randy = 270.rand;
				~mhxs.do {|mhx|
					mhx.rotX(randx);
					mhx.rotY(randy);
				};
				~controller.send;
				delay.wait;
				i = i+1;
			};
		);
	};
}).stop;
);

OSCdef(\fader4,
{|msg, time, addr, recvPort|
		Tdef(\test1).set(\speed, msg[1]);
		Tdef(\test1).set(\rotx, msg[1]);
		Tdef(\test1).set(\roty, msg[1]);
		Tdef(\test1).play;
}, '/1/fader4');

Tdef(\perfMode, {
	"Starting performance mode...".postln;
	Tdef.all.reject({|t| t.key == \perfMode}).do { |t| t.stop; };
	1.wait;
	6.do {
		"... next player".postln;
		Tdef.all.reject({|t| t.key == \perfMode}).do { |t| t.stop; };
		0.2.wait;
		~mhxs.do { |m| m.shutterOpen; m.dim(100); };
		Tdef(\startTheAlarm).play;
		Tdef(\movingHeadsGoNuts).play;
		6.wait;
		Tdef(\startTheAlarm).stop;
		Tdef(\movingHeadsGoNuts).stop;
		~globalHue = rrand(0.0, 0.99999);
		Tdef(~ledmodes.choose).play;
		~mhxs.do { |m| m.shutterOpen; m.dim(100); m.color(\white); };
		((60 * 3)-6).wait;
		Tdef(\dialog).stop;
	};
	Tdef(\startTheAlarm).play;
	Tdef(\movingHeadsGoNuts).play;
	6.wait;
	Tdef(\startTheAlarm).stop;
	Tdef(\movingHeadsGoNuts).stop;
	1.wait;
	"And we are done!!!!".postln;
	Tdef(\black).play;
});


Quant.default.quant = nil;

Tdef(\startTheAlarm, {
	var c, hue;
	var colors = [\red, \yellow, \yellowGreen, \green, \lightBlue, \darkBlue, \violet, \pink];

	~pars.do {|par|
		par.strobe(rrand(215, 255));
		c = [Color(rrand(125, 255), 0, 0), Color(0, rrand(125, 255), 0)].choose;
		par.color(c.red, c.green, c.blue);
	};
	~mhx25_1.color(\red);
	~mhx25_2.color(\green);
	~controller.send;

	5.wait;
	~pars.do {|par|
		par.strobe(0);
	};
	hue = (~globalHue*8).abs;
	~mhxs.do {|m| m.color(colors[hue])};
	~controller.send;
});

Tdef(\movingHeadsGoNuts, {
	loop {
		~mhxs.do {|m|
			m.shutterOpen;
			m.rotSpeed(100);
			m.rotX(rrand(0, 100));
			m.rotY(rrand(0, 50));
		};
		rrand(1, 2.4).wait;
		~controller.send;
		~mhxs.do {|m|
			m.rotSpeed(100);
			m.rotX(rrand(440, 540));
			m.rotY(rrand(220, 270));
		};
		rrand(0.4, 1.4).wait;
		~controller.send;
	};
}).stop;

Tdef(\black, {
	Tdef.all.do {|t| t.stop };
	~pars.do {|p|p.color(0,0,0)};
	~mhxs.do {|m|m.rotX(540 / 2); m.rotY(270/2); m.shutterOpen; m.color(\white); m.shutter(rrand(50,70))};
	~controller.send;
});

(
Tdef(\tryingToBeOrganic).set(\repeats, 4);

Tdef(\tryingToBeOrganic, {|envir|
	envir.repeats.do {
		var y = 170+ rrand(-50, 50); //rrand(0, 250);
		var x = 360+ rrand(-50, 50); // rrand(60+100, 60-100);
		var x2 = x + rrand(-15, 15);
		var y2 = y + rrand(-15, 15);

		//~mhx25_1.shutterOpen;
		//~mhx25_1.color(~mhx25_1.colorDict.keys.choose);

		~mhx25_1.rotX(x);
		~mhx25_1.rotY(y);
		~mhx25_2.rotX(x2);
		~mhx25_2.rotY(y2);
		//1.wait;
		100.rand.do {|i|
			var sinX = (i*1).sin;
			var sinY = (i*1.2).sin;
			if (0.1.coin, { x = rrand(360+100, 360-100); });
			//~mhx25_1.color(\green);

			//~mhx25_2.color(\red);
			~mhx25_1.rotX(360 + (sinY*50).asInt) ;
			~mhx25_1.rotY(y+ (sinX*34).asInt);
			~mhx25_2.rotX(360 + (sinY*50).asInt) ;
			~mhx25_2.rotY(y2+ (sinX*34).asInt);

			//~mhx25_1.rotY(y.gauss(10));
			//~mhx25_1.rotX(x.gauss(10));*/

		//~mhx25_1.gobo(~mhx25_2.goboDict.keys.choose);
		//~mhx25_2.gobo(~mhx25_2.goboDict.keys.choose);
			~controller.send;
			0.4.rand.wait;
		};
		~mhx25_1.shutterClose; ~controller.send;
		10.rand.wait;
	};
});
);

(
Tdef(\ping, {
	"starting ping".postln;
	~pars.do {|l|
		l.red(255); l.green(255); l.blue(255);
	};
	~mhxs.do {|l|
		l.rotX(255.rand);
		l.rotY(255.rand);
		l.shutterOpen;
	};
	~controller.send;
	1.wait;
	"now turn it off".postln;
	~pars.do {|l|
		l.color(0,0,0);
	};
	~mhxs.do {|l|
		l.rotX(0);
		l.rotY(0);
		l.shutterClose;
	};
	~controller.send;
}).play;
);

Tdef(\fog, {
	loop {
		~fog1.fog(0);
		rrand(60*3.0, 60*6).wait;
		~fog1.fog(rrand(0.5, 1.0));
		rrand(60*3, 60*6).wait;
	};
}).play;
Tdef.all.do {|t| t.stop};
~globalHue = 0.95;


(
Tdef(\rot, {
	inf.do { |i|
		~mhxs.do { |m|
			m.shutterOpen;
			//m.color(m.colorDict.keys.choose);
			m.rotX(270.rand);
			m.rotSpeed(5);

			m.rotY(53+50.rand);
			m.gobo(\redDot); //);m.goboDict.keys.choose.postln);
			//m.gobo(m.goboDict.keys.choose.postln);
			m.goboRot([68, 152][i%2]);
			m.shutterOpen;
			m.dim(60);
		};
		if (0.3.coin, {
			~mhx25_1.rotY(57 + rrand(-50, 50));
			~mhx25_1.rotX(353 + rrand(-50, 50));
		}, {
			~mhx25_1.color(\violet);
			~mhx25_1.rotY(57);
			~mhx25_1.rotX(353);
		});

		if (0.3.coin, {
			~mhx25_2.rotY(42 + rrand(-50, 50));
			~mhx25_2.rotX(45 + rrand(-50, 50));
		}, {
			~mhx25_2.color(\darkBlue);
			~mhx25_2.rotY(42);
			~mhx25_2.rotX(45);
		});

		~controller.send;
		6.wait;
	}
}).play;
);

//~ledmodes = [\rgbFadeColors, \rgbFade8, \rgbStrobe];
~ledmodes = [\rgbPickOneFollow111, \rgbFadeSametime111, \rgbFade111];
~modes = [\explorer, \tryingToBeOrganic, \mhxdance, \dialog, \ping];
Tdef(\master, {
	var mode = ~ledmodes.choose;
	2.wait;
	loop {
		//~mhxs.do {|l| l.dim(~globalDim) }; ~controller.send;
		Tdef(mode).stop;
		mode = ~ledmodes.choose;
		("New mode is: " ++ mode).postln;
		//Tdef(mode).set(\repeats, 10.rand);
		Tdef(mode).play;
		"Waiting for .... ".post;
		(100 + 100.rand).postln.wait;
	};
}).play;

Tdef(\parOrder, {
	var color;
	~pars.do {|par|
		par.color(0,0,0);

		~controller.send;
	};
	10.do {
		~pars.do {|par|
			par.color(255, 0, 0);
			~controller.send;
			0.5.wait;
			par.color(0, 0, 0);
		};
	};
});