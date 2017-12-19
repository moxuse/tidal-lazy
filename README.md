tidal-lazy
---

Livecode set with [TidalCycles]() and [SuperDirt]().

## build environment 

### editor

I use [tidal-vim](https://github.com/munshkr/vim-tidal) plugin on Vim.

### load modules on tidal-vim

Locaete ```modules``` directory to anywhere you want.

[Modify bin/tidal file to like this on tidal-vim](https://github.com/moxuse/vim-tidal/commit/0819012aac63dc065bb34890b8a0a29776991853) (ensure ```MODULE_SERCH_PATH``` to match with your directory path)

Then haskell codes of ```modules``` will be loaded when you boot tidal-vim.



### settings of Super-Dirt side

```start_superdirt.scd``` is a excutable file which would boot SuperDirt.

Includes server settings, some effect modules and extra synthDefs which chould play from tidal's pattern.


