s.options.device_("ZOOM TAC-2");
s.options.device_("Soundflower (2ch)");

"/Users/moxuse/dev/tidal_sc/start_superdirt.scd".load;


s.makeGui

(
~dirt.orbits[0].set(\freq, #{
	(~n.degreeToKey([0, 3, 5, 7, 9, 10], 12) +62).midicps
});
)




s.sendMsg("/b_allocRead", 10, Platform.resourceDir +/+ "sounds/superdirt/mfl/mfl5.wav")

s.sendMsg("/b_allocRead", 10, Platform.resourceDir +/+ "sounds/superdirt/msn/sn3.wav");

(
{
	var sin =  PlayBuf.ar(2, 10, BufRateScale.kr(10), doneAction:2).dup();
	Out.ar(0, sin * SinOsc.ar(5.midicps + LFNoise2.ar(0.5, 20, 24).midicps,2));
//	Out.ar(0, sin);
}.play()
)





//////////////PV practice
PV_MagMul


c = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

c = Buffer.read(s, Platform.resourceDir +/+ "sounds/superdirt/mfl/mfl3.wav")

c = Buffer.read(s, Platform.resourceDir +/+ "sounds/superdirt/msn/sn3.wav");

(
SynthDef("help-magMul2", { arg out=0, soundBufnum=0;
    var inA, chainA, inB, chainB, chain;
	inA = LFSaw.ar(550, 0, 0.3);
    inB = PlayBuf.ar(1, soundBufnum, BufRateScale.kr(soundBufnum), loop: 1).softclip();
    chainA = FFT(LocalBuf(512), inA);
    chainB = FFT(LocalBuf(512), inB);
    chain = PV_MagMul(chainA, chainB);
	    Out.ar(out, Limiter.ar( 0.5 * IFFT(chain), 0.4, 0.1).dup());
}).play(s,[\out, 0, \soundBufnum, c]);
)

///////////////


















//"open /Users/moxuse/dev/tidal_sc/start_superdirt.scd".unixCmd

//s.options.device_("Soundflower (2ch)");
//p = SerialPort("/dev/tty.usbserial-A800ctdi",baudrate: 57600,crtscts: true);

s.makeGui;

s.reboot;

SerialPort.closeAll();
//Quarks.gui


// free all synthbd
(
~dirt.orbits.collect { |each|
    each.freeSynths;
  }
)


//// osc bridge event


(
var diversions = ();  // make a dictionary of functions
~diversions = diversions; // make it available out of scope
~diversions[\trig] = {
	var msg;
  msg = [
    255,
		"dco13k              sdcsd          54",
    "                  sd                                                               ",
    "               334      453  345 45   453",
    3666,
    09,
    [16, 1230],
    46,
    "asjd98ry   387473487          t2374t8273587285254iaisdbsdblajs;oihqer oioerv"
  ].choose;
	if (0.125.coin, {
    p.putAll(msg);
  });
};

~d1.defaultParentEvent[\diversion] = { diversions[\trig].value };
)


//// osc bridge event


(
var trig_addr = NetAddr("localhost", 5000);
var diversions = ();  // make a dictionary of functions
~diversions = diversions; // make it available out of scope
~diversions[\trig] = {
	var msg;
  msg = ["/tr1", "/tr2", "/tr3", "/tr4"].choose;
	if (0.125.coin, {
		trig_addr.sendMsg(msg);
		msg.postln;
  });
};

~d1.defaultParentEvent[\diversion] = { diversions[\trig].value };
)


// remove event
~d1.defaultParentEvent[\diversion] = nil;

s.sendMsg(11,1026)
{ReplaceOut.ar(0,In.ar(2)).dup};


{In.ar(3).dup}.play();
////////////////// volca midi setings
/*~midiOut = MIDIOut(1);
~midiOut.allNotesOff(0);*/
MIDIClient.init;
(


var midiOut = MIDIOut(1);
~dirt.addModule('post',
	{ |dirtEvent|
    var note, amp, inst;
    inst = -1;
		dirtEvent.event.pairsDo { |key, val, i|
      var length, dscision;
      if('note' == key, {
        note = val + 60;
      });
      if('amp' == key, {
        amp = (val * 127).floor;
      });
      if('instrument' == key) {
        if ('volca0' == val, {
          inst = 0;
        });
        if ('volca1' == val, {
          inst = 1;
        });
      };
		};
    if(0 <= inst, {
      midiOut.noteOn(inst, note, amp);
      SystemClock.sched(~sustain *0.25, {
        midiOut.noteOff(inst, note, 0);
      });
    });
});
)


////////////////////// custom function

(
var trig_addr = NetAddr("localhost", 5000);
~dirt.addModule('post',
	{ |dirtEvent|
		dirtEvent.event.pairsDo { |key, val, i|
      var length, dscision;
      length = 0.8;
      dscision = false;
      if (key == 'length', {
        length = val*0.5;
      });
      if('instrument' == key) {
        if ('bang' == val, {
          dscision = true;
        });
        if(i % 4 == 0, {
          if (dscision, {
            var msg;
            msg = ["/tr1", "/tr2", "/tr3", "/tr4"].choose;
            if (length.coin,{
              trig_addr.sendMsg(msg);
            });

          })
        });
      };
		}
});
)


/////////////////// dump events


(
~dirt.addModule('post',
	{ |dirtEvent|
		"\n------------\n".post;
		dirtEvent.event.pairsDo { |key, val, i|
//      if (key == 'length', {
//        if(0.25 == val,{
        			"%: % ".format(key, val).post;
          if(i % 4 == 0) { "\n".post };

//        });


//      });
    }
});
)


// remove it again:
~dirt.removeModule(\post);

s.makeGui

s.quit;