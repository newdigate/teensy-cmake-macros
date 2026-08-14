# tests/resolve — configure-only test of the declared-library API. No
# toolchain, no compiler, no network: the declared URL is unreachable on
# purpose, so if resolution ever reaches for it the configure fails.
#
#   cmake -B build                                → RESOLVE-TEST: PASS
#   cmake -B build-neg -DRESOLVE_TEST_UNDECLARED=ON   → must FAIL, "not declared"
cmake_minimum_required(VERSION 3.24)
project(resolve_test NONE)

set(TEENSY_LIB_ROOT "${CMAKE_BINARY_DIR}/fake-root")   # pre-set: include must respect it
set(COREPATH "${CMAKE_BINARY_DIR}/no-core/")           # suppress the core fallback
include(${CMAKE_CURRENT_LIST_DIR}/../../CMakeLists.include.txt)

file(MAKE_DIRECTORY "${TEENSY_LIB_ROOT}/FakeLib")
teensy_declare_library(FakeLib FakeLib https://invalid.example/never-fetched deadbeef .)

if(RESOLVE_TEST_UNDECLARED)
    teensy_resolve_library(NeverDeclared _boom)        # must FATAL_ERROR
endif()

# local-first: the checkout under TEENSY_LIB_ROOT wins, URL never touched
teensy_resolve_library(FakeLib _first)
if(NOT _first STREQUAL "${TEENSY_LIB_ROOT}/FakeLib")
    message(FATAL_ERROR "local-first: expected ${TEENSY_LIB_ROOT}/FakeLib, got '${_first}'")
endif()

# memoized: same answer twice
teensy_resolve_library(FakeLib _second)
if(NOT _second STREQUAL "${_first}")
    message(FATAL_ERROR "memoization: got '${_second}' after '${_first}'")
endif()

message(STATUS "RESOLVE-TEST: PASS")
