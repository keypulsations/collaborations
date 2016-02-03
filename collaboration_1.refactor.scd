(
{
  ~seven = 7;
  ~delay = 1;
  ~active = LFSaw.kr(1/14, 1)<0.75;
  ~trig = Impulse.ar(~seven, 0, ~active) * SinOsc.ar(329.63);
  ~snd = GVerb.ar(~trig, 2, 1, spread: 50) * RLPF.ar(LFSaw.ar(333), LFNoise1.kr(2, 4, 100).midicps);
  ~snd = Select.ar(
    SetResetFF.ar(Impulse.ar(~seven) * SinOsc.ar(11.326)),
    [~snd, Compander.ar(~snd * LFPulse.ar(3000))]
  );
  ~snd   = ~snd * (Sweep.kr(0, 1.0) > (14 * ~delay * 1)) * 0.7;
  ~baseSnd = ~snd;

  ~lead = ~snd + FreeVerb.ar(
    AllpassC.ar(Ringz.ar(Impulse.ar(~seven, mul: 0.075),
      Select.kr(
        SinOsc.kr(4).range(0, 5),
        [64, 71, 67, 74, 76].midicps * 2
      ),
      0.2), 0.02, 0.02, 4, 4), 0.1, 0.5, 0.5);
  ~lead = ~lead * (Sweep.kr(0, 1.0) > (14 * ~delay * 2)) * (Sweep.kr(0, 1.0) < (14 * ~delay * 4)) * 0.7;
  ~snd = ~snd + ~lead;

  ~wanderfreq = LFSaw.kr(1/(14*7), 0).exprange(0.05, 3);
  ~wander = PitchShift.ar(
    ~snd,
    0.001,
    Gendy1.kr(1, 1, 1, 1, ~wanderfreq, ~wanderfreq, initCPs: 0).exprange(1, 4),
    mul: (Sweep.kr(0, 1.0) > (14 * ~delay)) * (Sweep.kr(0, 1.0) < (14 * ~delay * 4)) * 0.7;
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
  ~top = ~top * (Sweep.kr(0, 1.0) > (14 * ~delay)) * (Sweep.kr(0, 1.0) < (14 * ~delay * 4)) * 0.7;
  ~top = ~top * 2;
  ~snd = ~snd + ~top;

  ~bass = PMOsc.ar(
    SinOsc.kr(7/24, 0, 12, 52 + LFNoise0.kr(7/6, 4)).round(4).midicps * [1, 1.01],
    [165, 168.3],
    SinOsc.kr([1/7, 1/3]).exprange(0.25, 4),
    0,
    LFPulse.kr(7/2, [0.5, 0], 0.15, -15.dbamp)
  );
  ~bass = ~bass * (LFPulse.kr(8/14, 0, 0.25) + LFPulse.kr(14, 0, 0.25)).clip(0,1);
  ~bass = BLowPass.ar(~bass, 200, 1, 6) * ~active + (1 - ~active * HPF.ar(~bass, 200, -6.dbamp));
  ~bass = ~bass * (Sweep.kr(0, 1.0) > (14 * ~delay * 2)) * (Sweep.kr(0, 1.0) < (14 * ~delay * 4)) * 0.7;
  ~snd = ~snd + ~bass;

  ~melody = {
    var fall = 71;
    ~seq   = Dseq([
      Dseq([
        Dseq([65, 64, 68, fall+0, 83, 78, 76, 0, 0, 0, 0, 0].midicps, 1),
        Dseq([65, 64, 68, fall+1, 83, 78, 76, 0, 0, 0, 0, 0].midicps, 1),
        Dseq([65, 64, 68, fall+2, 83, 78, 76, 0, 0, 0, 0, 0].midicps, 1),
        Dseq([65, 64, 68, fall+3, 83, 78, 76, 0, 0, 0, 0, 0].midicps, 1),
      ], 1),
      Dseq([
        Dseq([65, 64, 68, fall+0, 83, 78, 76, 0, 0, 0, 0, 0].midicps, 1),
        Dseq([65, 64, 68, fall+1, 83, 78, 76, 0, 0, 0, 0, 0].midicps, 1),
        Dseq([65, 64, 68, fall+2, 83, 78, 76, 0, 0, 0, 0, 0].midicps, 1),
        Dseq([65, 64, 68, fall+3, 83, 78, 76, 0, 0, 0, 0, 86].midicps, 1),
      ], 1),
    ], 1);
    ~trigg = Impulse.kr(~seven);
    ~freq  = Demand.kr(~trigg, 0, ~seq);
    ~noise = LFNoise1;
    ~mel   = SinOsc.ar(~freq, Ndef('x').ar*~noise.ar(0.1).range(1, 5), ~noise.ar(0.5).range(1, 2)).tanh;
    2.do{~mel = AllpassL.ar(~mel,0.25,{0.2.rand+0.01}!2,5)};
    ~mel.tanh * 0.25;
  };
  ~melody = ~melody * (Sweep.kr(0, 1.0) < (14 * ~delay * 1)) * 0.7;
  ~melody = ~melody * 0.7;
  ~snd = ~snd + ~melody;

  ~melodyHi = {
    var fall = 71;
    var seq   = Dseq([
      Dseq([
        Dseq([65, 64, 68, fall+0, 83, 78, 76, fall+0, 68, 65, 64, 0].midicps * 2, 1),
        Dseq([65, 64, 68, fall+1, 83, 78, 76, 0, 0, 0, 0, 0].midicps, 1),
        Dseq([65, 64, 68, fall+2, 83, 78, 76, fall+2, 68, 65, 64, 0].midicps * 2, 1),
        Dseq([65, 64, 68, fall+3, 83, 78, 76, 0, 0, 0, 0, 0].midicps, 1)
      ], 3),
    ], inf);
    var trig = Impulse.kr(~seven);
    var freq  = Demand.kr(trig, 0, seq);
    var noise = LFNoise1;
    var mel   = SinOsc.ar(freq, Ndef('x').ar*noise.ar(0.1).range(1, 5), noise.ar(0.5).range(1, 2)).tanh;
    2.do{mel = AllpassL.ar(mel,0.25,{0.2.rand+0.01}!2,5)};
    mel.tanh * 0.25;
  };
  ~melodyHi = ~melodyHi * (Sweep.kr(0, 1.0) > (14 * ~delay * 1)) * (Sweep.kr(0, 1.0) < (14 * ~delay * 4)) * 0.7;
  ~snd = ~snd + ~melodyHi;

  ~melodyHi2 = {
    var fall = 71;
    var seq   = Dseq([
      Dseq([
        Dseq([65, 64, 68, fall+0, 83, 78, 76, 0, 0, 0, 0, 0].midicps, 1),
        Dseq([65, 64, 68, fall+1, 83, 78, 76, fall+1, 68, 65, 64, 0].midicps * 2, 1),
        Dseq([65, 64, 68, fall+2, 83, 78, 76, 0, 0, 0, 0, 0].midicps, 1),
        Dseq([65, 64, 68, fall+3, 83, 78, 76, fall+3, 68, 65, 64, 0].midicps * 2, 1)
      ], 3),
    ], inf);
    var trig = Impulse.kr(~seven);
    var freq  = Demand.kr(trig, 0, seq);
    var noise = LFNoise1;
    var mel   = SinOsc.ar(freq, Ndef('x').ar*noise.ar(0.1).range(1, 5), noise.ar(0.5).range(1, 2)).tanh;
    4.do{mel = AllpassL.ar(mel,0.25,{0.2.rand+0.01}!2,5)};
    mel.tanh * 0.25;
  };
  ~melodyHi2 = ~melodyHi2 * (Sweep.kr(0, 1.0) > (14 * ~delay * 2)) * (Sweep.kr(0, 1.0) < (14 * ~delay * 4)) * 0.7;
  ~snd = ~snd + ~melodyHi2;

  ~kickGate = Impulse.ar(~seven, 0) * SinOsc.ar(100); // derived from '~active' above. try other freqs beside 100 (200, 329.63, 330, etc)
  ~env0     =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4]), gate: 0); // try gate: 0
  ~env1     =  EnvGen.ar(Env.new([110, 59, 29], [0.005, 0.29], [-4, -5]), gate: ~kickGate);
  ~env1m    = ~env1.midicps;
  ~son      = LFPulse.ar(~env1m, 0, 0.5, 1, -0.5);
  ~son      = ~son + WhiteNoise.ar(1);
  ~son      = LPF.ar(~son, ~env1m*1.5, ~env0);
  ~son      = ~son + SinOsc.ar(~env1m, 0.5, ~env0);
  ~son      = ~son * (Sweep.kr(0, 1.0) > (14 * ~delay * 1)) * (Sweep.kr(0, 1.0) < (14 * ~delay * 4)) * 0.7;
  ~son      = ~son * 0.75;
  ~son      = ~son.clip2(1);
  ~snd      = ~snd + ~son;

  ~lfo    = LFTri.kr(3.8,Rand(0,2.0)!2);
  ~seqq   = Dseq([65, 64, 76, 64, 64, 65, 64, 76].midicps/8, inf);
  ~triggg = Impulse.kr(~seven);
  ~freqq  = Demand.kr(~triggg, 0, ~seqq);
  ~pulse  = Mix(Saw.ar(~freqq*[1,1.001]*[1.0,1.0+(0.01*~lfo)]))*0.5;
  ~filter = BLowPass.ar(~pulse,100,0.15);
  ~env    = EnvGen.ar(Env.adsr(0.1,0.0,1.0,3),1,doneAction:2);
  ~sigg   = Pan2.ar(~filter*~env,0);
  ~sigg   = ~sigg * (Sweep.kr(0, 1.0) > (14 * ~delay * 1)) * (Sweep.kr(0, 1.0) < (14 * ~delay * 4)) * 0.7;
  ~snd    = ~snd + ~sigg;

  ~leadLow = ~snd + FreeVerb.ar(
    AllpassC.ar(Ringz.ar(Impulse.ar(~seven, mul: 0.075),
      Select.kr(
        SinOsc.kr(4).range(0, 5),
        [64, 71, 67, 74, 76].midicps
      ),
      0.2), 0.02, 0.02, 4, 4), 0.1, 0.5, 0.5);
  ~leadLow = ~leadLow * (Sweep.kr(0, 1.0) > (14 * ~delay * 3)) * 0.7;
  ~snd = ~snd + ~leadLow;

  ~snd = ~snd * 0.75;
  Limiter.ar(~snd);

}.play;
)

