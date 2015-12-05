(
{
  ~seven = 7;
  ~delay = 1;
  ~active = LFSaw.kr(1/14, 1)<0.75;
  ~trig = Impulse.ar(~seven, 0, ~active) * SinOsc.ar(331);
  ~snd = GVerb.ar(~trig, 2, 1, spread: 50) * RLPF.ar(LFSaw.ar(333), LFNoise1.kr(2, 4, 100).midicps);
  ~snd = Select.ar(
    SetResetFF.ar(Impulse.ar(~seven) * SinOsc.ar(11.326)),
    [~snd, Compander.ar(~snd * LFPulse.ar(3000))]
  );
  ~baseSnd = ~snd;

  // borrowing from Nathnainiel's melodic idea here
  ~lead = ~snd + FreeVerb.ar(
    AllpassC.ar(Ringz.ar(Impulse.ar(~seven, mul: 0.075),
      Select.kr(
        SinOsc.kr(4).range(0, 5), // try different freqs for SinOsc [4, 8, etc.] and max ranges...5, 10, 20
        [329.63, 493.88, 392.00, 587.33, 659.25]
      ),
      0.2), 0.02, 0.02, 4, 4), 0.1, 0.5, 0.5);
  // ~lead = ~lead * (Sweep.kr(0, 1.0) > (14 * ~delay * 0)) * 0.7;
  // ~lead = ~lead * 1.5;
  ~snd = ~snd + ~lead;

  // nice, backseatviolinist. made a few small edits to make it thinner
  ~wanderfreq = LFSaw.kr(1/(14*7), 0).exprange(0.05, 3);
  ~wander = PitchShift.ar(
    ~snd,
    0.001,
    Gendy1.kr(1, 1, 1, 1, ~wanderfreq, ~wanderfreq, initCPs: 0).exprange(1, 4),
    // wait two phrases before turning this on
    mul: (Sweep.kr(0, 1.0) > (14 * ~delay * 1)) * 0.7
  );
  ~snd = ~snd + ~wander;

  // Glen's wonky ~bass
  ~bass = PMOsc.ar(
    SinOsc.kr(7/24, 0, 12, 52 + LFNoise0.kr(7/6, 4)).round(4).midicps * [1, 1.01],
    [165, 168.3],
    SinOsc.kr([1/7, 1/3]).exprange(0.25, 4),
    0,
    // LFPulse.kr(7/2, [0.5, 0], LFDNoise0.kr(7/32, 0.4, 0.5!2), -15.dbamp)
    LFPulse.kr(7/2, [0.5, 0], 0.15, -15.dbamp)
  );
  ~bass = ~bass * (LFPulse.kr(8/14, 0, 0.25) + LFPulse.kr(14, 0, 0.25)).clip(0,1);
  ~bass = BLowPass.ar(~bass, 200, 1, 6) * ~active + (1 - ~active * HPF.ar(~bass, 200, -6.dbamp));
  ~bass = ~bass * (Sweep.kr(0, 1.0) > (14 * ~delay)) * 0.7;
  ~snd = ~snd + ~bass;

  // top elementia
  ~melody = ~baseSnd + FreeVerb.ar(
    AllpassN.ar(Ringz.ar(Impulse.ar([7/2, 7], [0.5, 0], mul: 0.1),
      Select.kr(
        LFCub.kr(4).range(0, 20),
        [329.63, 392.00, 493.88, 587.33, 659.25] * 1.5
      ),
      0.2
  ), 0.02, 0.02, 4, 4), 0.1, 0.5, 0.5);
  ~melody = ~melody * (Sweep.kr(0, 1.0) > (14 * ~delay)) * 0.7;
  // ~melody = ~melody * 1.2;
  ~snd = ~snd + ~melody;

  // borrowing a kick from rukano: http://sccode.org/1-4Ek
  ~bassGate = Impulse.ar(~seven, 0) * SinOsc.ar(200); // derived from '~active' above. try other freqs beside 200 (331, 330, etc)
  ~env0 =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4]), gate: 0); // try gate: 0
  ~env1 =  EnvGen.ar(Env.new([110, 59, 29], [0.005, 0.29], [-4, -5]), gate: ~bassGate);
  ~env1m = ~env1.midicps;
  ~son = LFPulse.ar(~env1m, 0, 0.5, 1, -0.5);
  ~son = ~son + WhiteNoise.ar(1);
  ~son = LPF.ar(~son, ~env1m*1.5, ~env0);
  ~son = ~son + SinOsc.ar(~env1m, 0.5, ~env0);
  ~son = ~son * (Sweep.kr(0, 1.0) > (14 * ~delay)) * 0.7;
  ~son = ~son * 0.75;
  ~son = ~son.clip2(1);
  ~snd = ~snd + ~son;

  // thx jonatan liljedahl
  ~drone = {
    ~noise = LFNoise1;
    ~seq   = Dseq([
      Dseq([
        Dseq([349.23, 331, 493.88, 392.00, 659.25, 739.99, 987.77]*2, 2),
        Dseq([349.23, 698.46, 349.23]*2, 2),
      ], 2),
      Dseq([1046, 349.23, 1046]*2, 3),
    ], inf);
    ~trigg = Impulse.kr(~seven/2);
    ~freq  = Demand.kr(~trigg, 0, ~seq);
    ~mel   = SinOsc.ar(~freq, Ndef('x').ar*~noise.ar(0.1).range(1, 3), ~noise.ar(0.1).range(5, 10)).tanh;
    // ~mel      = SinOsc.ar(~freq).tanh;
    1.do{~mel = AllpassL.ar(~mel,0.3,{0.2.rand+0.01}!2,5)};
    ~mel.tanh * 0.15;
  };
  // ~drone = ~drone * (Sweep.kr(0, 1.0) > (14 * ~delay * 0)) * 0.7;
  ~snd = ~snd + ~drone;

  Limiter.ar(~snd);

}.play;
)