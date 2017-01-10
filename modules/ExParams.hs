-- Extra Params.hs

module ExParams where

import Sound.Tidal.Params
import Sound.Tidal.Context

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

dist :: Pattern Double -> ParamPattern
dist = make' VF dist_p
dist_p = F "dist" (Just 0)

wah :: Pattern Double -> ParamPattern
wah = make' VF wah_p
wah_p = F "wah" (Just 0.25)

tsdelay :: Pattern Double -> ParamPattern
tsdelay = make' VF tsdelay_p
tsdelay_p = F "tsdelay" Nothing

xsdelay :: Pattern Int -> ParamPattern
xsdelay = make' VI xsdelay_p
xsdelay_p = I "xsdelay" Nothing

conv :: Pattern Double -> ParamPattern
conv = make' VF conv_p
conv_p = F "conv" (Just 0) 

convn :: Pattern Double -> ParamPattern
convn = make' VF convn_p
convn_p = F "convn" (Just 0) 

modl :: Pattern Double -> ParamPattern
modl = make' VF modl_p
modl_p = F "mod" (Just 0)

