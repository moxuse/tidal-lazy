MIDIClient.init;
MIDIClient.sources;
MIDIClient.disposeClient;
MIDIIn.connect;    // init for one port midi interface
MIDIIn.addFuncTo(\noteOn, ~noteOn);
// register functions:
~noteOff = { arg src, chan, num, vel;    [chan,num,vel / 127].postln; };
~noteOn = { arg src, chan, num, vel;    [chan,num,vel / 127].postln; };













MIDIOut

m = MIDIOut(0);

m.noteOn(16, 60, 60);
m.noteOff(16, 61, 60);
m.allNotesOff(16);