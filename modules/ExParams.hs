-- Extra Params.hs

module ExParams where

import Sound.Tidal.Params
import Sound.Tidal.Context


tsdelay :: Pattern Double -> ParamPattern
tsdelay = make' VF tsdelay_p
tsdelay_p = F "tsdelay" Nothing

xsdelay :: Pattern Int -> ParamPattern
xsdelay = make' VI xsdelay_p
xsdelay_p = I "xsdelay" Nothing

-- Custom effects by moxus

binscr :: Pattern Double -> ParamPattern
binscr = make' VF binscr_p
binscr_p = F "binscr" (Just 0)

binfrz :: Pattern Double -> ParamPattern
binfrz = make' VF binfrz_p
binfrz_p = F "binfrz" (Just 0)

binshf :: Pattern Double -> ParamPattern
binshf = make' VF binshf_p
binshf_p = F "binshf" (Just 0)

binsmr :: Pattern Double -> ParamPattern
binsmr = make' VF binsmr_p
binsmr_p = F "binsmr" (Just 0)

brick :: Pattern Double -> ParamPattern
brick = make' VF brick_p
brick_p = F "brick" (Just 0)

dist :: Pattern Double -> ParamPattern
dist = make' VF dist_p
dist_p = F "dist" (Just 0)

wah :: Pattern Double -> ParamPattern
wah = make' VF wah_p
wah_p = F "wah" (Just 0.25)

conv :: Pattern Double -> ParamPattern
conv = make' VF conv_p
conv_p = F "conv" (Just 0) 

convn :: Pattern Double -> ParamPattern
convn = make' VF convn_p
convn_p = F "convn" (Just 0) 

convp :: Pattern Double -> ParamPattern
convp = make' VF convp_p
convp_p = F "convp" (Just 0) 

modl :: Pattern Double -> ParamPattern
modl = make' VF modl_p
modl_p = F "mod" (Just 0)

henon :: Pattern Double -> ParamPattern
henon = make' VF henon_p
henon_p = F "henon" (Just 0)

flangefq :: Pattern Double -> ParamPattern
flangefq = make' VF flangefq_p
flangefq_p = F "flangefq" (Just 0)

flangefb :: Pattern Double -> ParamPattern
flangefb = make' VF flangefb_p
flangefb_p = F "flangefb" (Just 0)

pipe :: Pattern Int -> ParamPattern
pipe = make' VI pipe_p
pipe_p = I "pipe" (Just 0)


-- this is exprimental
-- out :: Pattern Int -> ParamPattern
-- out = make' VI out_p
-- out_p = I "out" (Just 0)