(
{
  ~seven = 7;
  ~delay = 1;
  ~active = LFSaw.kr(1/14, 1)<0.75;
  ~trig = Impulse.ar(~seven, 0, ~active) * SinOsc.ar(329.63);
  ~snd = GVerb.ar(~trig, 2, 1, spread: 50) * RLPF.ar(LFSaw.ar(333), LFNoise1.kr(2, 4, 100).midicps);
  ~snd = Select.ar(
    SetResetFF.ar(Impulse.ar(~seven) * SinOsc.ar(11.326)),
    [~snd, Compander.ar(~snd * LFPulse.ar(3000))]
  );
  ~snd   = ~snd * (Sweep.kr(0, 1.0) < (14 * ~delay * 6)) * 0.7;
  ~baseSnd = ~snd;

  ~lead = ~snd + FreeVerb.ar(
    AllpassC.ar(Ringz.ar(Impulse.ar(~seven, mul: 0.075),
      Select.kr(
        SinOsc.kr(4).range(0, 5), // try different freqs for SinOsc [4, 8, etc.] and max ranges...5, 10, 20
        [64, 71, 67, 74, 76].midicps * 2
      ),
      0.2), 0.02, 0.02, 4, 4), 0.1, 0.5, 0.5);
  // ~lead = ~lead * 1.5;
  ~lead = ~lead * (Sweep.kr(0, 1.0) > (14 * ~delay * 3)) * (Sweep.kr(0, 1.0) < (14 * ~delay * 5));
  ~snd = ~snd + ~lead;

  ~leadLow = ~snd + FreeVerb.ar(
    AllpassC.ar(Ringz.ar(Impulse.ar(~seven, mul: 0.075),
      Select.kr(
        SinOsc.kr(4).range(0, 5), // try different freqs for SinOsc [4, 8, etc.] and max ranges...5, 10, 20
        [64, 71, 67, 74, 76].midicps
      ),
      0.2), 0.02, 0.02, 4, 4), 0.1, 0.5, 0.5);
  ~leadLow = ~leadLow * (Sweep.kr(0, 1.0) < (14 * ~delay * 6));
  ~snd = ~snd + ~leadLow;

  ~melody2 = {
    var fall = 71;
    var seq   = Dseq([
      Dseq([65, 64, 68, fall+0, 83, 78, 76, 0, 0, 0, 0, 0].midicps, 1), // extra zero
      Dseq([65, 64, 68, fall+1, 83, 78, 76, 0, 0, 0, 0, 0].midicps, 1),
      Dseq([65, 64, 68, fall+2, 83, 78, 76, 0, 0, 0, 0, 0].midicps, 1),
      Dseq([65, 64, 68, fall+3, 83, 78, 76, 0, 0, 0, 0, 0].midicps, 1),
    ], 12);
    var trig = Impulse.kr(~seven);
    var freq  = Demand.kr(trig, 0, seq);
    var noise = LFNoise1;
    var mel   = SinOsc.ar(freq, Ndef('x').ar*noise.ar(0.1).range(1, 5), noise.ar(0.5).range(1, 2)).tanh;
    // ~mel      = SinOsc.ar(~freq).tanh;
    2.do{mel = AllpassL.ar(mel,0.25,{0.2.rand+0.01}!2,5)};
    mel.tanh * 0.25;
  };
  ~melody2 = ~melody2 * (Sweep.kr(0, 1.0) < (14 * ~delay * 6.5));
  ~snd = ~snd + ~melody2;

  ~hard = {
    var fall = 71;
    var seq   = Dseq([
      Dseq([
        Dseq([100, 0, 0, 100, 0, 100, 0].midicps / 4, 6),
        Dseq([100, 0, 0, 100, 0, 98, 0].midicps / 4, 1)
      ], 1),
    ], inf);
    var trig  = Impulse.kr(~seven);
    var freq  = Demand.kr(trig, 0, seq);
    var noise = LFNoise1;
    var mel   = SinOsc.ar(freq, Ndef('x').ar*noise.ar(0.1).range(5, 10), noise.ar(0.5).range(5, 10)).tanh;
    2.do{ mel  = AllpassL.ar(mel,0.25,{0.2.rand+0.01}!2,5) };
    mel.tanh * 0.25;
  };
  ~hard = ~hard * (Sweep.kr(0, 1.0) > (14 * ~delay * 1)) * (Sweep.kr(0, 1.0) < (14 * ~delay * 5)) * 0.7;
  ~snd = ~snd + ~hard;

  ~hardHi = {
    var fall = 71;
    var seq   = Dseq([
      Dseq([
        Dseq([100, 0, 0, 100, 0, 100, 0].midicps / 2, 6),
        Dseq([100, 0, 0, 100, 0, 98, 0].midicps / 2, 1)
      ], 1),
    ], inf);
    var trig  = Impulse.kr(~seven);
    var freq  = Demand.kr(trig, 0, seq);
    var noise = LFNoise1;
    var mel   = SinOsc.ar(freq, Ndef('x').ar*noise.ar(0.1).range(5, 10), noise.ar(0.5).range(5, 10)).tanh;
    3.do{ mel  = AllpassL.ar(mel,0.25,{0.2.rand+0.01}!2,5) };
    mel.tanh * 0.25;
  };
  ~hardHi = ~hardHi * (Sweep.kr(0, 1.0) > (14 * ~delay * 3)) * (Sweep.kr(0, 1.0) < (14 * ~delay * 5)) * 0.7;
  ~snd = ~snd + ~hardHi;


  // thx jonatan liljedahl
  ~melodyHi = {
    var fall = 71;
    var seq   = Dseq([
      Dseq([
        Dseq([65, 64, 68, fall+0, 83, 78, 76, fall+0, 68, 65, 64, 0].shift(-2).midicps * 2, 1),
        Dseq([65, 64, 68, fall+1, 83, 78, 76, 0, 0, 0, 0, 0].midicps, 1),
        Dseq([65, 64, 68, fall+2, 83, 78, 76, fall+2, 68, 65, 64, 0].midicps * 2, 1),
        Dseq([65, 64, 68, fall+3, 83, 78, 76, 0, 0, 0, 0, 0].midicps, 1)
      ], 3),
    ], inf);
    var trig = Impulse.kr(~seven);
    var freq  = Demand.kr(trig, 0, seq);
    var noise = LFNoise1;
    var mel   = SinOsc.ar(freq, Ndef('x').ar*noise.ar(0.1).range(1, 5), noise.ar(0.5).range(1, 5)).tanh;
    4.do{mel = AllpassL.ar(mel,0.25,{0.2.rand+0.01}!2,5)};
    mel.tanh * 0.25;
  };
  ~melodyHi = ~melodyHi * (Sweep.kr(0, 1.0) > (14 * ~delay * 2)) * (Sweep.kr(0, 1.0) < (14 * ~delay * 5)) * 0.7;
  ~snd = ~snd + ~melodyHi;

  // thx jonatan liljedahl
  ~melodyHi2 = {
    var fall = 71;
    var seq   = Dseq([
      Dseq([
        Dseq([65, 64, 68, fall+0, 83, 78, 76, 0, 0, 0, 0, 0].midicps, 1),
        Dseq([65, 64, 68, fall+1, 83, 78, 76, fall+1, 68, 65, 64, 0].midicps * 2, 1),
        Dseq([65, 64, 68, fall+2, 83, 78, 76, 0, 0, 0, 0, 0].midicps, 1),
        Dseq([65, 64, 68, fall+3, 83, 78, 76, fall+3, 68, 65, 64, 0].midicps * 2, 1)
      ], 3),
    ], inf);
    var trig = Impulse.kr(~seven);
    var freq  = Demand.kr(trig, 0, seq);
    var noise = LFNoise1;
    var mel   = SinOsc.ar(freq, Ndef('x').ar*noise.ar(0.1).range(1, 5), noise.ar(0.5).range(1, 5)).tanh;
    // ~mel      = SinOsc.ar(~freq).tanh;
    4.do{mel = AllpassL.ar(mel,0.25,{0.2.rand+0.01}!2,5)};
    mel.tanh * 0.25;
  };
  ~melodyHi2 = ~melodyHi2 * (Sweep.kr(0, 1.0) > (14 * ~delay * 3)) * (Sweep.kr(0, 1.0) < (14 * ~delay * 5)) * 0.7;
  ~snd = ~snd + ~melodyHi2;

  // borrowing a kick from rukano: http://sccode.org/1-4Ek
  ~kickGate = Impulse.ar(~seven, 0) * SinOsc.ar(75); // derived from '~active' above. try other freqs beside 100 (200, 329.63, 330, etc)
  ~env0     =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4]), gate: ~kickGate); // try gate: 0
  ~env1     =  EnvGen.ar(Env.new([110, 59, 29], [0.005, 0.29], [-4, -5]), gate: ~kickGate);
  ~env1m    = ~env1.midicps;
  ~son      = LFPulse.ar(~env1m, 0, 0.5, 1, -0.5);
  ~son      = ~son + WhiteNoise.ar(1);
  ~son      = LPF.ar(~son, ~env1m*1.5, ~env0);
  ~son      = ~son + SinOsc.ar(~env1m, 0.5, ~env0);
  ~son      = ~son * (Sweep.kr(0, 1.0) > (14 * ~delay * 3)) * (Sweep.kr(0, 1.0) < (14 * ~delay * 5)) *  0.7;
  ~son      = ~son * 0.85;
  ~son      = ~son.clip2(1);
  ~snd      = ~snd + ~son;

  // bass pad
  ~lfo    = LFTri.kr(3.8,Rand(0,2.0)!2);
  ~seqq   = Dseq([65, 64, 76, 64, 64, 65, 64, 76].midicps/8, inf);
  ~triggg = Impulse.kr(~seven);
  ~freqq  = Demand.kr(~triggg, 0, ~seqq);
  ~pulse  = Mix(Saw.ar(~freqq*[1,1.001]*[1.0,1.0+(0.01*~lfo)]))*0.5;
  ~filter = BLowPass.ar(~pulse,100,0.15);
  ~highFilter= BHiPass.ar(~pulse,50,0.15);
  ~env    = EnvGen.ar(Env.adsr(0.1,0.0,1.0,3),1,doneAction:2);
  ~sigg   = Pan2.ar(~filter*~env,0);
  ~siggHi = Pan2.ar(~highFilter*~env,0);
  ~sigg   = ~sigg + ~siggHi;
  ~sigg   = ~sigg * (Sweep.kr(0, 1.0) > (14 * ~delay * 3)) * (Sweep.kr(0, 1.0) < (14 * ~delay * 5));
  ~snd    = ~snd + ~sigg;

  ~snd = ~snd * 0.75;
  Limiter.ar(~snd);

}.play;
)