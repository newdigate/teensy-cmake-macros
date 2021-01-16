# teensy cmake marcos

``` cmake
cmake_minimum_required(VERSION 3.10)
project(basic C CXX)
set(CMAKE_CXX_STANDARD 11)
# This toolchain file is based on https://github.com/apmorton/teensy-template
set(TEENSY_VERSION 40 CACHE STRING "Set to the Teensy version corresponding to your board (30 or 31 allowed)" FORCE)
set(CPU_CORE_SPEED 600000000 CACHE STRING "Set to 24000000, 48000000, 72000000 or 96000000 to set CPU core speed" FORCE) # Derived variables
set(CPU cortex-m7)
set(COMPILERPATH "/opt/gcc-arm-none-eabi-9-2019-q4-major/bin/")
set(DEPSPATH "/home/runner/work/midi-smf-reader/midi-smf-reader/deps")
set(COREPATH "${DEPSPATH}/cores/teensy4/")

# teensy_cmake_macros: https://github.com/newdigate/teensy-cmake-macros
find_package(teensy_cmake_macros)

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

teensy_add_executable(basic midiread.cpp)
```
