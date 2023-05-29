/* Coding Practice session 29/05/2023

- Interactive sound generation
   - microphone as input
        - grains
        - pitch change / playback rate
        - play with feedback
   - with echo for a while
       - sample sustain
       - turn off echo
       - amount of echo / size of delay
       - pitch modulation
       - delay modulations
       - distortion / drive
*/

// Creates  a new local buffer
~newbuf = Buffer.alloc(s, s.sampleRate*5);
~newbuf;

// Cleans the Ndef, stops the sound, clears the channels so we can
// run it with more or less channels
Ndef(\soundInWithFeedback).clear;

(
// Our sound process
Ndef(\soundInWithFeedback, {
	// Controls if we should loop the recording process or only record once
	arg loop = 1;
	// Gets the feedback sound
	var feedback = LPF.ar((LocalIn.ar(2) * 2.3).tanh * 0.4, 5000);

	// Gets microphone sound from input 0
	var snd = SoundIn.ar(0) * 5;
	// Gets mouse X coordinate and maps to values from -2 to 2
	// used for buffer playback rate
	var rate = MouseX.kr(-2,2);
	// Gets mouse Y coordinate and maps to values from -1 to 1
	var mousey = MouseY.kr(-1,1);
	// Returns 0 if mouse is below middle of the screen, or 1 if it is above
	var shouldPlay = mousey > 0;
	// Declare variables that we will use later
	var inSignal;
	var delSignal;
	// Records microphone (snd variable) to buffer, and keeps recording in loop
	RecordBuf.ar(snd, ~newbuf, loop: loop);

	// Play the buffer, store it into a variable to use later.
	inSignal = PlayBuf.ar(1, ~newbuf, loop: loop,
		// Buffer playback rate is controlled by the mouse x (rate varaible)
		// goes forward and backward on two channels
		// playback rate changes when trig happens with a ramp of 3 seconds
		rate: rate * [-1, 1] * shouldPlay.lag(2),
		// playing is controlled by mouse y position, whenever mouse
		// crosses the middle of the screen the play buf is triggered
		trigger: mousey,
	);

	//creates a delayed signal of 2 seconds
	delSignal = DelayN.ar(in: inSignal + feedback.reverse, maxdelaytime: 2, delaytime: 2);

	// Sends sound to feedback
	LocalOut.ar(LeakDC.ar(delSignal));
	//LocalOut.ar((delSignal));


	// mix dry and wet signals
	LeakDC.ar(inSignal + delSignal);
});
)

// Cleans the Ndef, stops the sound, clears the channels so we can
// run it with more or less channels
Ndef(\soundInWithFeedback).clear;

(
// Our sound process
Ndef(\soundIn, {
	// Controls if we should loop the recording process or only record once
	arg loop = 1;

	// Gets microphone sound from input 0
	var snd = SoundIn.ar(0) * 5;
	// Gets mouse X coordinate and maps to values from -2 to 2
	// used for buffer playback rate
	var rate = MouseX.kr(-2,2);
	// Gets mouse Y coordinate and maps to values from -1 to 1
	var mousey = MouseY.kr(-1,1);
	// Returns 0 if mouse is below middle of the screen, or 1 if it is above
	var shouldPlay = mousey > 0;
	// Declare variables that we will use later
	var inSignal;
	var delSignal;
	// Records microphone (snd variable) to buffer, and keeps recording in loop
	RecordBuf.ar(snd, ~newbuf, loop: loop);

	// Play the buffer, store it into a variable to use later.
	inSignal = PlayBuf.ar(1, ~newbuf, loop: loop,
		// Buffer playback rate is controlled by the mouse x (rate varaible)
		// goes forward and backward on two channels
		// playback rate changes when trig happens with a ramp of 3 seconds
		rate: rate * [-1, 1] * shouldPlay.lag(2),
		// playing is controlled by mouse y position, whenever mouse
		// crosses the middle of the screen the play buf is triggered
		trigger: mousey,
	);

	//creates a delayed signal of 2 seconds
	delSignal = DelayN.ar(in: inSignal, maxdelaytime: 2, delaytime: 2);

	// Sends sound to feedback
	LocalOut.ar(LeakDC.ar(delSignal));
	//LocalOut.ar((delSignal));


	// mix dry and wet signals
	LeakDC.ar(inSignal + delSignal);
});
)



Ndef(\soundIn).gui;

// Plots what is inside the buffer
~newbuf.plot;

// Simply plays the buffer to the output
~newbuf.play;



