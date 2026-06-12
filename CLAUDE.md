# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A minimal CMake toolchain + macro package for cross-compiling Teensy 4.x (4.0/4.1) firmware and libraries with `arm-none-eabi-gcc`, without the Arduino IDE. It targets Teensy 4.1 (tested) and can be extended for 3.x. Library code is compiled to `.a` archives to avoid unnecessary recompilation. Based on [ronj/teensy-cmake-template](https://github.com/ronj/teensy-cmake-template).

**The entire product is one file: `cmake/teensy.cmake`.** Everything else (`CMakeLists.txt`, `tests/`) exists to install or exercise it. When changing behavior, you are almost always editing `cmake/teensy.cmake`.

## Architecture

There are two distinct CMake roles:

1. **This repo's root `CMakeLists.txt`** is only an *installer*. It packages `cmake/teensy.cmake` as a CMake config package (`teensy_cmake_macros`) and installs it system-wide to `lib/cmake/teensy_cmake_macros`. It does not build any firmware.
2. **Consumer projects** (including everything under `tests/`) pull the macros in via `find_package(teensy_cmake_macros)` from a toolchain file, then call the macros from their own `CMakeLists.txt`.

**Critical workflow consequence:** consumers load the *installed* copy of `cmake/teensy.cmake`, not the one in this working tree. After editing `cmake/teensy.cmake`, you must re-run `sudo make install` (step below) before any test/consumer build will see the change.

### The macros (all defined in `cmake/teensy.cmake`)

- `teensy_set_dynamic_properties()` — builds the compile/link flag strings from `TEENSY_VERSION` (40 or 41), `CPU_CORE_SPEED`, `COMPILERPATH`, `DEPSPATH`, `COREPATH`. Runs once per configure (guarded by a cache variable). Hardcodes `TEENSYDUINO=159`, `ARDUINO=10607`, `-std=gnu++17`, `-fno-exceptions -fno-rtti`. Called automatically by `teensy_add_executable`/`teensy_add_library`.
- `teensy_add_executable(TARGET srcs...)` — creates target **`TARGET.elf`** plus a `TARGET_hex` custom target that runs `arm-none-eabi-objcopy` to emit `TARGET.hex`. Accepts `.cpp` and `.ino` (compiled as C++).
- `teensy_add_library(TARGET srcs...)` — creates a STATIC library target named **`TARGET.o`** (the `.o` suffix is part of the CMake target name, not a file).
- `import_arduino_library(NAME ROOT [subdirs...])` — globs `.cpp/.c/.S` from `ROOT` (and each listed subdir), adds include dirs, and calls `teensy_add_library(NAME ...)`. Missing `ROOT` is a warning (ignored); a missing named subdir is a fatal error.
- `teensy_target_link_libraries(TARGET libs...)` — links each `lib.o` into `TARGET.elf`. **Link order matters** — symbols are garbage-collected with `--gc-sections`, so dependencies must come after their dependents.
- `teensy_include_directories(paths...)` / `teensy_remove_sources(dir)`.

Include dirs are threaded through the macros as a single accumulated `-I...` string in the `INCLUDE_DIRECTORIES` variable, not via normal CMake target includes.

## Required variables (set in the consumer toolchain file)

`TEENSY_VERSION`, `CPU_CORE_SPEED`, `COMPILERPATH` (arm-none-eabi bin dir, trailing slash), `DEPSPATH` (root of cloned deps). `COREPATH` defaults to `${DEPSPATH}/cores/teensy4/`. See `tests/teensy41.toolchain.cmake` for the template — but note its `COMPILERPATH` (`/opt/gcc-arm-none-eabi-9-2019-q4-major/bin/`) and `DEPSPATH` (a CI path) are hardcoded for CI and must be edited for local builds.

## Build commands

Install (or reinstall after editing `cmake/teensy.cmake`) the macros system-wide:

```shell
mkdir -p cmake-build-debug && cd cmake-build-debug
cmake -DCMAKE_BUILD_TYPE=Debug ..
sudo make install
```

Uninstall: `make uninstall` (custom target driving `cmake/uninstall.cmake`).

Build a test/consumer project (requires the deps cloned into `DEPSPATH` and the macros installed):

```shell
cd tests/basic
mkdir -p cmake-build-debug && cd cmake-build-debug
cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE:FILEPATH=../teensy41.toolchain.cmake ..
make
```

## Tests & CI

Each subdir of `tests/` (`basic`, `spi`, `audio`, `eeprom`, `vector`) is an independent consumer project with its own `CMakeLists.txt`, exercising a different dependency set. There is one GitHub Actions workflow per test in `.github/workflows/`; each clones the relevant PaulStoffregen libraries into `deps/`, downloads the ARM 9-2019-q4 toolchain to `/opt`, installs the macros, then configures+builds that one test. A "test" passing means it compiles and links — there is no on-device runtime check.

`tests/vector` is the reference for linking the C++ std library: set `CMAKE_EXE_LINKER_FLAGS "--specs=nano.specs"` and `target_link_libraries(<target>.elf stdc++)` (note `.elf` suffix and raw `target_link_libraries`, not the `teensy_` wrapper).

## Runtime dependencies

Consumer firmware needs PaulStoffregen Arduino libraries cloned into `DEPSPATH` — at minimum `cores` (the Teensy 4 core). Others as needed: `Audio`, `SD` (branch `Juse_Use_SdFat`), `Wire`, `SPI`, `SerialFlash`, `arm_math`, and `greiman/SdFat`. See the `actions/checkout` steps in the relevant `.github/workflows/*.yml` for the exact repo/branch each test uses.
