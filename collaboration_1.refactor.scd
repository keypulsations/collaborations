(

{

  var interval = 14, baseBeatFreq = 7, fall = 71;
  ~baseTrig = Impulse.kr(baseBeatFreq);

  ~active = LFSaw.kr(1/interval, 1) < 0.75;
  ~trig = Impulse.ar(baseBeatFreq, 0, ~active) * SinOsc.ar(329.63);

  ~snd = GVerb.ar(~trig, 2, 1, spread: 50) * RLPF.ar(LFSaw.ar(333), LFNoise1.kr(2, 4, 100).midicps);

  ~sweeper = Sweep.kr(0, 1.0);
  ~noise = LFNoise1;


  ~seqA = [66, 64, 68, fall+0, 83, 78, 76, 0, 0, 0, 0, 0].midicps;
  ~seqB = [66, 64, 68, fall+1, 83, 78, 76, 0, 0, 0, 0, 0].midicps;
  ~seqC = [66, 64, 68, fall+2, 83, 78, 76, 0, 0, 0, 0, 0].midicps;
  ~seqD = [66, 64, 68, fall+3, 83, 78, 76, 0, 0, 0, 0, 0].midicps;
  ~seqX = [66, 64, 68, fall+1, 83, 78, 76, fall+1, 68, 66, 64, 0].midicps;
  ~seqW = [66, 64, 68, fall+0, 83, 78, 76, fall+0, 68, 66, 64, 0];
  ~seqY = [66, 64, 68, fall+2, 83, 78, 76, fall+2, 68, 66, 64, 0].midicps;

  ~snd = Select.ar(
    SetResetFF.ar(Impulse.ar(baseBeatFreq) * SinOsc.ar(11.326)),
    [~snd, Compander.ar(~snd * LFPulse.ar(3000))]
  );
  ~snd = ~snd * (~sweeper > (interval * 1));
  ~baseSnd = ~snd;


  ~lead = ~snd + FreeVerb.ar(
    AllpassC.ar(Ringz.ar(Impulse.ar(baseBeatFreq, mul: 0.075),
      Select.kr(
        SinOsc.kr(4).range(0, 5),
        [64, 71, 67, 74, 76].midicps * 2
      ),
      0.2), 0.02, 0.02, 4, 4), 0.1, 0.5, 0.5);
  ~lead = ~lead * (~sweeper > (interval * 2)) * (~sweeper < (interval * 4));
  ~snd = ~snd + ~lead;

  ~wanderfreq = LFSaw.kr(1/(interval*7), 0).exprange(0.05, 3);
  ~wander = PitchShift.ar(
    ~snd,
    0.001,
    Gendy1.kr(1, 1, 1, 1, ~wanderfreq, ~wanderfreq, initCPs: 0).exprange(1, 4),
    mul: (~sweeper > interval) * (~sweeper < (interval * 4));
  );
  ~snd = ~snd + ~wander;



  ~top = ~baseSnd + FreeVerb.ar(
    AllpassN.ar(Ringz.ar(Impulse.ar([7/2, 7], [0.5, 0], mul: 0.1),
      Select.kr(
        LFCub.kr(4).range(0, 20),
        [64, 67, 71, 74, 76].midicps * 1.5
      ),
      0.2
  ), 0.02, 0.02, 4, 4), 0.1, 0.5, 0.5);
  ~top = ~top * (~sweeper > interval) * (~sweeper < (interval * 4));
  ~top = ~top * 2;
  ~snd = ~snd + ~top;



  ~bass = PMOsc.ar(
    SinOsc.kr(7/24, 0, 12, 52 + LFNoise0.kr(7/6, 4)).round(4).midicps * [1, 1.01],
    [166, 168.3],
    SinOsc.kr([1/7, 1/3]).exprange(0.25, 4),
    0,
    LFPulse.kr(7/2, [0.5, 0], 0.15, -15.dbamp)
  );
  ~bass = ~bass * (LFPulse.kr(8/interval, 0, 0.25) + LFPulse.kr(interval, 0, 0.25)).clip(0,1);
  ~bass = BLowPass.ar(~bass, 200, 1, 6) * ~active + (1 - ~active * HPF.ar(~bass, 200, -6.dbamp));
  ~bass = ~bass * (~sweeper > (interval * 2)) * (~sweeper < (interval * 4));
  ~snd = ~snd + ~bass;



  ~melody = {
    ~seq   = Dseq([
      Dseq([
        Dseq(~seqA, 1),
        Dseq(~seqB, 1),
        Dseq(~seqC, 1),
        Dseq(~seqD, 1),
      ], 1),
      Dseq([
        Dseq(~seqA, 1),
        Dseq(~seqB, 1),
        Dseq(~seqC, 1),
        Dseq([66, 64, 0, fall+3, 83, 78, 76, 0, 84, 84, 84, 0].midicps, 1),
      ], 1),
    ], 1);
    ~freq  = Demand.kr(~baseTrig, 0, ~seq);
    ~mel   = SinOsc.ar(~freq, Ndef('x').ar*~noise.ar(0.1).range(1, 5), ~noise.ar(0.5).range(1, 2)).tanh;
    2.do{~mel = AllpassL.ar(~mel,0.25,{0.2.rand+0.01}!2,5)};
    ~mel.tanh * 0.25;
  };
  ~melody = ~melody * (~sweeper < (interval * 1));
  ~melody = ~melody;
  ~snd = ~snd + ~melody;



  ~melodyHi = {
    var seq   = Dseq([
      Dseq([
        Dseq(~seqW.shift(-2).midicps * 2, 1),
        Dseq(~seqB, 1),
        Dseq(~seqY * 2, 1),
        Dseq(~seqD, 1)
      ], 3),
    ], inf);
    var freq  = Demand.kr(~baseTrig, 0, seq);
    var mel   = SinOsc.ar(freq, Ndef('x').ar*~noise.ar(0.1).range(1, 5), ~noise.ar(0.5).range(1, 2)).tanh;
    2.do{mel = AllpassL.ar(mel,0.25,{0.2.rand+0.01}!2,5)};
    mel.tanh * 0.25;
  };
  ~melodyHi = ~melodyHi * (~sweeper > (interval * 1)) * (~sweeper < (interval * 4));
  ~snd = ~snd + ~melodyHi;



  ~melodyHi2 = {
    var seq   = Dseq([
      Dseq([
        Dseq(~seqA, 1),
        Dseq(~seqX * 2, 1),
        Dseq(~seqC, 1),
        Dseq([66, 64, 68, fall+3, 83, 78, 76, fall+3, 68, 66, 64, 0].midicps * 2, 1)
      ], 3),
    ], inf);
    var freq  = Demand.kr(~baseTrig, 0, seq);
    var mel   = SinOsc.ar(freq, Ndef('x').ar*~noise.ar(0.1).range(1, 5), ~noise.ar(0.5).range(1, 2)).tanh;
    4.do{mel = AllpassL.ar(mel,0.25,{0.2.rand+0.01}!2,5)};
    mel.tanh * 0.25;
  };
  ~melodyHi2 = ~melodyHi2 * (~sweeper > (interval * 2)) * (~sweeper < (interval * 4));
  ~snd = ~snd + ~melodyHi2;




  ~kickGate =  Impulse.ar(baseBeatFreq, 0) * SinOsc.ar(100);
  ~env0     =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4]), gate: 0); // try gate: 0
  ~env1     =  EnvGen.ar(Env.new([110, 59, 29], [0.005, 0.29], [-4, -5]), gate: ~kickGate);
  ~env1m    = ~env1.midicps;
  ~son      = LFPulse.ar(~env1m, 0, 0.5, 1, -0.5);
  ~son      = ~son + WhiteNoise.ar(1);
  ~son      = LPF.ar(~son, ~env1m*1.5, ~env0);
  ~son      = ~son + SinOsc.ar(~env1m, 0.5, ~env0);
  ~son      = ~son * (~sweeper > (interval * 1)) * (~sweeper < (interval * 4));
  ~son      = ~son * 0.75;
  ~son      = ~son.clip2(1);
  ~snd      = ~snd + ~son;

  ~lfo    = LFTri.kr(3.8,Rand(0,2.0)!2);
  ~seqq   = Dseq([66, 64, 76, 64, 64, 66, 64, 76].midicps/8, inf);
  ~freqq  = Demand.kr(~baseTrig, 0, ~seqq);
  ~pulse  = Mix(Saw.ar(~freqq*[1,1.001]*[1.0,1.0+(0.01*~lfo)]))*0.5;
  ~filter = BLowPass.ar(~pulse,100,0.15);

  ~env    = EnvGen.ar(Env.adsr(0.1,0.0,1.0,3),1,doneAction:2);
  ~sigg   = Pan2.ar(~filter*~env,0);
  ~sigg   = ~sigg * (~sweeper > (interval * 1)) * (~sweeper < (interval * 4));
  ~snd    = ~snd + ~sigg;

  ~leadLow = ~snd + FreeVerb.ar(
    AllpassC.ar(Ringz.ar(Impulse.ar(baseBeatFreq, mul: 0.075),
      Select.kr(
        SinOsc.kr(4).range(0, 5),
        [64, 71, 67, 74, 76].midicps
      ),
      0.2), 0.02, 0.02, 4, 4), 0.1, 0.5, 0.5);
  ~leadLow = ~leadLow * (~sweeper > (interval * 3));
  ~snd = ~snd + ~leadLow;

  ~snd = ~snd * 0.75;
  Limiter.ar(~snd);

}.play;
)

