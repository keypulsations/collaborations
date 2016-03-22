(

{

  var sweeper      = Sweep.kr(0, 1.0), damper = 0.7, noise = LFNoise1;
  var baseBeatFreq = 7, interval = 14;  // original

  // var baseBeatFreq = 1, interval = 2;
  // var baseBeatFreq = 28, interval = 0.25;
  // var baseBeatFreq = 14, interval = 0.25;
  // var baseBeatFreq = 7, interval = 0.25;

  var baseTrig     = Impulse.kr(baseBeatFreq);
  var impulseMul   = LFSaw.kr(1/interval, 1) < 0.75;
  // var impulseMul   = LFSaw.kr(1/interval, 1) < 0.75 + LFSaw.kr(1/4, 1) < 0.75;
  var foundation   = Impulse.ar(baseBeatFreq, 0, impulseMul) * SinOsc.ar(329.63);
  var resetFF      = SetResetFF.ar(Impulse.ar(baseBeatFreq)  * SinOsc.ar(11.326));

  var seqA = [65, 67, 0, 71, 83, 78, 76, 0, 0, 0, 0, 0].midicps;
  var seqB = [65, 67, 0, 72, 83, 78, 76, 0, 0, 0, 0, 0].midicps;
  var seqC = [65, 67, 0, 73, 83, 78, 76, 0, 0, 0, 0, 0].midicps;
  var seqD = [65, 67, 0, 74, 83, 78, 76, 0, 0, 0, 0, 0].midicps;
  var seqX = [65, 67, 0, 72, 83, 78, 76, 72, 68, 67, 64, 0].midicps;
  var seqW = [65, 67, 0, 71, 83, 78, 76, 71, 68, 67, 64, 0];
  var seqY = [65, 67, 0, 73, 83, 78, 76, 73, 68, 67, 64, 0].midicps;

  var cubMel = [65, 71, 67, 74, 76].midicps;
  var melSin = { |freq| SinOsc.ar(freq, Ndef('x').ar*noise.ar(0.1).range(1, 5), noise.ar(0.5).range(1, 2)).tanh };

  ~from = { |intvl| sweeper > (interval * intvl) };
  ~to   = { |intvl| sweeper < (interval * intvl) };

  ~out  = GVerb.ar(foundation, 2, 1, spread: 50) * RLPF.ar(LFSaw.ar(333), LFNoise1.kr(2, 4, 100).midicps);
  ~out  = Select.ar(resetFF, [~out, Compander.ar(~out * LFPulse.ar(3000))]);

  ~out  = ~out * ~to.value(6) * damper;



  // LEAD ///////////////////////////////////
  ~leadHigh_ = ~out + FreeVerb.ar(
    AllpassC.ar(Ringz.ar(Impulse.ar(baseBeatFreq, mul: 0.075),
      Select.kr(
        SinOsc.kr(4).range(0, 5),
        cubMel * 2
      ),
      0.2), 0.02, 0.02, 4, 4), 0.1, 0.5, 0.5);
  ~leadHigh_ = ~leadHigh_ * ~from.value(3) * ~to.value(5) * damper;
  ~out = ~out + ~leadHigh_;
  // LEAD ///////////////////////////////////



  // LEADLOW ////////////////////////////////
  ~leadLow_ = ~out + FreeVerb.ar(
    AllpassC.ar(Ringz.ar(Impulse.ar(baseBeatFreq, mul: 0.075),
      Select.kr(
        SinOsc.kr(4).range(0, 5),
        cubMel
      ),
      0.2), 0.02, 0.02, 4, 4), 0.1, 0.5, 0.5);
  ~leadLow_ = ~leadLow_ * ~to.value(6);
  ~out = ~out + ~leadLow_;
  // LEADLOW ////////////////////////////////



  // MELODYMAIN /////////////////////////////
  ~melodyMain_ = {
    var seq   = Dseq([
      Dseq(seqA, 1),
      Dseq(seqB, 1),
      Dseq(seqC, 1),
      Dseq(seqD, 1),
    ], 12);
    var freq  = Demand.kr(baseTrig, 0, seq);
    var mel   = SinOsc.ar(freq, Ndef('x').ar*noise.ar(0.1).range(1, 5), noise.ar(0.5).range(1, 2)).tanh;

    2.do{mel = AllpassL.ar(mel,0.25,{0.2.rand+0.01}!2,5)};
    mel.tanh * 0.25;
  };
  ~melodyMain_ = ~melodyMain_ * ~to.value(6.5);
  ~out         = ~out + ~melodyMain_;
  // MELODYMAIN /////////////////////////////



  // HARDLOW ////////////////////////////////
  ~hardLow_ = {
    var seq = Dseq([
      Dseq([
        Dseq([100, 0, 0, 100, 0, 100, 0].midicps / 4, 6),
        Dseq([100, 0, 0, 100, 0, 98, 0].midicps / 4, 1)
      ], 1),
    ], inf);
    var freq  = Demand.kr(baseTrig, 0, seq);
    var mel   = SinOsc.ar(freq, Ndef('x').ar*noise.ar(0.1).range(5, 10), noise.ar(0.5).range(5, 10)).tanh;
    2.do{ mel  = AllpassL.ar(mel,0.25,{0.2.rand+0.01}!2,5) };
    mel.tanh * 0.25;
  };
  ~hardLow_ = ~hardLow_ * ~from.value(1) * ~to.value(5) * damper;
  ~out = ~out + ~hardLow_;
  // HARDLOW ////////////////////////////////



  // HARDHI /////////////////////////////////
  ~hardHi_ = {
    var seq   = Dseq([
      Dseq([
        Dseq([100, 0, 0, 100, 0, 100, 0].midicps / 2, 6),
        Dseq([100, 0, 0, 100, 0, 98, 0].midicps / 2, 1)
      ], 1),
    ], inf);

    var freq  = Demand.kr(baseTrig, 0, seq);
    var mel   = SinOsc.ar(freq, Ndef('x').ar*noise.ar(0.1).range(5, 10), noise.ar(0.5).range(5, 10)).tanh;
    3.do{ mel  = AllpassL.ar(mel,0.25,{0.2.rand+0.01}!2,5) };
    mel.tanh * 0.25;
  };
  ~hardHi_ = ~hardHi_ * ~from.value(3) * ~to.value(5) * damper;
  ~out = ~out + ~hardHi_;
  // HARDHI /////////////////////////////////



  // MELODYHIA //////////////////////////////
  ~melodyHiA_ = {
    var seq   = Dseq([
      Dseq([
        Dseq(seqW.shift(-2).midicps * 2, 1),
        Dseq(seqB, 1),
        Dseq(seqY * 2, 1),
        Dseq(seqD, 1)
      ], 3),
    ], inf);
    var freq   = Demand.kr(baseTrig, 0, seq);
    var mel    = SinOsc.ar(freq, Ndef('x').ar*noise.ar(0.1).range(1, 5), noise.ar(0.5).range(1, 5)).tanh;
    4.do { mel = AllpassL.ar(mel,0.25,{0.2.rand+0.01}!2,5)};
    mel.tanh * 0.25;
  };
  ~melodyHiA_ = ~melodyHiA_ * ~from.value(2) * ~to.value(5) * damper;
  ~out = ~out + ~melodyHiA_;
  // MELODYHIA //////////////////////////////



  // MELODYHIB //////////////////////////////
  ~melodyHiB_ = {
    var seq   = Dseq([
      Dseq([
        Dseq(seqA, 1),
        Dseq(seqX * 2, 1),
        Dseq(seqC, 1),
        Dseq([65, 67, 68, 74, 83, 78, 76, 74, 68, 65, 67, 0].midicps * 2, 1)
      ], 3),
    ], inf);
    var freq   = Demand.kr(baseTrig, 0, seq);
    var mel    = SinOsc.ar(freq, Ndef('x').ar*noise.ar(0.1).range(1, 5), noise.ar(0.5).range(1, 5)).tanh;
    4.do { mel = AllpassL.ar(mel,0.25,{0.2.rand+0.01}!2,5) };
    mel.tanh * 0.25;
  };
  ~melodyHiB_ = ~melodyHiB_ * ~from.value(3) * ~to.value(5) * damper;
  ~out = ~out + ~melodyHiB_;
  // MELODYHIB //////////////////////////////




  ~kickGate =  Impulse.ar(baseBeatFreq, 0) * SinOsc.ar(75);
  ~env0     =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4]), gate: 0);
  ~env1     =  EnvGen.ar(Env.new([110, 59, 29], [0.005, 0.29], [-4, -5]), gate: ~kickGate).midicps;
  ~son      = LFPulse.ar(~env1, 0, 0.5, 1, -0.5);
  ~son      = ~son + WhiteNoise.ar(1);
  ~son      = LPF.ar(~son, ~env1*1.5, ~env0);
  ~son      = ~son + SinOsc.ar(~env1, 0.5, ~env0);
  ~son      = ~son * 0.85;
  ~son      = ~son.clip2(1);

  ~son      = ~son * ~from.value(3) * ~to.value(5) * damper;
  ~out      = ~out + ~son;

  ~lfo      = LFTri.kr(3.8,Rand(0,2.0)!2);
  ~seqq     = Dseq([65, 67, 76, 65, 65, 67, 65, 76].midicps/8, inf);
  ~freqq    = Demand.kr(baseTrig, 0, ~seqq);
  ~pulse    = Mix(Saw.ar(~freqq*[1,1.001]*[1.0,1.0+(0.01*~lfo)]))*0.5;
  ~filter   = BLowPass.ar(~pulse,100,0.15);

  ~highFilter = BHiPass.ar(~pulse,50,0.15);

  ~env        = EnvGen.ar(Env.adsr(0.1,0.0,1.0,3),1,doneAction:2);
  ~sigg       = Pan2.ar(~filter*~env,0);
  ~siggHi     = Pan2.ar(~highFilter*~env,0);
  ~sigg       = ~sigg + ~siggHi;
  ~sigg       = ~sigg * ~from.value(3) * ~to.value(5);
  ~out        = ~out + ~sigg;

  ~out = ~out * 0.75;
  Limiter.ar(~out);

}.play;

)