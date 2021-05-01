{-# LANGUAGE TypeSynonymInstances, FlexibleInstances, OverloadedStrings #-}

module Ex where

import qualified Data.Map.Strict as Map
import ExEffects
import Sound.Tidal.Context

-- pttern boost

msvo time s = whenmod 4 3 (within (0.4, 0.8) (chop 2))
  $ every 2 (within (0.6,0.8) (density 0.75) . (0.25<~))
  $ every 4 (within (0.5,1.0) (slow 2))
  $ every 6 (within (0.2,0.4) (hurry 2))
  $ every 8 (within (0.5,1.0) (slow 8) . (0.25~>))
  $ every 12 (within (0,0.5) (slow 5))
  $ every 4 (within (0.4, 0.75) (slow 3))
  $ every 2 (off time (mvSpeed "-0.25 -0.5 3 -2")) 
  $ s

msvoA time s = every 9 (within (0.3, 0.4) (chop 3))
  $ every 4 (off time (|> speed "-0.5 2 [0.4 -0.3] -2"))
  $ every 7 (within (0.7, 0.9) (chop 2))
  $ every 2 (within (0.3, 0.5) (slow 2))
  $ s

msvoS time s = every 9 (within (0.3, 0.4) (chop 2))
  $ every 6 (off time (|> speed "-0.5 2 [~ -0.3] -2"))
  $ every 5 (within (0.2, 0.5) (|> disv "-0.2 -0.1" "3 2"))
  $ every 7 (within (0.7, 0.9) (chop 2))
  $ every 2 (within (0.3, 0.5) (slow 2))
  $ whenmod 5 3 (within (0.2, 0.4) (density 2))
  $ s

-- effect function wrapper

mSlowDiv n s = off n (|+ speed (slow (n / 2) $ "[2 0.75] 0.666 [2 [0.5 0.125]*3]*2 0.6666"))
  $ s

mDefault = mGain
  |+ shape "0.15"
  |+ binshfR
  |+ slowPanS 3

mDefaultN = mGain
  |+ shape "0.15"
  |+ binshfNR
  |+ slowPanS 3


mGrav = mGain
  |+ shape "0.2"
  |+ slowPanR 3
  |+ slowSpeedR 4

msvoB time s = every 2 (|> mfDel' (slow 3 (range 1 0.01 rand)))
  $ every 4 (within (0.5, 0.75) (slow 3))
  $ every 15 (within (0.4, 0.8) (|> unit "s") . (|> accelerate "<0.76 0 -0.16>") . (|> loop "<0.125 0.75 0.5>"))
  $ every 7 (off time (stut 3 0.05 6) . (zoom (0.5, 0.75)))
  $ s

msvoC time s = every 4 (|+ mfDel' (slow 2 (range 1 0.01 rand)))
  $ every 4 (within (0.5, 0.75) (|> speed "1 0.75 2 1 0.8"))
  $ every 8 (within (0.25, 1.0) (|> speed "<1 0.75 0.5 1.125>"))
  $ every 12 (within (0.4, 0.8) (|> unit "s") . (|> accelerate "<0.76 0 -0.16>") . (|> loop "<0.125 0.75 0.5>"))
  $ s


inverse 1 = 0
inverse 0 = 1

so0 s = spaceOut [1, 0.75, 1.33, 2] $ s
so1 s = spaceOut [2, 0.75, 0.33, 2] $ s
so2 s = spaceOut [1, 0.1, 2.33, 2, 0.5] $ s

mStut pt sp s = sometimes (stut 4 1 1) 
  $ s
  |+ up (foldr (+) pt ["[0 5 7]*2", "<0 3>", "<0 5 8>"])
  |+ up (foldl (-) "<0 1 0 3>" ["{0 0 2}/2", "<0 1>", "0 1", "0 3"])
  |* speed sp

mStut' pt sp s = sometimes (stut 4 1 1) 
  $ s
  |+ n (foldr (+) pt ["[0 5 7]*2", "<0 3>", "<0 5 8>"])
  |+ n (foldl (-) "<0 1 0 3>" ["{0 0 2}/2", "<0 1>", "0 1", "0 3"])
  |* speed sp

mvSpeed pt s = within (0.2, 0.85) (# speed (sometimesBy 0.75 ((slow "<0.75 2 1.25>") . (sometimes rev)) pt)) $ s

unison p f pt = overlay (rotR shiftT f) pt
  where matches = matchManyToOne (flip $ Map.isSubmapOfBy (==)) p pt
        matched :: ControlPattern
        matched = filterJust $ (\(t, a) -> if t then Just a else Nothing) <$> matches
        shiftT = start $ whole ((queryArc matched (Arc 0 1))!!0)
