# teensy cmake macros
installable cmake package containing macros to compile teensy code using cmake and gcc-arm-none-eabi

once installed, just add below line to your `CMakeLists.txt`
```cmake 
find_package(teensy_cmake_macros)
``` 

* teensy_add_executable( TARGET files... )
  ```cmake 
  teensy_add_executable(basic midiread.cpp)
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
  * left as a reference (was handy when I was recursively adding source code folders, needed to un-add certain folders like **/examples/)
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
set(CMAKE_CXX_STANDARD 11)
set(TEENSY_VERSION 40 CACHE STRING "Set to the Teensy version corresponding to your board (30 or 31 allowed)" FORCE)
set(CPU_CORE_SPEED 600000000 CACHE STRING "Set to 24000000, 48000000, 72000000 or 96000000 to set CPU core speed" FORCE) # Derived variables
set(CPU cortex-m7)
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
```

## used in
* [midi-smf-reader](https://github.com/newdigate/midi-smf-reader)
* [teensy-quencer](https://github.com/newdigate/teensy-quencer)
