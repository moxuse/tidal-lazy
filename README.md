tidal-lazy
---

Livecode set with [TidalCycles](https://github.com/tidalcycles/Tidal) and [SuperDirt](https://github.com/musikinformatik/SuperDirt).

## build environment 

### editor

I use [tidal-vim](https://github.com/munshkr/vim-tidal) plugin on Vim.

### load modules on tidal-vim

#### using stack

move to tidal-lazy's directory and do

`
stack build
`

in your editor, change GHCI execution command to

`stack ghci`


#### using cabal

Locate ```modules``` directory to anywhere you want.

[Modify bin/tidal file to like this on tidal-vim](https://github.com/moxuse/vim-tidal/commit/0819012aac63dc065bb34890b8a0a29776991853) (ensure ```MODULE_SERCH_PATH``` to match with your directory path)

In BootTidal.tidal(Tidal.ghci in case tidal-vim) add a line to load.

```:load ExModules```

Then haskell codes in ```modules``` will be loaded when you boot tidal-vim.

each file contains..

file | content
--- | ---
Ex.hs | collection of wrapper functions
ExEffects.hs | shotrhands for function of effect
ExLazy.hs | implementation of ```lazy``` function
ExInstruments | implementation of ```inst``` function
ExModules.hs | include file
ExParams.hs | declaration of paramaters of effect modules

### settings of Super-Dirt side

```start_superdirt.scd``` is a excutable file which would boot SuperDirt.

Includes server settings, some effect modules and extra synthDefs which chould play from tidal's pattern.


## functions

### lazy'

Generate Ptterns have some length randomly.

Requires two argments, one is Pattern Time as density of pattern another is DefaultInstrument.

Actuary now lazy' is just random choose of pattern list. It will be passed to an `ur` function of Tidal. It is detailed at the [source](https://github.com/moxuse/tidal-lazy/blob/master/modules/ExLazy.hs).

```
lazy' :: Pattern Time -> DefaultInstrument -> IO (Pattern ParamMap)
```

```
lazy' 2 defaultI
```

It makes `IO (Pattern ParamMap)` so you need use in action. 

In TidalCycles use with do block, And execute connections `d1` at the same time is useful.

```
do
  x <- lazy' 2 defaultI
  d1
    $ x
```

### DefaultInstrument

Data type used in lazy patterns as instrument set.

`defaultI` makes a DefaultInstrument data that declerd in [modules/ExInstruments.hs](https://github.com/moxuse/tidal-lazy/blob/master/modules/ExInstruments.hs)

```
defaultI
```

### inst

Function to set field of DefaultInstrument and make an instance. 

`hh` `sn` `bd` `cp` `pd` `ps` are functions to set field of each instrument. 

They are composable by dot operator so you could set instrument partially.


```
inst $ inst $ hh "myhat:2" . sn "mysnr:1"
```

## Use as a Pattern ParamMap

Even though `lazy'` is IO but behave as a Pattern ParamMap in action.

So it could add any pattern transformers or effect pattern at before and behind.

```
do
  x <- lazy' 2 defaultI
  d1
    $ slow 2
    $ jux (iter 2)
    $ x
    |+| speed (rand + 0.25)
```


(```devel``` branch includes many code fragments besides these explanations)
