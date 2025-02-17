cmake_minimum_required(VERSION 3.10)
project(test_teensy_eeprom)
# in this case we already have a local copy of teensy-cmake-macros (usually we wouldn't, we would use FetchContent below
include(../../CMakeLists.include.txt)

#include(FetchContent)
#FetchContent_Declare(teensy_cmake_macros
#        GIT_REPOSITORY https://github.com/newdigate/teensy-cmake-macros
#        GIT_TAG        main
#)
#FetchContent_MakeAvailable(teensy_cmake_macros)
#include(${teensy_cmake_macros_SOURCE_DIR}/CMakeLists.include.txt)

import_arduino_library(cores ${teensy_cores_SOURCE_DIR}/teensy4 avr util)
import_arduino_library_git(EEPROM https://github.com/PaulStoffregen/EEPROM master "")
teensy_add_executable(eepromapp eepromapp.cpp)
teensy_target_link_libraries(eepromapp EEPROM cores)
set(CMAKE_VERBOSE_MAKEFILE 1)
