-- ExEffects.hs

module ExEffects where

import ExParams
import Sound.Tidal.Context

chord l p = up (unwrap' (fit (length l) l p))

slowPanS n = pan (slow n $ scale 0.2 0.8 sine1)
slowPanR n = pan (slow n $ scale 0.2 0.8 rand)
panR = pan (scale 0.2 0.8 $ rand)

mGain = gain "1.1"

binshfR = binshf (choose [0,0,0, 0.75, 0.3, 1])
binshfS n = binshf (slow n $ scale 0.0 0.7 sine1)
speedR = speed (choose [1,1,1,1, 0.6666, 0.5, 2, -0.75, 4])

mNudge = nudge "[0 0.015]*4"
disv n l = accelerate n |+| loop l
