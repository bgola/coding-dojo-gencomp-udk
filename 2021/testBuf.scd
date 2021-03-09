~buffer = Buffer.read(s,"/Users/fangtsai/Documents/March_performance/recorded_Fang_reading/Letter_audible.wav",bufnum:2);
s.reboot
~buffer.play
a.stop
s.volume.gui
~buffer.duration
(
Ndef(\playBuffer, { |rate=1, trigger_speed=10, pos=6|
	var slices = 100;
	var slice_dur = (~buffer.duration / slices);
	var trigger = Impulse.kr(trigger_speed);
	var startPos = (~buffer.duration-slice_dur-pos);

	PlayBuf.ar(
		~buffer.numChannels,  // Channels
		~buffer,  // Buffer
		rate, // rate (speed of playing the sample)
		trigger: trigger,
		startPos:pos*14400,
		loop: 1
	);
}).play;
)

Ndef(\playBuffer).stop
Ndef(\playBuffer).set(\rate, 1);
Ndef(\playBuffer).set(\pos,8);
Ndef(\playBuffer).set(\trigger_speed, 0.5);
Ndef(\playBuffer).gui
Ndef(\playBuffer).scope


(
Ndef(\sliceBuffer, { |rate, slices, slice_dur,trigger,possible_slices, slice_number |
	 rate=1;
	 slices = 10;
	 slice_dur=(~buffer.duration / slices);
	 trigger = Impulse.kr(1 / (slice_dur/rate));
	// Generates a list of index slices from 0 to the number of slices (like: [0, 1, 2, ...] and scramble/random this list
	  possible_slices = (0..slices-1).scramble;
	// Creates a sequence out of the scrambled list and go over it one by one
	  slice_number = Demand.kr(
		trigger,
		0,
		Dseq(possible_slices, inf) // Change the 1 to 2, 3... or inf to play for 2, 3 times or forever
	);

	// Makes the sound stop after playing all slices
	Line.ar(0, 1,
		~buffer.duration/rate,
		doneAction: Done.freeSelf
	);

	PlayBuf.ar(
		1,  // Channels
		~buffer,  // Buffer
		// rate (speed of playback)
		rate * (~buffer.sampleRate / s.sampleRate),
		trigger: trigger,
		startPos: ((~buffer.sampleRate * slice_dur) * slice_number),
		loop: inf
	);
}).play;
)

Ndef(\sliceBuffer).set(\rate, 3);
Ndef(\sliceBuffer).set(\slices, 100);
Ndef(\sliceBuffer).set(\slice_dur, 1);
Ndef(\sliceBuffer).gui
Ndef(\sliceBuffer).scope

