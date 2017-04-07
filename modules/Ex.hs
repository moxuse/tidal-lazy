module Ex where

import ExEffects
import Sound.Tidal.Context

-- pttern boost

msvo time s = whenmod 4 3 (within (0.3, 0.6) (striateL' 3 0.02 7))
  $ every 8 (slow 2)
  $ every 2 (off time (|+| speed "-0.25 -0.4 6 -2")) 
  $ s

msvoA time s = every 9 (within (0.3, 0.4) (striateL' 2 0.08 11))
  $ every 3 (off time (|+| speed "-0.5 2 [0.4 -0.3] -2"))
  $ every 7 (within (0.7, 0.9) (chop 2))
  $ every 4 (within (0.3, 0.5) (slow 2))
  $ s

msvoS time s = every 9 (within (0.3, 0.4) (striateL' 2 0.08 11))
  $ every 6 (off time (|+| speed "-0.5 2 [~ -0.3] -2"))
  $ every 5 (within (0.2, 0.5) (|+| disv "-0.2 -0.1" "3 2"))
  $ every 7 (within (0.7, 0.9) (chop 2))
  $ every 2 (within (0.3, 0.5) (slow 2))
  $ whenmod 5 3 (within (0.2, 0.4) (density 2))
  $ s

-- effect wrapper

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
  |+| mNudge

