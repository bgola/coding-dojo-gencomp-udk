/*

08/05/2023

GOAL:
- N track looper

features of the looper:

- record a track
- loop a track
- playback speed for each track
- individually start and stop each track
- erase a track
- overdub
- pan per track
- loop length per track

*/

s.options.outDevice = ServerOptions.outDevices[0]
s.boot;
().play

// Get some sound in from the mic
// Record the sound in to a buffer
~maxloop = 5;

~buf = Buffer.alloc(s, s.sampleRate*~maxloop);
~buf2 = Buffer.alloc(s, s.sampleRate*~maxloop);

// overdub; preLevel: 0/1(off/on)
Ndef(\recorder, {RecordBuf.ar(SoundIn.ar(0), ~buf, loop:0, preLevel: 1)});
Ndef(\recorder2, {RecordBuf.ar(SoundIn.ar(0), ~buf2, loop:0, preLevel: 1)});

~buf.play;
~buf.plot;

~buf.bufnum;

// to find something about an object
b.dump;

// make the buffer loop
//{PlayBuf.ar(1, b, loop: 1)}.play

//Playbackspeed and panning
(
Ndef(\loop1, {
        arg rate = 1, pan = 0, loopdur = 2;
        var trig = Impulse.kr(1/loopdur * rate);
        Pan2.ar(PlayBuf.ar(1, ~buf, rate, trigger: trig, loop: 0,), pan)
}).play
);

(
Ndef(\loop2, {
        arg rate = 1, pan = 0, loopdur = 2;
        var trig = Impulse.kr(1/loopdur * rate);
        Pan2.ar(PlayBuf.ar(1, ~buf2, rate, trigger: trig, loop: 0,), pan)
}).play
);


Ndef(\loop1).reshaping = \elastic;
Ndef(\loop1).numChannels;
Ndef(\loop1).scope;
Ndef(\loop1).stop;

Ndef(\loop1).set(\rate, 1, \pan, 0, \loopdur, 2);
Ndef(\loop1).gui;
Ndef(\loop2).gui;

// erase a loop/existing buffer
Ndef(\recorder, {RecordBuf.ar(Silent.ar(1), ~buf, loop:0)});
Ndef(\recorder2, {RecordBuf.ar(Silent.ar(1), ~buf2, loop:0)});






// Multiple bufs recorder
~bufs = 10.collect { Buffer.alloc(s,s.sampleRate*~maxloop) };

(
Ndef(\recorder, {
        var triggers = ~bufs.size.collect { arg idx; "t_trig_%".format(idx).asSymbol.kr(0)}.postln;
        RecordBuf.ar(SoundIn.ar(0), ~bufs, loop:0, preLevel: 1, trigger: triggers)
});
)


Ndef(\recorder).set(\t_trig, 1)
Ndef(\recorder).set(\t_trig2, 1)