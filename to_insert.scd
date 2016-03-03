// MELODYLOW //////////////////////////////
  ~melodyLow = {
    var seq   = Dseq([
      Dseq([
        Dseq(seqA, 1), Dseq(seqB, 1), Dseq(seqC, 1), Dseq(seqD, 1),
      ], 1),
      Dseq([
        Dseq(seqA, 1), Dseq(seqB, 1), Dseq(seqC, 1),
        Dseq([66, 64, 68, 74, 83, 78, 76, 0, 84, 84, 84, 0].midicps, 1),
      ], 1),
    ], 1);
    var freq   = Demand.kr(baseTrig, 0, seq);
    var mel    = melSin.value(freq);
    2.do { mel = AllpassL.ar(mel,0.25,{0.2.rand+0.01}!2,5) };
    mel.tanh * 0.25;
  };
  ~melodyLow = ~melodyLow * ~to.value(1) * damper;
  ~out = ~out + ~melodyLow;
  // MELODYLOW //////////////////////////////



  // TOP ////////////////////////////////////
  ~top = ~out + FreeVerb.ar(
    AllpassN.ar(Ringz.ar(Impulse.ar([7/2, 7], [0.5, 0], mul: 0.1),
      Select.kr(LFCub.kr(4).range(0, 20), cubMel * 1.5),
      0.2
  ), 0.02, 0.02, 4, 4), 0.1, 0.5, 0.5);
  ~top = ~top * ~from.value(1) * ~to.value(4) * damper;
  ~top = ~top * 2;
  ~out = ~out + ~top;
  // TOP ////////////////////////////////////



  // WANDER /////////////////////////////////
  ~wanderfreq = LFSaw.kr(1/(interval*7), 0).exprange(0.05, 3);
  ~wander = PitchShift.ar(
    ~out,
    0.001,
    Gendy1.kr(1, 1, 1, 1, ~wanderfreq, ~wanderfreq, initCPs: 0).exprange(1, 4)
  );
  ~wander = ~wander * ~from.value(1) * ~to.value(4) * damper;
  ~out = ~out + ~wander;
  // WANDER /////////////////////////////////


  // LEADHIGH ///////////////////////////////
  ~leadHigh = ~out + FreeVerb.ar(
    AllpassC.ar(Ringz.ar(Impulse.ar(baseBeatFreq, mul: 0.075),
      Select.kr(
        SinOsc.kr(4).range(0, 5),
        cubMel * 2
      ),
      0.2), 0.02, 0.02, 4, 4), 0.1, 0.5, 0.5);
  ~leadHigh = ~leadHigh * ~from.value(2) * ~to.value(4) * damper;
  ~out = ~out + ~leadHigh;
  // LEADHIGH ///////////////////////////////



  // BASS ///////////////////////////////////
  ~bass = PMOsc.ar(
    SinOsc.kr(7/24, 0, 12, 52 + LFNoise0.kr(7/6, 4)).round(4).midicps * [1, 1.01],
    [166, 168.3],
    SinOsc.kr([1/7, 1/3]).exprange(0.25, 4),
    0,
    LFPulse.kr(7/2, [0.5, 0], 0.15, -15.dbamp)
  );
  ~bass = ~bass * (LFPulse.kr(8/interval, 0, 0.25) + LFPulse.kr(interval, 0, 0.25)).clip(0,1);
  ~bass = BLowPass.ar(~bass, 200, 1, 6) * impulseMul + (1 - impulseMul * HPF.ar(~bass, 200, -6.dbamp));
  ~bass = ~bass * ~from.value(2) * ~to.value(4) * damper;
  ~out = ~out + ~bass;
  // BASS ///////////////////////////////////



  // MELODYHIA //////////////////////////////
  ~melodyHiA = {
    var seq   = Dseq([
      Dseq([
        Dseq(seqW.midicps * 2, 1),
        Dseq(seqB, 1),
        Dseq(seqY * 2, 1),
        Dseq(seqD, 1)
      ], 3),
    ], inf);
    var freq   = Demand.kr(baseTrig, 0, seq);
    var mel    = melSin.value(freq);
    2.do { mel = AllpassL.ar(mel,0.25,{0.2.rand+0.01}!2,5)};
    mel.tanh * 0.25;
  };
  ~melodyHiA = ~melodyHiA * ~from.value(1) * ~to.value(4) * damper;
  ~out = ~out + ~melodyHiA;
  // MELODYHIA //////////////////////////////


  // MELODYHIB //////////////////////////////
  ~melodyHiB = {
    var seq   = Dseq([
      Dseq([
        Dseq(seqA, 1),
        Dseq(seqX * 2, 1),
        Dseq(seqC, 1),
        Dseq([66, 64, 68, 74, 83, 78, 76, 74, 68, 66, 64, 0].midicps * 2, 1)
      ], 3),
    ], inf);
    var freq   = Demand.kr(baseTrig, 0, seq);
    var mel    = melSin.value(freq);
    4.do { mel = AllpassL.ar(mel,0.25,{0.2.rand+0.01}!2,5) };
    mel.tanh * 0.25;
  };
  ~melodyHiB = ~melodyHiB * ~from.value(2) * ~to.value(4) * damper;
  ~out = ~out + ~melodyHiB;
  // MELODYHIB //////////////////////////////



  // LEADHIGHLOW ////////////////////////////
  ~leadHighLow = ~out + FreeVerb.ar(
    AllpassC.ar(Ringz.ar(Impulse.ar(baseBeatFreq, mul: 0.075),
      Select.kr(
        SinOsc.kr(4).range(0, 5),
        cubMel
      ),
      0.2
  ), 0.02, 0.02, 4, 4), 0.1, 0.5, 0.5);
  ~leadHighLow = ~leadHighLow * ~from.value(3) * ~to.value(4) * damper;
  ~out = ~out + ~leadHighLow;
  // LEADHIGHLOW ////////////////////////////