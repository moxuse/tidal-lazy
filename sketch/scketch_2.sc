s.boot;

(
SynthDef("boomer",{arg out = 0;
  var osc;
  osc = SinOsc.ar(440,0,0.2);
  Out.ar(0,osc);
}).store();
)


s.sendMsg("/s_new", "boomer", 1001, 1, 0);

s.sendMsg(11, 1001);
