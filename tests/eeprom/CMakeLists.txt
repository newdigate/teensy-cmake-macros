cmake_minimum_required(VERSION 3.10)
project(test_teensy_eeprom)
include(${teensy_cmake_macros_SOURCE_DIR}/CMakeLists.include.txt)

import_arduino_library(cores ${teensy_cores_SOURCE_DIR}/teensy4 avr util)
import_arduino_library_git(EEPROM https://github.com/PaulStoffregen/EEPROM master "")
teensy_add_executable(eepromapp eepromapp.cpp)
teensy_target_link_libraries(eepromapp EEPROM cores)
