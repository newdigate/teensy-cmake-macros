cmake_minimum_required(VERSION 3.10)
project(test_teensy_project_vector)

include(FetchContent)
FetchContent_Declare(teensy_cmake_macros
        GIT_REPOSITORY https://github.com/newdigate/teensy-cmake-macros
        GIT_TAG        main
)
FetchContent_MakeAvailable(teensy_cmake_macros)
include(${teensy_cmake_macros_SOURCE_DIR}/CMakeLists.include.txt)

set(CMAKE_EXE_LINKER_FLAGS "--specs=nano.specs" CACHE INTERNAL "")
import_arduino_library(cores ${teensy_cores_SOURCE_DIR}/teensy4 avr util)
teensy_add_executable(vector vector.cpp)
target_link_libraries(vector.elf stdc++)
teensy_target_link_libraries(vector cores)
