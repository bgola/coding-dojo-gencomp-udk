// Silly way to load files to an array
s.boot;


b = [];
b = b.add([Buffer.read(s, "/home/bgola/workspace/samples/dmxkrew/mag01.wav"), nil]);
b = b.add([Buffer.read(s, "/home/bgola/workspace/samples/dmxkrew/mag02.wav"), nil]);
b = b.add([Buffer.read(s, "/home/bgola/workspace/samples/dmxkrew/tou00.wav"), nil]);
b = b.add([Buffer.read(s, "/home/bgola/workspace/samples/dmxkrew/tou01.wav"), nil]);
b = b.add([Buffer.read(s, "/home/bgola/workspace/samples/dmxkrew/tou02.wav"), nil]);
b = b.add([Buffer.read(s, "/home/bgola/workspace/samples/dmxkrew/tou03.wav"), nil]);


// If you want Live input from your mic:
Ndef(\liveInput, {HPF.ar(LPF.ar(SoundIn.ar(0)!2 * 1.5, 3000),200)});

// Add some effects to our Master output:

// Granular master effect
~masterGrainBuf = Buffer.alloc(s, s.sampleRate*1, 1);
ProxyChain.add3(\grains, \filter -> {|in, dur=0.1, density=10, pos=0|
	var snd;
	RecordBuf.ar(in[0], ~masterGrainBuf);

	snd = GrainBuf.ar(
		2, Impulse.ar(density), dur, ~masterGrainBuf, 1,
		LFNoise1.ar(4).range(0.0, 1.0), 2, LFNoise1.ar(1).range(-1,1));
	/*snd = Mix.ar([snd, GrainBuf.ar(
		4, Impulse.ar(density), dur, ~buf2, rate,
		0, 2, LFNoise1.ar(1).range(-1,1))]);*/
	snd;
}, 1, (dur: [0.01, 1.0, \lin], density: [1.0, 100.0, \exp], pos: [0.0, 1.0, \lin]));

// Filter
ProxyChain.add3(\filters, \filterIn -> {|in, hpf=20, lpf=20000, res=0|
	var snd = LPF.ar(in, lpf);
	HPF.ar(snd, hpf);
}, 1, (hpf: \freq.asSpec, lpf: \freq.asSpec, res: [0.0, 0.5, \lin]));


// Filter
ProxyChain.add3(\reverb, \filter -> {|in, revAmt=0, revTime=1.0, revDamp=0.0, revSize=1.0|
	var snd = JPverb.ar(in*revAmt, revTime, revDamp, revSize);
	in + snd;
}, 1, (revAmt: [0, 1], revTime: [0.1, 5], revSize: [0.5, 5.0], revDamp: [0.0, 1.0, \lin]));


// Delay master effect
ProxyChain.add3(\delay, \filter -> {|in, delayDur=1.0, fdbk=2.0, delayAmt=0|
	in+[
		AllpassC.ar(LPF.ar(HPF.ar(in[0],300),1500)*delayAmt, 1.0, delayDur, fdbk),
		AllpassC.ar(LPF.ar(HPF.ar(in[1],300),1500)*delayAmt, 1.0, delayDur+rrand(0.05,0.2), fdbk)
	];
}, 1, (delayDur: [0.05, 0.6, \lin], fdbk: [1.0, 10.0, \lin], delayAmt: [0.0, 1.0, \lin]));


// Master volume
ProxyChain.add3(\volume, \filter -> {|in, level=1.0|
	in * (level*2.5);
}, 1, (level: [0.0, 1.0]));


// Create a new MasterFX with our effects:
m  = MasterFX.new(s, 2, [\grains, \filters, \reverb, \delay, \volume], 0);

m.add(\grains, 1);
m.add(\filters, 1);
m.add(\reverb, 1);
m.add(\delay, 1);
m.add(\volume, 1);



// Influx maps few parameters to many, in a matrix of weights
a = Influx([\x, \y], [\dur, \rate, \pos,\delayDur, \fdbk, \density], (x: 0.5, y: 0.1));
(
a.action = { |val|
	m.set(\density, a.outValDict[\density].linlin(-1.0, 1.0, 1.0, 100));
	m.set(\dur, a.outValDict[\dur].linlin(-1.0, 1.0, 0.01, 1));
	m.set(\delayDur, a.outValDict[\delayDur].linlin(-1.0, 1.0, 0.05, 0.6));
	m.set(\fdbk, a.outValDict[\fdbk].linlin(-1.0, 1.0, 1.0, 10));
};
);

// See how parameters are affected

// If you are not happy AND feel lucky:
a.rand(0.7);

// Find your controller:
// You will find a line like one of the below:
// to load your controller description:
k = MKtl(\nk2, "korg-nanokontrol2");// k.gui;

// Check if your controller is working correctly
// you can trace and see the labels to know which
// button is what.


// Set what each control does.
// Examples:

// Slider 1 changes parameter \x of influx and sets MasterFX accordingly
k.elAt(\sl, 1).action_({ |elem|
	a.set(\x, elem.value.linlin(0, 1, -1, 1));
});

k.elAt(\sl, 2).action_({ |elem|
	a.set(\y, elem.value.linlin(0, 1, -1, 1));
});

k.elAt(\kn, 1).action_({ |elem|
	m.set(\hpf, \freq.asSpec.map(elem.value));
});

k.elAt(\kn, 2).action_({ |elem|
	m.set(\lpf, \freq.asSpec.map(elem.value));
});

k.elAt(\kn, 3).action_({ |elem|
	m.set(\revDamp, elem.value.linlin(0, 1, 0.0, 1.0));
});

k.elAt(\kn, 4).action_({ |elem|
	m.set(\revTime, elem.value.linlin(0, 1, 0.1, 5.0));
});

k.elAt(\kn, 5).action_({ |elem|
	m.set(\revSize, elem.value.linlin(0, 1, 0.5, 5.0));
});


k.elAt(\kn, 7).action_({ |elem|
	m.set(\level, elem.value.linlin(0, 1, 0.0, 1.0));
});




k.elAt(\sl, 5).action_({ |elem|
	m.set(\revAmt, elem.value);
});

k.elAt(\sl, 6).action_({ |elem|
	var wet = m.proxyChain.keysAt(\grains).detect { |key| key.asString.contains("wet")};
	m.set(wet, elem.value);
});

k.elAt(\sl, 7).action_({ |elem|
	//var wet = m.proxyChain.keysAt(\delay).detect { |key| key.asString.contains("wet")};
	m.set(\delayAmt, elem.value);
	//m.set(wet, elem.value);
});


k.elAt(\tr, \play).action_({|e|
	if (e.value == 1, {
		Ndef(\liveInput).play;
	}, {
		Ndef(\liveInput).stop;
	});
});

b.do {|elem,i|
	k.elAt(\bt, \S, i).action_({|e|
		if (e.value > 0, {
			elem[1].free;
			elem[1] = {PlayBuf.ar(1,elem[0])!2}.play;
		});
	});
	k.elAt(\bt, \M, i).action_({|e|
		if (e.value > 0, {
			elem[1].free;
		});
		//elem[1] = elem[0].play;
	});
};



s.scope;
s.meter;
m.gui;

~infgui = InfluxIOWGui(a);
