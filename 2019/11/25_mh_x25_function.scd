(
~new_mhx25 = {

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
			milkyShake: 64,
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
			self.internal_values[2] =
			self.colorDict[colorName].linlin(0, 255, 0, 1);
		},

		gobo: {|self, goboName|
			self.internal_values[4] =
			self.goboDict[goboName].linlin(0, 255, 0, 1);
		},
	)
};

~mhx25_1 = ~new_mhx25.value();
)

~port = "/dev/ttyUSB0";
~dmx = EnttecDMX.new(~port, 6);


(
~mhx25_1.rotX(270);
~mhx25_1.rotY(180);
~mhx25_1.on;
~dmx.sendDMX(*~mhx25_1.internal_values)
)

(
~mhx25_1.on;
~mhx25_1.rotY(90);
~mhx25_1.color(~mhx25_1.colorDict.keys.choose;);
~mhx25_1.gobo(~mhx25_1.goboDict.keys.choose;);

~dmx.sendDMX(*~mhx25_1.internal_values)
)


