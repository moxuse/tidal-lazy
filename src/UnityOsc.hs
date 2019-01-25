{-# LANGUAGE TypeSynonymInstances, FlexibleInstances, OverloadedStrings #-}

-- custom osc send

module UnityOsc where
import Sound.Tidal.Stream
import Sound.Tidal.Pattern
import Sound.Tidal.ParseBP
import Sound.Tidal.OscStream
import Sound.Tidal.Context

port = 5000

unityShape = Shape {

  params = [
    S "thing" Nothing,
    F "x" (Just 0),
    F "y" (Just 0),
    F "z" (Just 0),
    F "moveX" (Just 0),
    F "moveY" (Just 0),
    F "moveZ" (Just 0),
    F "vscale" (Just 1.0),
    F "duration" (Just 0.5),
    F "twist" (Just 0),
    I "rigid" (Just 0),
    F "randCam" (Just 0),
    F "vortexRadX" (Just 0.5),
    F "vortexRadY" (Just 0.5),
    F "vortexAngle" (Just 0),
    -- S "skybox" (Just ""),
    F "ripple" (Just 0),
    S "dlight" (Just "r")
  ],
  cpsStamp = True,
  latency = 0.1
}

unitySlang = OscSlang {
  path = "/unity_osc",
  timestamp = NoStamp,
  namedParams = False,
  preamble = []
}

unityStream = do
  s <- makeConnection "127.0.0.1" port unitySlang
  stream (Backend s $ (\_ _ _ -> return ())) unityShape

thing = makeS unityShape "thing"
x = makeF unityShape "x"
y = makeF unityShape "y"
z = makeF unityShape "z"
moveX = makeF unityShape "moveX"
moveY = makeF unityShape "moveY"
moveZ = makeF unityShape "moveZ"
vscale = makeF unityShape "vscale"
duration = makeF unityShape "duration"
twist = makeF unityShape "twist"
rigid = makeI unityShape "rigid"
randCam = makeF unityShape "randCam"
vortexRadX = makeF unityShape "vortexRadX"
vortexRadY = makeF unityShape "vortexRadY"
vortexAngle = makeF unityShape "vortexAngle"

vortex x y angle = vortexRadX x |+| vortexRadY y |+| vortexAngle angle

move x y z = moveX x |+| moveY y |+| moveZ z

ripple = makeF unityShape "ripple"

dlight = makeS  unityShape "dlight"
-- skybox = makeS unityShape "skybox"

