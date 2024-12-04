/*
Buffer scrubbing in the style of vynil scratch simulation.

Using a Buffer that we load from the file system and use control parameters or mouse to set position and amplitude.
*/

// Choose a .wav file
//        you can also use:
// b = Buffer.loadDialog;
b = Buffer.read(s, "~/scratch.wav".standardizePath);

(
Ndef(\scratch).addSpec(\pos, [0, 1]);
Ndef(\scratch).addSpec(\offset, [0, b.numFrames]);
Ndef(\scratch).addSpec(\scratchLength, [0, 2]);
Ndef(\scratch).addSpec(\lagtime, [0, 1]);
Ndef(\scratch).addSpec(\playback, [0, 1, \lin, 1]);

Ndef(\scratch, {
	arg pos = 0, scratchLength = 0.4, offset = 0, lagtime = 0.1, playback=1;
	// PlayBuf.ar(b.numChannels, b.bufnum, 1.0)
	var phs = Phasor.ar(0, playback, 0, b.numFrames);
	var apos = (phs + K2A.ar((pos).lag(lagtime)));
	BufRd.ar(b.numChannels,
		b.bufnum,
		(phs+offset) +
		(K2A.ar((pos).lag(lagtime))
			* scratchLength
			* b.sampleRate))
	// Envelope so it only sounds if playback is on or
	// if we change the position (scratch)
	* ((playback | Changed.kr(pos)).lag(0.1) > 0)
}).play;
)

(
// Autoscratch without pause
Tdef(\autoScratch, {
	loop {
		Ndef(\scratch).set(\pos, 1.0.rand);
		0.01.wait;
	}
}).play;
)


(
// Auto scratch with pause
Tdef(\autoScratch, {
	loop {
		100.rand.do {
			Ndef(\scratch).set(\pos, 1.0.rand);
			0.05.rand.wait;
		};
		1.0.wait;
		Ndef(\scratch).set(
			\offset, b.numFrames.rand,
			\scratchLength, rrand(0.1,2),
			\lagtime, rrand(0.01,0.8),
		);
	}
}).play;
)

(
// autoscratch with multiple points
Tdef(\autoScratch, {
	loop {
		var points = rrand(2,10).collect {1.0.rand};
		var intervals = (points.size - 1).collect { 1.0.rand }.normalizeSum;
		var nloops = 100.rand;
		nloops.do {|idx|
			var normIdx = idx/nloops;
			var currentSlice = (normIdx * (points.size-1)).floor.asInteger;
			var current = normIdx.linlin(
				(currentSlice/points.size), ((currentSlice+1)/(points.size-1)),
				points[currentSlice], points[currentSlice+1]);
			Ndef(\scratch).set(\pos, current);
			(intervals[currentSlice] * (0.05.rand * points.size)).wait;
		};
		1.0.wait;
		if (Ndef(\scratch).get(\playback) < 1) {
			Ndef(\scratch).set(
				\offset, b.numFrames.rand,
				\scratchLength, rrand(0.1,2),
				\lagtime, rrand(0.01,0.8),
			);
		};
		1.0.rand.wait;
	}
}).play;
)

Ndef(\scratch).gui

// Multichannel LFDNoise scratch
(
~numChannels = 2;

Ndef(\scratchMC).addSpec(\pos, [0, 1]);
Ndef(\scratchMC).addSpec(\offset, [0, b.numFrames]);
Ndef(\scratchMC).addSpec(\scratchLength, [0, 2]);
Ndef(\scratchMC).addSpec(\lagtime, [0, 1]);

Ndef(\scratchMC).reshaping = \elastic;
Ndef(\scratchMC, {
	arg pos = 0, scratchLength = 2, offset = 0, lagtime = 0.1;
	var phs = Phasor.ar(0, 1, 0, b.numFrames);
	var apos = (phs + K2A.ar((pos).lag(lagtime)));
	BufRd.ar(b.numChannels,
		b.bufnum,
		(phs+offset) +
		(K2A.ar((LFDNoise3.ar(\dens.kr(1)*{10.0.rand}!~numChannels) * LFDNoise1.ar(1.0!~numChannels) > 0).lag(lagtime))
			* scratchLength
			* b.sampleRate)).flop.sum
}).scope;
Ndef(\monitor, {Splay.ar(Ndef(\scratchMC).ar(~numChannels))});
Ndef(\scratchMC).gui
)

