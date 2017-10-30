module ExComposeSepar where

import System.Random (randomRIO)
import ExEffects
import Ex
import Sound.Tidal.Context

randpick xs = fmap (xs !!) $ randomRIO (0, length xs - 1)

binPats = [
  (slow 4 $ "1/6 1 1/8 0/4 0*2 0/2 1/2 0*2 1/4 1 0/6 1 1*2 1/2 0/4 1/2"),
  (slow 4 $ "1/2 0 1/8 0/2 1? 0/4 1 0/4 1/2 0/4 1/2 0/4 0*2 1/8 0/4 1/2"),
  (slow 4 $ "0/2 0/5 1/8 0 1/4 1/3 1/2 0/3 0*2? 0/2 1/2 0 1 1/4 0/3 1?"),
  (slow 4 $ "0 1 0 1*2 0/2 0 0*2 1/2 0*2 1/4 1 1/2 0")]

seqlist = [
  "<0 0 3 3 1 1 2 2 1 1>",
  "<1 0 1 0 1 1 2 2 0 0 3 3>",
  "<2 2 0 0 1 1 3 3>",
  "<0 0 1 1 2 1 0 0 2 3 1>",  
  "<0 0 2 2 1 1>",
  "<1 1 3 3 0 0 2 2>",
  "<0 0 2 2 1 1 0 0 1 1 3 3 2 2>"]

pat0 bpt pats = stack [
    ((0.125 ~>) $ gain bpt |+| s (pats!!0))
    ,(gain (inverse <$> bpt) |+| s (pats!!1))
    ,((0.125 <~) $ gain (inverse <$> bpt) |+| s (pats!!2))]

pat1 bpt pats = stack [
      ((0.125 ~>) $ gain bpt |+| s (pats!!0))
      ,(gain bpt |+| s (pats!!1))
      ,(gain (inverse <$> bpt) |+| sound (pats!!2))
      ,((0.125 <~) $ gain (inverse <$> bpt) |+| s (pats!!3))]

pat2 bpt pats = stack [
      (gain bpt |+| sound (pats!!0))
      ,((slow 4) $ gain bpt |+| sound (pats!!1) |+| sustain "0.125" |+| up "0 2 -3 0")
      ,((0.125 <~) $ gain bpt |+| sound (pats!!2))
      ,(gain (inverse <$> bpt) |+| sound (pats!!3))
      ,(slow 4 $ (0.125 ~>) $ gain bpt |+| sound (pats!!4))]

pat3 bpt pats = stack [
      (gain bpt |+| s (pats!!0))
      ,(gain (inverse <$> bpt) |+| s (pats!!1))
      ,((0.125 <~) $ gain (inverse <$> bpt) |+| s (pats!!2))]

pat4 = whenmod 4 2 (off 0.375 (|+| speed "1.5"))
      $ whenmod 3 2 (within (0.5, 0.8) (slow "2 1"))
      $ sound "[mb2/4, mbd mhh*2]/2 [[msn*2 mcp]/2 ~ [mhh*2 mbd]/3 msn]/4 ~ [msn mhh]"
pat5 = sound "{mpd*2? ~ , [~  mbd*2] mhh}" |+| cut (choose[3, 2, 1]) |+| slowWahR 2
pat6 = whenmod 3 2 (within (0.5, 0.8) (slow "0.5 1"))
      $ sound "{mbd(2,5), mhh:3*8, [mbd msn*2 mnz]/3 [msn*2 mb]/2 , ~ ~ ~ mbd*2 mcp}"
pat7 = whenmod 4 2 (within (0.4, 0.8) (0.125<~))
      $ sound "[mb/2 mhh*2 mnz/4 ~, [mhh*3 msn*2]/2, mhh*12, mbd(3,5) ~ mhh*2]/3"
pat8 = sound "[mbd(3,8), mhh msn, ~ ml/4 ~ ~]"

-- paatternList1 :: IO (Pattern Double, [Pattern String]) -> IO [Pattern ParamMap]
paatternList1 bpt = do
  let b_f = (fst bpt)
  let b_s = (snd bpt)
  let p0 = (pat0 b_f b_s)
  let p1 = (pat1 b_f b_s)
  let p2 = (pat2 b_f b_s)
  let p3 = (pat3 b_f b_s)
  return [p0, p1, p2, p3]

-- paatternList2 :: IO [Pattern ParamMap]
paatternList2 bpt = do
  return [(pat4),(pat5),(pat6),(pat7),(pat8)]

-- chooseUr :: [Pattern a] -> IO (Pattern a)
chooseUr pat = do
  p <- (randpick seqlist :: IO (Pattern String))
  return (ur 1 p pat)

-- chooseUr2 :: IO (Pattern Double, [Pattern String]) -> IO [Pattern ParamMap]
chooseUr2 bpt = do
  let pt_0 = (paatternList1 bpt)
  let pt_1 = (paatternList1 bpt)
  let pt_2 = (paatternList1 bpt)
  let pt_3 = (paatternList1 bpt)
  p0 <- (randpick pt_0)
  p1 <- (randpick pt_1)
  p2 <- (randpick pt_2)
  p3 <- (randpick pt_3)
  -- return ()
  return [p0, p1, p2, p3]

chooseBpt :: [Pattern String] -> IO (Pattern Double, [Pattern String])
chooseBpt pats = do
  p <- (randpick binPats :: IO (Pattern Double))
  return (p, pats)

-- mxl :: [Pattern String] -> (IO (Pattern Double), [Pattern String])
mxl pats = do
  p <- (chooseBpt pats)
  -- return p
  return (chooseUr2 p) 
--   return ()
  -- return (chooseUr pat)

-- mxur pats = mxl pats

