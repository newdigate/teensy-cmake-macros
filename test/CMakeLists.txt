cmake_minimum_required(VERSION 3.10)
project(test_teensy_project)
set(TEENSY_VERSION 41 CACHE STRING "Set to the Teensy version corresponding to your board (30 or 31 allowed)" FORCE)
set(CPU_CORE_SPEED 600000000 CACHE STRING "Set to 24000000, 48000000, 72000000 or 96000000 to set CPU core speed" FORCE) # Derived variables
set(COMPILERPATH "/opt/gcc-arm-none-eabi-9-2019-q4-major/bin/")
#set(COMPILERPATH "/Applications/Arm/bin/")
set(DEPSPATH "/home/runner/work/teensy-cmake-macros/teensy-cmake-macros/deps")
#set(DEPSPATH "/Users/nicholasnewdigate/Development/github/newdigate/temp_dep")
find_package(teensy_cmake_macros)  # use installed 
#include(../cmake/teensy.cmake)      # use local cmake

import_arduino_library(cores ${DEPSPATH}/cores/teensy4 avr util)
teensy_add_executable(myapplication basic.cpp)
teensy_target_link_libraries(myapplication cores)
