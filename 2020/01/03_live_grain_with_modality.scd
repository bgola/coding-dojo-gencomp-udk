



~buf = Buffer.alloc(s, s.sampleRate * 1, 1);

(
Ndef(\liveGrain, {
	arg rate=1, dur=0.1, density=10, pos=1, rec=1;
	var snd;
	RecordBuf.ar(SoundIn.ar(1), ~buf, run: rec);
	snd = GrainBuf.ar(
		4, Impulse.ar(density), dur, ~buf, rate,
		pos, 2, LFNoise1.ar(1).range(-1,1));
	Mix.ar([snd, JPverb.ar(snd*0.1, 2.0)]);
}).play;

)

Ndef(\liveGrain).gui



(
MKtlDesc.loadDescs("*trol2");
k = MKtl(\nk2, "*trol2");// k.gui;
)

k.gui

k.elAt(\kn, 1).action_({ |elem|
	Ndef(\liveGrain).set(\dur, elem.value.linlin(0.0, 1.0, 0.005, 1).postln);
});

k.elAt(\kn, 2).action_({ |elem|
	Ndef(\liveGrain).set(\density, elem.value.linlin(0.0, 1.0, 1.0, 400).postln);
});


k.elAt(\kn, 3).action_({ |elem|
	Ndef(\liveGrain).set(\rate, elem.value.linlin(0.0, 1.0, 0.2, 10));
});

k.elAt(\kn, 4).action_({ |elem|
	Ndef(\liveGrain).set(\pos, elem.value.linlin(0.0, 1.0, 0.0, 1.0));
});


k.elAt(\bt, \S, 0).action_({ |elem|
	Ndef(\liveGrain).set(\rec, 0);
});

k.elAt(\bt, \M, 0).action_({ |elem|
	Ndef(\liveGrain).set(\rec, 1);
});