(
{
  var interval = 14, baseBeatFreq = 7, fall = 71;

  ~baseTrig = Impulse.kr(baseBeatFreq);
  ~active   = LFSaw.kr(1/interval, 1)<0.75;
  ~trig     = Impulse.ar(baseBeatFreq, 0, ~active) * SinOsc.ar(329.63);

  ~snd = GVerb.ar(~trig, 2, 1, spread: 50) * RLPF.ar(LFSaw.ar(333), LFNoise1.kr(2, 4, 100).midicps);
  ~sweeper = Sweep.kr(0, 1.0) * 0.7;
  ~noise = LFNoise1;

  ~seqA = [65, 67, 0, fall+0, 83, 78, 76, 0, 0, 0, 0, 0].midicps;
  ~seqB = [65, 67, 0, fall+1, 83, 78, 76, 0, 0, 0, 0, 0].midicps;
  ~seqC = [65, 67, 0, fall+2, 83, 78, 76, 0, 0, 0, 0, 0].midicps;
  ~seqD = [65, 67, 0, fall+3, 83, 78, 76, 0, 0, 0, 0, 0].midicps;
  ~seqX = [65, 67, 0, fall+1, 83, 78, 76, fall+1, 68, 67, 64, 0].midicps;
  ~seqW = [65, 67, 0, fall+0, 83, 78, 76, fall+0, 68, 67, 64, 0];
  ~seqY = [65, 67, 0, fall+2, 83, 78, 76, fall+2, 68, 67, 64, 0].midicps;

  ~snd = Select.ar(
    SetResetFF.ar(Impulse.ar(baseBeatFreq) * SinOsc.ar(11.326)),
    [~snd, Compander.ar(~snd * LFPulse.ar(3000))]
  );
  ~snd   = ~snd * (~sweeper < (interval * 6));
  ~baseSnd = ~snd;


  ~lead = ~snd + FreeVerb.ar(
    AllpassC.ar(Ringz.ar(Impulse.ar(baseBeatFreq, mul: 0.075),
      Select.kr(
        SinOsc.kr(4).range(0, 5),
        [65, 71, 67, 74, 76].midicps * 2
      ),
      0.2), 0.02, 0.02, 4, 4), 0.1, 0.5, 0.5);
  ~lead = ~lead * (~sweeper > (interval * 3)) * (~sweeper < (interval * 5));
  ~snd = ~snd + ~lead;

  ~leadLow = ~snd + FreeVerb.ar(
    AllpassC.ar(Ringz.ar(Impulse.ar(baseBeatFreq, mul: 0.075),
      Select.kr(
        SinOsc.kr(4).range(0, 5),
        [65, 71, 67, 74, 76].midicps
      ),
      0.2), 0.02, 0.02, 4, 4), 0.1, 0.5, 0.5);
  ~leadLow = ~leadLow * (~sweeper < (interval * 6));
  ~snd = ~snd + ~leadLow;


  ~melody2 = {
    var seq = Dseq([
      Dseq(~seqA, 1), // extra zero
      Dseq(~seqB, 1),
      Dseq(~seqC, 1),
      Dseq(~seqD, 1),
    ], 12);
    var freq  = Demand.kr(~baseTrig, 0, seq);
    var mel   = SinOsc.ar(freq, Ndef('x').ar*~noise.ar(0.1).range(1, 5), ~noise.ar(0.5).range(1, 2)).tanh;
    2.do { mel = AllpassL.ar(mel,0.25,{0.2.rand+0.01}!2,5) };
    mel.tanh * 0.25;
  };
  ~melody2 = ~melody2 * (~sweeper < (interval * 6.5));
  ~snd = ~snd + ~melody2;



  ~hard = {
    var seq = Dseq([
      Dseq([
        Dseq([100, 0, 0, 100, 0, 100, 0].midicps / 4, 6),
        Dseq([100, 0, 0, 100, 0, 98, 0].midicps / 4, 1)
      ], 1),
    ], inf);
    var freq  = Demand.kr(~baseTrig, 0, seq);
    var mel   = SinOsc.ar(freq, Ndef('x').ar*~noise.ar(0.1).range(5, 10), ~noise.ar(0.5).range(5, 10)).tanh;
    2.do{ mel  = AllpassL.ar(mel,0.25,{0.2.rand+0.01}!2,5) };
    mel.tanh * 0.25;
  };
  ~hard = ~hard * (~sweeper > (interval * 1)) * (~sweeper < (interval * 5));
  ~snd = ~snd + ~hard;


  ~hardHi = {
    var seq   = Dseq([
      Dseq([
        Dseq([100, 0, 0, 100, 0, 100, 0].midicps / 2, 6),
        Dseq([100, 0, 0, 100, 0, 98, 0].midicps / 2, 1)
      ], 1),
    ], inf);
    var freq  = Demand.kr(~baseTrig, 0, seq);
    var mel   = SinOsc.ar(freq, Ndef('x').ar*~noise.ar(0.1).range(5, 10), ~noise.ar(0.5).range(5, 10)).tanh;
    3.do{ mel  = AllpassL.ar(mel,0.25,{0.2.rand+0.01}!2,5) };
    mel.tanh * 0.25;
  };
  ~hardHi = ~hardHi * (~sweeper > (interval * 3)) * (~sweeper < (interval * 5));
  ~snd = ~snd + ~hardHi;



  ~melodyHi = {
    var seq = Dseq([
      Dseq([
        Dseq(~seqW.shift(-2).midicps * 2, 1),
        Dseq(~seqB, 1),
        Dseq(~seqY * 2, 1),
        Dseq(~seqD, 1)
      ], 3),
    ], inf);
    var freq  = Demand.kr(~baseTrig, 0, seq);
    var mel   = SinOsc.ar(freq, Ndef('x').ar*~noise.ar(0.1).range(1, 5), ~noise.ar(0.5).range(1, 5)).tanh;
    4.do{mel = AllpassL.ar(mel,0.25,{0.2.rand+0.01}!2,5)};
    mel.tanh * 0.25;
  };
  ~melodyHi = ~melodyHi * (~sweeper > (interval * 2)) * (~sweeper < (interval * 5));
  ~snd = ~snd + ~melodyHi;



  ~melodyHi2 = {
    var seq   = Dseq([
      Dseq([
        Dseq(~seqA, 1),
        Dseq(~seqX * 2, 1),
        Dseq(~seqC, 1),
        Dseq([65, 67, 68, fall+3, 83, 78, 76, fall+3, 68, 65, 67, 0].midicps * 2, 1)
      ], 3),
    ], inf);
    var freq  = Demand.kr(~baseTrig, 0, seq);
    var mel   = SinOsc.ar(freq, Ndef('x').ar*~noise.ar(0.1).range(1, 5), ~noise.ar(0.5).range(1, 5)).tanh;
    4.do { mel = AllpassL.ar(mel,0.25,{0.2.rand+0.01}!2,5) };
    mel.tanh * 0.25;
  };
  ~melodyHi2 = ~melodyHi2 * (~sweeper > (interval * 3)) * (~sweeper < (interval * 5));
  ~snd = ~snd + ~melodyHi2;



  ~kickGate = Impulse.ar(baseBeatFreq, 0) * SinOsc.ar(75);
  ~env0     =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4]), gate: ~kickGate);
  ~env1     =  EnvGen.ar(Env.new([110, 59, 29], [0.005, 0.29], [-4, -5]), gate: ~kickGate);
  ~env1m    = ~env1.midicps;
  ~son      = LFPulse.ar(~env1m, 0, 0.5, 1, -0.5);
  ~son      = ~son + WhiteNoise.ar(1);
  ~son      = LPF.ar(~son, ~env1m*1.5, ~env0);
  ~son      = ~son + SinOsc.ar(~env1m, 0.5, ~env0);
  ~son      = ~son * (~sweeper > (interval * 3)) * (~sweeper < (interval * 5)) *  ~damper;
  ~son      = ~son * 0.85;
  ~son      = ~son.clip2(1);
  ~snd      = ~snd + ~son;

  ~lfo    = LFTri.kr(3.8,Rand(0,2.0)!2);
  ~seqq   = Dseq([65, 67, 76, 65, 65, 67, 65, 76].midicps/8, inf);
  ~freqq  = Demand.kr(~baseTrig, 0, ~seqq);
  ~pulse  = Mix(Saw.ar(~freqq*[1,1.001]*[1.0,1.0+(0.01*~lfo)]))*0.5;
  ~filter = BLowPass.ar(~pulse,100,0.15);
  ~highFilter= BHiPass.ar(~pulse,50,0.15);
  ~env    = EnvGen.ar(Env.adsr(0.1,0.0,1.0,3),1,doneAction:2);
  ~sigg   = Pan2.ar(~filter*~env,0);
  ~siggHi = Pan2.ar(~highFilter*~env,0);
  ~sigg   = ~sigg + ~siggHi;
  ~sigg   = ~sigg * (~sweeper > (interval * 3)) * (~sweeper < (interval * 5));
  ~snd    = ~snd + ~sigg;

  ~snd = ~snd * 0.75;
  Limiter.ar(~snd);

}.play;
)