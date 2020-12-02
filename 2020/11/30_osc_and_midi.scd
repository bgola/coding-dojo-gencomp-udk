// Control twoBufs parameters using OSC and MIDI


// mode: button
// rate1 & rate2: X Y 
// pulseFreq: 
// extra: filter frequency and rq


(
SynthDef.new(\twoBufs,{
	arg rate1=1, rate2=1, buffer1, buffer2, fr = 440, rq=1, pulseFreq = 440.0, glitchfrq=1, mode=0;
	var sig, file1, file2, out, pulsingMul, mix;
	file1 = PlayBuf.ar(1, buffer1, rate1, loop: 1);
	file2 = PlayBuf.ar(1, buffer2, rate2, loop: 1);

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

arg rate1=1, rate2=1, buffer1, buffer2, loop = 1, fr = 440, rq=1, pulseFreq = 440.0, glitchfrq=1, mode=0;


(
OSCdef(\xy, { arg msg, time, addr;
	var rate1 = msg[1];
	var rate2 = msg[2];
	"This is:".postln;
	msg.postln;
	x.set(\rate1,rate1);
	x.set(\rate2,rate2);

}, "/r_xy/1");
	
)


(
OSCdef(\qrControl, { arg msg, time, addr;
	var fr = msg[1].linexp(0, 1, 20,20000);
	var rq = msg[2];
	"This is:".postln;
	msg.postln;
	x.set(\fr,fr);
	x.set(\rq,rq);

}, "/qr_xy");
	
)


(
OSCdef(\fader1, { arg msg, time, addr;
	var fader1 = msg[1].linexp(0, 1, 0.01, 1000);
	"This is fader1:".postln;
	fader1.postln;
	x.set(\pulseFreq,fader1);
}, "/1/fader1");
)

(
OSCdef(\fader2, { arg msg, time, addr;
	var fader2 = msg[1].linexp(0, 1,0.1,1);
	"This is fader2:".postln;
	fader2.postln;
	x.set(\glitchfrq,fader2);
}, "/1/fader2");
)

(
MIDIdef.cc(\mode0, { arg val, num, channel, srcID;
	if (val == 127) {
		if (num == 32) {
			x.set(\mode, 0);
		} {
			x.set(\mode, 1);
		};
	};
}, [32, 48]);
)


(
MIDIdef.cc(\mode0, { 
}, 48, 0);
)

MIDIFunc.trace(true)

OSCdef(\xy).enable

f.disable
f.enable

OSCFunc.trace(false)



Modality

MIDIClient
CCResponder


MIDIIn.connectAll
MIDIFunc.trace(true)



n = NetAddr("194.95.203.163", 9000);


n.sendMsg("/1/fader1", 1.0.rand)
