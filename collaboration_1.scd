(
{
	var trig, snd;
	trig = Impulse.ar(7) * SinOsc.ar(331);
	snd = GVerb.ar(trig, 1) * RLPF.ar(LFSaw.ar(333), LFNoise1.kr(2, 4, 100).midicps);
	snd = Select.ar(
		ToggleFF.ar(Impulse.ar(7) * SinOsc.ar(11.326)),
		[snd, Normalizer.ar(snd * LFPulse.ar(3000), 0.1)]
	);
	snd = snd + Ringz.ar(PinkNoise.ar()*0.0005, Lag2.kr(
		Select.kr(LFNoise1.kr(1.625).range(0, 11),
			[336, 300, 369, 356, 336, 336, 300, 369, 400, 504, 450]), 0.1),
		5);
	Limiter.ar(snd);
}.play;
)