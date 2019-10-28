/*
Proposal:

- create a sampler instrument that receives a sample, a number of slices, and the slice you want to play.
- use patterns to play your sampler.
- additionally, also lets you choose the playback rate

*/


~sample = Buffer.read(s, "/path/to/your/file.wav");

(
SynthDef(\sampler, { arg sample, numberOfSlices, sliceIndex;
	var sound;
	var numberofframes = BufFrames.kr(sample);
	var valueOfSlice = numberofframes/numberOfSlices;
	var duration  = (numberofframes / BufSampleRate.kr(sample)) / numberOfSlices;
	var env = EnvGen.ar(
		Env.new([0,1,1,0], [0, duration, 0]),
		doneAction: Done.freeSelf);

	sound = PlayBuf.ar(2,
		sample, loop:0,
		startPos: valueOfSlice*sliceIndex);
	Out.ar(0, sound * env);
}).add;
)

(
Pdef(\mypat,
	Pbind(
		\instrument, \sampler,
		\numberOfSlices, 10,
		\sample, ~sample,
		\sliceIndex, Pseq([6,1,4,3,2], inf),
		\dur, ~sample.duration/Pkey(\numberOfSlices),
	);
).play;
)

