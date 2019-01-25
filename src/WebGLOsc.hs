module WebGLOsc where
import Sound.Tidal.Stream
import Sound.Tidal.Pattern
import Sound.Tidal.Parse
import Sound.Tidal.OscStream
import Sound.Tidal.Context

port = 8000

webGLShape = Shape {

  params = [
    F "vx" (Just 0.5),
    F "vy" (Just 0.5),
    F "voffset" (Just 0),
    F "vamp" (Just 0),
    F "vfreq" (Just 0),
    F "vphase" (Just 0),
    F "vufreq" (Just 1.0),
    F "vssize" (Just 0.4)
  ],
  cpsStamp = True,
  latency = 0.1
}

webGLSlang = OscSlang {
  path = "/webgl_osc",
  timestamp = NoStamp,
  namedParams = False,
  preamble = []
}

webGLStream = do
  s <- makeConnection "127.0.0.1" port webGLSlang
  stream (Backend s $ (\_ _ _ -> return ())) webGLShape

vy = makeF webGLShape "vx"
vx = makeF webGLShape "vy"
voffset = makeF webGLShape "voffset"
vamp = makeF webGLShape "vamp"
vfreq = makeF webGLShape "vfreq"
vufreq = makeF webGLShape "vufreq"
vphase = makeF webGLShape "vphase"
vssize = makeF webGLShape "vssize"

