-- ExEffects.hs

module ExEffects where

import ExParams
import Sound.Tidal.Context

chord l p = up (unwrap' (fit (length l) l p))

slowPanS n = pan (slow n $ scale 0.2 0.8 sine1)
slowPanR n = pan (slow n $ scale 0.2 0.8 rand)
panR = pan (scale 0.2 0.8 $ rand)

mGain = gain "1.25"

binshfR = binshf (choose [0,0,0, 0.75, 0.3, 1])
binshfS n = binshf (slow n $ scale 0.0 0.7 sine1)
binfrzR = binfrz (choose [0,0,0,0,0, 0.75, 0.3, 1, 1])
slowSpeedR n = speed (slow n $ choose [1,1,1,1, 0.6666, 0.5, 2, -0.75, 4])
slowWahR n = wah (slow n $ choose [0,0,0,0,0, 0.1, 0.2, 0.5])

mNudge = nudge "[0 0.083 0.025]*3"
disv n l = unit "s" |+| loop l |+| accelerate n

mfDel p = delayt (density "<0.3 1 0.5 2>" (scale 1.0e-4 0.05 $ saw1)) |+| delay (slow 2 (scale 0.1 0.8 $ saw1)) |+| delayfb p

flange f b = flangefq f |+| flangefb b
flangeD = flange (density 0.75 $ "{0.5 0.0 1.2 1.4 0.8}%7") "{0.8 0.6 0.7}%4"
flangeL = flange (density 0.5 $ "{0.1 0.2 0.0 0.4 0.3}%7") "{0.0 0.4 0.0 0.3 0.1}%7"


mUp pt = up (foldl (+) "<0 1 2>" [pt, "[0 1]"])

