(
Ndef(\combzzzzz).addSpec(\modfreq1, [0.01, 100, \exp]);
Ndef(\combzzzzz).addSpec(\modfreq2, [0.01, 100, \exp]);
Ndef(\combzzzzz).addSpec(\modfreq3, [0.01, 100, \exp]);
Ndef(\combzzzzz).addSpec(\modfreq4, [0.01, 100, \exp]);

Ndef(\combzzzzz).addSpec(\min, [0.2, 20, \exp]);
Ndef(\combzzzzz).addSpec(\max, [0.2, 20, \exp]);

Ndef(\combzzzzz, {
	arg modfreq1=1, modfreq2=1, modfreq3=1, modfreq4=1, min=1, max=1;
	var in, del1, del2, del3, del4;
    in = SoundIn.ar(0);
	del1 = CombC.ar(in, 8, LFDNoise3.kr(modfreq1).range(min, max), 1);
    del2 = CombC.ar(del1, 8, LFDNoise3.kr(modfreq2).range(min, max), 1);
    del3 = CombC.ar(del2, 8, LFDNoise3.kr(modfreq3).range(min, max), 1);
    del4 = CombC.ar(del3, 8, LFDNoise3.kr(modfreq4).range(min, max), 1);
	[del1 + del3, del2 + del4];
})
)