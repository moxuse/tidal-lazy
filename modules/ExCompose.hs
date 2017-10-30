module ExCompose where

import System.Random (randomRIO)
import ExEffects
import Ex
import Sound.Tidal.Context

randpick xs = fmap (xs !!) $ randomRIO (0, length xs - 1)

binPats n = [
  (slow n $ "1/6 1 1/8 0/4 0*2 0/2 1/2 0*2 1/4 1 0/6 1 1*2 1/2 0/4 1/2"),
  (slow n $ "1/2 0 1/8 0/2 1? 0/4 1 0/4 1/2 0/4 1/2 0/4 0*2 1/8 0/4 1/2"),
  (slow n $ "0/2 0/5 1/8 0 1/4 1/3 1/2 0/3 0*2? 0/2 1/2 0 1 1/4 0/3 1?"),
  (slow n $ "0 1/4 1/3 0/2 1 0 1*2 0/2 0 0*2 1/2 0*2 1/4 1 1/2 0")]

seqlist = [
  "<0 0 3 3 1 1 2 2 1 1>",
  "<1 0 1 0 1 1 2 2 0 0 3 3>",
  "<2 2 0 0 1 1 3 3>",
  "<0 0 1 1 2 1 0 0 2 3 1>",  
  "<0 0 2 2 1 1>",
  "<1 1 3 3 0 0 2 2>",
  "<0 0 2 2 1 1 0 0 1 1 3 3 2 2>"]

pat0 bpt = stack [
  ((0.125 ~>) $ gain bpt |+| s "mhh2")
  ,(gain (inverse <$> bpt) |+| s "msn2")
  ,((0.125 <~) $ gain (inverse <$> bpt) |+| s "mbd2")]

pat1 bpt　= stack [
  ((0.125 ~>) $ gain bpt |+| s "mhh2")
  ,(gain bpt |+| s "mps/2")
  ,(gain (inverse <$> bpt) |+| sound "msn2")
  ,((0.125 <~) $ gain (inverse <$> bpt) |+| s "mbd2")]

pat2 bpt = stack [
  (gain bpt |+| sound "ecco_kick")
  ,((slow 4) $ gain bpt |+| sound "ecco_bass" |+| sustain "0.125" |+| up "0 2 -3 0")
  ,((0.125 <~) $ gain bpt |+| sound "ecco_hihat")
  ,(gain (inverse <$> bpt) |+| sound "msn2")
  ,(slow 4 $ (0.125 ~>) $ gain bpt |+| sound "mps/2")]

pat3 bpt　= stack [
  (gain bpt |+| s "mhh2")
  ,(gain (inverse <$> bpt) |+| s "msn2")
  ,((0.125 <~) $ gain (inverse <$> bpt) |+| s "mbd2")]

pat4 = whenmod 4 2 (off 0.375 (|+| speed "1.5"))
  $ whenmod 3 2 (within (0.5, 0.8) (slow "2 1"))
  $ sound "[mb2/4, mbd2 mhh2*2]/2 [[msn2*2 mcp]/2 ~ [mhh2*2 mbd2]/3 msn2]/4 ~ [msn2 mps]"
pat5 = sound "{mpd2*2? ~ , [~  mbd2*2] mhh2}" |+| cut (choose[3, 2, 1]) |+| slowWahR 2
pat6 = whenmod 3 2 (within (0.5, 0.8) (slow "0.5 1"))
  $ sound "{mbd2(2,5), mhh2:3*8, [mbd2 msn2*2 mnz]/3 [msn2*2 mb2]/2 , ~ mps ~ mbd2*2 mps}" |+| cut (choose[3, 2, 1])
pat7 = whenmod 4 2 (within (0.4, 0.8) (0.125<~))
  $ sound "[mps/2 mhh2*2 mnt2/4 ~, [mhh2*3 msn2*2]/2, mhh2*12, mbd2(3,5) ~ mhh2*2]/3"
pat8 = sound "[mbd2(3,5), mhh2 msn2, mps/2 ml2/4 ~ mps/4]"


paatternList1 bpt = [
  (pat0 bpt),
  (pat1 bpt),
  (pat2 bpt),
  (pat3 bpt)]

paatternList2 bpt = [
  (pat4),
  (pat5),
  (pat6),
  (pat7),
  (pat8)]

chooseUr :: [Pattern a] -> IO (Pattern a)
chooseUr pat = do
  p <- (randpick seqlist :: IO (Pattern String))
  let m = ur 2 p pat
  return $ m

chooseUr0 bpt = do
  p0 <- (randpick (paatternList1 bpt))
  p1 <- (randpick (paatternList1 bpt))
  p2 <- (randpick (paatternList2 bpt))
  p3 <- (randpick (paatternList2 bpt))
  return [p0, p1, p2, p3]

chooseUr1 bpt = do
  p0 <- (randpick (paatternList1 bpt))
  p1 <- (randpick (paatternList1 bpt))
  p2 <- (randpick (paatternList1 bpt))
  p3 <- (randpick (paatternList1 bpt))
  return [p0, p1, p2, p3]

chooseUr2 bpt = do
  p0 <- (randpick (paatternList2 bpt))
  p1 <- (randpick (paatternList2 bpt))
  p2 <- (randpick (paatternList2 bpt))
  p3 <- (randpick (paatternList2 bpt))
  return [p0, p1, p2, p3]

chooseBpt n = (randpick (binPats n))


lazy = (chooseBpt 2) >>= chooseUr0 >>= chooseUr

lazy' :: Pattern Time -> IO (Pattern ParamMap)

lazy' n = chooseBpt n >>= chooseUr1 >>= chooseUr
