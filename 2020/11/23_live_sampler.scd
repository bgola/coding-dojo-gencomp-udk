// Suggestions:
//   - Work with live audio input
//   - Sample live input and reorder it
//   - Record two buffers
//   - Add some effects that can be controlled from outside
//
//   - synth params:
//     - number of slices
//     - slice number to play
//     - toggle on and off the sampler / recording
//     - playback rate
//     - add reverb & delay controls (extra task)
//
//   - OSC interface (receive OSC message to control our synth)


ServerOptions.devices.postcs
s.options.device =  "Scarlett 2i2 USB"
s.boot

// create a buffer to save live input - 4 seonds * samplerate
b = Buffer.alloc(s, 44100 * 4.0, 1); // a four second 1 channel Buffer

// record live audio into Buffer
// make the synthdef first with .add
(
SynthDef(\recordbuf, { arg bufnum = 0;
    var source;
	source = SoundIn.ar(0);
    RecordBuf.ar(source, bufnum, preLevel: 0.2, doneAction: Done.freeSelf, loop: 0);
}).add
)
// use the synthdef to record:
Synth(\recordbuf, [\bufnum, b.bufnum]);

s.meter
// quick way to play buffer for testing
b.play;
b.plot;

SynthDef(\play_Buffer, {arg bufnum;
	var signal;
	signal = PlayBuf.ar(1, bufnum, doneAction: Done.freeSelf);
	Out.ar(0, signal);
}).add

Synth(\play_Buffer, [\bufnum, b.bufnum]);


(
//devide steps in 16
SynthDef(\playStep, {arg bufnum, numStep=0, steps=16, rate=1;
	var signal;
	var bufdur = BufDur.kr(bufnum);
	var stepTime = bufdur / steps;
	var startTime = numStep * stepTime;
	var startFrame = startTime * BufSampleRate.kr(bufnum);
	var rate2 = BufRateScale.kr(bufnum) * rate;
	var duration = stepTime/rate2.abs;
	var env = Env(
		[0, 1, 1, 0],
		[0.01, duration - 0.01,  0.01]);
	var envGen=EnvGen.kr(env, doneAction: 2);

	signal = PlayBuf.ar(1, bufnum,
		rate2,
		startPos: startFrame);
	Out.ar(0, LeakDC.ar(signal) * envGen);
}).add
)

(
Pdef(\playPat,
	Pbind(
		\instrument, \playStep,
		\bufnum, b,
		\steps, 128,
		//\numStep,  Pseq([Pseries(0,1,128)], inf), /
		\numStep, Pwhite(0, Pkey(\steps)),
		//\numStep, Pseq([0, 10, 4, 1, 3, 5], inf),
		\dur, (4 / 64) * 0.5)
).play;

(
Pdef(\recPat,
	Pbind(
		\instrument, \recordbuf,
		\bufnum, b,
		\dur, 4)
).play;
)

)

TempoClock.default.tempo = 1

(instrument: \playStep, bufnum: b, steps: 128, numStep: 128.rand).play


Synth(\recordbuf, [\bufnum, b])

44100 / 48000

Synth(\playStep, [\bufnum, b.bufnum, \numStep, 16.rand.postln, \steps, 16, \rate, rrand(-1.5, 1.5)].postln);

Synth(\playStep, [\bufnum, b.bufnum, \numStep, 4, \steps, 16, \rate, 0.5]);




SynthDef(\playSeg, { |out, buf, start = 0, amp = 0.2, sustain = 1|
	// something with Playbuf here
}).add;




// To reorder and manipulate the buffer



/* Feedback

Pros
  - was good to change the dynamics of pairing
  - font size was good.
  - success!!!!
  - really cool sounds

Cons
  -  we forgot to change the documentation font size.

Suggestions
  - OSC and midi
*/