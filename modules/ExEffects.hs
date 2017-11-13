-- ExEffects.hs

module ExEffects where

import ExParams
import Sound.Tidal.Context

chord l p = up (unwrap' (fit (length l) l p))

slowPanS n = pan (slow n $ scale 0.2 0.8 sine1)
slowPanR n = pan (slow n $ scale 0.2 0.8 rand)
panR = pan (scale 0.2 0.8 $ rand)

mGain = gain "1.2" -- |+| nudge "0.125"

binshfR = binshf (choose [0,0,0, 0.75, 0.3, 1])
binshfS n = binshf (slow n $ scale 0.0 0.7 sine1)
binfrzR = binfrz (choose [0,0,0,0,0, 0.75, 0.3, 1, 1])
slowSpeedR n = speed (slow n $ choose [1,1,1,1, 0.6666, 0.5, 2, -0.75, 4])
slowWahR n = wah (slow n $ choose [0,0,0,0,0, 0.1, 0.2, 0.5])

mNudge = nudge "[0 0.015]*4"
disv n l = unit "s" |+| loop l |+| accelerate n

mfDel pat = delayt (density "<0.3 1 0.5 2>" (scale 1.0e-4 0.05 $ saw1)) |+| delay (slow 2 (scale 0.1 0.8 $ saw1)) |+| delayfb pat

