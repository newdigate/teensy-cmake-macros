# tests/corepath-fallback — include the macros WITHOUT COREPATH and assert the
# fallback resolved a real teensy4 core. Local-first: with a teensy-cores
# checkout under TEENSY_LIB_ROOT this must resolve locally (instant, no clone).
#   cmake -B build    → COREPATH-FALLBACK-TEST: PASS
cmake_minimum_required(VERSION 3.24)
project(corepath_fallback_test NONE)
include(${CMAKE_CURRENT_LIST_DIR}/../../CMakeLists.include.txt)
if(NOT COREPATH MATCHES "/teensy4/$")
    message(FATAL_ERROR "fallback COREPATH is not a teensy4 core: '${COREPATH}'")
endif()
if(NOT EXISTS "${COREPATH}core_pins.h")
    message(FATAL_ERROR "fallback COREPATH has no core_pins.h: '${COREPATH}'")
endif()
if(NOT DEFINED teensy_cores_SOURCE_DIR)
    message(FATAL_ERROR "teensy_cores_SOURCE_DIR not exported (tests/basic consumes it)")
endif()
message(STATUS "COREPATH-FALLBACK-TEST: PASS (${COREPATH})")
