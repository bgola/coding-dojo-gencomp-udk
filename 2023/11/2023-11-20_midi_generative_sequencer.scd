/*

Dojo session 20.11.2023


- Control the roland tr-8 from SuperCollider
- using MIDI
- midi channel is 10 (9 if you count from 0), notes are between (36 and 46)
- Sequencer that the trigger for the next step is Dust.kr, dust value is also sending some values through CC
- should send: instrument (midi note), tune (cc0), attack, comp, decay, level
- values come from buffers, that we can draw the shape using Plots


MIDI notes to instruments:
BASS DRUM   36
BASS DRUM2  35
SNARE DRUM  38
SNARE DRUM2 40
LOW TOM     41
LOW TOM     43
MID TOM     45
MID TOM     47
HIGH TOM    48
HIGH TOM    50
RIM SHOT    37
COW BELL    56
HAND CLAP   39
TAMBOURINE  54
CLOSED HH   42
OPEN HI-HAT 46
CRASHCYMBAL 49
RIDE CYMBAL 51

CC values:

cc 20 - bd tune
cc 21 - attack
cc 22 - comp
cc 23 - decay
cc 24 - level

cc 25 - sd tune
...
cc 74
*/

// Initialize MIDI
MIDIClient.init;
m = MIDIOut(0);

// Play a note / 36 is midi note for BD
// TR-8 is configured to listen on MIDI Channel 10 (9 in SC because we count from 0)
m.noteOn(9, 36);

// sends noteOff to all the possible notes
127.do { |note| m.noteOff(9, note) };

// change some parameters and play BD again
(
m.control(9, 24, 120);
m.control(9, 20, 10);
m.noteOn(9, 36);
)


// set density range
Spec.add(\density, [0, 100, \amp]);
// Spec.add(\density, [0, 1, \amp]);

// make an Ndef that plays Dust, with controllable density.
Ndef(\Dust, {|density = 5|
	Dust.ar(density)
});

// tell it to play
Ndef(\Dust).play;
// make a GUI for it
Ndef(\Dust).gui;


// make an Ndef that plays Dust, with controllable density.
// should send triggers to SC language
(
Ndef(\Dust, {|density = 5|
	var snd = Dust.ar(density);
	// SendTrig sends a OSC message back from SC synth to the langague
	SendTrig.ar(snd, 23, snd);
	snd
});
)

// to receive the trig this message
(
OSCdef(\dust, { arg msg, time;
	// msg contains: ['/tr', synthid, replyID (23), value]
	var amp = msg[3];
	var note = amp.linlin(0, 1, 35, 56).asInteger.postln;
	// [time, msg].postln;
	//amp.postln;

	//plays note from the value of dust
	fork {
		m.noteOn(9, note, 127.rand);
		// wait and send a noteOff
		0.2.wait;
		m.noteOff(9, note);
	}
}, '/tr');

)


//new version with 2x rand
// make an Ndef that plays Dust, with controllable density.
// sends triggers to SC language,
// and random parameter values
(
Ndef(\Dust, {|density = 0.5|
	var dust = Dust.ar(density);
	// generates a random value between 0 and 1 for every new value of Dust
	var rand = TRand.ar(0.0, 1.0, dust);
	SendReply.ar(dust, '/tr',
		[dust, rand],
		23);
	dust
});
)


// a lookup table to map midi note to CC for tune value
// to use it: ~note2cc[NOTE]
(
~note2cc = (
	// note:ccnum
	35:20, // BD
	36:20, // BD
	38:25, // SD
	40:25, // SD
	41:46, //LT TUNE
	43:46, //LT TUNE
	45:49,// MT TUNE
	47: 49, // MT
	48: 52, // HT
	50:52, // HT
	37:55, // RS
	51:86,
	39:58,
	42:61,
	46:80,
	49:83,
))

// change tune on every note,
// by using the lookup dictionary
(
OSCdef(\dust, { arg msg, time;
	var amp = msg[3];
	var note = amp.linlin(0, 1, 35, 56).asInteger;
	var tune = msg[4].linlin(0, 1, 2, 127).asInteger;

	//plays note from the value of dust
	fork {
		// bassdrum
		m.control(9, ~note2cc[note], tune);
		0.01.wait;
		m.noteOn(9, note, rrand(32, 127));
		0.02.wait;
		m.noteOff(9, note);

	}
},'/tr');
)


// special Ndef adding some extra things including an audio feedback
// depending on the amplitude of the audio input, audio gets modulated
// also, has a fader between keeping regular pulses or irregular
Spec.add(\regularity, [0,1]);
Spec.add(\extin, \amp);
(
Ndef(\Dust, {|density = 0.5, regularity = 0, extin = 0|
	var ampin = (1-Amplitude.ar(SoundIn.ar([0,1]).sum*extin, 0.01, 1));
	var imptrg = Impulse.ar(ampin * 50 * (density * regularity));
	var dustrg = Dust.ar(ampin * 50 * (density * (1-regularity)));
	var trg = imptrg + dustrg;
	var dust = WhiteNoise.ar.abs;
	var rand = TRand.ar(0.0, 1.0, trg);
	SendReply.ar(trg, '/tr',
		[dust, rand, SinOsc.ar(0.1).range(0,1)],
		23);
	dust
});
)

(
OSCdef(\dust, { arg msg, time;
	var amp = msg[3];
	var note = amp.linlin(0, 1, 35, 51).asInteger;
	var tune = msg[4].linlin(0, 1, 2, 127).asInteger;
	var decay = msg[5].linlin(0, 1, 2, 127).asInteger;

	//plays note from the value of dust
	fork {
		var cc = ~note2cc[note];
		if (cc.notNil) {
			// sets tune for the current note
			m.control(9, cc, tune);
			// sets decay for the current note
			m.control(9,
				if ([35,36,38,40].includes(note)) { cc + 3 } { cc + 1 },
				decay
			);
			0.01.wait;
		};
		m.noteOn(9, note, rrand(32, 127));
		0.02.wait;
		m.noteOff(9, note);
	};


	// Random values for stutter
	if (0.1.coin) {
		m.control(9, 68, 127.rand);
		m.control(9, 69, 127.rand);
		m.control(9, 70, 127.rand);
	};

	// Random values for Reverb
	if (0.5.coin) {
		m.control(9, 89, 127.rand);
		m.control(9, 90, 127.rand);
		m.control(9, 91, 127.rand);
	};

	// Random values for Delay
	if (0.5.coin) {
		m.control(9, 16, 127.rand);
		m.control(9, 17, 127.rand);
		m.control(9, 18, 127.rand);
	};
},'/tr');
);