-- Extra Params.hs

module ExParams where

import Sound.Tidal.Pattern
import Sound.Tidal.Params
import Sound.Tidal.Context

portaTime :: Pattern Double -> ControlPattern
portaTime = pF "portaTime"

-- Custom effects by moxus

binscr :: Pattern Double -> ControlPattern
binscr = pF "binscr"

binfrz :: Pattern Double -> ControlPattern
binfrz = pF "binfrz"

binshf :: Pattern Double -> ControlPattern
binshf = pF "binshf"

binshfN :: Pattern Double -> ControlPattern
binshfN = pF "binshfN"

binsmr :: Pattern Double -> ControlPattern
binsmr = pF "binsmr"

brick :: Pattern Double -> ControlPattern
brick = pF "brick"

dist :: Pattern Double -> ControlPattern
dist = pF "dist"

wah :: Pattern Double -> ControlPattern
wah = pF "wah"

conv :: Pattern Double -> ControlPattern
conv = pF "conv"

convn :: Pattern Double -> ControlPattern
convn = pF "convn"

convp :: Pattern Double -> ControlPattern
convp = pF "convp"

modl :: Pattern Double -> ControlPattern
modl = pF "mod"

henon :: Pattern Double -> ControlPattern
henon = pF "henon"

flangefq :: Pattern Double -> ControlPattern
flangefq = pF "flangefq"

flangefb :: Pattern Double -> ControlPattern
flangefb = pF "flangefb"

chorus :: Pattern Double -> ControlPattern
chorus = pF "chorus"

pipe :: Pattern Int -> ControlPattern
pipe = pI "pipe"



-- this is exprimental
-- out :: Pattern Int -> ParamPattern
-- out = make' VI out_p
-- out_p = I "out" (Just 0)
