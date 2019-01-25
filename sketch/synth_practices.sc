{Crackle.ar(1.92, 0.5).dup()}.play;

{Crackle.ar(1.52, 0.5).dup()}.play;

{BrownNoise.ar(0.2).dup()}.play()


{Klank.ar(`[[120, 1031, 7353, 1723], nil, [1, 1, 1, 1]], Dust.ar(4, 0.1).dup()) }.play;


{Crackle.ar(TExpRand.ar(0.1,1.94,Impulse.ar(8)),mul:0.5).dup}.play()

{Klank.ar(`[[831, 17353, 8723], nil, [1, 1, 1]],PinkNoise.ar(0.03).dup()) }.play;

{Klank.ar(`[[181, 353, 2723], nil, [1, 1, 1]], Crackle.ar(1.94, 0.03).dup()) }.play;

{Klank.ar(`[[81, 11353, 6013], nil, [1, 1, 1]], BrownNoise.ar(0.01).dup()) }.play;


(
{arg lpf=107;
AllpassC.ar(Mix.fill(9,{SinOsc.ar({[0,5,7,10,12,-12].choose+60}.midicps*{[1,0.5,2,0.666,0.75].choose},SinOsc.ar({[0,5,7,10,12,-12].choose+56}.midicps*122) ,HenonC.ar(SampleRate.ir/2, LFNoise2.ar(0.6,8.2), TExpRand.ar(0.13, 1.14, Dust.ar(2))) * 0.25 )})
,0.1,{[0.04.rand,0.05.rand]},{[0.4.rand,0.3.rand]})
}.play();
)