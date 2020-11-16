// sound file
// grains
// blend two sound files glitchy

// create a synthesizer that blends two sound files. the parameters are:
//  soundfile1
//  soundfile2
//  mix
//  glitchyness:chop file and blend
//  mode
//    0: mix both files
//    1: file1 influences file2

s.boot

//read sound file
~buffer = Buffer.read(s,"/home/bgola/workspace/samples/dmxkrew/mag02.wav");
~buffer2 = Buffer.read(s,"/home/bgola/workspace/samples/n0p/techno_pad_intro_keys_132bpm.wav");
// define server 1. s 2. Server.default
~buffer.play();
~buffer.stop();

// create synth from buffer
SynthDef.new(\mag02,{
	arg rate=1;
	var sig, out;
	sig = PlayBuf.ar(1, ~buffer, rate, doneAction:Done.freeSelf);
	out = Out.ar(0, sig!2)
}).add;

x = Synth(\mag02, [\rate, 0.1])
x.set(\rate, 0.1)
x.free
mag02Synth = Synth


// play two buffers at the same time with individual rates
// create synth from buffer
SynthDef.new(\twoBufs,{
	arg rate1=1, rate2=1, buffer1, buffer2, mix=0.5;
	var sig, file1, file2, out;
	file1 = PlayBuf.ar(1, buffer1, rate1, doneAction:Done.freeSelf);
	file2 = PlayBuf.ar(1, buffer2, rate2, doneAction:Done.freeSelf);
	file1 = file1 * mix;
	file2 = file2 * (1 - mix);
	sig = file1 + file2;
	out = Out.ar(0, sig!2);
}).add;

x = Synth(\twoBufs, [\buffer1, ~buffer, \buffer2, ~buffer2])


x.set(\mix, 1.0)

// PlayBuf with loop
// Autoplay next sound file

SynthDef.new(\twoBufs,{
	arg rate1=1, rate2=1, buffer1, buffer2, mix=0.5, loop = 1;
	var sig, file1, file2, out;
	file1 = PlayBuf.ar(1, buffer1, rate1, loop: loop, doneAction:Done.freeSelf);
	file2 = PlayBuf.ar(1, buffer2, rate2, loop: loop, doneAction:Done.freeSelf);
	file1 = file1 * mix;
	file2 = file2 * (1 - mix);
	sig = file1 + file2;
	out = Out.ar(0, sig!2);
}).add;

x = Synth(\twoBufs, [\buffer1, ~buffer, \buffer2, ~buffer2])

x.set(\rate2, 4.0, \rate1, 4.0)





// chop soundfile and blend
(
SynthDef.new(\twoBufs,{
	arg rate1=1, rate2=1, buffer1, buffer2, mix=0.5, loop = 1, fr = 440, rq=1, pulseFreq = 440.0;
	var sig, file1, file2, out, pulsingMul;
	file1 = PlayBuf.ar(1, buffer1, rate1, loop: loop, doneAction:Done.freeSelf);
	file2 = PlayBuf.ar(1, buffer2, rate2, loop: loop, doneAction:Done.freeSelf);
	file1 = file1 * mix;
	file2 = file2 * (1 - mix);
	sig = file1 + file2;

	// a pulse to control the mul(volume) of the BPF filter
	pulsingMul = LFPulse.ar(freq: pulseFreq, iphase: 0.0, width: 0.5, mul: 1.0, add: 0.0);

	sig = BPF.ar(in: sig, freq: fr, rq: rq, mul: pulsingMul, add: 0.0);


	out = Out.ar(0, sig!2);
}).add;
)
x = Synth(\twoBufs, [\buffer1, ~buffer, \buffer2, ~buffer2]);

x.set(\rate2, 1.0, \rate1, 2.0, \mix,1.0.rand,\fr, 1000,\rq, 1.0)
x.set(\pulseFreq, exprand(5,50).postln)

x.free;



// LFNoise on mix to create glitchyness between audio files


(
SynthDef.new(\twoBufs,{
	arg rate1=1, rate2=1, buffer1, buffer2, loop = 1, fr = 440, rq=1, pulseFreq = 440.0, glitchfrq=1, mode=0;
	var sig, file1, file2, out, pulsingMul, mix;
	file1 = PlayBuf.ar(1, buffer1, rate1, loop: loop, doneAction:Done.freeSelf);
	file2 = PlayBuf.ar(1, buffer2, rate2, loop: loop, doneAction:Done.freeSelf);

	mix = Select.kr(mode, [
		LFNoise0.kr(glitchfrq).range(0, 1.999999999).floor,
		LFNoise0.kr(glitchfrq).range(0, 1.0),
	]);

	file1 = file1 * mix;
	file2 = file2 * (1 - mix);

	sig = Select.ar(BinaryOpUGen('==', mode, 2), [
		file1 + file2,
		file1 * file2
	]);

	// a pulse to control the mul(volume) of the BPF filter
	pulsingMul = LFPulse.ar(freq: pulseFreq, iphase: 0.0, width: 0.5, mul: 1.0, add: 0.0);

	sig = BPF.ar(in: sig, freq: fr, rq: rq, mul: pulsingMul, add: 0.0);
	out = Out.ar(0, sig!2);
}).add;
)
x = Synth(\twoBufs, [\buffer1, ~buffer, \buffer2, ~buffer2]);

x.set(\rate2, 1, \rate1, 0.3, \mix,1.0.rand,\fr, 2000,\rq, 6.0)
x.set(\pulseFreq, exprand(0.5,50).postln)
x.set(\pulseFreq, 0)

// automatic chaning mode in random timing

(
fork	{
	loop	{
		x.set(\mode, choose([0, 1]).postln);
		x.set(\glitchfrq, 20.0.rand, \mode, 0, \fr, 1400, \rq, 10);
		1.0.rand.wait;
	}
}
)

x.set(\glitchfrq, 20, \mode, 0, \fr, 1400, \rq, 10)

x.free;

2.03213.floor

// Different LFNoises

{[LFNoise0.ar(10), LFNoise1.ar(10), LFNoise2.ar(10)]}.plot(1);


{[Impulse.kr(10), Dust.kr(10)]}.plot(1);



/* FEEDBACK

Pros:
  Accessible
  Successful goal :)
  Step by step
  Thought process based
  Nice sounds

Cons:
  Keyboard layout problems as always
  Text bigger next time

Suggestion:
  Try different rotation dynamics of pairs / pilot - co-pilot

*/