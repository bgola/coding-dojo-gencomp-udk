Quark("Modality-toolkit").update

s.boot;

s.options.inDevice = "Steinberg CI1";
s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 2;
s.options.sampleRate = 48000;



// Silly way to load files to an array
(
b = [];
b = b.add([Buffer.read(s, "/Users/ferreira/Desktop/dojo/mag01.wav"), nil]);
b = b.add([Buffer.read(s, "/Users/ferreira/Desktop/dojo/mag02.wav"), nil]);
b = b.add([Buffer.read(s, "/Users/ferreira/Desktop/dojo/mag03.wav"), nil]);
b = b.add([Buffer.read(s, "/Users/ferreira/Desktop/dojo/tou01.wav"), nil]);
b = b.add([Buffer.read(s, "/Users/ferreira/Desktop/dojo/tou02.wav"), nil]);
b = b.add([Buffer.read(s, "/Users/ferreira/Desktop/dojo/tou03.wav"), nil]);
b = b.add([Buffer.read(s, "/Users/ferreira/Desktop/dojo/tou04.wav"), nil]);
b = b.add([Buffer.read(s, "/Users/ferreira/Desktop/dojo/design.wav"), nil]);
)

// How to play one of the buffers
x = b.choose.play;
// ... and how to stop it:
x.free;

// If you want Live input from your mic:
Ndef(\liveinput, {SoundIn.ar!2}).play;
Ndef(\liveinput).stop;

// Add some effects to our Master output:

// Granular master effect
~masterGrainBuf = Buffer.alloc(s, s.sampleRate*2, 1);

(
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
)

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
k = MKtl('npad', "korg-nanopad2");
// k.gui;
)


// Check if your controller is working correctly
// you can trace and see the labels to know which
// button is what.
k.gui


// Set what each control does.
// Examples:

// Slider 1 changes parameter \x of influx and sets MasterFX accordingly
(
k.elAt(\touch, \x).action_({ |elem|
	a.set(\x, elem.value.linlin(0, 1, -1, 1)).postln;
});

k.elAt(\touch, \y).action_({ |elem|
	a.set(\y, elem.value.linlin(0, 1, -1, 1));
});



k.elAt(\pad, 0, 0).action_({ |elem|
	b[0][1].free;
	b[0][1] = b[0][0].play(true);
});

k.elAt(\pad, 0, 2).action_({ |elem|
	b[1][1].free;
	b[1][1] = b[1][0].play(true);
});

k.elAt(\pad, 0, 4).action_({ |elem|
	b[2][1].free;
	b[2][1] = b[2][0].play(true);
});

k.elAt(\pad, 0, 6).action_({ |elem|
	b[3][1].free;
	b[3][1] = b[3][0].play(true);
});

k.elAt(\pad, 0, 8).action_({ |elem|
	b[4][1].free;
	b[4][1] = b[4][0].play(true);
});

k.elAt(\pad, 0, 10).action_({ |elem|
	b[5][1].free;
	b[5][1] = b[5][0].play(true);
});

k.elAt(\pad, 0, 12).action_({ |elem|
	b[6][1].free;
	b[6][1] = b[6][0].play(true);
});

k.elAt(\pad, 0, 14).action_({ |elem|
	b[7][1].free;
	b[7][1] = b[7][0].play(true);
});

// clear samples

k.elAt(\pad, 0, 1).action_({ |elem|
	b[0][1].free;
});

k.elAt(\pad, 0, 3).action_({ |elem|
	b[1][1].free;
});

k.elAt(\pad, 0, 5).action_({ |elem|
	b[2][1].free;
});

k.elAt(\pad, 0, 7).action_({ |elem|
	b[3][1].free;
});

k.elAt(\pad, 0, 9).action_({ |elem|
	b[4][1].free;
});

k.elAt(\pad, 0, 11).action_({ |elem|
	b[5][1].free;
});

k.elAt(\pad, 0, 13).action_({ |elem|
	b[6][1].free;
});

k.elAt(\pad, 0, 15).action_({ |elem|
	b[7][1].free;
});

)
s.boot
s.scope
