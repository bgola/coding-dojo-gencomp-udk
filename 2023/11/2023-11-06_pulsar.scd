/*

Coding dojo

06.11.2023

- Implement Pulsar Synthesis as an Ndef
- parameters:
+ fundamental frequency
+ formant frequency
+ multiple envelope shapes
+ multiple formants
+ panning and amplitude control

+ Implement NdefPreset for our Ndef

- make our Ndef NTMI-ready

*/

// create a buffer and fill it with some sine waves
(
b = Buffer.alloc(s, 2048, 1);
g = Signal.sineFill(2048, [7,0.5,2,19], [0]);
b.loadCollection(g);
/*
b.plot;
*/
);

// define parameter ranges
(
Ndef(\pulsar).addSpec(\fundfreq, [1, 1000, \exp]);
Ndef(\pulsar).addSpec(\amp, \amp);
Ndef(\pulsar).addSpec(\formfreq1, [20, 20000, \exp]);
Ndef(\pulsar).addSpec(\curve1, [-10, 10, \lin]);
Ndef(\pulsar).addSpec(\amp1, \amp);
Ndef(\pulsar).addSpec(\pan1, \pan);
Ndef(\pulsar).addSpec(\formfreq2, [20, 20000, \exp]);
Ndef(\pulsar).addSpec(\curve2, [-10, 10, \lin]);
Ndef(\pulsar).addSpec(\amp2, \amp);
Ndef(\pulsar).addSpec(\pan2, \pan);
Ndef(\pulsar).addSpec(\formfreq3, [20, 20000, \exp]);
Ndef(\pulsar).addSpec(\curve3, [-10, 10, \lin]);
Ndef(\pulsar).addSpec(\amp3, \amp);
Ndef(\pulsar).addSpec(\pan3, \pan);


// make an Ndef that does pulsar synthesis
(
// amp has to be first for NTMI
Ndef(\pulsar, { |amp = 1,
    fundfreq = 10,
    formfreq1 = 100, curve1= -4, pan1 = 0, amp1= 1,
    formfreq2 = 100, curve2= -4, pan2 = 0, amp2= 1,
    formfreq3 = 100, curve3= -4, pan3 = 0, amp3= 2
    |
    var trig, pulseReader, bufferOutput, shapes, envelope, unpanned;
    var formfreqs = [formfreq1,formfreq2,formfreq3];
    var curves = [curve1, curve2, curve3];
    var pans = [pan1, pan2, pan3];
    var amps = [amp1, amp2, amp3];
    var pulseDur = 1/formfreqs.clip(fundfreq,20000);

// generate a trigger signal for the pulsar waveform playback
    trig = Impulse.ar(fundfreq);
    pulseReader = EnvGen.ar(Env([0, 1, 0], [pulseDur, 0]), trig);

    // Envelope for the waveform
    envelope = EnvGen.ar(Env.perc(0, pulseDur, curve: curves), trig);

    bufferOutput = BufRd.ar(1, b.bufnum,
        pulseReader * BufFrames.ir(b.bufnum),
        0);
    Mix.ar(Pan2.ar(bufferOutput * envelope, pans, amps));
});
);
);

// NTMI compatibility - when you run the whole file,
// build Ndef once, then end it on startup
fork { 0.3.wait; Ndef(\pulsar).end };

/* Preset tests:

p = NdefPreset(Ndef(\pulsar));
NdefPresetGui(p, 16);

p.setRand(1.0)
*/

