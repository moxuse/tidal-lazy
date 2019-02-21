module MIDIClockShape where


import Sound.Tidal.MIDI.Control
import Sound.Tidal.Params

clockController :: ControllerShape

clockController = 
  ControllerShape
  { controls = 
    [
      mCC test_p 99
    ]  
  , latency = 0.3
  }  

(test, test_p) = pF "test" (Just 0)

