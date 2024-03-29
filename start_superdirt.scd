(
var numChannels, viznut_sig, viznut_buf;
var diversions = ();
var syncTempo = TempoClock.new; // sync Tempo
var tempo = 120 / 150;

s.quit;
// s.options.device_("Soundflower (2ch)");

// s.options.device_("Audinst HUD-mx1");

// s.options.device_("ZOOM TAC-2");

// configure the sound server: here you could add hardware specific options
// see http://doc.sccode.org/Classes/ServerOptions.html
s.options.sampleRate = 44100;
s.options.numBuffers = 1024 * 256; // increase this if you need to load more samples
s.options.memSize = 8192 * 64; // increase this if you get "alloc failed" messages
s.options.maxNodes = 1024 * 64; // increase this if you are getting drop outs and the message "too many nodes"
s.options.numOutputBusChannels = 2; // set this to your hardware output channel size, if necessary
s.options.numInputBusChannels = 2; // set this to your hardware output channel size, if necessary
// boot the server and start SuperDirt
s.waitForBoot {
  s.makeGui;
  ~dirt = SuperDirt(2, s); // two output channels, increase if you want to pan across more channels
  ~dirt.loadSoundFiles;   // load samples (path can be passed in)
  //s.sync; // wait for samples to be read
  ~dirt.loadSoundFiles(Platform.resourceDir ++ "/sounds/superdirt/*", true);   // load samples (path can be passed in)P
  s.sync; // wait for samples to be read

  ~dirt.start(57120, [0, 0]);   // start listening on port 57120, create two busses each sending audio to channel 0

  // optional, needed for the sclang tests only:
	// (
	//
	// 	~d1 = ~dirt.orbits[0]; // one orbit
	// 	~d2 = ~dirt.orbits[1];
	// );


  s.latency = 0.1; // increase this if you get "late" messages

  numChannels =  ~dirt.numChannels;

	//clock for Orca sync

	~dirt.soundLibrary.addSynth(\sync, (play: {
		/*syncTempo.clear;
		syncTempo = TempoClock.new;
		syncTempo.tempo = tempo;
		syncTempo.schedAbs(0, { arg beat, sec;
			var current;
			current = (beat * 8).asInteger;
			NetAddr("localhost", 49160).sendMsg("frame:" ++ current);
			1
		});*/
		NetAddr("localhost", 49160).sendMsg("frame:0");
	}));

	~dirt.soundLibrary.addSynth(\dig0, (play: {
		NetAddr("localhost", 49160).sendMsg("write:E;2;16");
	}));
	~dirt.soundLibrary.addSynth(\dig1, (play: {
		NetAddr("localhost", 49160).sendMsg("write:E;2;18");
	}));
	~dirt.soundLibrary.addSynth(\dig2, (play: {
		NetAddr("localhost", 49160).sendMsg("write:E;2;20");
	}));
	~dirt.soundLibrary.addSynth(\dig3, (play: {
		NetAddr("localhost", 49160).sendMsg("write:E;2;22");
	}));
	~dirt.soundLibrary.addSynth(\dig4, (play: {
		NetAddr("localhost", 49160).sendMsg("write:E;16;16");
	}));
	~dirt.soundLibrary.addSynth(\dig5, (play: {
		NetAddr("localhost", 49160).sendMsg("write:E;16;18");
	}));
	~dirt.soundLibrary.addSynth(\dig6, (play: {
		NetAddr("localhost", 49160).sendMsg("write:E;16;20");
	}));
	~dirt.soundLibrary.addSynth(\dig7, (play: {
		NetAddr("localhost", 49160).sendMsg("write:E;16;22");
	}));


  /**
   * superdirt filter modulest
   */

  ~dirt.addModule('spectral-delay', { |dirtEvent|
    dirtEvent.sendSynth('spectral-delay' ++ ~dirt.numChannels,
      // OPTIONAL
      // passing this array of parameters could be left out,
      // but it makes it clear what happens
      [
        xsdelay: ~xsdelay,
        tsdelay: ~tsdelay,
        sustain: ~sustain,
        out: ~out
      ]
    )
  }, { ~tsdelay.notNil or: { ~xsdelay.notNil } }); // play synth only if at least one of the two was given

  SynthDef("spectral-delay" ++ numChannels, { |out, tsdelay, xsdelay = 1, sustain|

    var signal, delayTime, delays, freqs, filtered;
    var size = 12;
    var maxDelayTime = 0.2;

    signal = In.ar(out, numChannels);
    delayTime = tsdelay * maxDelayTime;
    filtered = (1..size).sum { |i|
      var filterFreq = i.linexp(1, size, 40, 17000);
      var sig = BPF.ar(signal, filterFreq, 0.01);
      // the delay pattern is determined from xsdelay by bitwise-and:
      DelayN.ar(sig, maxDelayTime, (i & xsdelay * (1/size) * delayTime) * LFNoise2.kr(10.2 * tsdelay, 2.5).abs);
    };
    signal = signal * 0.2 + (filtered * 4); // this controls wet/dry
    ReplaceOut.ar(out, signal)

  }).add;


  ~dirt.addModule('binscramble', { |dirtEvent|
    dirtEvent.sendSynth('binscramble' ++ numChannels,
      [
        out: ~out,
        bscr: ~binscr
      ]
    )
  }, { ~binscr.notNil });


  SynthDef("binscramble" ++ numChannels, { |out, pan = 0, binscr = 0|
    var signal, chain, chain_r, lfo, lfo2, trig;
    signal = In.ar(out, numChannels) * 1.9;
    chain = FFT(LocalBuf(2048), signal[0]);
    chain_r = FFT(LocalBuf(2048), signal[1]);
    lfo = LFNoise2.kr(4).abs;
    lfo2 = LFNoise2.kr(2).abs;
    trig = Impulse.kr(32);
    chain = PV_BinScramble(chain, lfo, lfo2, trig);
    chain_r = PV_BinScramble(chain_r, lfo, lfo2, trig);
    ReplaceOut.ar(out, Pan2.ar((signal * (1.0 - binscr)) + (binscr * [IFFT(chain), IFFT(chain_r)]), pan));
  }).store;

  ~dirt.addModule('binfreeze', { |dirtEvent|
    dirtEvent.sendSynth('binfreeze' ++ numChannels,
      [
        out: ~out,
        binfrz: ~binfrz
      ]
    )
  }, { ~binfrz.notNil });

  SynthDef("binfreeze" ++ numChannels, { |out, pan = 0, binfrz = 0|
    var signal, chain, chain_r, thr;
    signal = In.ar(out, numChannels) * 1.9;
    chain = FFT(LocalBuf(2048), signal[0]);
    chain_r = FFT(LocalBuf(2048), signal[1]);
    thr = MouseY.kr;
    chain = PV_MagFreeze(chain, thr > 0.5);
    chain_r = PV_MagFreeze(chain_r, thr > 0.5);
    ReplaceOut.ar(out, Pan2.ar((signal * (1.0 - binfrz)) + (binfrz * [IFFT(chain), IFFT(chain_r)]), pan));
  }).store;

  ~dirt.addModule('binshift', { |dirtEvent|
    dirtEvent.sendSynth('binshift' ++ numChannels,
      [
        out: ~out,
        binshf: ~binshf
      ]
    )
  }, { ~binshf.notNil });


  SynthDef("binshift" ++ numChannels, { |out, pan = 0, binshf = 0|
    var signal, chain, chain_r, thr;
    signal = In.ar(out, numChannels) * 1.4;
    chain = FFT(LocalBuf(2048), signal[1]);
    chain_r = FFT(LocalBuf(2048), signal[0]);
    thr = MouseX.kr(0.25, 4, \exponential);
    chain =  PV_BinShift(chain, thr);
    chain_r =  PV_BinShift(chain_r, thr);
    ReplaceOut.ar(out, Pan2.ar((signal * (1.0 - binshf)) + (binshf * [IFFT(chain), IFFT(chain_r)]), pan));
  }).store;

  ~dirt.addModule('binshiftN', { |dirtEvent|
    dirtEvent.sendSynth('binshiftN' ++ numChannels,
      [
        out: ~out,
        binshfN: ~binshfN
      ]
    )
  }, { ~binshfN.notNil });


  SynthDef("binshiftN" ++ numChannels, { |out, pan = 0, binshfN = 0|
    var signal, chain, chain_r, thr, shifter;
    signal = In.ar(out, numChannels) * 1.4;
    chain = FFT(LocalBuf(2048), signal[1]);
    chain_r = FFT(LocalBuf(2048), signal[0]);
	thr = LFNoise2.kr(4, 8).abs + 0.125;
	shifter = LFNoise2.kr(4, 128);
		// MouseX.kr(0.25, 4, \exponential);
		chain =  PV_BinShift(chain, thr, shifter);
		chain_r =  PV_BinShift(chain_r, thr, shifter);
		ReplaceOut.ar(out, Pan2.ar((signal * (1.0 - binshfN)) + (binshfN * [IFFT(chain), IFFT(chain_r)]), pan));
	}).store;


	~dirt.addModule('binsmear', { |dirtEvent|
		dirtEvent.sendSynth('binsmear' ++ numChannels,
			[
				out: ~out,
				binsmr: ~binsmr
			]
		)
	}, { ~binsmr.notNil });

	SynthDef("binsmear" ++ numChannels, { |out, pan = 0, binsmr = 0|
		var in, chain, chain_r, bins;
		in = In.ar(out, numChannels) * 1.75;
		chain = FFT(LocalBuf(2048), in[1]);
		chain_r = FFT(LocalBuf(2048), in[0]);
		bins = MouseY.kr(0, 100);
		chain = PV_MagSmear(chain, bins);
		chain_r = PV_MagSmear(chain_r, bins);

		ReplaceOut.ar(out, Pan2.ar((in * (1.0 - binsmr)) + (binsmr * [IFFT(chain), IFFT(chain_r)]), pan));
	}).store;


	~dirt.addModule('brick', { |dirtEvent|
		dirtEvent.sendSynth('brick' ++ numChannels,
			[
				out: ~out,
				brick: ~brick
			]
		)
	}, { ~brick.notNil });

	SynthDef("brick" ++ numChannels, { |out, pan = 0, brick = 0|
		var in, chain, chain_r, wall;
		in = In.ar(out, numChannels) * 1.35;
		chain = FFT(LocalBuf(2048), in[1]);
		chain_r = FFT(LocalBuf(2048), in[0]);
		wall = LFNoise2.kr(0.0 + brick);
		chain = PV_BrickWall(chain, wall);
		chain_r = PV_BrickWall(chain_r, wall);

		ReplaceOut.ar(out, Pan2.ar([IFFT(chain), IFFT(chain_r)], pan));
	}).store;


	~dirt.addModule('distortion', { |dirtEvent|
		dirtEvent.sendSynth('distortion' ++ numChannels,
			[
				out: ~out,
				dist: ~dist
			]
		)
	}, { ~dist.notNil });

	SynthDef("distortion" ++ numChannels, { arg out, pan = 0, dist = 0;
		var in, mix;
		in = Pan2.ar(In.ar(out, numChannels), LFNoise2.kr(0.3,0.4));
		mix = ((in[0]*120).softclip)* 0.75;
		ReplaceOut.ar(out, (in * (1.0 - dist)) + (dist * mix));
	}).store;

	~dirt.addModule('convolution', { |dirtEvent|
		dirtEvent.sendSynth('convolution' ++ numChannels,
			[
				out: ~out,
				note: ~note,
				conv: ~conv
			]
		)
	}, { ~conv.notNil });

	SynthDef("convolution" ++ numChannels, { arg out, note, pan = 0, conv = 0;
		var in, karnel, mix;
		karnel = LFPulse.ar((note + 60).midicps, 0.0, 0.15, 0.2) + Impulse.ar((note + 60).midicps, 0.0, 0.4);
		in = In.ar(out, numChannels);
		mix = [Convolution.ar(in[0], karnel, 1024, 0.5), Convolution.ar(in[1], karnel, 1024, 0.5)];
		ReplaceOut.ar(out, Pan2.ar((in * (1.0 - conv)) + (conv * mix), pan));
	}).store;

	~dirt.addModule('mod', { |dirtEvent|
		dirtEvent.sendSynth('mod' ++ ~dirt.numChannels,  [
			out: ~out,
			mod: ~mod
		])
	}, { ~mod.notNil });


	SynthDef('mod'++ numChannels, { |out, pan = 0, mod|

		var trate, index, in, mix, signal;

		index = Amplitude.kr((mod.ceil).clip(0,1));

		in = In.ar(out, numChannels);

		trate = MouseY.kr(12,9320,1);

		mix = MonoGrain.ar(in, 0.75 / trate, trate);

		signal = Select.ar(index, [in, mix]);

		ReplaceOut.ar(out, Pan2.ar(signal, pan));

	}).store();


	~dirt.addModule('convolution_n', { |dirtEvent|
		dirtEvent.sendSynth('convolution_n' ++ numChannels,
			[
				out: ~out,
				convn: ~convn
			]
		)
	}, { ~convn.notNil });

	SynthDef("convolution_n" ++ numChannels, { arg out, note, pan = 0, convn = 0;
		var in, karnel, mix;
		karnel = ClipNoise.ar(0.2);
		in = In.ar(out, numChannels);
		mix = [Convolution.ar(in[0], karnel, 1024, 0.5), Convolution.ar(in[1], karnel, 1024, 0.5)];
		ReplaceOut.ar(out, Pan2.ar((in * (1.0 - convn)) + (convn * mix),pan));
	}).store;

	~dirt.addModule('convolution_p', { |dirtEvent|
		dirtEvent.sendSynth('convolution_p' ++ numChannels,
			[
				out: ~out,
				note: ~note,
				convp: ~convp
			]
		)
	}, { ~convp.notNil });

	SynthDef("convolution_p" ++ numChannels, { arg out, note = 0, pan = 0, convp = 0;
		var src, kernel, mix, env;
		kernel = Mix.new(Pulse.ar(((note + 60)).midicps, 0.5, 0.1));
		src = In.ar(out, numChannels);
		mix = Convolution.ar(src[0], kernel, 2048);
		ReplaceOut.ar(out, Pan2.ar((src * (1.0 - convp)) + (convp * mix),pan));
	}).store();

	~dirt.addModule('decay-filter', { |dirtEvent|
		dirtEvent.sendSynth('decay-filter' ++ numChannels,
			[
				out: ~out,
				decay: ~decay
			]
		)
	}, { ~decay.notNil });

	SynthDef("decay-filter" ++ numChannels, { |out = 0, decay = 0|
		var signal, mix, mix_2, trig;
		signal = In.ar(out, numChannels);
		trig = Decay.ar(Impulse.ar(decay, 2 / decay ));
		mix = signal[0] * trig;
		mix_2 = signal[1] * trig;
		ReplaceOut.ar(out, [mix, mix_2]);
	}).store;

	~dirt.addModule('wah', { |dirtEvent|
		dirtEvent.sendSynth('wah' ++ numChannels,
			[
				out: ~out,
				wah: ~wah
			]
		)
	}, { ~wah.notNil });

	SynthDef("wah" ++ numChannels, { arg out, pan = 0, wah = 0;
		var index, in, mix, signal;

		index = Amplitude.kr((wah.ceil).clip(0,1));

		in = In.ar(out, numChannels);

		mix = RLPF.ar(in, LFNoise2.kr(wah.linexp(0, 1.0, 0.8, 40), 40, 84).midicps, 0.2);

		signal = Select.ar(index, [in, mix]);

		ReplaceOut.ar(out, Pan2.ar(signal, pan));
	}).store;

	~dirt.addModule('henon', { |dirtEvent|
		dirtEvent.sendSynth('henon' ++ numChannels,
			[
				out: ~out,
				henon: ~henon
			]
		)
	}, { ~henon.notNil });

	SynthDef("henon" ++ numChannels, { arg out, pan = 0, henon = 0;
		var index, in, mix, rate;

		rate = henon;

		in = In.ar(out, numChannels);

		mix = in * HenonC.ar(SampleRate.ir/2, LFNoise2.ar(0.6,1.2),  LFNoise1.ar(0.4,0.9));

		ReplaceOut.ar(out, Pan2.ar((in * (1.0 - rate)) + (mix * rate), pan));
	}).store;

	~dirt.addModule('flange', { |dirtEvent|
		dirtEvent.sendSynth('flange' ++ numChannels,
			[
				out: ~out,
				flangefq: ~flangefq,
				flangefb: ~flangefb,
			]
		)
	}, { ~flangefq.notNil or: { ~flangefb.notNil } });

	SynthDef("flange" ++ numChannels, { | out, pan = 0, flangefq = 0.1, flangefb = 0.1 |
		var input, effect;
		input = In.ar(out, numChannels);
		input = input + LocalIn.ar(numChannels); //add some feedback
		effect = DelayN.ar(input, 0.02, SinOsc.kr(flangefq, 0, 0.005, 0.005));
		LocalOut.ar(flangefb * effect);
		ReplaceOut.ar(out, Pan2.ar(effect, pan));
	}).store;


	~dirt.addModule('pipe', { |dirtEvent|
		dirtEvent.sendSynth('pipe' ++ numChannels,
			[
				out: ~out,
				pipe: ~pipe
			]
		)
	}, { ~pipe.notNil and: { ~pipe != 0 }});

	SynthDef("pipe" ++ numChannels, { | out, pipe = 0, pan = 0 |
		var input;
		input = In.ar(out, numChannels) ;
		OffsetOut.ar(pipe, input);
		ReplaceOut.ar(out, Silent.ar(numChannels));
	},[\ir, \ir, \ir]).store;


	~dirt.addModule('chorus', { |dirtEvent|
		dirtEvent.sendSynth('chorus' ++ numChannels,
			[
				out: ~out,
				chorus: ~chorus
			]
		)
	}, { ~chorus.notNil and: { ~chorus != 0 } });

	SynthDef("chorus" ++ numChannels, { | out, pan = 0, chorus = 0.1 |
		var input, effect;
		input = In.ar(out, numChannels);

		effect = Mix.fill(6, {
			DelayN.ar(input, chorus, LFNoise1.kr(Rand(5,10),0.01,0.02));
		});

		ReplaceOut.ar(out, Pan2.ar(effect, pan));
	}).store;


	// ~dirt.orderModules(['sound', 'vowel', 'flange', 'shape',  'crush', 'coarse', 'mod', 'wah', 'brick', 'spectral-delay','decay-filter','binfreeze', 'binscramble', 'binshift', 'binsmear', 'conv', 'convn', 'convp', 'henon', 'distortion', 'hpf', 'lpf', 'bpf', 'envelope', 'tremolo', 'phaser', 'convolution', 'convolution_n', 'convolution_p']);

	~dirt.orderModules(['sound', 'vowel', 'flange', 'chorus', 'shape',  'crush', 'coarse', 'mod', 'wah', 'brick', 'spectral-delay','decay-filter','binfreeze', 'binscramble', 'binshift', 'binshiftN', 'binsmear', 'conv', 'convn', 'convp', 'henon', 'distortion', 'hpf', 'lpf', 'bpf', 'envelope', 'tremolo', 'phaser', 'convolution', 'convolution_n', 'convolution_p', 'pipe']);



	/**
	* custom synths
	*/

	SynthDef(\ld0, { |out, sustain = 1, note = 0, speed = 1, begin=0, end=1, pan, accelerate, amp = 1, offset|
		var env, sound, dur;
		dur = 0.5 * (end - begin)/speed;
		sound = RLPF.ar( Mix.fill(7, {Pulse.ar((note + 60).midicps * (1.0 + Sweep.kr(1, accelerate)), 0.1, 0.04) + SinOsc.ar((note+[60, 72].choose).midicps * 2, LFSaw.ar((note+48).midicps,0,0.3,2), 0.03)}), LFNoise2.kr(0.4, 20 ,72).midicps, 0.2);
		env = EnvGen.ar(Env.perc(0.02, dur, amp * 0.5, -8), timeScale:sustain,
			doneAction:2);
		OffsetOut.ar(out,
			DirtPan.ar(sound, 2, pan, env)
		)
	}).store();

	SynthDef(\ld1, {|out, sustain = 1, note = 0, speed = 1, begin=0, end=1, pan, accelerate, amp = 1, offset|
		var sound, d_freq, dur, env;
		dur = 1.5 * (end - begin);
		d_freq = (note + 60).midicps * (1.0 + Sweep.kr(1, accelerate)) * speed;

		env = EnvGen.ar(Env.adsr(0.1, dur, 0.8, 2.3, 1, 2), timeScale:sustain, doneAction:2);

		sound=MoogFF.ar(
			SinOsc.ar(d_freq + LFNoise2.ar(0.2, 10),
				SinOsc.ar(d_freq * 3, SinOsc.ar(d_freq, 0, 6), 3) * EnvGen.kr(Env.perc(0.1, 0.35, amp , -4),  timeScale:sustain),
				SinOsc.ar(d_freq, pi / 2, amp)
			),
			TExpRand.kr(1800.0, 8300.0, Impulse.kr(1.5))
		);

		OffsetOut.ar(out,
			DirtPan.ar(sound, ~dirt.numChannels, pan, env)
		)
	}).store;


	SynthDef(\ld2, {|out, sustain = 1, note = 0, speed = 1, begin=0, end=1, pan, accelerate, amp = 1, offset|
		var sound, d_freq, dur, env;
		dur = 2.0 * (end - begin);
		d_freq = (note + 48).midicps * (1.0 + Sweep.kr(1, accelerate));
		env = EnvGen.ar(Env.adsr(0.0, dur * sustain, 0.2, 1.5 * sustain,  1.2 * amp, -4), timeScale:sustain, doneAction:2);
		sound = Resonz.ar(Dust.ar(12000), d_freq, 0.0025) * 50 * amp;
		OffsetOut.ar(out,
			DirtPan.ar(sound, ~dirt.numChannels, pan, env)
		)
	}).store;

	SynthDef(\ld3, {|out, sustain = 1, note = 0, speed = 1, begin=0, end=1, pan, accelerate, amp = 1, offset|
		var sound, d_freq, dur, env;
		dur = 2.0 * (end - begin);
		d_freq = (note + 60).midicps * (1.0 + Sweep.kr(1, accelerate));

		env = EnvGen.ar(Env.adsr(0.05, dur * sustain, 0.2, sustain, amp, -4), timeScale:sustain, doneAction:2);

		sound = RLPF.ar( Mix.fill(5, {Impulse.ar(d_freq, 0.0, 0.4) + SinOsc.ar((note+[60, 72].choose).midicps * 2, LFSaw.ar((note+72).midicps,0,0.1,1), 0.03)}), LFNoise2.kr(0.4, 20 ,82).midicps, 0.3);

		OffsetOut.ar(out,
			DirtPan.ar(sound, ~dirt.numChannels, pan, env)
		)
	}).store;


	SynthDef(\ldb, {|out, sustain = 1, gate = 1, note = 0, speed = 1, begin=0, end=1, pan, accelerate, amp = 1, offset|
		var sound, d_freq, dur, env;
		dur = 1.0 * (end - begin)/speed;
		d_freq = (note + 60).midicps * (1.0 + Sweep.kr(1, accelerate));
		env = EnvGen.ar(Env.perc(0.025 * sustain, 2*dur,  1, -4), gate, timeScale:sustain*8, doneAction:2);
		sound = RLPF.ar(SinOsc.ar(SinOsc.kr(d_freq/pi, 0, d_freq*2, 0.5), 0, 0.3),LFNoise2.kr(5,23,60).midicps,0.3);
		OffsetOut.ar(out,
			DirtPan.ar(sound, ~dirt.numChannels, pan, env)
		)
	}).store;


	SynthDef(\moe1, {|out, sustain = 1, gate = 1, note = 0, speed = 1, begin=0, end=1, pan, accelerate, amp = 1, offset|
		var sound, d_freq, dur, env;
		dur = 1.0 * (end - begin)/speed;
		d_freq = ((note + 60).midicps * (1.0 + Sweep.kr(1, accelerate)) * 0.003 )+ 1.0;
		env = EnvGen.ar(Env.perc(0.0, 0.05*dur,  1, -6), gate, timeScale:sustain*8, doneAction:2);
		sound = Klank.ar(`[[60,18492,8354] * d_freq, nil, [0.6, 0.6,1]], ClipNoise.ar(0.04)) * amp;
		OffsetOut.ar(out,
			DirtPan.ar((sound*32).softclip*0.3, ~dirt.numChannels, pan, env)
		)
	}).store;


	// s.sendMsg(\b_allocRead, 10, Platform.resourceDir ++ "/sounds/sui1.aif");

	SynthDef(\moe2, {|out, sustain = 1, gate = 1, note = 0, speed = 1, begin=0, trate = 5,end=1, pan, accelerate, amp = 1, offset|
		var sound, d_freq, dur,r_dur, env;
		dur = 1.0 * (end - begin) / speed;
		r_dur = SinOsc.ar(2,0,18,20).abs / trate;
		d_freq = ((note + 60).midicps * (1.0 + Sweep.kr(1, accelerate)) * 0.3 )+ 1.0;
		env = EnvGen.ar(Env.perc(0.01, 0.2 * dur, 1, -2), gate, timeScale:sustain*8, doneAction:2);
		sound = RLPF.ar((TGrains.ar(2, Impulse.ar(XLine.ar(222,trate,0.2)), 10, speed , MouseX.kr(0,BufDur.kr(10)), 0.02 * dur, LFNoise2.kr(4), 1)*20).softclip * 0.2 * amp, LFNoise2.ar(2.8,20,98).midicps,0.3);
		OffsetOut.ar(out,
			DirtPan.ar((sound*32).softclip*0.2, ~dirt.numChannels, pan, env)
		)
	}).store;


	SynthDef(\moe3, {|out, sustain = 1, gate = 1, note = 0, speed = 1, begin=0, end=1, pan, accelerate, amp = 1, offset|
		var sound, d_freq, dur, env, dom;
		dom=12800;
		dur = 1.0 * (end - begin)/speed;
		d_freq = ((note + 60).midicps * (1.0 + Sweep.kr(1, accelerate)) * 0.003 )+ 1.0;
		env = EnvGen.ar(Env.perc(0.02, 0.2 * dur,  1, -3), gate, timeScale:sustain, doneAction:2);
		sound = Pulse.ar(XLine.kr(dom,60,0.05),0.5,0.4) * Decay2.ar(Impulse.ar(16), 0.01, 0.14, 5) * amp;
		OffsetOut.ar(out,
			DirtPan.ar(sound.softclip, ~dirt.numChannels, pan, env)
		)
	}).store;


	SynthDef(\moe4, {|out, sustain = 1, gate = 1, note = 0, speed = 1, begin=0, end=1, pan, accelerate, amp = 1, offset|
		var sound, d_freq, dur, env, yy, ww;

		dur = 1.0 * (end - begin)/speed;
		d_freq = ((note + 60).midicps * (1.0 + Sweep.kr(1, accelerate)) * 0.003 ) + 1.0;
		env = EnvGen.ar(Env.perc(0.02 , 0.3*dur,  1, 1), gate, timeScale:sustain, doneAction:2);
		sound = ClipNoise.ar(0.5)*Decay2.ar(Impulse.ar(9), 0.01, 0.02, 5) * amp;

		sound = (sound*800)*gate/8;
		ww = (sound).softclip*0.2;
		ww = AllpassN.ar(ww, 0.1,{[ Rand(0.03, 0.1), Rand(0.03, 0.1)]}.dup(2), 1.0);
		//yy = (yy * -0.5) + (ww * 0.5);

		OffsetOut.ar(out,
			DirtPan.ar(ww, ~dirt.numChannels, pan, env);
		)
	}).store;


	SynthDef('mgut',{|out, sustain = 1, gate = 1, note = 0, speed = 1, begin=0, end=1, pan, accelerate, amp = 1, offset|

		var sound, d_freq, dur, env;
		dur = 1.5 * (end - begin);
		d_freq = (note + 60).midicps * (1.0 + Sweep.kr(1, accelerate)) * speed;

		env = EnvGen.ar(Env.adsr(0.1, dur, 0.2, 1, amp, -6), timeScale:sustain, doneAction:2);

		sound = Pluck.ar(WhiteNoise.ar(0.1),1, 68.midicps.reciprocal, d_freq.reciprocal, 12,
			coef: 0);
		OffsetOut.ar(out,
			DirtPan.ar(sound, ~dirt.numChannels, pan, env);
		)
	}).store();

	/*
	SynthDef(\mstring, {|out, sustain = 1, gate = 1, note = 0, speed = 1, begin=0, end=1, pan, accelerate, amp = 1, offset|
	var sound, d_freq, dur, env, sig;

	dur = 1.0 * (end - begin)/speed;

	env = EnvGen.ar(Env.perc(0.1 , 0.3 * dur,  1, 1), gate, timeScale:sustain, doneAction:2);

	sound = Mix.fill(32 ,{|i|
	Pluck.ar(WhiteNoise.ar(0.05),
	Impulse.kr(200),
	((60 + note).midicps).reciprocal,
	{((([0, 2, 7, 10, 24].choose + 60 + note).midicps) * rrand(0.99, 1.01)).reciprocal},
	30,
	coef: {rrand(-0.02, 0.02)})
	* LFNoise2.kr(0.03, 1, 0.3).abs
	* 0.3;
	}) * amp;

	sig = AllpassN.ar(sound, 0.1,{[ Rand(0.03, 0.1), Rand(0.03, 0.1)]}.dup(2), 1.0);
	//yy = (yy * -0.5) + (ww * 0.5);

	OffsetOut.ar(out,
	DirtPan.ar(sig, ~dirt.numChannels, pan, env);
	)
	}).store;
	*/

	// viznut grain synth

	/*
	viznut_sig = Signal.fill(512 * 1200, {|i|
	var t= i;
	var calc;
	calc= t*(((t>>12)|(t>>8))&(56&(t>>3)));
	(calc%256)/128.0-1.0;
	});

	viznut_buf = Buffer.alloc(s, 512 * 1200, bufnum: 99999);
	viznut_buf.loadCollection(viznut_sig);


	SynthDef(\mviznut, {|out, sustain = 1, gate = 1, note = 0, speed = 1, begin=0, end=1, pan, accelerate, amp = 1, offset|
	var sound, d_freq, dur, env, sig, tdur, trate, rate;

	trate = MouseY.kr(0.7,200,1);
	tdur = 4 / trate;
	rate = Dseq([1, 0.5], inf);

	dur = 1.0 * (end - begin)/speed;

	env = EnvGen.ar(Env.perc(0.0 , dur,  1, 4), gate, timeScale:sustain, doneAction:2);

	sound = TGrains.ar(1, Impulse.ar(trate), 99999, rate * speed, MouseX.kr(0,BufDur.kr(99999)), tdur, 0, 0.1, 1) * 0.5 * amp;


	OffsetOut.ar(out,
	DirtPan.ar(sound, ~dirt.numChannels, pan, env);
	)
	}).store;
	*/

	SynthDef(\pmosc, {|out, sustain = 1, gate = 1, note = 0, speed = 1, begin=0, end=1, pan, accelerate, amp = 1, offset|
		var sound, d_freq, dur, env;
		dur = 1.0 * (end - begin)/speed;

		sound = Mix.new(
			PMOsc.ar(
				((([0, 5, 12, 24, 36] + (note + 60)).midicps)) * (1.0 + Sweep.kr(1, accelerate)) * speed,
				ExpRand(3, 50),
				EnvGen.ar(Env.adsr(Rand(0.1, 0.25) * dur, ExpRand(0.01, 0.5), 0.03, 1.0, ExpRand(3, 10), 1)),
				1,
				0.1));
		env = EnvGen.ar(Env.perc(0.5, 2.2 * dur,  1 * amp, -9), gate, timeScale:sustain, doneAction:2);
		OffsetOut.ar(out,
			DirtPan.ar(sound, ~dirt.numChannels, pan, env)
		)
	}).store;


	SynthDef(\txosc, {|out, sustain = 1, gate = 1, note = 0, speed = 1, begin=0, end=1, pan, accelerate, amp = 1, offset|
		var sound, d_freq, dur, env, d_env, src;
		dur = 1.0 * (end - begin)/speed;
		d_freq = ([0,-12]+(note + 60).midicps) * (1.0 + Sweep.kr(1, accelerate)) * speed;
		d_env = EnvGen.ar(Env.adsr(Rand(0.1, 0.25) * dur, ExpRand(0.01, 0.5), 0.2, 1.0, ExpRand(4, 10), 1));

		sound = AllpassC.ar(
			(DynKlank.ar(`[[d_freq/2,d_freq,d_freq*2], nil, [0.25, 1, 0.75]], BrownNoise.ar([0.07, 0.07])) * 4).softclip * 0.3 * Decay2.ar(Dust.ar((d_freq/35).clip(0.25,12)), 0.2, 0.35),
			0.2, 0.5, 2);

		env = EnvGen.ar(Env.perc(1, 1.5 * dur,  1 * amp, -4), gate, timeScale:sustain, doneAction:2);
		OffsetOut.ar(out,
			DirtPan.ar(sound, ~dirt.numChannels, pan, env)
		)
	}).store;

	SynthDef(\fm7, {|out, sustain = 1, note = 0, speed = 1, begin=0, end=1, pan, accelerate, amp = 1, offset|
		var env, dur;
		var freq = (note + 60).midicps;
		var ctls = [
			// freq, phase, amp
			[SinOsc.kr(Line.kr(30, freq, 0.9)).range(60, freq), 0, EnvGen.ar(Env.perc(0.01,1))],
			[LFNoise2.kr(Line.kr(15, freq * 13, 0.13)), SinOsc.kr(freq * 3, 0, 2), EnvGen.ar(Env.perc(0.02,1.4))],
			[LFNoise1.kr(2).exprange(10, freq / 2), 0, EnvGen.ar(Env.perc(0.05,2.0))],
			[SinOsc.kr(Line.kr(20, freq / 12, 0.3)).exprange(3, freq * 2.75) , 0, EnvGen.ar(Env.perc(0.02,1.3))],
			[LFNoise2.kr(Line.kr(15, 2, 0.2)).exprange(1, 8), 0, EnvGen.ar(Env.perc(0.02,1.2))],
			[LFPulse.kr(Line.kr(30,freq * 4, 0.2)).exprange(20, freq * 14), 0.1, EnvGen.ar(Env.perc(0.06,1.0))]
		];
		var src = FM7.arAlgo(0, ctls, LFNoise2.kr(1, 2).abs);
		src = CombN.ar(src, LFNoise2.kr(2, 0.125) + 0.1, 0.2, 0.8);
		dur = 0.5 * (end - begin)/speed;
		env = EnvGen.ar(Env.perc(0.02, dur, amp * 0.5, -8), timeScale:sustain, doneAction:2);
		OffsetOut.ar(out,
			DirtPan.ar(src,  ~dirt.numChannels, pan, env)
		)
	}).add;

	SynthDef ("melo2", {|amp=0.5, note=1, velo=0.4, out, sustain=1|
		var src;
		src = RLPF.ar(Mix.fill(5, {
			SinOsc.ar(
				(note+[0,5,7,12,-12].choose + 60).midicps,
				0,
				SinOsc.ar((note + 60).midicps * 2.0, pi, SinOsc.ar((note + 60).midicps * 3.0))
			)
		}),  LFNoise2.kr(0.02,23,60).midicps, 0.3);
		src = (src * 5).softclip * 0.2;
	2.do({src = CombL.ar(src, 0.02 + LFNoise2.kr(0.02, 0.02), {[0.03.rand, 0.04.rand] + 0.1}, 0.5)});
		Out.ar(out, src * EnvGen.ar(Env.perc(2, 4, 1, -5), timeScale:sustain, doneAction:2, levelScale:1) );
	}).store;

	SynthDef("mbass",{arg freq=440, out, sustain=1;
		var src,env;
		src=SinOsc.ar(freq,SinOsc.ar(freq*2));
		env=EnvGen.kr(Env.perc(0.1,0.9,0.8,4),doneAction:2);
		Out.ar(out, Pan2.ar(src*env,LFNoise1.ar(1)));
	}).store;

	SynthDef(\wnoise, {|out, sustain = 0.5, note = 0, pan = 0, amp = 1.0, begin = 0, end = 1.0|
		var src, env, dur;
		dur = 0.5 * (end - begin);
		env = EnvGen.ar(Env.perc(0.02, dur, amp, -0.8), timeScale:sustain, doneAction:2);
		src = ClipNoise.ar(0.1) * amp;
		OffsetOut.ar(out, DirtPan.ar(src, 2, pan, env));
	}).store();

	SynthDef(\flau, {|out, sustain = 2, note = 0, pan = 0, amp = 1.0, begin = 0, end = 1.0|
		var src;
		var mod = LFNoise0.kr(18, 20);
		var freqs = (((0,12..45) + (note + 60)).midicps);
		var env = EnvGen.kr(Env.perc(0, 4, 1, 2), 1, levelScale: amp, doneAction: 2);
		src = RLPF.ar((DynKlang.ar(`[freqs, nil, mod ], 1, 0) * 6).softclip * 0.3, 2000, 0.4)
		* Decay2.ar(Dust.ar(Line.kr(125, 10, 0.5)), 0.0, Line.kr(0.025, 0.76, 0.8), 0.3);
		3.do({
			src = CombC.ar(
				src,
				0.1, {[0.01.rand,0.03.rand] + 0.085}, 0.26
			)
		});
		OffsetOut.ar(out, DirtPan.ar(src, 2, pan, env));
	}).store();


	SynthDef(\sur, {|out, sustain = 1, note = 0, pan = 0, amp = 1.0, begin = 0, end = 1.0|
		var freq, src, env;
		freq = (note + 60).midicps;
		env = Decay2.ar(Impulse.ar(8), 0.01, 0.85) * EnvGen.ar(Env.perc(0.01, 0.5 * sustain, 1, -8), levelScale: amp, doneAction: 2);
		src = Klank.ar(
			`[[80, 850, freq, freq * 1.28, 4223, 9220], nil, [0.75, 0.125, 0.25, 0.5, 1, 1]],
			Mix.fill(7, {
				SinOsc.ar({freq * [0.5, 1, 1.6, 1.5, 2, 4].choose},
					SinOsc.kr(freq,
						LFCub.kr(freq / 2, 0,  0.125),
						2),
					0.05)
		}));
		OffsetOut.ar(out, DirtPan.ar((src * 1.1).softclip * 0.2, ~dirt.numChannels, pan, env));
	}).store();


}; //wait for boot.
)

