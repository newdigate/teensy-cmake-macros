cmake_minimum_required(VERSION 3.10)
project(test_teensy_eeprom)

include(FetchContent)
FetchContent_Declare(teensy_cmake_macros
        GIT_REPOSITORY https://github.com/newdigate/teensy-cmake-macros
        GIT_TAG        main
)
FetchContent_MakeAvailable(teensy_cmake_macros)
include(${teensy_cmake_macros_SOURCE_DIR}/CMakeLists.include.txt)

import_arduino_library(cores ${teensy_cores_SOURCE_DIR}/teensy4 avr util)
import_arduino_library_git(SPI https://github.com/PaulStoffregen/SPI master "")
teensy_add_executable(spiapp spiapp.cpp)
teensy_target_link_libraries(spiapp SPI cores)