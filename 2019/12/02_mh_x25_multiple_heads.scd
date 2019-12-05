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
~mhx25_2 = ~new_mhx25.value();
)


(
~dmx_controller = { |port, channels, dev1, dev2|

	(
		dmx: EnttecDMX.new(port, channels),
		obj1: dev1,
		obj2: dev2,

		send: {|self|
			self.dmx.sendDMX(*(self.obj1.internal_values++self.obj2.internal_values))
		},
	)
};

~port = "/dev/tty.usbserial-EN225291";
~controller = ~dmx_controller.value(~port, 12, ~mhx25_1, ~mhx25_2);
)

//send values for both heads
// ~controller.send;

(
Tdef(\update).set(\mhx, ~mhx25_1);

Tdef(\update).addSpec(\rotX, [0,540,0,1]);
Tdef(\update).addSpec(\rotY, [0,270,0,1]);
Tdef(\update).addSpec(\color, [0,8,0,1]);
Tdef(\update).addSpec(\shutter, [-1,101,0,1]);
Tdef(\update).addSpec(\gobo, [0,8,0,1]);

Tdef(\update).set(\rotX, 0);
Tdef(\update).set(\rotY, 0);
Tdef(\update).set(\color, 0);
Tdef(\update).set(\shutter, 50);
Tdef(\update).set(\gobo, 0);

Tdef(\update, { |envir|
	loop{
		envir.mhx.rotX(envir.rotX);
		envir.mhx.rotY(envir.rotY);
		envir.mhx.color(envir.mhx.colorDict.keys.asList()[envir.color]);
		envir.mhx.shutter(envir.shutter);
		case
			{envir.shutter == -1} {envir.mhx.off}
			{envir.shutter == 101} {envir.mhx.on}
			{(envir.shutter >= 0) && (envir.shutter <= 100)} {envir.mhx.shutter(envir.shutter)};
		envir.mhx.gobo(envir.mhx.goboDict.keys.asList()[envir.gobo]);
		~controller.send;
		0.1.wait;
	}
}).gui;

Tdef(\update).copy(\update2);
Tdef(\update2).set(\mhx, ~mhx25_2);
Tdef(\update2).addSpec(\rotX, [0,540,0,1]);
Tdef(\update2).addSpec(\rotY, [0,270,0,1]);
Tdef(\update2).addSpec(\color, [0,8,0,1]);
Tdef(\update2).addSpec(\shutter, [-1,101,0,1]);
Tdef(\update2).addSpec(\gobo, [0,8,0,1]);
Tdef(\update2).gui;
)





(
// manual control
// don't forget to send
// ~controller.send;
~mhx25_1.rotX(90);
~mhx25_1.rotY(180);
~mhx25_1.on;

~mhx25_2.rotX(200);
~mhx25_2.rotY(180);
~mhx25_2.on;

~mhx25_1.color(~mhx25_1.colorDict.keys.choose;);
~mhx25_1.gobo(\crystal);
~mhx25_1.color(
~mhx25_2.gobo(~mhx25_2.goboDict.keys.choose;);
)








