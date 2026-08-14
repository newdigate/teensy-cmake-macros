# tests/resolve — configure-only test of the declared-library API. No
# toolchain, no compiler, no network: the declared URL is unreachable on
# purpose, so if resolution ever reaches for it the configure fails.
#
#   cmake -B build                                → RESOLVE-TEST: PASS
#   cmake -B build-neg -DRESOLVE_TEST_UNDECLARED=ON   → must FAIL, "not declared"
#   cmake -B build-ff -DRESOLVE_TEST_FORCE=ON     → must FAIL after printing
#                                          "resolve_arduino_library_auto(FakeLib2): fetching"
cmake_minimum_required(VERSION 3.24)
project(resolve_test NONE)

set(TEENSY_LIB_ROOT "${CMAKE_BINARY_DIR}/fake-root")   # pre-set: include must respect it
set(COREPATH "${CMAKE_BINARY_DIR}/no-core/")           # suppress the core fallback
include(${CMAKE_CURRENT_LIST_DIR}/../../CMakeLists.include.txt)

file(MAKE_DIRECTORY "${TEENSY_LIB_ROOT}/FakeLib")
teensy_declare_library(FakeLib FakeLib https://invalid.example/never-fetched deadbeef .)
teensy_declare_library(FakeLib2 FakeLib https://invalid.example/never-fetched deadbeef .)

if(RESOLVE_TEST_UNDECLARED)
    teensy_resolve_library(NeverDeclared _boom)        # must FATAL_ERROR
endif()

if(RESOLVE_TEST_FORCE)
    # force-fetch must SKIP the existing local checkout: the resolver's own
    # "fetching" STATUS line proves the skip happened before any network use,
    # and the unreachable URL then fails the configure (asserted from outside).
    set(TEENSY_FORCE_FETCH ON)
    teensy_resolve_library(FakeLib2 _boom)
endif()

# local-first: the checkout under TEENSY_LIB_ROOT wins, URL never touched
teensy_resolve_library(FakeLib _first)
if(NOT _first STREQUAL "${TEENSY_LIB_ROOT}/FakeLib")
    message(FATAL_ERROR "local-first: expected ${TEENSY_LIB_ROOT}/FakeLib, got '${_first}'")
endif()

# memoized: delete the local checkout, then resolve again — only the memo can
# still answer; a re-resolve would take the fetch branch and fail on the URL.
file(REMOVE_RECURSE "${TEENSY_LIB_ROOT}/FakeLib")
teensy_resolve_library(FakeLib _second)
if(NOT _second STREQUAL "${_first}")
    message(FATAL_ERROR "memoization: got '${_second}' after '${_first}'")
endif()

message(STATUS "RESOLVE-TEST: PASS")
