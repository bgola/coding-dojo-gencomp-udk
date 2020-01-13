// Silly way to load files to an array
b = [];
b = b.add(Buffer.read(s, "Users/fangtsai/Desktop/superCollider/dojo samples/mag01.wav"));
b = b.add(Buffer.read(s, "Users/fangtsai/Desktop/superCollider/dojo samples/mag02.wav"));
b = b.add(Buffer.read(s, "Users/fangtsai/Desktop/superCollider/dojo samples/tou00.wav"));
b = b.add(Buffer.read(s, "Users/fangtsai/Desktop/superCollider/dojo samples/tou01.wav"));
b = b.add(Buffer.read(s, "Users/fangtsai/Desktop/superCollider/dojo samples/tou02.wav"));
b = b.add(Buffer.read(s, "Users/fangtsai/Desktop/superCollider/dojo samples/tou03.wav"));

Buffer.read(s, "Users/fangtsai/Desktop/superCollider/dojo samples/mag01.wav")

// How to play one of the buffers
x = b.choose.play;
// ... and how to stop it:
x.free;

// If you want Live input from your mic:
(
Ndef(\liveinput).set(\inVol, 0.5);
Ndef(\liveinput, {|inVol|
	SoundIn.ar(0, mul: inVol)}).play;
)

Ndef(\liveinput).stop;

// How to play one of the buffers in a random loop
/*(
Tdef(\loopBuf,{
	loop{
		var buf = b.choose;
		buf.play;
		buf.duration.wait;
	}
}).stop;
)*/

(
Ndef(\loopBufN).set(\buf1, b[1]);
Ndef(\loopBufN2).set(\buf2, b[1]);

Ndef(\loopBufN).set(\sPos,0);
Ndef(\loopBufN2).set(\sPos,0);

Ndef(\loopBufN,{|buf1, sPos|
	PlayBuf.ar(1, buf1, startPos: 1 , loop:1);
}).play;
Ndef(\loopBufN2,{|buf2, sPos|
	PlayBuf.ar(1, buf2, startPos: 1 , loop:1);
}).play;
)

(
/*n = NdefGui.new;
n.object_(Ndef(\loopBufN2));*/
Ndef(\loopBufN).stop;
Ndef(\loopBufN2).stop;
)
///////////////////////////
// Add some effects to our Master output:
(
// Granular master effect
~masterGrainBuf = Buffer.alloc(s, s.sampleRate*2, 1);
ProxyChain.add3(\grains, \filter -> {|in, dur=0.1, density=10, pos=0|
	var snd;
	RecordBuf.ar(in[0], ~masterGrainBuf);

	snd = GrainBuf.ar(
		2, Impulse.ar(density), dur, ~masterGrainBuf, 1,
		pos);
	//LFNoise1.ar(4).range(0.0, 1.0), 2, LFNoise1.ar(1).range(-1,1)
	/*snd = Mix.ar([snd, GrainBuf.ar(
		4, Impulse.ar(density), dur, ~buf2, rate,
		0, 2, LFNoise1.ar(1).range(-1,1))]);*/
	Mix.ar([snd, JPverb.ar(snd*0.1, 2.0)]);
}, 1, (dur: [0.01, 2.0, \lin], density: [1.0, 100.0, \exp], pos: [0.0, 1.0, \lin]));

// HPfilter master effect
ProxyChain.add3(\hpf, \filterIn -> {|in, hFreq = 440.0 |
	HPF.ar(in, 4.0, freq: hFreq);
}, 1, (hFreq: [20.0, 5000.0, \exp]));


// LPfilter master effect
ProxyChain.add3(\lpf, \filterIn -> {|in, lFreq = 440.0 |
	LPF.ar(in, 4.0, freq: lFreq);
}, 1, (lFreq: [20.0, 20000.0, \exp]));

// Delay master effect
ProxyChain.add3(\delay, \filterIn -> {|in, delayDur=1.0, fdbk=2.0|
	AllpassC.ar(in, 4.0, delayDur, fdbk);
}, 1, (delayDur: [0.05, 4.0, \lin], fdbk: [1.0, 10.0, \lin]));

// Volume master effect
ProxyChain.add3(\volume, \filterIn -> {|in, level=1.0|
	in * level;
}, 1, (level: [0.0, 1.0, \lin]));
)

(
// Create a new MasterFX with our effects:
m  = MasterFX.new(s, 2, [\grains,\hpf,\lpf, \delay, \volume,], 0);

m.add(\grains, 1);
m.add(\hpf, 1);
m.add(\lpf, 1);
m.add(\delay, 1);
m.add(\volume, 1);
)
// See effects:
m.gui


