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
	snd = SinOsc.ar(662 * [1.2, 1.5]) * Trig.ar(cut, 0.01) * 0.03 + snd;
	Limiter.ar(snd);
}.play;
)