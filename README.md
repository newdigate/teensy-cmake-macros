# teensy cmake macros [![teensy-cmake-test](https://github.com/newdigate/teensy-cmake-macros/actions/workflows/test.yml/badge.svg)](https://github.com/newdigate/teensy-cmake-macros/actions/workflows/test.yml)
installable cmake package containing macros to cross compile teensy firmware using cmake and gcc-arm-none-eabi

* based on [ronj/teensy-cmake-template](https://github.com/ronj/teensy-cmake-template)

## TL/DR
* clone dependencies to ${DEPSPATH}
```shell
 > cd /home/runner/work/midi-smf-reader/midi-smf-reader/deps
 > git clone https://github.com/PaulStoffregen/cores
```
* add this to begining of your `CMakeLists.txt`
```cmake 
set(TEENSY_VERSION 41 CACHE STRING "Set to the Teensy version corresponding to your board (40 or 41 allowed)" FORCE)
set(CPU_CORE_SPEED 600000000 CACHE STRING "Set to 600000000, 24000000, 48000000, 72000000 or 96000000 to set CPU core speed" FORCE) # Derived variables
set(COMPILERPATH "/opt/gcc-arm-none-eabi-9-2019-q4-major/bin/") 
set(DEPSPATH "/home/runner/work/midi-smf-reader/midi-smf-reader/deps")
# COREPATH is optional (ie. only need to change if necessary)
set(COREPATH "${DEPSPATH}/cores/teensy4/")
find_package(teensy_cmake_macros)
``` 

* [teensy_cmake_macros](#teensy_cmake_macros)
* [dependencies](#dependencies)
* [download and install](#download-and-install)
* [example usage](#example-usage)
* [used in](#used-in)

## teensy_cmake_macros 
* teensy_add_executable( TARGET files... )
  ```cmake 
  teensy_add_executable(myapplication midiread.cpp)
  ``` 
* import_arduino_library ( LibraryPath LibraryName )
  ```cmake 
  import_arduino_library(${DEPSPATH} SPI)
  ``` 
* import_arduino_library_absolute (LibraryPath)
  ```cmake 
  import_arduino_library_absolute(${DEPSPATH}/SPI)
  ``` 
* ~~teensy_remove_sources ( PathToRemoveAllFilesFromSOURCE )~~ 
  * left as a reference 
  * handy recursively adding source folders, need to recursively un-add certain folders
  ```cmake 
  teensy_remove_sources(${DEPSPATH}/Audio/examples)
  ```
## dependencies
* [CMake](https://cmake.org)
* [gcc-arm-none-eabi](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads)
  
## download and install
```shell
> git clone https://github.com/newdigate/teensy-cmake-macros.git
> cd teensy-cmake-macros
> mkdir cmake-build-debug
> cd cmake-build-debug
> cmake ..
> sudo make install        
```

## example usage
* set *DEPSPATH*, *COMPILERPATH*, *TEENSY_VERSION*, *CPU_CORE_SPEED*, *CPU*
``` cmake
cmake_minimum_required(VERSION 3.10)
project(basic C CXX)
set(CMAKE_CXX_STANDARD 14)
set(TEENSY_VERSION 40 CACHE STRING "Set to the Teensy version corresponding to your board (30 or 31 allowed)" FORCE)
set(CPU_CORE_SPEED 600000000 CACHE STRING "Set to 24000000, 48000000, 72000000 or 96000000 to set CPU core speed" FORCE) # Derived variables
set(COMPILERPATH "/opt/gcc-arm-none-eabi-9-2019-q4-major/bin/")
set(DEPSPATH "/home/runner/work/midi-smf-reader/midi-smf-reader/deps")
set(COREPATH "${DEPSPATH}/cores/teensy4/")

# teensy_cmake_macros: https://github.com/newdigate/teensy-cmake-macros
find_package(teensy_cmake_macros)

# include header files and source files (non-recursive)
import_arduino_library(${DEPSPATH} SPI)
import_arduino_library(${DEPSPATH} SdFat/src)
import_arduino_library(${DEPSPATH} SdFat/src/common)
import_arduino_library(${DEPSPATH} SdFat/src/DigitalIO)
import_arduino_library(${DEPSPATH} SdFat/src/ExFatLib)
import_arduino_library(${DEPSPATH} SdFat/src/FatLib)
import_arduino_library(${DEPSPATH} SdFat/src/FsLib)
import_arduino_library(${DEPSPATH} SdFat/src/iostream)
import_arduino_library(${DEPSPATH} SdFat/src/SdCard)
import_arduino_library(${DEPSPATH} SdFat/src/SpiDriver)
import_arduino_library(${DEPSPATH} SD/src)

# add targets to create teensy firmware .o, .hex file
teensy_add_executable(basic midiread.cpp)

# add targets to compile library 
teensy_add_library(libbasic midiread.cpp)

```

## used in
* [midi-smf-reader](https://github.com/newdigate/midi-smf-reader)
* [teensy-quencer](https://github.com/newdigate/teensy-quencer)
