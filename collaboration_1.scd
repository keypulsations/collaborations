(
{
	var trig, cut, snd;
	trig = Impulse.ar(7) * SinOsc.ar(331);
	snd = GVerb.ar(trig, 1) * RLPF.ar(LFSaw.ar(333), LFNoise1.kr(2, 4, 100).midicps);
	cut = Impulse.ar(7) * SinOsc.ar(11.326);
	snd = Select.ar(
		ToggleFF.ar(cut),
		[snd, Normalizer.ar(snd * LFPulse.ar(3000), 0.1)]
	);
	snd = snd + SinOsc.ar(331 * 1.5 * 2, 0, Trig.ar(cut, 0.01) * 0.03);
	Limiter.ar(snd);
}.play;
)