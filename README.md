tidal-lazy
---

Livecode set with [TidalCycles](https://github.com/tidalcycles/Tidal) and [SuperDirt](https://github.com/musikinformatik/SuperDirt).

## build environment 

### editor

I use [tidal-vim](https://github.com/munshkr/vim-tidal) plugin on Vim.

### load modules on tidal-vim

Locate ```modules``` directory to anywhere you want.

[Modify bin/tidal file to like this on tidal-vim](https://github.com/moxuse/vim-tidal/commit/0819012aac63dc065bb34890b8a0a29776991853) (ensure ```MODULE_SERCH_PATH``` to match with your directory path)

Then haskell codes of ```modules``` will be loaded when you boot tidal-vim.

each file contains..

file | content
--- | ---
Ex.hs | collection of wrapper functions
ExEffects.hs | shotrhands for function of effect
ExLazy.hs | implementation of ```lazy``` function
ExInstruments | implementation of ```inst``` function
ExModulses.hs | include file
ExParams.hs | declaration of paramaters of effect modules

### settings of Super-Dirt side

```start_superdirt.scd``` is a excutable file which would boot SuperDirt.

Includes server settings, some effect modules and extra synthDefs which chould play from tidal's pattern.


## functions

### lazy

```
lazy
```

### inst


```
inst
```

```
defaultI
```

(```devel``` branch includes many code fragments besides these explanations)






