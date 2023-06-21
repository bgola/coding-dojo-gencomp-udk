/*

Coding Practice Session 19.06.2023

Input from continuous chaotic, non-deterministic synthesizer

Output should sound like internal organs sounds, sort of rhytmic and bubbly but not happy bubbly, upset stomach-like

*/

// Saves a place in memory / a buffer to record one second of the input continuously
b = Buffer.alloc(s, s.sampleRate*1);

// Loads only one channel of the buffer
c=Buffer.readChannel(s,"/Users/gc12_ferrari/Desktop/57167__juskiddink__collywobbles.wav",channels:[0]);

(
Ndef(\bubbly, {
	// gets the sound input
	var snd = SoundIn.ar(0);
	//
	var pitch = Pitch.kr(snd).at(0);
	var last = LastValue.kr(pitch);
	var minMove = \minMove.kr(0.5);
	var maxMove = \maxMove.kr(20);
	var move = (pitch - last).abs.lag(0.5);
	// randomise trigers per second, play with the values between 0 and 20 to get different reactions
	var trig = Dust.kr(move.linlin(minMove, maxMove, 0, 20));
	var grain = GrainBuf.ar(2,
		trig,
		// the duration of each grain
		//TRand.kr(0.1,0.5, trig),
		move.linlin(minMove,maxMove, 0.9, 0.05),
		TWChoose.kr(trig, [c], [1]),
		move.linlin(minMove, maxMove, 0.8,6),
		// randomising the position of grain
		TRand.kr(0,1, trig),
		2,
		WhiteNoise.kr
	);
	grain;
}).play;
)

Ndef(\bubbly).gui


// changing rec. for1 channel sound( grain buffer read only mono)
Quarks.gui

c.numChannels;



(
Ndef(\soundIn, {
	// gets the sound input
	var snd = SoundIn.ar(0);
	// analyze pitch from input
	var pitch = Pitch.kr(snd).at(0);
	// record input into a buffer
	var rec = RecordBuf.ar(snd, b);
	// create a randomized envelope time between 0 and 0.4 seconds
	var gate=Dust.kr(10);
	var envTime = TRand.kr(0,0.4,gate);
	// create an envelope for the amplitude of our sound
	var ampEnv = Env.perc(0.01, 0.99, 1, -5.rand).ar(gate:gate, timeScale: envTime);
	//create a pitch envelope for our sound
	var pitchEnv =Env.new([0, 1, 0], [0.01, 0.1], [5, 2]).ar(gate:gate, timeScale: envTime);
	//play sound und multiply it with our envelopes to change volume and pitch
	PlayBuf.ar(1, b, loop:1, rate:pitchEnv.range(0.1,0.2))*ampEnv;
}).play;
)

Env.new([0, 1, 0], [0.1, 0.1], [5, -5]).plot;

Env.new([0.05,0.05,0.05,0.65], [-5,-6,30]).plot
Env.new([0,0.8,0.5,1,0], [0.1,0.05,0.05,0.7], [-5,-6,10]).plot

b.plot;













// ANALYZES OF THE INPUT
(
Ndef(\in, {
	// get sound from soundcard
	var snd = SoundIn.ar([0]);
	// analyze the pitch
	var pitch = Pitch.kr(snd)[0];
	// gets value for pitch on the last sample
	var last = LastValue.kr(pitch);
	// does average of the change of the pitch
	var mean = (pitch - last).lag(2);
	// here we can scope / plot the actual pitch
	pitch.explin(50,900,0,1);
	// uncomment this here to scope / plot the average:
	mean;
}).scope
)

// play the sound coming from input
Ndef(\insnd, {SoundIn.ar(0)*0.1}).play;
Ndef(\insnd).stop



