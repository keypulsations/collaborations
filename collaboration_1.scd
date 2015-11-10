(
{
  var trig, snd, melody;
  trig = Impulse.ar(7, 0, LFSaw.kr(1/14, 1)<0.75) * SinOsc.ar(331);
  snd = GVerb.ar(trig, 2, 1, spread: 50) * RLPF.ar(LFSaw.ar(333), LFNoise1.kr(2, 4, 100).midicps);

  snd = Select.ar(
    SetResetFF.ar(Impulse.ar(7) * SinOsc.ar(11.326)),
    [snd, Compander.ar(snd * LFPulse.ar(3000))]
  );

  // borrowing from Nathnainiel's melodic idea here
  snd = snd + FreeVerb.ar(AllpassC.ar(Ringz.ar(Impulse.ar(7, mul: 0.075),
    Select.kr(SinOsc.kr(4).range(0, 5), // try different freqs for SinOsc [4, 8, etc.] and max ranges...5, 10, 20
      [329.63, 493.88, 392.00, 587.33, 659.25]),
    0.2), 0.02, 0.02, 4, 4), 0.1, 0.5, 0.5);

  // variant
  /*  snd = snd + FreeVerb.ar(AllpassC.ar(Ringz.ar(Impulse.ar(7, mul: 0.1),
  Select.kr(SinOsc.kr(1).range(0, 4),
  [329.63, 493.88, 392.00, 587]),
  0.2), 0.02, 0.02, 4, 4), 0.1, 0.25, 0.25);*/


  Limiter.ar(snd);

}.play;
)
