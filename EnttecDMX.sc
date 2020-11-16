/********************************************
EnttecDMX Interface Class
Jonathan Reus, 2016
Usage:
~port = SerialPort.devices[2]; // the serial port where the Enttec is connected
d = EnttecDMX.new(~port, 3);   // 3 channel DMX output
d.sendDMX(0.5,0.5,0.5);        // set all 3 channels to half brightness
d.sendDMX(0, 0, 0);            // set all 3 channels to 0 brightness
d.close();                     // close the serial port
*********************************************/


EnttecDMX {
	var <num_channels, ch1_idx;
	var <port;
	var <serial_packet;
	var <>brightness;

	*new {|portid=nil, numchannels=4, cmdperiod=true|
		^super.new.init(portid, numchannels, cmdperiod);
	}

	// ENTTEC serial protocol
	// 126 6 nb 0 0 b1 b2 b3 ... bn 231
	// 126 - start byte 0x7E 6
	// 6   - send DMX op code
	// nb  - number of bytes (channels) to send + 1
	// 0 0 - start code
	// b1 ... bn channel values (each 1 byte)
	// 231 - end byte 0xE7
	init {|portid, numchannels, cmdperiod|
		var tmp;
		num_channels = numchannels;
		brightness = 1.0;

		// Create serial packet array
		serial_packet = Int8Array.with(0x7E, 6, numchannels + 1, 0, 0);
		ch1_idx = 5;
		numchannels.do({|i|
			serial_packet = serial_packet.add(0);
		});
		serial_packet = serial_packet.add(0xE7);

		// Create serial port
		if(portid.isNil) {
			// Use default
			tmp = SerialPort.devicePattern;
			SerialPort.devicePattern = "/dev/tty.usbserial-EN*";
			portid = SerialPort.devices[0];
			SerialPort.devicePattern = tmp;
		};
		("Opening serial port" + portid + " ...").postln;
		port = SerialPort.new(portid, 57600);

		if(cmdperiod == true) {
			CmdPeriod.add({
				this.close;
			});
		};

	}

	// DMX values from 0.0 - 1.0.
	// Any value greater than 1.0 is replaced with the previously
	// sent value.
	sendDMX {|...vals|
		var numargs = vals.size;
		if(numargs > num_channels) {
			("Too many arguments, max dmx channels is "+num_channels).postln;
		} {
			vals.do ({|theval, i|
				if(theval <= 1.0) {
					serial_packet[ch1_idx + i] = (theval * brightness * 255.0).asInteger;
				}
			});
			//("Sending packet "+serial_packet).postln;
			port.putAll(serial_packet);
		};
	}

	close {
		"Closing serial ports for EnttecDMX...".postln;
		SerialPort.closeAll;
		this.release;
	}
}
