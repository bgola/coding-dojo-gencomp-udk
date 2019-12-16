(

// Function to create a new object representing the
// DMX configuration of the mhx25 moving head.
~mhx25 = {
	(
		internal_values: [0,0,0,0,0,0],

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

		on: {|self|
			self.internal_values[3] = 5.linlin(0, 255, 0, 1);
		},

		off: {|self|
			self.internal_values[3] = 2.linlin(0, 255, 0, 1);
		},

		// speed between 0-100, strobe effect
		shutter: {|self, speed|
			var sspeed = speed.linlin(0, 100, 15, 182);
			self.internal_values[3] = sspeed.linlin(8, 215, 0, 1);
		},

		color: {|self, colorName|
			self.internal_values[2] = self.colorDict[colorName].linlin(0, 255, 0, 1);
		},

		gobo: {|self, goboName|
			self.internal_values[4] = self.goboDict[goboName].linlin(0, 255, 0, 1);
		},

		goboOff: {|self|
			self.internal_values[4] = 0;
		},

		goboRot: {|self, value|
			self.internal_values[5] = value.linlin(0, 255, 0, 1);
		},

		rainbow: {|self, speed|
			// 128-191
			var sspeed = speed.linlin(0, 100, 128, 191);
			self.internal_values[2] = sspeed.linlin(0, 255, 0, 1);
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
~controller = ~dmx_controller.value(~port, [~mhx25_1, ~mhx25_2, ~par64_1, ~par64_2, ~par64_3, ~par64_4, ~par64_5]);
)


(
// Example of how to send values, you set all values and then call ~controller.send
~mhx25_1.rotX(5);
~mhx25_1.rotY(65);
~mhx25_1.on;

~mhx25_2.rotX(8);
~mhx25_2.rotY(65);
~mhx25_2.on;

//~mhx25_1.shutter(0);
//~mhx25_2.shutter(0);

//~mhx25_1.color(\red);
//~mhx25_2.color(\lightBlue);

~mhx25_1.rainbow(0);
~mhx25_2.rainbow(0);

~mhx25_1.gobo(\crystal);
~mhx25_2.gobo(\crystal);

~mhx25_1.goboRot(70);
~mhx25_2.goboRot(150);

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
Tdef(\shifting, {
	loop {
		~mhx25_1.rotX(10);
		~mhx25_1.rotY(60);

		~mhx25_2.rotX(10);
		~mhx25_2.rotY(60);


		~mhx25_1.shutter(rrand(80, 160));
		~mhx25_2.shutter(rrand(60, 200));

		//~mhx25_1.color(~mhx25_1.colorDict.keys.choose);
		//~mhx25_2.color(~mhx25_1.colorDict.keys.choose);
		~mhx25_1.rainbow(rrand(0,100));
		~mhx25_2.rainbow(rrand(0,100));
		//~mhx25_1.goboOff;
		//~mhx25_2.goboOff;
		~par64_1.green(rrand(0,255));
		~par64_1.red(rrand(0,255));

		~par64_2.red(rrand(0,255));
		~par64_2.blue(rrand(0,255));
		~par64_3.blue(rrand(0,255));
		~par64_4.red(rrand(0,255));
		~par64_4.blue(rrand(0,255));
		~par64_1.strobe(rrand(145,255));
		~par64_2.strobe(rrand(100,255));
		~par64_3.strobe(rrand(100,255));
		~par64_4.strobe(rrand(0,255));
		~par64_5.strobe(rrand(0,255));

		~par64_1.macro(10);
		~par64_2.macro(rrand(0,15));


		~par64_1.dim(255);
		~par64_2.dim(255);
		~par64_3.dim(255);
		~par64_4.dim(255);
		~par64_5.dim(255);

		~controller.send;
		7.rand.wait;
	}
}).stop;
)


(
// Step sequencer style, using color
Tdef(\sequencer, {|envir|
	var curr = 0;
	var color;
	[~par64_1, ~par64_2, ~par64_3, ~par64_4, ~par64_5].do {|light|
		light.red(255.rand);
		light.green(255.rand);
		light.blue(255.rand);
	};
	loop {
		[~par64_1, ~par64_2, ~par64_3, ~par64_4, ~par64_5].do {|light|
			curr = (curr + 0.01);
			if (curr > 0.9999, {curr = 0});
			color = Color.hsv(curr, 1, 1);


			light.dim(255);
			~controller.send;
			0.1.wait;
			light.dim(0);  ~controller.send;
			0.1.wait;
		};
	}
}).play;
)