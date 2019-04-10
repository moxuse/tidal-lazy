{-# LANGUAGE TypeSynonymInstances, FlexibleInstances, OverloadedStrings #-}

module ExInstruments where

import Sound.Tidal.Params
import Sound.Tidal.Context

data InstType = HH | SN | BD | CP | PD | PS
data DefaultInstrument = DefaultInstrument {
  hh' :: Pattern String,
  sn' :: Pattern String, 
  bd' :: Pattern String,
  cp' :: Pattern String,
  pd' :: Pattern String, 
  ps' :: Pattern String
} deriving Show

getDefaultInstrument = DefaultInstrument { 
  hh' = "mhh2",
  sn' = "msn2",
  bd' = "mbd", 
  cp' = "mcp", 
  pd' = "mpd",
  ps' = "mps"}
defaultI = getDefaultInstrument

instr :: InstType -> Pattern String -> Maybe DefaultInstrument -> Maybe DefaultInstrument
instr itype inst base =
  case base of
    Nothing -> Just defaultI
    Just base -> Just (c_base itype inst base)
      where 
        c_base itype_ inst_ base_ =
          case itype_ of 
            HH -> base_ { hh' = inst_ }
            SN -> base_ { sn' = inst_ }
            BD -> base_ { bd' = inst_ }
            CP -> base_ { cp' = inst_ }
            PD -> base_ { pd' = inst_ }
            PS -> base_ { ps' = inst_ }

makeInst itype = instr itype
hh = makeInst HH
sn = makeInst SN
bd = makeInst BD
cp = makeInst CP
pd = makeInst PD
ps = makeInst PS

getInst :: Maybe DefaultInstrument -> DefaultInstrument
getInst ins =
  case ins of
    Just ins -> ins
    Nothing -> defaultI

inst a = getInst (a (Just defaultI))

-- shorthand
inst0 = inst $ sn "[mst:6, zap:19/4]" . hh "mhh2:11" . pd "[msn3:12 mst:10/6]" . bd "mbd2:6"
inst1 = inst $ hh "mhh2:10" . sn "mst:10" . pd "mwb:19/4". ps "zap:19/4". bd "mbd:4"
inst2 = inst $ hh "mst:9" . sn "[zap:15, mhh2:3]" . cp "mwb:3?". bd "mbd:2"
inst3 = inst $ hh "mst:2" . sn "[zap:15, msn:3]" . cp "[mcp, mwb:8?]/2". bd "mbd2:5"

