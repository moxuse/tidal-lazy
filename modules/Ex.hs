module Ex where

import ExEffects
import Sound.Tidal.Context

-- pttern boost

msvo time s = whenmod 4 3 (within (0.3, 0.6) (striateL' 3 0.02 7))
  $ every 4 (within (0.4, 0.75) (slow 3))
  $ every 2 (off time (|+| speed "-0.25 -0.4 6 -2")) 
  $ s

msvoA time s = every 9 (within (0.3, 0.4) (striateL' 2 0.08 11))
  $ every 4 (off time (|+| speed "-0.5 2 [0.4 -0.3] -2"))
  $ every 7 (within (0.7, 0.9) (chop 2))
  $ every 2 (within (0.3, 0.5) (slow 2))
  $ s

msvoS time s = every 9 (within (0.3, 0.4) (striateL' 2 0.08 11))
  $ every 6 (off time (|+| speed "-0.5 2 [~ -0.3] -2"))
  $ every 5 (within (0.2, 0.5) (|+| disv "-0.2 -0.1" "3 2"))
  $ every 7 (within (0.7, 0.9) (chop 2))
  $ every 2 (within (0.3, 0.5) (slow 2))
  $ whenmod 5 3 (within (0.2, 0.4) (density 2))
  $ s

-- effect function wrapper

mSlowDiv n s = off n (|+| speed (slow (n / 2) $ "[2 0.75] 0.666 [2 [0.5 0.125]*3]*2 0.6666"))
  $ s

mDefault = mGain
  |+| shape "0.4"
  |+| binshfR
  |+| slowPanS 3

mGrav = mGain
  |+| shape "0.4"
  |+| slowPanR 3
  |+| slowSpeedR 4

msvoB time s = every 2 (|+| mfDel (slow 3 (scale 1 0.01 rand)))
    $ every 4 (within (0.5, 0.75) (slow 3))
    $ every 12 (within (0.4, 0.8) (|+| unit "s") . (|+| accelerate "<0.76 0 -0.16>") . (|+| loop "<0.125 0.75 0.5>"))
    $ every 3 (off time (stut 3 0.05 6) . (zoom (0.25, 0.75)))
    $ s

msvoC time s = every 4 (|+| mfDel (slow 2 (scale 1 0.01 rand)))
    $ every 4 (within (0.5, 0.75) (|*| speed "1 0.75 2 1 0.8"))
    $ every 8 (within (0.25, 1.0) (|*| speed "<1 0.75 0.5 1.125>"))
    $ every 12 (within (0.4, 0.8) (|+| unit "s") . (|+| accelerate "<0.76 0 -0.16>") . (|+| loop "<0.125 0.75 0.5>"))
    $ s

inverse 1 = 0
inverse 0 = 1

