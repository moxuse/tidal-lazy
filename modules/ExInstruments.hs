module ExInstruments where

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
inst0 = inst $ sn "[msn2:6, ml:19/8]" . hh "mhh2:11" . pd "[msn2:12 mps:10/6]" . bd "mbd2:6"
inst1 = inst $ hh "mhh2:10" . sn "msn2:10" . pd "msoz:19". ps "msoz:19/4". bd "mbd2:4"

