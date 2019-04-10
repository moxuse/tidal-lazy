{-# LANGUAGE TypeSynonymInstances, FlexibleInstances, OverloadedStrings #-}
-- ExEffects.hs

module ExEffects where

import ExParams

import Sound.Tidal.Context


slowPanS n = pan (slow n $ range 0.2 0.8 sine)
slowPanR n = pan (slow n $ range 0.2 0.8 rand)
panR = pan (range 0.2 0.8 $ rand)

mGain = gain 1.25

binshfR = binshf (choose [0.5, 0.75, 0.3, 0.8])
binshfNR = binshfN (choose [0.5, 0.75, 0.3, 0.8])
binshfS n = binshf (slow n $ range 0.0 0.7 sine)
binfrzR = binfrz (choose [0,0,0,0,0, 0.75, 0.3, 1, 1])
slowSpeedR n = speed (slow n $ choose [1,1,1,1, 0.6666, 0.5, 2, -0.75, 4])
slowWahR n = wah (slow n $ choose [0,0,0,0,0, 0.1, 0.2, 0.5])
rotAccelerate n = accelerate (rot n "{0.03 0.1 0.04 0.05 2 0 0.04}%13")
rotPipe n = pipe (rot n "{[0 ,40] 0 0 [0, 40] 0}")
mNudge = nudge "[0 0.083 0.025]*3"
disv n l = unit "s" |+ loop l |+ accelerate n

mfDel = delayt (density "<0.3 1.75 0.5 2>" (range 1.0e-4 0.05 $ saw)) |+ delay (slow 2 (range 0.04 0.8 $ sine)) |+ delayfb "{0 0 0.04 0.1 0 0 0.8 0 01}%12"
mfDel' pt = delayt (density "<0.3 1.75 0.5 2>" (range 1.0e-4 0.05 $ saw)) |+ delay (slow 2 (range 0.04 0.8 $ sine)) |+ delayfb pt

flange f b = flangefq f |+ flangefb b
flangeD = flange (density 0.75 $ "{0.5 0.0 1.2 1.4 0.8}%7") "{0.8 0.6 0.7}%4"
flangeL = flange (density 0.5 $ "{0.1 0.2 0.0 0.4 0.3}%7") "{0.0 0.4 0.0 0.3 0.1}%7"


mUp pt = up (foldl (+) "<0 1 2>" [pt, "[0 1]"])