///question: how to read which buffer is reading?
///question how to read


m.clear
MasterFX.clear



// Influx maps few parameters to many, in a matrix of weights
/*a = Influx([\x, \y], [\dur, \rate, \pos,\delayDur, \fdbk, \density], (x: 0.5, y: 0.1));
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
*/




// Find your controller:
MKtl.find
// You will find a line like one of the below:
// to load your controller description:

k = MKtl(\nk2, "korg-nanokontrol2");// k.gui;



k.gui

// Check if your controller is working correctly
// you can trace and see the labels to know which
// button is what.



// Set what each control does.
// Examples:
(
// Slider 1 changes parameter \x of influx and sets MasterFX accordingly
k.elAt(\sl, 0).action_({ |elem|
	m.set(\dur, elem.value.linlin(0, 1, 0.01, 2.0));
});

k.elAt(\sl, 1).action_({ |elem|
	m.set(\density, elem.value.linexp(0, 1, 1, 100));
});

k.elAt(\sl, 2).action_({ |elem|
	m.set(\pos, elem.value.linlin(0, 1, -1.0, 1.0));
});

k.elAt(\sl, 7).action_({ |elem|
	m.set(\delayDur, elem.value.linlin(0, 1, 0.05, 4));
});

k.elAt(\sl, 3).action_({ |elem|
	Ndef(\loopBufN).set(\sPos, elem.value.linlin(0, 1, 1, 4000));
	Ndef(\loopBufN2).set(\sPos, elem.value.linlin(0, 1, 1, 4000));
});

k.elAt(\sl, 4).action_({ |elem|
	m.set(\fdbk, elem.value.linlin(0, 1, 1.0, 10.0));
});

k.elAt(\kn, 6).action_({ |elem|
	Ndef(\liveinput).set(\inVol,  elem.value.linlin(0, 1, 0.0, 1.0));
});

k.elAt(\kn, 7).action_({ |elem|
	m.set(\level, elem.value.linlin(0, 1, 0.0, 1.0));
});
k.elAt(\kn, 0).action_({ |elem|
	m.set(\hFreq,  elem.value.linexp(0, 1, 5000.0, 20.0));
});
k.elAt(\kn, 1).action_({ |elem|
	m.set(\lFreq,  elem.value.linexp(0, 1, 20.0, 20000.0));
});

//////////buf1//////////////

k.elAt(\bt, \S, 0).action_({ |elem|
	Ndef(\loopBufN).set(\buf1, b[0]);
});


k.elAt(\bt, \S, 1).action_({ |elem|
	Ndef(\loopBufN).set(\buf1, b[1]);
});

k.elAt(\bt, \S, 2).action_({ |elem|
	Ndef(\loopBufN).set(\buf1, b[2]);
});

k.elAt(\bt, \S, 3).action_({ |elem|
	Ndef(\loopBufN).set(\buf1, b[3]);
});

k.elAt(\bt, \S, 4).action_({ |elem|
	Ndef(\loopBufN).set(\buf1, b[4]);
});

k.elAt(\bt, \S, 5).action_({ |elem|
	Ndef(\loopBufN).set(\buf1, b[5]);
});

k.elAt(\bt, \S, 6).action_({ |elem|
	Ndef(\loopBufN).set(\buf1, b[6]);
});
////////////////buf2//////////////////

k.elAt(\bt, \M, 1).action_({ |elem|
	Ndef(\loopBufN2).set(\buf2, b[1]);
});

k.elAt(\bt, \M, 2).action_({ |elem|
	Ndef(\loopBufN2).set(\buf2, b[2]);
});

k.elAt(\bt, \M, 3).action_({ |elem|
	Ndef(\loopBufN2).set(\buf2, b[3]);
});

k.elAt(\bt, \M, 4).action_({ |elem|
	Ndef(\loopBufN2).set(\buf2, b[4]);
});

k.elAt(\bt, \M, 5).action_({ |elem|
	Ndef(\loopBufN2).set(\buf2, b[5]);
});

k.elAt(\bt, \M, 6).action_({ |elem|
	Ndef(\loopBufN2).set(\buf2, b[6]);
});
)

Ndef(\loopBufN2).gui;
//
// k.elAt(\tr, \mleft).action_({ |elem|
// 	i = Ndef(\loopBufN).get(\buf2);
// 	i = i -1;
// 	Ndef(\loopBufN).set(\buf2, i.clip(0,6));
// });
//
// k.elAt(\tr, \mright).action_({ |elem|
//
// 	//i = i +1;
// 	Ndef(\loopBufN).set(\buf2, b[1]);
// });
