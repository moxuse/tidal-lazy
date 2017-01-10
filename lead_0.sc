//s.boot
//~isMIDI = false;

// MIDI options
//~midi_ = MIDIOut(1);
//~isMIDI = true;
/////////////////

(
  //var prog;
  l = [
    //\Cm, \Gm_b, \Fm_g, \Cm_g,
    //\Cm, \Fm,  \Am, \Em_g,
    //\Am9, \Fmaj9, \Em, \Dm
     \C, \Gm, \F, \Cm
  ].chordProg;

  p = Pn(
    Plazy{
      Pfindur(32,
        Pbind(\instrument, \lead_n, \dur,
          Prand([2,3,4]*4,inf), \accelerate , Pwhite(0.00125,0.00125,inf))
      )
    }, inf);

a = {|td = 8, list = 60|
  Pn(
    Plazy{
      Pfindur(td,
        Pbind(\instrument, \bass_n, \note, Prand(list, inf) - 24, \dur,
          Prand([1, 0.5, 0.25, 1],inf), \accelerate , Pwhite(-0.0125, 0.0125,inf))
      )
    }, 1)
};



Tdef(\lead_0,{
  var str = Pevent(p).asStream, event, cycle = 0;
  loop {
    var alp;
    event = str.next;
    event[\note] = l[cycle%8];
    event.play;

    alp = Pevent(a.value(event[\dur], l[cycle%8]));
    if (false ,{
      (alp <> (type: \midi, midiout: ~midi_)).play;
    }, {
      alp.play;
    });


    event[\dur].wait;

    cycle = cycle + 1;
    ("current_"+cycle).postln;
  }
}).play;

)

Tdef(\lead_0).stop();


(
SynthDef(\lead_n, {|freq, amp = 1, gate = 1, dur =1, accelerate = 0|
  var src, env, freq_d;
  freq_d = freq * (1.0 + Sweep.kr(1, accelerate));
  src = SinOsc.ar(freq_d * SinOsc.ar(SinOsc.ar(freq_d*LFNoise0.kr(0.3,4,2), 0, 2), SinOsc.ar(freq_d * 0.5, 0, 2), 2) + LFNoise2.kr(0.4, 10), 0, 0.25);
  src = AllpassC.ar(RLPF.ar(src, LFNoise2.kr(0.3, 20, 64).midicps, 0.3), 0.2, {[0.01.rand,0.04.rand]} + LFNoise2.kr(0.1,0.1,0.23).abs, 0.2);
  env = EnvGen.ar(Env.perc(1.0, 1.25 * dur, 1, -2), gate, doneAction:2);
  Out.ar(0, src * env);
}).store();

SynthDef(\bass_n, {|freq, amp = 1, gate = 1, dur =1, accelerate = 0|
  var src, env, freq_d;
  freq_d = freq * (1.0 + Sweep.kr(1, accelerate)) * 1.5;
  src = SinOsc.ar(freq_d * SinOsc.ar(freq_d * 3, 0, SinOsc.ar(freq_d*3, 0, 0.5)) + LFNoise2.kr(0.2, 10), 0, 0.3);
  src = AllpassC.ar(RLPF.ar(src.distort, LFNoise2.kr(2, 30, 94).midicps, 0.3), 0.4, {[0.05.rand,0.04.rand]}, 0.03);
  env = EnvGen.ar(Env.perc(0.2, 1.5 * dur, 1, 4), gate, doneAction:2);
  Out.ar(0, (src * 72).softclip*0.1 * env);
}).store();
)

s.makeGui