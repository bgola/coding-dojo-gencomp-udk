
s.boot;

~router = OSCRouterClient(\sani);
~router.join( { ~syncText = SyncText(\coderehearsal, ~router.userName, ~router); ~syncText.showDoc; });

~router.addResp(\fang2, {|msg| msg.postln;});
~router.addResp(\fang2, {|msg| msg.postln;});
~router.addResp(\fang2, {|msg| msg.postln;});
~router.addResp(\fang2, {|msg| msg.postln;});
~router.addResp(\fang2, {|msg| msg.postln;});

~buffer = Buffer.read(s,"/Users/mnm/Desktop/rgrt/1610 qtm_spektrum/watmm_04_04_br3.aif");
~buffer2 = Buffer.read(s,"/Users/mnm/Desktop/rgrt/1610 qtm_spektrum/watmm_04_04_br5.aif");

~buffer.play();
~buffer.free();

~buffer2.play();
~buffer2.free();


(
Ndef(\glitchBuf, {
	arg rate1=1, rate2=1, mix=0.5, loop = 0, fr = 440, rq=10, pulseFreq = 440.0;
	var sig, file1, file2, out, pulsingMul;

	file1 = PlayBuf.ar(1, ~buffer, rate1, loop: loop);
	file2 = PlayBuf.ar(1, ~buffer2, rate2, loop: loop);

	file1 = file1 * mix;
	file2 = file2 * (1 - mix);
	sig = file1 + file2;

	pulsingMul = LFPulse.ar(freq: pulseFreq, mul: 1.0);
	sig = BPF.ar(in: sig, freq: fr, rq: rq, mul: pulsingMul);

	out = Out.ar(0, sig!2);
})
)

~router.addResp(\fang2, {arg msg;
	if(0.3.coin) {
		fork {
			1.wait;
			~rouoter.sendMsg(Ndef(\glitchBuf).set(\fr, msg[1]))
			}
		}
	}
);




Ndef(\glitchBuf).play
Ndef(\glitchBuf).clear

Ndef(\glitchBuf).set(\loop, 1)

Ndef(\glitchBuf).clear(\buffer1, ~buffer, \buffer2, ~buffer2)
Ndef(\glitchBuf).set(\rate2, 5.0, \rate1, 8.0, \mix, 1.0.rand, \fr, 2000,\rq, 10.0)
Ndef(\glitchBuf).set(\pulseFreq, exprand(2, 1000).postln)


Ndef(\glitchBuf).gui



~counter=0;
Tdef(\chunli, {arg envir;
	var newfreq;
	~counter = ~counter+1;
	if(~counter==4){
		newfreq = (envir.freq-10).postln;
		~counter = 0;
	}

	sendMsg(\chunli, newfreq);
}).clear






Ndef(\gate).set(\mode, 1, \speed, 4)

(
Ndef(\synth, {
	arg vol= 0.3;
	var sig;
	var freq = Ndef(\synthmelo).kr;
	var mod = Ndef(\synthmod).ar;
	sig = EnvGen.ar(Env.perc, Ndef(\gate).kr)  * SinOsc.ar(freq*mod, mul: vol) ! 2
}).play
)


(
//create a melody
Ndef(\synthmelo, {
	arg vol = 1.0;
	var freqs = [800,10000,8000,8400];
	var a, trig;
	a = Dseq(freqs,inf);
	trig = Ndef(\gate).kr;
	Demand.kr(trig,0,a);
});
)


(
Ndef(\synthmod, {
	arg vol= 1.0;
	var sig;
	var ratio = Demand.kr(Ndef(\gate).kr, 0,
		Dseq([0.25, 0.3, 0.5, 0.75, 0.125, 1.0, 2.0], inf));
	var freq = Ndef(\synthmelo).kr*ratio;
	Pulse.ar(freq).range(0, SinOsc.kr(0.01).range(0.1,10));
})
)

(
Ndef(\gate, { arg speed = 10, mode=0;
	Select.kr(mode, [
		Impulse.kr(speed),
		Dust.kr(speed)
	]);
});
)


(
~counter=0;
Tdef(\chunli, {arg envir;
	var newfreq;
	~counter = ~counter+1;
	if(~counter==4){
		newfreq = (envir.freq-10);
		~counter = 0;
	}
})
)
