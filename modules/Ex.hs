module Ex where

import ExEffects
import Sound.Tidal.Context



msvo time s = whenmod 4 3 (within (0.3, 0.6) (striateL' 3 0.02 7))
  $ every 8 (slow 3)
  $ every 2 (off time (|+| speed "-0.25 -0.4 6 -2")) 
  $ s

msvoA time s = every 9 (within (0.3, 0.4) (striateL' 2 0.08 11))
  $ every 3 (off time (|+| speed "-0.5 2 [0.4 -0.3] -2"))
  $ every 7 (within (0.7, 0.9) (chop 2))
  $ every 4 (within (0.3, 0.5) (slow 2))
  $ s

mDefault = mGain
  |+| shape "0.4"
  |+| binshfR
  |+| slowPanS 3

mGrav = mGain
  |+| shape "0.4"
  |+| slowWahR 0.75
  |+| slowPanR 3
  |+| slowSpeedR 4
  |+| mNudge