cmake_minimum_required(VERSION 3.10)
project(test_teensy_project_basic)

include(${teensy_cmake_macros_SOURCE_DIR}/CMakeLists.include.txt)

import_arduino_library(cores ${teensy_cores_SOURCE_DIR}/teensy4 avr util)
teensy_add_executable(basic basic.cpp)
teensy_target_link_libraries(basic cores)
