{-# LANGUAGE TypeSynonymInstances, FlexibleInstances, OverloadedStrings #-}

module ExLazy where

import System.Random (randomRIO)
import ExEffects
import Ex
import Sound.Tidal.Context
import ExInstruments

randpick xs = fmap (xs !!) $ randomRIO (0, length xs - 1)

binPats :: Pattern Time -> [Pattern Double]
binPats n = [
  (slow n $ "1 1/4 0 0/6 1 0/2 0 1/3 1/2 1 1 0/4 0*2 0/2 1/2 0*2"),
  (slow n $ "1/2 0 1/4 0 [1 0] 0/4 1 0*2 0/6 1 1/3 1 1/4 0 1/2 0/4 1"),
  (slow n $ "0 0 1/4 0/2 0 1/2 1 0/3 1/2 0 1 1/4 0/3 1? 0 1/5"),
  (slow n $ "0 1/4 1 0 1/4 0 0 1/4 [0 0/3] 0 1/6 0*2 1/2 0*2 1 0/6"),
  (slow "<4 5 4 1.75>" "[0 [1 0 [1 0]]]/4 1/2 [0 1/2]/2 0 [1 0? 1]*2 1/3"),
  (slow "<5 4 6>" "0 1*2 [1/2 [0? 1]] 1 1/2 [1 [0 [1 0]?]?]/2 1? [0 [1 0 1]?]/3")]
  

seqlist = [
  "0 3 0 3 3 0 0 3",
  "1 0 1 0 1 1 2 2",
  "0 3 0 0 1 3 3 3",
  "0 2 1 2 0 1 0 0",  
  "0 2 1 0 1 1 0 2",
  "1 1 3 1 3 2 1 3",
  "0 0 3 3 1 0 0 1"]

pat0 bpt c = whenmod 3 2 (within (0.2, 0.8) (slow "2 0.75"))
  $ stack [
  ((0.125 ~>) $ gain bpt |+| s (hh' c))
  ,(gain (inverse <$> bpt) |+| s (sn' c))
  ,((0.125 <~) $ gain (inverse <$> bpt) |+| s (bd' c))]
  |+| gain "[1 0.8 1]*2"
pat1 bpt c = whenmod 3 1 (within (0.5, 0.8) (slow 2)) 
  $ stack [
  ((0.125 ~>) $ gain bpt |+| s (hh' c))
  ,(gain bpt |+| s (slow 2 (cp' c)))
  ,(gain (inverse <$> bpt) |+| sound (sn' c))
  ,((0.125 <~) $ gain (inverse <$> bpt) |+| s (bd' c))]
  |+| gain "[1 0.8 1 0.75]*2"

pat2 bpt c = whenmod 3 2 (within (0.2, 0.8) (slow "2 0.75"))
  $ stack[
  (gain bpt |+| sound (bd' c))
  ,((slow 4) $ gain bpt |+| sound (cp' c) |+| sustain "0.25" |+| up "0 2 -3 0")
  ,((0.125 <~) $ gain bpt |+| sound (hh' c))
  ,(gain (inverse <$> bpt) |+| sound (sn' c))
  ,(slow 4 $ (0.125 ~>) $ degradeBy 0.5 $ gain bpt |+| sound (slow 2 (ps' c)))]
  |+| gain "[1 0.8 0.75]/2"

pat3 bpt c = stack [
  (gain bpt |+| s (hh' c))
  ,(gain (inverse <$> bpt) |+| s (sn' c))
  ,((0.125 <~) $ gain (inverse <$> bpt) |+| s (bd' c))]
  |+| gain "[1 0.8 0.75]*2"

pat4 = whenmod 4 2 (off 0.175 (|+| speed "1.5"))
  $ whenmod 3 2 (within (0.2, 0.8) (slow "2 0.75"))
  $ sound "[mb2/4, mbd2 mhh2*2]/2 [[msn2*2 mcp]/2 ~ [mhh2*2 mbd2]/3 msn2]/4 ~ [msn2 mps]" # gain "1.1"
pat5 = sound "{mpd2*2? ~ , [~  mbd2*2]*2 mhh2}" # gain "1.1"
pat6 = whenmod 3 2 (within (0.25, 0.8) (slow "0.75 2"))
  $ sound "{mbd2(2,5), mhh2:3*2, [mbd2 msn2*2 mnz]/3 [msn2*2 mb2]/2 , ~ mps ~ mbd2*2 mps}" |+| cut (choose[3, 2, 1]) # gain "1"
pat7 = whenmod 4 2 (within (0.4, 0.8) (0.125<~))
  $ sound "[mps/2 mhh2*2 mnt2/4 ~, [mhh2*3 msn2*2]/2, mhh2*2, mbd2(3,5) ~ mhh2*2]/3" # gain "1"
pat8 = sound "[mbd2(3,5), mhh2 msn2, mps/2 ml2/4 ~ mps/4]" # gain "1" 

paatternList1 bpt c = [
  (pat0 bpt c),
  (pat1 bpt c),
  (pat2 bpt c),
  (pat3 bpt c)]

paatternList2 bpt = [
  (pat4),
  (pat5),
  (pat6),
  (pat7),
  (pat8)]

paatternList2' bpt c = [
  (pat4),
  (pat5),
  (pat6),
  (pat7),
  (pat8)]

chooseUr :: [(String, Pattern a)] -> IO (Pattern a)
chooseUr pat = do
  p <- (randpick seqlist :: IO (Pattern String))
  let m = ur 8 p pat []
  return $ m

chooseUr0 bpt = do
  p0 <- (randpick (paatternList2 bpt))
  p1 <- (randpick (paatternList2 bpt))
  p2 <- (randpick (paatternList2 bpt))
  p3 <- (randpick (paatternList2 bpt))
  return [("0", p0), ("1", p1), ("2", p2), ("3", p3)]

chooseUr1 c bpt = do
  p0 <- (randpick (paatternList1 bpt c))
  p1 <- (randpick (paatternList1 bpt c))
  p2 <- (randpick (paatternList1 bpt c))
  p3 <- (randpick (paatternList2' bpt c))
  return [("0", p0), ("1", p1), ("2", p2), ("3", p3)]

chooseUr2 bpt = do
  p0 <- (randpick (paatternList2 bpt))
  p1 <- (randpick (paatternList2 bpt))
  p2 <- (randpick (paatternList2 bpt))
  p3 <- (randpick (paatternList2 bpt))
  return [("0", p0), ("1", p1), ("2", p2), ("3", p3)]

chooseBpt :: Pattern Time -> IO (Pattern Double)
chooseBpt n = (randpick (binPats n))

lazy = (chooseBpt 2) >>= chooseUr0 >>= chooseUr

lazy' :: Pattern Time -> DefaultInstrument -> IO (ControlPattern)
lazy' n c = chooseBpt n >>= chooseUr1 c >>= chooseUr


replicateN :: Int -> Pattern a -> Pattern a 
replicateN n p =  (fastCat) (replicate n p)

pickSeedA def = randpick [
  fastAppend (euclid 4 5 (hh' def)) "~"
  ,overlay (euclid 3 9 (bd' def)) (sn' def)
  ,overlay (euclid 2 5 (sn' def)) (hh' def)
  ,fastAppend (fastAppend (euclid 2 5 (bd' def)) "~") (replicateN 3 (cp' def))
  ]

pickSeedB def = randpick [
  overlay (replicateN 2 (sn' def)) $ fastAppend (euclid 4 5 (bd' def)) "~"
  ,fastAppend "~" (fastAppend (replicateN 4 (sn' def)) "~")
  ,overlay (replicateN 4 (bd' def)) (fastAppend (euclid 3 8 (cp' def)) "~")
  ,(euclid 3 8 (bd' def))
  ,fastAppend "~" (euclid 2 5 (bd' def))
  ]

partialPat pat instr = do 
  cp <- pickSeedA instr
  dp <- pickSeedB instr
  return (sound (sew pat cp dp))

lazy'' :: Pattern Bool -> DefaultInstrument -> IO (ControlPattern)
lazy'' pat instr = do
  pa <- partialPat pat instr
  pb <- partialPat pat instr
  pc <- partialPat pat instr
  pd <- partialPat pat instr
  return $ stack [
      pa
    , pb
    , pc
    , pd
    ] 

