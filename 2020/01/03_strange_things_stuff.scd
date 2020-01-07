(

// Function to create a new object representing the
// DMX configuration of the mhx25 moving head.
~mhx25 = {
	(
		internal_values: [0,0,0,0,0,0,0,0,0,0,0,0],

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


		on: {|self|
			self.internal_values[6] = 5.linlin(0, 255, 0, 1);
		},

		off: {|self|
			self.internal_values[6] = 2.linlin(0, 255, 0, 1);
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


// Creates two mhx25 objects
~mhx25_1 = ~mhx25.value();
~mhx25_2 = ~mhx25.value();

// Creates five par64 objects
~par64_1 = ~par64.value();
~par64_2 = ~par64.value();
~par64_3 = ~par64.value();
~par64_4 = ~par64.value();
~par64_5 = ~par64.value();
)


(
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
//~port = "/dev/tty.usbserial-EN225291";
//
// On GNU/Linux it is:
~port = "/dev/ttyUSB0";

// Here we create a controller with the objects instantiated in the block above.
//~controller = ~dmx_controller.value(~port, [~mhx25_1, ~mhx25_2, ~par64_1, ~par64_2, ~par64_3, ~par64_4, ~par64_5]);
~controller = ~dmx_controller.value(~port, [~mhx25_1, ~mhx25_2]);
)



(
~par64_1.green(255);
~par64_1.red(150);

~par64_2.red(150);
~par64_2.blue(150);
~par64_3.blue(200);
~par64_4.red(50);
~par64_4.blue(150);
~par64_1.strobe(0);
~par64_2.strobe(0);
~par64_3.strobe(0);
~par64_4.strobe(0);
~par64_5.strobe(0);

~par64_1.macro(10);
~par64_2.macro(rrand(0,15));


~par64_1.dim(255);
~par64_2.dim(255);
~par64_3.dim(255);
~par64_4.dim(255);
~par64_5.dim(255);

~controller.send;
)



(
// OOOOSSSSSSCCCCCC receive values via touchosc
OSCFunc.trace(true);

OSCdef(\speedReceiver,
{|msg, time, addr, recvPort|
		~mhx25_1.rotSpeed(msg[1]*100);
		~controller.send;
}, '/1/speedFader');

OSCdef(\xyReceiver,
{|msg, time, addr, recvPort|
		~mhx25_1.rotX(msg[1]*540);
		~mhx25_1.rotY(msg[2]*270);
		~controller.send;
}, '/1/xy1');


OSCdef(\toggleSequence1,
{|msg, time, addr, recvPort|
		if(msg[1] == 1.0, {Tdef(\explorer).play;}, {Tdef(\explorer).stop;});

}, '/1/toggle3');

OSCdef(\onOff,
{|msg, time, addr, recvPort|
		if(msg[1] == 1.0, {~mhx25_1.on;}, {~mhx25_1.off;});
		~controller.send;

}, '/1/toggle1');

OSCdef(\shutter,
{|msg, time, addr, recvPort|
		if(msg[1] == 1.0, {~mhx25_1.shutter(100);}, {~mhx25_1.shutter(50);});
		~controller.send;

}, '/1/toggle2');

OSCdef(\whiteButton,
{|msg, time, addr, recvPort|
		~mhx25_1.color(\white);
		~controller.send;

}, '/1/push1');
OSCdef(\pinkButton,
{|msg, time, addr, recvPort|
		~mhx25_1.color(\pink);
		~controller.send;

}, '/1/push2');
)

(
Tdef(\explorer, {
	i = 0;
	while ( { i < 27 },
	{
			var z;
			z = if ((i % 2) == 0, { 0 },{ 540 });
			if (i > 10, { ~mhx25_1.on; },{});
			if (i > 20, { ~mhx25_1.off; },{});
			~mhx25_1.rotSpeed(i * 4);
			~mhx25_1.rotX(z);
			~mhx25_1.rotY(i * 10);
			~controller.send;
			2.5.wait;
			i = i+1;
	});

}).play;
)

OSCdef(\fader4,
{|msg, time, addr, recvPort|
		Tdef(\test1).set(\speed, msg[1]);
		Tdef(\test1).set(\rotx, msg[1]);
		Tdef(\test1).set(\roty, msg[1]);
		Tdef(\test1).play;
}, '/1/fader4');

(
Tdef(\test1, {|envir|
	envir.postln;
	~mhx25_1.off;
	~mhx25_1.rotSpeed(envir.speed * 100);
	~mhx25_1.rotX(envir.rotx * 540);
	~mhx25_1.rotY(envir.roty * 270);
	~controller.send;
}).play;
)

		~mhx25_1.off; ~controller.send
 ~
(
Tdef(\tryingToBeOrganic).set(\repeats, 4);

Tdef(\tryingToBeOrganic, {|envir|
	envir.repeats.do {
		var y = 170+ rrand(-50, 50); //rrand(0, 250);
		var x = 360+ rrand(-50, 50); // rrand(60+100, 60-100);
		var x2 = x + rrand(-15, 15);
		var y2 = y + rrand(-15, 15);

		~mhx25_1.on;
		~mhx25_1.color(~mhx25_1.colorDict.keys.choose);

		~mhx25_1.dim(10);
		~mhx25_1.rotX(x);
		~mhx25_1.rotY(y);
		~mhx25_2.rotX(x2);
		~mhx25_2.rotY(y2);
		//1.wait;
		100.rand.do {|i|
			var sinX = (i*1).sin;
			var sinY = (i*1.2).sin;
			~mhx25_1.dim(1 + sinY*10);
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
		~mhx25_1.off; ~controller.send;
		10.rand.wait;
	};
}).play;
)

~mhx25_1.dim(3); ~controller.send
~mhx25_1.on


~modes = [\explorer, \tryingToBeOrganic];
Tdef(\master, {
	var mode = ~modes.choose;
	loop {
		Tdef(mode).stop;
		mode = ~modes.choose;
		Tdef(mode).set(\repeats, 10.rand);
		Tdef(mode).play;
		300.rand.wait;
	};
});
