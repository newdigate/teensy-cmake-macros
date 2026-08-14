# tests/corepath-fallback — include the macros WITHOUT COREPATH and assert the
# fallback resolved a real teensy4 core. Local-first: with a teensy-cores
# checkout under TEENSY_LIB_ROOT this must resolve locally (instant, no clone).
#   cmake -B build    → COREPATH-FALLBACK-TEST: PASS
#   cmake -B build-ff -DTEENSY_FORCE_FETCH=ON   → PASS via the CPM fetch branch
#                                                 (needs network; clones at the pin)
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
if(NOT EXISTS "${teensy_cores_SOURCE_DIR}/teensy4/core_pins.h")
    message(FATAL_ERROR "teensy_cores_SOURCE_DIR is not the repo root: '${teensy_cores_SOURCE_DIR}' (tests/basic appends /teensy4)")
endif()
# The fallback's REF must be a pinned 40-hex SHA — `master` here is the exact
# defect this fallback replaced, and local-first resolution never reads the
# REF, so only this shape check keeps the pin honest on developer machines.
# CMake's regex engine has no {n} interval quantifier (confirmed: [0-9a-f]{40}
# matches nothing, not "40 hex chars" — it would FATAL_ERROR on a real pinned
# SHA), so length and charset are checked separately.
string(LENGTH "${TEENSY_LIB_teensy_cores_REF}" _teensy_cores_ref_len)
if(NOT _teensy_cores_ref_len EQUAL 40 OR NOT TEENSY_LIB_teensy_cores_REF MATCHES "^[0-9a-f]+$")
    message(FATAL_ERROR "COREPATH fallback ref must be a pinned 40-hex SHA, got '${TEENSY_LIB_teensy_cores_REF}'")
endif()
message(STATUS "COREPATH-FALLBACK-TEST: PASS (${COREPATH})")
