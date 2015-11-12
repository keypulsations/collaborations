(
{
  var trig, snd, melody, bass, active, ff, wanderfreq, wander;
  active = LFSaw.kr(1/14, 1)<0.75;
  trig = Impulse.ar(7, 0, active) * SinOsc.ar(331);
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

  // Glen's wonky bass
  bass = PMOsc.ar(
    SinOsc.kr(7/24, 0, 12, 52 + LFNoise0.kr(7/6,  4)).round(4).midicps.lag * [1, 1.01],
    [165, 168.3],
    SinOsc.kr([1/7, 1/3]).exprange(0.25, 4),
    0,
    LFPulse.kr(7/2, [0.5, 0], LFDNoise0.kr(7/32, 0.4, 0.5!2), -15.dbamp)
  );
  bass = bass * (LFPulse.kr(8/14, 0, 0.2) + LFPulse.kr(14, 0, 0.7)).clip(0,1).lag;
  ff = active.lag;
  bass = BLowShelf.ar(bass, 200, 1, 6) * ff + (1 - ff * HPF.ar(bass, 200, -6.dbamp));
  bass = CombN.ar(bass.reverse, 1, 3.5/7, 0.75, 0.2, bass);
  snd = snd + bass;

  wanderfreq = LFSaw.kr(1/(14*7), 1).exprange(0.05, 3);
  wander = PitchShift.ar(
    snd,
    0.03,
    Gendy1.kr(1, 1, 1, 1, wanderfreq, wanderfreq, initCPs: 5).exprange(1, 4),
    // wait two phrases before turning this on
    mul: (Sweep.kr(0, 1.0) > (14 * 2)) * 0.7
  );
  snd = snd + wander;

  Limiter.ar(snd);

}.play;
)