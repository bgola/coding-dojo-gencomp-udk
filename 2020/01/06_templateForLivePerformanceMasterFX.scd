// Silly way to load files to an array
b = [];
b = b.add(Buffer.read(s, "/home/bgola/workspace/samples/dmxkrew/mag01.wav"));
b = b.add(Buffer.read(s, "/home/bgola/workspace/samples/dmxkrew/mag02.wav"));
b = b.add(Buffer.read(s, "/home/bgola/workspace/samples/dmxkrew/tou00.wav"));
b = b.add(Buffer.read(s, "/home/bgola/workspace/samples/dmxkrew/tou01.wav"));
b = b.add(Buffer.read(s, "/home/bgola/workspace/samples/dmxkrew/tou02.wav"));
b = b.add(Buffer.read(s, "/home/bgola/workspace/samples/dmxkrew/tou03.wav"));

// How to play one of the buffers
x = b.choose.play;
// ... and how to stop it:
x.free;

// If you want Live input from your mic:
Ndef(\liveinput, {SoundIn.ar}).play;
Ndef(\liveinput).stop;

// Add some effects to our Master output:

// Granular master effect
~masterGrainBuf = Buffer.alloc(s, s.sampleRate*2, 1);
ProxyChain.add3(\grains, \filter -> {|in, dur=0.1, density=10, pos=0|
	var snd;
	RecordBuf.ar(in[0], ~masterGrainBuf);

	snd = GrainBuf.ar(
		2, Impulse.ar(density), dur, ~masterGrainBuf, 1,
		LFNoise1.ar(4).range(0.0, 1.0), 2, LFNoise1.ar(1).range(-1,1));
	/*snd = Mix.ar([snd, GrainBuf.ar(
		4, Impulse.ar(density), dur, ~buf2, rate,
		0, 2, LFNoise1.ar(1).range(-1,1))]);*/
	Mix.ar([snd, JPverb.ar(snd*0.1, 2.0)]);
}, 1, (dur: [0.01, 1.0, \lin], density: [1.0, 100.0, \exp], pos: [0.0, 1.0, \lin]));

// Delay master effect
ProxyChain.add3(\delay, \filterIn -> {|in, delayDur=1.0, fdbk=2.0|
	AllpassC.ar(in, 4.0, delayDur, fdbk);
}, 1, (delayDur: [0.05, 4.0, \lin], fdbk: [1.0, 10.0, \lin]));


// Create a new MasterFX with our effects:
m  = MasterFX.new(s, 2, [\grains, \delay], 0);

m.add(\grains, 1);
m.add(\delay, 1);

// See effects:
m.gui


// Influx maps few parameters to many, in a matrix of weights
a = Influx([\x, \y], [\dur, \rate, \pos,\delayDur, \fdbk, \density], (x: 0.5, y: 0.1));
(
a.action = { |val|
	m.set(\density, a.outValDict[\density].linlin(-1.0, 1.0, 1.0, 100));
	m.set(\dur, a.outValDict[\dur].linlin(-1.0, 1.0, 0.01, 1));
	m.set(\delayDur, a.outValDict[\delayDur].linlin(-1.0, 1.0, 0.05, 4));
	m.set(\fdbk, a.outValDict[\fdbk].linlin(-1.0, 1.0, 1.0, 10));
};
)

// See how parameters are affected
~infgui = InfluxIOWGui(a);

// If you are not happy AND feel lucky:
a.rand(0.7)

// Find your controller:
MKtl.find
(
// You will find a line like one of the below:
// to load your controller description:
k = MKtl(\nk2, "korg-nanokontrol2");// k.gui;
)


// Check if your controller is working correctly
// you can trace and see the labels to know which
// button is what.
k.gui


// Set what each control does.
// Examples:

// Slider 1 changes parameter \x of influx and sets MasterFX accordingly
k.elAt(\sl, 1).action_({ |elem|
	a.set(\x, elem.value.linlin(0, 1, -1, 1));
});

k.elAt(\sl, 2).action_({ |elem|
	a.set(\y, elem.value.linlin(0, 1, -1, 1));
});