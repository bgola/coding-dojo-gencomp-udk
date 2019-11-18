// This code controls the StairVille MH-X25 moving heads
// It needs the class defined in:
// https://github.com/jreus/ENTTEC_USB_PRO/blob/master/SuperCollider/EnttecDMX.sc
//
// So you need to download that file, add it to your extensions folder and
// recompile the class library (Language -> Recompile class library)
// To find your extensions folder, simply run:

Platform.userExtensionDir.postln

// You can also open it:

Platform.userExtensionDir.openOS

// We tested it with two moving heads, controlling them simultaneously
// in sync (using the same address) or individually.

// To set the address you need to hold the mode button and press it until you see
// d000 or some other number in the display, then set the address.
// In our tests we set one to the address d000 and the other to d007, and used
// the 6 channels mode (there is a 6 channel and a 12 channel mode)

// 6 channels options:
// ch1 is Panning, panning is configurable from 180, 270 or *540*.
// ch2 is Tilt, tilt is configurable from 90, 180 or *270*.
// ch3 is colors:
//     0-5:   white
//     5-9:   yellow
//     10-14: pink
//     15-19: green
//     20-24: peachblow (violet)
//     25-29: light blue
//     30-34: yellow green
//     35-39: red
//     40-44: dark blue
//     45-54: transitions from white to yellow
//     55-64: transitions yellow to pink
//     65-73: transitions pink to green
//     74-83: transitions green to violet
//     84-92: transitions violet to light blue
//     93-101: transitions light blue to yellow green
//     102-110: transitions yellow green to red
//     111-119: transitions red to dark blue
//     120-127: transitions dark blue to white
//     128-191: rainbow effect, clock wise, speed control
//     192-255: rainbow effect, counter clock wise, speed control
// ch4 is shutter:
//     0-3: closed
//     4-7: open
//     8-215: strobe, increased speed
//     216-255: open
// ch5 is gobo rotation (masks)
//     0-7: open
//     8-15: gobo 2
//     16-23: gobo 3
//     24-31: gobo 4
//     32-39: gobo 5
//     40-47: gobo 6
//     48-55: gobo 7
//     56-63: gobo 8
//     64-71: gobo 8 shake mode
// ch6 is gobo rotation


// the serial port where the Enttec is connected
// on linux its usually /dev/ttyUSB0 , on mac its /dev/tty.usbserial.EN*
~port = "/dev/ttyUSB0";

// We create a 12 channel instance because we want to control 2 moving heads
// and each will use 6 channels
~dmx = EnttecDMX.new(~port, 12);

// lazy function to convert from uni values to 0-255 (because values are specified
// from 0-255 in the manual of MH-X25
f = {|v| v.linlin(0,255, 0,1)}

(
~dmx.sendDMX(
	// Moving head 1, set to addr d001
	f.value(120), // sets pan position
	f.value(120), // sets tilt position
	f.value(0),   // color mode
	f.value(4),   // shutter / strobe
	f.value(20),  // gobo
	f.value(0),   // gobo rotation
	// Moving head 2, set to addr d007
	f.value(120),
	f.value(80),
	f.value(0),
	f.value(200),
	f.value(20),
	f.value(0),
);
)

(
// Blinks for 0.1 seconds
~blink = {
	~dmx.sendDMX(
		// Moving head 1
		f.value(255.rand),
		f.value(255.rand),
		f.value(0),
		f.value(4),
		f.value(20),
		f.value(0),
		// Moving head 2
		f.value(255.rand),
		f.value(255.rand),
		f.value(0),
		f.value(4),
		f.value(20),
		f.value(0),
	);
	0.1.wait;
	~dmx.sendDMX(
		// Moving head 1
		f.value(120),
		f.value(10),
		f.value(0),
		f.value(0),
		f.value(20),
		f.value(0),
		// Moving head 2
		f.value(120),
		f.value(120),
		f.value(0),
		f.value(0),
		f.value(20),
		f.value(0),
	);
};
)
// call blink
~blink.fork