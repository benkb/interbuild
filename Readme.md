Interbuild - Compile and Interpret
==================================

An input files is compiled or transpiled, the resulting file can than be
interpreted. This system stitches together the path needed



Files
-----

- interbuild.sh the main script, sources build.conf or build.cache, and then
- build.sh

- build.conf:  user defined variables
- build.cache: caching the build variables, print those with `interbuild print`
- build.sh:    user script that consumes the variables from the interbuild script
- hello.sml    example


User Variables
---------------

```
COMPILER_NAME='lunarml'
COMPILER_HOME="${LUNARML_HOME:-}"
COMPILER_HOME_DEFAULT=$HOME/build/lunarml/lunarml.git
COMPILER_LIB='lib/lunarml'

INTERP_NAME=lua
INTERP_VERS=5.3
INTERP_VERS_BASEDIR='/usr/local/Cellar/'
INTERP_VERS_MINOR=5.3.6

INTERP_VERS_BASEDIR/COMPILER_VERS_BASEDIR: basedir for versioned systems

or

INTERP_HOME/COMPILER_HOME: homedir for non versioned systems

```


Resulting Build Variables
-------------------------

These variables can be used in your personaal `build.sh` script

```
BUILD__COMPILER_BIN='/Users/ben/build/lunarml/lunarml.git/bin/lunarml'
BUILD__COMPILER_LIB='/Users/ben/build/lunarml/lunarml.git/lib/lunarml'
BUILD__INTERP_BIN='/usr/local/Cellar//lua@5.3/5.3.6/bin/lua'
BUILD__INTERP_LIB=''
```
